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

@class MPLayoutPaperView;

/*!
 * @abstract Layout strategy base class
 */
@interface MPLayout : NSObject<NSCoding>

/*!
 * @abstract List of supported orientation strategies
 * @const MPLayoutOrientationPortrait Specifies that the content should be laid out on a portrait page regardless of the content aspect ratio
 * @const MPLayoutOrientationLandscape Specifies that the content should be laid out on a landscape page regardless of the content aspect ratio
 * @const MPLayoutOrientationBestFit Specifies that the content should be laid out on a portrait page if the content is portrait and a landscape page if the content is landscape
 * @const MPLayoutOrientationFixed Specifies that the orientation is fixed to the existing orientation of the container
 * @const MPLayoutOrientationIgnored Specifies that the orientation is not used in the layout logic
 */
typedef enum {
    MPLayoutOrientationPortrait,
    MPLayoutOrientationLandscape,
    MPLayoutOrientationBestFit,
    MPLayoutOrientationFixed,
    MPLayoutOrientationIgnored
} MPLayoutOrientation;


/*!
 * @abstract List of supported vertical layout strategies
 * @const MPLayoutVerticalPositionTop Specifies that the content should be laid out at the top of the containing rectangle
 * @const MPLayoutVerticalPositionMiddle Specifies that the content should be laid out vertically centered in the containing rectangle
 * @const MPLayoutVerticalPositionBottom Specifies that the content should be laid out at the bottom of the containing rectangle
 */
typedef enum {
    MPLayoutVerticalPositionTop,
    MPLayoutVerticalPositionMiddle,
    MPLayoutVerticalPositionBottom
} MPLayoutVerticalPosition;

/*!
 * @abstract List of supported vertical layout strategies
 * @const MPLayoutHorizontalPositionLeft Specifies that the content should be laid out on the left edge of the containing rectangle
 * @const MPLayoutHorizontalPositionMiddle Specifies that the content should be laid out horizontally centered in the containing rectangle
 * @const MPLayoutHorizontalPositionRight Specifies that the content should be laid out on the right edge of the containing rectangle
 */
typedef enum {
    MPLayoutHorizontalPositionLeft,
    MPLayoutHorizontalPositionMiddle,
    MPLayoutHorizontalPositionRight
} MPLayoutHorizontalPosition;

/*!
 * @abstract A unique identifier for the layout class.
 * @discussion Returns the name of the layout class.  Thus, each subclass has a built-in unique identifier.
 */
+ (NSString *)layoutType;

/*!
 * @abstract Creates a layout with a specific asset position
 * @param position A CGRect of percentage-based values that locates the layout content rectangle on the page
 * @param orientation An MPLayoutOrientation value specifiying the orientation strategy to use
 * @discussion Note that the iOS method CGRectStandardize will be used to ensure positive size values of the asset position rectangle.
 * @seealso assetPosition
 * @seealso orientation
 */
- (id)initWithOrientation:(MPLayoutOrientation)orientation assetPosition:(CGRect)position;

/*!
 * @abstract Creates a layout with a specific asset position
 * @param position A CGRect of percentage-based values that locates the layout content rectangle on the page
 * @param orientation An MPLayoutOrientation value specifiying the orientation strategy to use
 * @param shouldRotate Indicates whether to include rotation in the layout logic
 * @discussion Note that the iOS method CGRectStandardize will be used to ensure positive size values of the asset position rectangle.
 * @seealso assetPosition
 * @seealso orientation
 */
- (id)initWithOrientation:(MPLayoutOrientation)orientation assetPosition:(CGRect)position shouldRotate:(BOOL)shouldRotate;

/*!
 * @abstract Draws the image onto a content rectangle
 * @param image The image asset to draw
 * @param rect The reference rectangle onto which the image is drawn.
 * @discussion The actual content rectangle used for layout will be computed using the rectangle passed in with the assetPosition percentages applied.
 * @seealso initWithOrientation:assetPosition:
 */
