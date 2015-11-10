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
#import <CoreLocation/CoreLocation.h>
#import "MPPrintSettings.h"

/*!
 * @abstract Class used to remember default settings
 */
@interface MPDefaultSettingsManager : NSObject

/*!
 * @abstract Used to access the singleton instance of this class
 */
+ (MPDefaultSettingsManager *)sharedInstance;

/*!
 * @abstract Returns the printer name of the default printer set by the user.
 */
@property (strong, nonatomic) NSString *defaultPrinterName;

/*!
 * @abstract Returns the printer URL of the default printer set by the user.
 */
@property (strong, nonatomic) NSString *defaultPrinterUrl;

/*!
 * @abstract Returns the network of the default printer.
 */
@property (strong, nonatomic) NSString *defaultPrinterNetwork;

/*!
 * @abstract Returns the model of the default printer.
 */
@property (strong, nonatomic) NSString *defaultPrinterModel;

/*!
 * @abstract Returns the location of the default printer.
 */
@property (strong, nonatomic) NSString *defaultPrinterLocation;

/*!
 * @abstract Returns the coordinate of the default printer.
 */
@property (assign, nonatomic) CLLocationCoordinate2D defaultPrinterCoordinate;

/*!
 * @abstract Indicates whether or not a default printer has been set.
 */
- (BOOL)isDefaultPrinterSet;

/*!
 * @abstract Returns the default settings encapsulated within a print settings object.
 */
- (MPPrintSettings *)defaultsAsPrintSettings;

@end
