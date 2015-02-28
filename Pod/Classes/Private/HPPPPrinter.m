//
// Hewlett-Packard Company
// All rights reserved.
//
// This file, its contents, concepts, methods, behavior, and operation
// (collectively the "Software") are protected by trade secret, patent,
// and copyright laws. The use of the Software is governed by a license
// agreement. Disclosure of the Software to third parties, in any form,
// in whole or in part, is expressly prohibited except as authorized by
// the license agreement.
//

#import "HPPPPrinter.h"
#import "HPPP.h"

@interface HPPPPrinter ()

@property (nonatomic, getter = isRefreshing) BOOL refreshing;

@end

@implementation HPPPPrinter

+ (HPPPPrinter *)sharedInstance
{
    static dispatch_once_t once;
    static HPPPPrinter *sharedInstance;
    dispatch_once(&once, ^{
        sharedInstance = [[HPPPPrinter alloc] init];
    });
    return sharedInstance;
}

- (void)checkLastPrinterUsedAvailability
{
    if (!self.isRefreshing) {
        self.refreshing = YES;
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
            
            NSString *lastPrinterUrl = [[NSUserDefaults standardUserDefaults] objectForKey:LAST_PRINTER_USED_URL_SETTING];
            NSLog(@"Searching for printer %@", lastPrinterUrl);
            
            if( nil != lastPrinterUrl ) {
                UIPrinter *printerFromUrl = [UIPrinter printerWithURL:[NSURL URLWithString:lastPrinterUrl]];
                [printerFromUrl contactPrinter:^(BOOL available) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:
                                              [NSNumber numberWithBool:available], HPPP_PRINTER_AVAILABLE_KEY,
                                              printerFromUrl, HPPP_PRINTER_URL_KEY, nil];
                                              
                        [[NSNotificationCenter defaultCenter] postNotificationName:HPPP_PRINTER_AVAILABILITY_NOTIFICATION object:nil userInfo:dict];
                    });
                    self.refreshing = NO;
                }];
            } else {
                self.refreshing = NO;
            }
        });
    }
}

@end
