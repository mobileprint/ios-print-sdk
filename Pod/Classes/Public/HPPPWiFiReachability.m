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

#import "HPPPWiFiReachability.h"
#import "HPPP.h"
#import "NSBundle+Localizable.h"

@interface HPPPWiFiReachability ()

@property (weak, nonatomic) UILabel *label;
@property (weak, nonatomic) UITableViewCell *cell;
@property (strong, nonatomic) HPPPReachability *reachability;
@property (assign, nonatomic) BOOL connected;

@end

@implementation HPPPWiFiReachability

NSString * const kHPPPWiFiConnectionEstablished = @"kHPPPWiFiConnectionEstablished";
NSString * const kHPPPWiFiConnectionLost = @"kHPPPWiFiConnectionLost";

+ (HPPPWiFiReachability *)sharedInstance
{
    static HPPPWiFiReachability *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[HPPPWiFiReachability alloc] init];
        [sharedInstance startMonitoring];
    });
    
    return sharedInstance;
}

- (void)startMonitoring
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reachabilityChanged:) name:kReachabilityChangedNotification object:nil];
    self.reachability = [HPPPReachability reachabilityForLocalWiFi];
    [self.reachability startNotifier];
    self.connected = (NotReachable != [self.reachability currentReachabilityStatus]);
}

- (void)noPrintingAlert
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:HPPPLocalizedString(@"Wi-Fi Required", ni)
                                                    message:HPPPLocalizedString(@"Printing requires your mobile device and printer to be on same Wi-Fi network. Please check your Wi-Fi settings.", nil)
                                                   delegate:nil
                                          cancelButtonTitle:HPPPLocalizedString(@"OK", nil)
                                          otherButtonTitles:nil];
    [alert show];
}

- (void)noPrinterSelectAlert
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:HPPPLocalizedString(@"Wi-Fi Required", nil)
                                                    message:HPPPLocalizedString(@"Selecting a printer requires your mobile device and printer to be on same Wi-Fi network. Please check your Wi-Fi settings.", nil)
                                                   delegate:nil
                                          cancelButtonTitle:HPPPLocalizedString(@"OK", nil)
                                          otherButtonTitles:nil];
    [alert show];
}

- (BOOL)isWifiConnected
{
    return (NotReachable != [self.reachability currentReachabilityStatus]);
}

- (void)reachabilityChanged:(NSNotification *)notification
{
    HPPPReachability *currentReachability = [notification object];
    NSParameterAssert([currentReachability isKindOfClass:[HPPPReachability class]]);
    BOOL connected = (NotReachable != [currentReachability currentReachabilityStatus]);
    if (connected != self.connected) {
        self.connected = connected;
        if (self.connected) {
            [[NSNotificationCenter defaultCenter] postNotificationName:kHPPPWiFiConnectionEstablished object:nil];
        } else {
            [[NSNotificationCenter defaultCenter] postNotificationName:kHPPPWiFiConnectionLost object:nil];
        }
    }
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
