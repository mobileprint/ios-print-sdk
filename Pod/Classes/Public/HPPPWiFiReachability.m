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

@property (weak, nonatomic) UITableViewCell *cell;
@property (nonatomic) Reachability *wifiReachability;

@end


@implementation HPPPWiFiReachability

- (void)start:(UITableViewCell *)cell
{
    self.cell = cell;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reachabilityChanged:) name:kReachabilityChangedNotification object:nil];
    self.wifiReachability = [Reachability reachabilityForLocalWiFi];
    [self.wifiReachability startNotifier];
    [self verifyWifiIsConnected:self.wifiReachability];
}

- (void)verifyWifiIsConnected:(Reachability *)reachability
{
    NetworkStatus wifiStatus = [reachability currentReachabilityStatus];
    if (wifiStatus != NotReachable) {
        self.cell.userInteractionEnabled = YES;
        self.cell.textLabel.textColor = [UIColor blackColor];
    } else {
        self.cell.userInteractionEnabled = NO;
        self.cell.textLabel.textColor = [UIColor grayColor];
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
    Reachability *currentReachability = [notification object];
    NSParameterAssert([currentReachability isKindOfClass:[Reachability class]]);
    [self verifyWifiIsConnected:currentReachability];
}


- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kReachabilityChangedNotification object:nil];
}

@end
