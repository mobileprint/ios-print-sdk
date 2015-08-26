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

#import "HPPPLayout.h"

/*!
 * @abstract A key for specifying the desired horizontal position of the layout
 * @discussion This key is to be used when calling the layoutWithType:orientation:layoutOptions:allowRotation
 *  function on the HPPPLayoutFactoryClass.  Use this key as a key on the layoutOptions dictionary to specify
 *  which HPPPLayoutHorizontalPosition to use with the layout.
 */
extern NSString * const kHPPPLayoutHorizontalPositionKey;

/*!
 * @abstract A key for specifying the desired vertical position of the layout
 * @discussion This key is to be used when calling the layoutWithType:orientation:layoutOptions:allowRotation
 *  function on the HPPPLayoutFactoryClass.  Use this key as a key on the layoutOptions dictionary to specify
 *  which HPPPLayoutVerticalPosition to use with the layout.
 */
extern NSString * const kHPPPLayoutVerticalPositionKey;

/*!
 * @abstract Layout intended to best fill the paper without stretching or cropping.
 */
@interface HPPPLayoutFit : HPPPLayout

/*!
 * @abstract List of supported vertical layout strategies
 * @const HPPPLayoutVerticalPositionTop Specifies that the content should be laid out at the top of the containing rectangle
 * @const HPPPLayoutVerticalPositionMiddle Specifies that the content should be laid out vertically centered in the containing rectangle
 * @const HPPPLayoutVerticalPositionBottom Specifies that the content should be laid out at the bottom of the containing rectangle
 */
typedef enum {
    HPPPLayoutVerticalPositionTop,
    HPPPLayoutVerticalPositionMiddle,
    HPPPLayoutVerticalPositionBottom
} HPPPLayoutVerticalPosition;

/*!
 * @abstract List of supported vertical layout strategies
 * @const HPPPLayoutHorizontalPositionLeft Specifies that the content should be laid out on the left edge of the containing rectangle
 * @const HPPPLayoutHorizontalPositionMiddle Specifies that the content should be laid out horizontally centered in the containing rectangle
 * @const HPPPLayoutHorizontalPositionRight Specifies that the content should be laid out on the right edge of the containing rectangle
 */typedef enum {
     HPPPLayoutHorizontalPositionLeft,
     HPPPLayoutHorizontalPositionMiddle,
     HPPPLayoutHorizontalPositionRight
 } HPPPLayoutHorizontalPosition;

/*!
 * @abstract Computes the rectangle that should contain the contentRect within the containerRect
 * @param contentRect The CGRect of the content to be laid out
 * @param containerRect The CGRect of the container which will receive the contentRect
 */
- (CGRect)computeRectWithContentRect:(CGRect)contentRect andContainerRect:(CGRect)containerRect;

/*!
 * @abstract The desired horizontal position for the content.  The default value is HPPPLayoutHorizontalPositionMiddle.
 */
@property (assign, nonatomic) HPPPLayoutHorizontalPosition horizontalPosition;

/*!
 * @abstract The desired vertical position for the content.  The default value is HPPPLayoutVerticalPositionMiddle.
 */
@property (assign, nonatomic) HPPPLayoutVerticalPosition verticalPosition;

@end
