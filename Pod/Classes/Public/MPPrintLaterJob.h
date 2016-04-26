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
#import "MPPageRange.h"
#import "MPPrintItem.h"

/*!
 * @abstract Represents a single print job
 */
@interface MPPrintLaterJob : NSObject <NSCoding>

/*!
 * @abstract Dictionary of print items for the print job
 * @discussion The dictionary should contain a print item for each paper size. The key for each image is the paper size title as an NSString object.
 */
@property (strong, nonatomic) NSDictionary *printItems; // Dictionary with printing items (key = the paper size title, object = printing item)

/*!
 * @abstract ID of the print job
 * @discussion Use the retrievePrintLaterJobNextAvailableId method of MPPrintLaterQueue to obtain the next available ID
 */
@property (strong, nonatomic) NSString *id;

/*!
 * @abstract Display name of the print job
 */
@property (strong, nonatomic) NSString *name;

/*!
 * @abstract Number of copies desired in the print job
 */
@property (assign, nonatomic) NSInteger numCopies;

/*!
 * @abstract Pages to be printed within the document.  Valid characters are: [0-9],-
 */
@property (strong, nonatomic) MPPageRange *pageRange;

/*!
 * @abstract Flag set to TRUE if the print job should be printed in black and white
 */
@property (assign, nonatomic) BOOL blackAndWhite;

/*!
 * @abstract Date of the print job
 */
@property (strong, nonatomic) NSDate *date;

/*!
 * @abstract A dictionary of extra information to store with the print job
 * @discussion The objects in this dictionary must be encodable with the NSCoding protocol
 */
@property (strong, nonatomic) NSDictionary *extra;

/*!
 * @abstract A dictionary of custom analytics information to store with the print job
 * @discussion The objects in this dictionary must be encodable with the NSCoding protocol
 */
@property (strong, nonatomic) NSDictionary *customAnalytics;

/*!
 * @abstract The default preview image
 * @discussion This image is created to suit the MP default paper size
 */
- (UIImage *)previewImage;

/*!
 * @abstract A method to return the print item based on paper size title
 */
- (MPPrintItem *) printItemForPaperSize:(NSString *)paperSizeTitle;

/*!
 * @abstract A method to return the print item for the default paper size
 */
- (MPPrintItem *)defaultPrintItem;

/*!
 * @abstract Populates job with metrics info
 * @param offramp The metrics offramp to use
 */
- (void)prepareMetricsForOfframp:(NSString *)offramp;

/*!
 * @abstract Populates job with print session info
 * @param printItem The print item to use to get the print session
 */
- (void)setPrintSessionForPrintItem:(MPPrintItem *)printItem;

@end
