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

/*!
 * @abstract Represents a single print job
 */
@interface HPPPPrintLaterJob : NSObject <NSCoding>

/*!
 * @abstract Dictionary of print items for the print job
 * @discussion The dictionary should contain a print item for each paper size. The key for each image is the paper size title as an NSString object.
 * @seealso HPPPPrintItem
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
 * @abstract Date of the print job
 */
@property (strong, nonatomic) NSDate *date;

/*!
 * @abstract A dictionary of extra information to store with the print job
 * @discussion The objects in this dictionary must be encodable with the NSCoding protocol
 */
@property (strong, nonatomic) NSDictionary *extra;

- (UIImage *)previewImage;

@end
