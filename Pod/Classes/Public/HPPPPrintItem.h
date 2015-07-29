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
#import <UIKit/UIKit.h>
#import "HPPPPaper.h"
#import "HPPPLayout.h"
#import "HPPPPageRange.h"

/*!
 * @abstract Represents an item to be printed
 */
@interface HPPPPrintItem : NSObject<NSCoding>


/*!
 * @abstract Used to convert points to inches
 */
extern CGFloat const kHPPPPointsPerInch;

/*!
 * @abstract The key used during serialization (NSCoder)
 */
extern NSString * const kHPPPPrintAssetKey;

/*!
 * @abstract Specifies measurement units
 * @const Inches Report measurements in inches
 * @const Pixels Report measurements in pixels
 */
typedef enum {
    Inches,
    Pixels
} HPPPUnits;

/*!
 * @abstract Specifies which rendering strategy to use
 * @const DefaultPrintRenderer Allow iOS to handle printing this item (i.e. standard AirPrint using printItem property)
 * @const CustomPrintRenderer Use the custom print renderer provided in HPPhotoPrint. This will use the HPPPLayout provided in the layout property to draw the content on the page
 * @seealso HPPPLayout
 */
typedef enum {
    DefaultPrintRenderer,
    CustomPrintRenderer
} HPPPPrintRenderer;

/*!
 * @abstract The actual asset to be printed
 * @discussion This must be a UIImage or an NSData object representing an image or PDF document.
 */
@property (strong, nonatomic, readonly) id printAsset;

/*!
 * @abstract Specifies the type of print item (e.g. PDF, image, etc.).
 */
@property (strong, nonatomic, readonly) NSString *assetType;

/*!
 * @abstract Specifies the type of rendering to use
 * @seealso HPPPPrintRenderer
 */
@property (assign, nonatomic, readonly) HPPPPrintRenderer renderer;

/*!
 * @abstract Specifies the layout to use for drawing content
 */
@property (strong, nonatomic) HPPPLayout *layout;

/*!
 * @abstract Reports the dimensions of the printable content
 * @param units The units used for the dimensions
 * @return The size of the printable content in the units specfied
 */
- (CGSize)sizeInUnits:(HPPPUnits)units;

/*!
 * @abstract Reports the total number of pages of the content
 * @return The number of pages
 */
- (NSInteger)numberOfPages;

/*!
 * @abstract Retrieves the default preview image for the print asset
 * @return The preview image
 */
- (UIImage *)defaultPreviewImage;

/*!
 * @abstract Retrieves the preview image for the print asset for a given paper
 * @param paper The paper that the print asset will be printed on. Determines the size and aspect ratio of the preview.
 * @return The preview image
 */
- (UIImage *)previewImageForPaper:(HPPPPaper *)paper;

/*!
 * @abstract Retrieves the preview image for a given paper for each page of the print asset
 * @param paper The paper that the print asset will be printed on. Determines the size and aspect ratio of the preview.
 * @return An array of preview image
 */
- (NSArray *)previewImagesForPaper:(HPPPPaper *)paper;

/*!
 * @abstract Used to serialize the print asset during encoding
 * @param encoder The encoder used by the NSCoder protocol
 * @discussion Override this method if the print asset needs special processing to be encoded
 */
- (void)encodeAssetWithCoder:(NSCoder *)encoder;

/*!
 * @abstract Used to deserialize the print asset during decoding
 * @param decoder The decoder used by the NSCoder protocol
 * @discussion Override this method if the print asset needs special processing to be decoded
 */
- (id)initAssetWithCoder:(NSCoder *)decoder;

/*!
 * @abstract Used to retrieve a print asset for the specified page range
 * @param pageRange The page range to include in the returned print asset
 * @discussion A print asset that contains only he pages within the specified page range.
 */
- (id)printAssetForPageRange:(HPPPPageRange *)pageRange;

@end
