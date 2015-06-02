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

@class HPPPLayoutPaperView;

/*!
 * @abstract Layout strategy base class
 */
@interface HPPPLayout : NSObject

/*!
 * @abstract List of supported orientation strategies
 * @const HPPPLayoutOrientationPortrait Specifies that the content should be laid out on a portrait page regardless of the content aspect ratio
 * @const HPPPLayoutOrientationLandscape Specifies that the content should be laid out on a landscape page regardless of the content aspect ratio
 * @const HPPPLayoutOrientationBestFit Specifies that the content should be laid out on a portrait page if the content is portrait and a landscape page if the content is landscape
 * @const HPPPLayoutOrientationMatchContainer Specifies that the a portrait or landscape layout should be used to match the container orientation
 */
typedef enum {
    HPPPLayoutOrientationPortrait,
    HPPPLayoutOrientationLandscape,
    HPPPLayoutOrientationBestFit,
    HPPPLayoutOrientationMatchContainer
} HPPPLayoutOrientation;

/*!
 * @abstract Creates a layout with a specific asset position
 * @param position A CGRect of percentage-based values that locates the layout content rectangle on the page
 * @param orientation An HPPPLayoutOrientation value specifiying the orientation strategy to use
 * @discussion Note that the position of the asset on the page is specified as a rectangle with an origin and size. Both the origin (x, y) and the size (width, height) are specified in percentage of total page size. The origin can include negative values but the size should include only positive values. The iOS method CGRectStandardize will be used to ensure positive size values.
 */
- (id)initWithOrientation:(HPPPLayoutOrientation)orientation andAssetPosition:(CGRect)position;

/*!
 * @abstract Draws the image onto a content rectangle
 * @param image The image asset to draw
 * @param rect The reference rectangle onto which the image is drawn.
 * @discussion The actual content rectangle used for layout will be computed using the rectangle passed in with the assetPosition percentages applied.
 * @seealso initWithOrientation:andAssetPosition:
 */
- (void)drawContentImage:(UIImage *)image inRect:(CGRect)rect;

/*!
 * @abstract Lays out a view inside another view
 * @param contentView The view being laid out
 * @param containerView The view that contains the view being laid out
 * @discussion The actual reference rectangle used for layout will be computed using the frame of the view passed in with the assetPosition percentages applied.
 */
- (void)layoutContentView:(UIView *)contentView inContainerView:(UIView *)containerView;

/*!
 * @abstract Computes an adjusted content rect
 * @discussion Applies the assetPosition percentages to the given rect to compute a rect with adjusted orign and size.
 */
- (CGRect)assetPositionForRect:(CGRect)rect;


/*!
 * @abstract Determines of content rotation is required
 * @param contentRect The content rectangle being laid out
 * @param containerRect The container rectangle in which the content is being laid out
 * @discussion Uses the orientation stragey specified in the layout to determine whether or not the content should be rotated.
 * @seealso HPPPLayoutOrientation
 */
- (BOOL)rotationNeededForContent:(CGRect)contentRect withContainer:(CGRect)containerRect;

/*!
 * @abstract The default asset position
 * @discussion The default is to fill the entire page with the asset. This means an asset position of origin 0%, 0% and size 100%, 100%.
 */
+ (CGRect)defaultAssetPosition;

// TODO: needs documentation
+ (void)preparePaperView:(HPPPLayoutPaperView *)paperView withPaper:(HPPPPaper *)paper;
+ (void)preparePaperView:(HPPPLayoutPaperView *)paperView withPaper:(HPPPPaper *)paper image:(UIImage *)image layout:(HPPPLayout *)layout;

// TODO: needs documentation
- (void)applyConstraintsWithFrame:(CGRect)frame toContentView:(UIView *)contentView inContainerView:(UIView *)containerView;

@property (assign, nonatomic, readonly) CGRect assetPosition;
@property (assign, nonatomic, readonly) HPPPLayoutOrientation orientation;

@end
