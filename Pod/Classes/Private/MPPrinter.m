//
// HP Inc.
// All rights reserved.
//
// This file, its contents, concepts, methods, behavior, and operation
// (collectively the "Software") are protected by trade secret, patent,
// and copyright laws. The use of the Software is governed by a license
// agreement. Disclosure of the Software to third parties, in any form,
// in whole or in part, is expressly prohibited except as authorized by
// the license agreement.
//

#import "MPPrinter.h"
#import "MP.h"
#import "MPDefaultSettingsManager.h"

@interface MPPrinter ()

@property (nonatomic, getter = isRefreshing) BOOL refreshing;

@end

@implementation MPPrinter

+ (MPPrinter *)sharedInstance
{
    static dispatch_once_t once;
    static MPPrinter *sharedInstance;
    dispatch_once(&once, ^{
        sharedInstance = [[MPPrinter alloc] init];
    });
    return sharedInstance;
}

- (void)checkLastPrinterUsedAvailability
{
    if (!self.isRefreshing) {
        self.refreshing = YES;
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
            
            NSString *lastPrinterUrl = [[NSUserDefaults standardUserDefaults] objectForKey:LAST_PRINTER_USED_URL_SETTING];
            
            if (nil != lastPrinterUrl) {
                MPLogInfo(@"Searching for last printer used %@", lastPrinterUrl);

                UIPrinter *printerFromUrl = [UIPrinter printerWithURL:[NSURL URLWithString:lastPrinterUrl]];
                [printerFromUrl contactPrinter:^(BOOL available) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:
                                              [NSNumber numberWithBool:available], kMPPrinterAvailableKey,
                                              printerFromUrl, kMPPrinterKey, nil];
                        
                        [[NSNotificationCenter defaultCenter] postNotificationName:kMPPrinterAvailabilityNotification object:nil userInfo:dict];
                    });
                    self.refreshing = NO;
                }];
            } else {
                self.refreshing = NO;
            }
        });
    }
}

- (void)checkDefaultPrinterAvailabilityWithCompletion:(void(^)(BOOL available))completion
{
    // This check is called when the region of the printer is crossed, if the app is not active iOS will wake it up for a short period of time to perform some actions, so it has to be fast...
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        
        NSString *defaultPrinterUrl = [MPDefaultSettingsManager sharedInstance].defaultPrinterUrl;
        
        if (nil != defaultPrinterUrl) {
            MPLogInfo(@"Searching for default printer %@", defaultPrinterUrl);
            
            UIPrinter *printerFromUrl = [UIPrinter printerWithURL:[NSURL URLWithString:defaultPrinterUrl]];
            [printerFromUrl contactPrinter:^(BOOL available) {
                completion(available);
            }];
        } else {
            completion(NO);
        }
    });
}

@end
