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

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

@interface HPPPDefaultSettingsManager : NSObject

+ (HPPPDefaultSettingsManager *)sharedInstance;

/*!
 * @abstract Returns the printer name of the default printer set by the user.
 */
@property (strong, nonatomic) NSString *defaultPrinterName;

/*!
 * @abstract Returns the printer URL of the default printer set by the user.
 */
@property (strong, nonatomic) NSString *defaultPrinterUrl;

/*!
 * @abstract Returns the printer Network of the default printer.
 */
@property (strong, nonatomic) NSString *defaultPrinterNetwork;

/*!
 * @abstract Returns the coordinate of the default printer.
 */
@property (assign, nonatomic) CLLocationCoordinate2D defaultPrinterCoordinate;

- (BOOL)isDefaultPrinterSet;

@end
