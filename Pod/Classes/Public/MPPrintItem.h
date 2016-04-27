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
#import "MPPaper.h"
#import "MPLayout.h"
#import "MPPageRange.h"

/*!
 * @abstract Represents an item to be printed
 */
@interface MPPrintItem : NSObject<NSCoding>


/*!
 * @abstract Used to convert points to inches
 */
extern CGFloat const kMPPointsPerInch;

/*!
 * @abstract The key used during serialization (NSCoder)
 */
extern NSString * const kMPPrintAssetKey;

/*!
 * @abstract Dictionary key used to specify a dictionary of custom analytics
 * @discussion An NSDictionary value representing any items to be stored as custom analytics
 */
extern NSString * const kMPCustomAnalyticsKey;

/*!
 * @abstract Specifies measurement units
 * @const Inches Report measurements in inches
 * @const Pixels Report measurements in pixels
 */
typedef enum {
    Inches,
    Pixels
} MPUnits;

/*!
 * @abstract Specifies which rendering strategy to use
 * @const DefaultPrintRenderer Allow iOS to handle printing this item (i.e. standard AirPrint using printItem property)
 * @const CustomPrintRenderer Use the custom print renderer provided in MobilePrintSDK. This will use the MPLayout provided in the layout property to draw the content on the page
 * @seealso MPLayout
 */
typedef enum {
    DefaultPrintRenderer,
    CustomPrintRenderer
} MPPrintRenderer;

/*!
 * @abstract The actual asset to be printed
 * @discussion This must be a UIImage or an NSData object representing an image or PDF document.
 */
@property (strong, nonatomic, readonly) id printAsset;

/*!
 * @abstract Representations of the print item that can work with a sharing activity
 * @discussion The standard iOS share menu uses UIActivityViewController to allow the user to take an action with a given object. When sharing a print item, this property provides a list of print item representations suitable for using with the activityItems property of UIActivityViewController.
 * @returns An array of shareable representations of this print item
 */
@property (strong, nonatomic, readonly) NSArray *activityItems;

/*!
 * @abstract Specifies the type of print item (e.g. PDF, image, etc.).
 */
@property (strong, nonatomic, readonly) NSString *assetType;

/*!
 * @abstract Specifies the type of rendering to use
 * @seealso MPPrintRenderer
 */
@property (assign, nonatomic, readonly) MPPrintRenderer renderer;

/*!
 * @abstract Specifies the layout to use for drawing content
 */
@property (strong, nonatomic) MPLayout *layout;

/*!
 * @abstract Reports the dimensions of the printable content
 * @param units The units used for the dimensions
 * @return The size of the printable content in the units specfied
 */
- (CGSize)sizeInUnits:(MPUnits)units;

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
- (UIImage *)previewImageForPaper:(MPPaper *)paper;

/*!
 * @abstract Retrieves the preview image for a given paper for each page of the print asset
 * @param paper The paper that the print asset will be printed on. Determines the size and aspect ratio of the preview.
 * @return An array of preview image
 */
- (NSArray *)previewImagesForPaper:(MPPaper *)paper;

/*!
 * @abstract Retrieves the preview image for a given paper for the specified page of the print asset
 * @param page The page of the print asset to be retrieved
 * @param paper The paper that the print asset will be printed on. Determines the size and aspect ratio of the preview.
 * @return An array of preview image
 */
- (UIImage *)previewImageForPage:(NSUInteger)page paper:(MPPaper *)paper;

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
- (id)decodeAssetWithCoder:(NSCoder *)decoder;

/*!
 * @abstract Used to retrieve a print asset for the specified page range
 * @param pageRange The page range to include in the returned print asset
 * @discussion A print asset that contains only he pages within the specified page range.
 */
- (id)printAssetForPageRange:(MPPageRange *)pageRange;

/*!
 * @abstract A dictionary of extra information to store with the print item
 * @discussion Typically this information is copied from the print job to the print item when the job is printed from the print queue. It is used to record print metrics information. Note, this property is not persisted on the print item when stored in the print queue. Use the 'extra' property of the print job itself for persistent storage in the queue.
 */
@property (strong, nonatomic) NSDictionary *extra;

/*!
 * @abstract A dictionary of custom analytics to log with printing analytics
 * @discussion Note, this property is not persisted on the print item when stored in the print queue. Use the 'customAnalytics' property of the print job itself for persistent storage in the queue.
 */
@property (strong, nonatomic) NSDictionary *customAnalytics;

@end