- (void)drawContentImage:(UIImage *)image inRect:(CGRect)rect;

/*!
 * @abstract Does not draw the image, but returns the CGRect that the image would be drawn into if drawn
 * @param image The image asset that would be drawn
 * @param rect The reference rectangle onto which the image would be drawn.
 * @discussion The actual content rectangle used for layout will be computed using the rectangle passed in with the assetPosition percentages applied.
 */
- (CGRect)contentImageLocation:(UIImage *)image inRect:(CGRect)rect;

/*!
 * @abstract Lays out a view inside another view
 * @param contentView The view being laid out
 * @param containerView The view that contains the view being laid out
 * @discussion The actual reference rectangle used for layout will be computed using the frame of the view passed in with the assetPosition percentages applied.
 */
- (void)layoutContentView:(UIView *)contentView inContainerView:(UIView *)containerView;

/*!
 * @abstract The asset position that fills the container completely
 * @discussion This assetPosition will fill the entire page with the asset. This means an asset position of origin 0%, 0% and size 100%, 100%.
 * @seealso assetPosition
 */
+ (CGRect)completeFillRectangle;

/*!
 * @abstract Sets paper view to its initial aspect ratio
 * @param paperView The content paper view to prepare
 * @param paper The MPPaper object that the paper view will represent
 * @discussion Uses the image and layout to determine whether portrait or landscape is best for the paper orientation. Then sets paper to "unit dimensions" that represent the orientation and aspect ratio desired.
 * @seealso preparePaperView:withPaper:image:layout:
 */
+ (void)preparePaperView:(MPLayoutPaperView *)paperView withPaper:(MPPaper *)paper;

/*!
 * @abstract Sets paper view to its initial aspect ratio and stores the image and layout
 * @param paperView The content paper view to prepare
 * @param paper The MPPaper object that the paper view will represent
 * @param image The image to be laid out on the paper
 * @param layout The layout to use for laying out content on the paper
 * @discussion Stores the image and layout and uses them to determine whether portrait or landscape is best for the paper orientation. Then sets paper to "unit dimensions" that represent the orientation and aspect ratio desired.
 * @seealso preparePaperView:withPaper:
 */
+ (void)preparePaperView:(MPLayoutPaperView *)paperView withPaper:(MPPaper *)paper image:(UIImage *)image layout:(MPLayout *)layout;

/*!
 * @abstract Gets the best paper orientation for the given image and layout
 * @param image The image to be laid out on the paper
 * @param layout The layout to use for laying out content on the paper
 * @return The best paper orientation for the given image and layout
 */
+ (MPLayoutOrientation)paperOrientationForImage:(UIImage *)image andLayout:(MPLayout *)layout;

/*!
 * @abstract The adjusted position of the content
 * @discussion The position of the asset on the page is specified as a rectangle with an origin and size. Both the origin (x, y) and the size (width, height) are specified in percentage of total page size. The origin can include negative values but the size should include only positive values. The layout rectangle used when the layout is applied is computed as follows. The origin of the content is the origin of the container + the percentage of container width/height specified in the assetPosition origin. The content width/height is equal to the percentage of container width/height in assetPosition size.
 */
@property (assign, nonatomic, readonly) CGRect assetPosition;

/*!
 * @abstract The orientation of the layout
 * @discussion This property controls how the layout handles content orientation relative to the container orientation.
 * @seealso MPLayoutOrientation
 */
@property (assign, nonatomic, readonly) MPLayoutOrientation orientation;

/*!
 * @abstract Indicates the print paper that the layout will be applied to
 * @description This is used to ensure things like border width are scaled properly in printing and previews
 */
@property (weak, nonatomic) MPPaper *paper;

/*!
 * @abstract Width of the border in inches
 * @description Border is applied equally on all sides of the print rectangle before any other layout logic is performed
 */
@property (assign, nonatomic) float borderInches;

@end
