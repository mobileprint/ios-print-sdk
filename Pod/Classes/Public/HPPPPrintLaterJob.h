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
#import "HPPPPageRange.h"
#import "HPPPPrintItem.h"

/*!
 * @abstract Represents a single print job
 */
@interface HPPPPrintLaterJob : NSObject <NSCoding>

/*!
 * @abstract Dictionary of print items for the print job
 * @discussion The dictionary should contain a print item for each paper size. The key for each image is the paper size title as an NSString object.
 */
@property (strong, nonatomic) NSDictionary *printItems; // Dictionary with printing items (key = the paper size title, object = printing item)

/*!
 * @abstract ID of the print job
 * @discussion Use the retrievePrintLaterJobNextAvailableId method of HPPPPrintLaterQueue to obtain the next available ID
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
@property (strong, nonatomic) HPPPPageRange *pageRange;

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
 * @abstract The default preview image
 * @discussion This image is created to suit the HPPP default paper size
 */
- (UIImage *)previewImage;

/*!
 * @abstract A method to return the print item based on paper size title
 */
- (HPPPPrintItem *) printItemForPaperSize:(NSString *)paperSizeTitle;

/*!
 * @abstract A method to return the print item for the default paper size
 */
- (HPPPPrintItem *)defaultPrintItem;

/*!
 * @abstract Populates job with metrics info
 * @param offramp The metrics offramp to use
 */
- (void)prepareMetricswithOfframp:(NSString *)offramp;

@end
