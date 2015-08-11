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

#import "HPPPSubstituteReachability.h"
#import "HPPP.h"

#import <SystemConfiguration/CaptiveNetwork.h>

@interface HPPPSubstituteReachability ()

@property (weak, nonatomic) UILabel *label;
@property (weak, nonatomic) UITableViewCell *cell;
@property (strong, nonatomic) HPPPReachability *reachability;
@property (assign, nonatomic) BOOL connected;

@end

@implementation HPPPSubstituteReachability

NSString * const kHPPPSubstituteWiFiConnectionEstablished = @"kHPPPWiFiConnectionEstablished";
NSString * const kHPPPSubstituteWiFiConnectionLost = @"kHPPPWiFiConnectionLost";
NSString * const kHPPPSubstituteNoNetwork = @"NO-WIFI";

+ (HPPPSubstituteReachability *)sharedInstance
{
    static HPPPSubstituteReachability *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[HPPPSubstituteReachability alloc] init];
        [sharedInstance startMonitoring];
    });
    
    return sharedInstance;
}

- (void)startMonitoring
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reachabilityChanged:) name:kHPPPReachabilityChangedNotification object:nil];
    self.reachability = [HPPPReachability reachabilityForLocalWiFi];
    [self.reachability startNotifier];
    self.connected = (NotReachable != [self.reachability currentReachabilityStatus]);
}

- (void)noPrintingAlert
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Wi-Fi Required"
                                                    message:@"Printing requires your mobile device and printer to be on same Wi-Fi network. Please check your Wi-Fi settings."
                                                   delegate:nil
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles:nil];
    [alert show];
}

- (void)noPrinterSelectAlert
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Wi-Fi Required"
                                                    message:@"Selecting a printer requires your mobile device and printer to be on same Wi-Fi network. Please check your Wi-Fi settings."
                                                   delegate:nil
                                          cancelButtonTitle:@"OK"
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
            [[NSNotificationCenter defaultCenter] postNotificationName:kHPPPSubstituteWiFiConnectionEstablished object:nil];
        } else {
            [[NSNotificationCenter defaultCenter] postNotificationName:kHPPPSubstituteWiFiConnectionLost object:nil];
        }
    }
}

- (NSString *)wifiName {
    NSString *wifiName = kHPPPSubstituteNoNetwork;
    NSArray *ifs = (__bridge_transfer id)CNCopySupportedInterfaces();
    for (NSString *ifnam in ifs) {
        NSDictionary *info = (__bridge_transfer id)CNCopyCurrentNetworkInfo((__bridge CFStringRef)ifnam);
        if (info[@"SSID"]) {
            wifiName = info[@"SSID"];
        }
    }
    return wifiName;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
