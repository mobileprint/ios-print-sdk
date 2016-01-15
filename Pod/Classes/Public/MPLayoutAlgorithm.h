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
#import "MPLayout.h"

/*!
 * @abstract Algorithm strategy base class
 */
@interface MPLayoutAlgorithm : NSObject <NSCoding>

/*!
 * @abstract Draws an image in the specified rectangle
 * @param image The image to be drawn
 * @param containerRect The rectangle the image should be drawn in
 * @discussion The algorithm may display the image in a cropped or resized fashion to fit the rectangle
 */
- (void)drawImage:(UIImage *)image inContainer:(CGRect)containerRect;

/*!
 * @abstract Returns the rectangle an image would occupy if drawn in the specified container rectangle
 * @param image The image that would be drawn
 * @param containerRect The rectangle the image would be drawn in
 * @return The rectangle the image would occupy within the container rectangle
 * @discussion The image is not drawn into the rectangle.  The rectangle the image would occupy if it was drawn into the container rectangle is returned.
 */
- (CGRect)getContainerForImage:(UIImage *)image inContainer:(CGRect)containerRect;

/*!
 * @abstract Resizes the content view such that it will be the proper size for the content rect with respect to the container rect
 * @param contentView The view containing the content to be drawn
 * @param containerView The view that contains the contentView
 * @param contentRect The rectangle containing the "payload", or item to be drawn
 * @param containerRect The rectangle containing the contentRect
 */
- (void)resizeContentView:(UIView *)contentView containerView:(UIView *)containerView contentRect:(CGRect)contentRect containerRect:(CGRect)containerRect;

/*!
 * @abstract Resizes the content view such that it occupies the specified rectangle
 * @param frame The rectangle the contentView needs to occupy
 * @param contentView The view to be resized
 * @param containerView The view that contains the contentView
 */
- (void)applyConstraintsWithFrame:(CGRect)frame toContentView:(UIView *)contentView inContainerView:(UIView *)containerView;


@end
