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

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "MPMobilePrintSDKReachability.h"

/*!
 * @abstract Class that provides Wi-Fi utility methods
 */
@interface MPWiFiReachability : NSObject

/*!
 * @abstract Used to access the singleton instance of this class
 */
+ (MPWiFiReachability *)sharedInstance;

/*!
 * @abstract Indicates whether or not Wi-Fi is connected
 * @return YES or NO
 */
- (BOOL)isWifiConnected;

/*!
 * @abstract Displays a modal alert indicating that printing is unavailable
 */
- (void)noPrintingAlert;

/*!
 * @abstract Displays a modal alert indicating that printer selection is unavailable
 */
- (void)noPrinterSelectAlert;

@end

