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

#import "MPWiFiReachability.h"
#import "MP.h"
#import "NSBundle+MPLocalizable.h"

@interface MPWiFiReachability ()

@property (weak, nonatomic) UILabel *label;
@property (weak, nonatomic) UITableViewCell *cell;
@property (strong, nonatomic) MPMobilePrintSDKReachability *reachability;
@property (assign, nonatomic) BOOL connected;

@end

@implementation MPWiFiReachability

+ (MPWiFiReachability *)sharedInstance
{
    static MPWiFiReachability *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[MPWiFiReachability alloc] init];
        [sharedInstance startMonitoring];
    });
    
    return sharedInstance;
}

- (void)startMonitoring
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reachabilityChanged:) name:kMPReachabilityChangedNotification object:nil];
    self.reachability = [MPMobilePrintSDKReachability reachabilityForLocalWiFi];
    [self.reachability startNotifier];
    self.connected = (NotReachable != [self.reachability currentReachabilityStatus]);
}

- (void)noPrintingAlert
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:MPLocalizedString(@"Wi-Fi Required", ni)
                                                    message:MPLocalizedString(@"Printing requires your mobile device and printer to be on same Wi-Fi network. Please check your Wi-Fi settings.", nil)
                                                   delegate:nil
                                          cancelButtonTitle:MPLocalizedString(@"OK", nil)
                                          otherButtonTitles:nil];
    [alert show];
}

- (void)noPrinterSelectAlert
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:MPLocalizedString(@"Wi-Fi Required", nil)
                                                    message:MPLocalizedString(@"Selecting a printer requires your mobile device and printer to be on same Wi-Fi network. Please check your Wi-Fi settings.", nil)
                                                   delegate:nil
                                          cancelButtonTitle:MPLocalizedString(@"OK", nil)
                                          otherButtonTitles:nil];
    [alert show];
}

- (BOOL)isWifiConnected
{
    if ([MP sharedInstance].useBluetooth) {
        return YES;
    } else {
        return (NotReachable != [self.reachability currentReachabilityStatus]);
    }
}

- (void)reachabilityChanged:(NSNotification *)notification
{
    MPMobilePrintSDKReachability *currentReachability = [notification object];
    NSParameterAssert([currentReachability isKindOfClass:[MPMobilePrintSDKReachability class]]);
    BOOL connected = (NotReachable != [currentReachability currentReachabilityStatus]);
    if (connected != self.connected) {
        self.connected = connected;
        if (self.connected) {
            [[NSNotificationCenter defaultCenter] postNotificationName:kMPWiFiConnectionEstablished object:nil];
        } else {
            [[NSNotificationCenter defaultCenter] postNotificationName:kMPWiFiConnectionLost object:nil];
        }
    }
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
