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
#import "MPPaper.h"

/*!
 * @abstract Represents a the settings used to print
 */
@interface MPPrintSettings : NSObject

/*!
 * @abstract The URL of the printer
 * @discussion Typically this is used only in iOS 8 when printing directly to the printer with no iOS AirPrint dialog
 * @availability iOS 8 and later
 */
@property (strong, nonatomic) NSURL *printerUrl;

/*!
 * @abstract The ID of the printer
 * @discussion This is the value returned by iOS after printing is complete
 */
@property (strong, nonatomic) NSString *printerId;

/*!
 * @abstract The display name of the printer
 * @availability iOS 8 and later
 */
@property (strong, nonatomic) NSString *printerName;

/*!
 * @abstract The display location of the printer
 * @availability iOS 8 and later
 */
@property (strong, nonatomic) NSString *printerLocation;

/*!
 * @abstract The printer model
 * @availability iOS 8 and later
 */
@property (strong, nonatomic) NSString *printerModel;

/*!
 * @abstract Inidicates whether or not the printer was contacted successfully
 * @availability iOS 8 and later
 */
@property (assign, nonatomic) BOOL printerIsAvailable;

/*!
 * @abstract The paper to use for printing
 */
@property (strong, nonatomic) MPPaper *paper;

/*!
 * @abstract A boolean indicating whether to print in color
 */
@property (assign, nonatomic) BOOL color;

@end
