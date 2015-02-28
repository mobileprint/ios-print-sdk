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

@interface HPPPWiFiReachability ()

@property (weak, nonatomic) UIBarButtonItem *button;
@property (nonatomic) HPPPReachability *wifiReachability;

@end


@implementation HPPPWiFiReachability

-(void)start:(UIBarButtonItem *)button
{
    self.button = button;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reachabilityChanged:) name:kReachabilityChangedNotification object:nil];
    self.wifiReachability = [HPPPReachability reachabilityForLocalWiFi];
    [self.wifiReachability startNotifier];
    [self verifyWifiIsConnected:self.wifiReachability];
}

- (void)verifyWifiIsConnected:(HPPPReachability *)reachability {
    NetworkStatus wifiStatus = [reachability currentReachabilityStatus];
    if (wifiStatus != NotReachable) {
        [self.button setEnabled:YES];
    } else {
        [self.button setEnabled:NO];
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Printing Requires Wi-Fi"
                                                        message:@"Printing requires your mobile device and printer to be on same Wi-Fi network. Please check your Wi-Fi settings."
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
    }
}

- (void)reachabilityChanged:(NSNotification *)notification
{
    HPPPReachability *currentReachability = [notification object];
    NSParameterAssert([currentReachability isKindOfClass:[HPPPReachability class]]);
    [self verifyWifiIsConnected:currentReachability];
}


- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kReachabilityChangedNotification object:nil];
}

@end
