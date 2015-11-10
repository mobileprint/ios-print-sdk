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

#import "MPLayout.h"

/*!
 * @abstract Layout intended to best fill the paper without stretching or cropping.
 */
@interface MPLayoutFit : MPLayout

/*!
 * @abstract A key for specifying the desired horizontal position of the layout
 * @discussion This key is to be used when calling the layoutWithType:orientation:layoutOptions:
 *  function on the MPLayoutFactoryClass.  Use this key as a key on the layoutOptions dictionary to specify
 *  which MPLayoutHorizontalPosition to use with the layout.
 */
extern NSString * const kMPLayoutHorizontalPositionKey;

/*!
 * @abstract A key for specifying the desired vertical position of the layout
 * @discussion This key is to be used when calling the layoutWithType:orientation:layoutOptions:
 *  function on the MPLayoutFactoryClass.  Use this key as a key on the layoutOptions dictionary to specify
 *  which MPLayoutVerticalPosition to use with the layout.
 */
extern NSString * const kMPLayoutVerticalPositionKey;

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
 * @abstract Computes the rectangle that should contain the contentRect within the containerRect
 * @param contentRect The CGRect of the content to be laid out
 * @param containerRect The CGRect of the container which will receive the contentRect
 */
- (CGRect)computeRectWithContentRect:(CGRect)contentRect andContainerRect:(CGRect)containerRect;

/*!
 * @abstract The desired horizontal position for the content.  The default value is MPLayoutHorizontalPositionMiddle.
 */
@property (assign, nonatomic) MPLayoutHorizontalPosition horizontalPosition;

/*!
 * @abstract The desired vertical position for the content.  The default value is MPLayoutVerticalPositionMiddle.
 */
@property (assign, nonatomic) MPLayoutVerticalPosition verticalPosition;

@end
