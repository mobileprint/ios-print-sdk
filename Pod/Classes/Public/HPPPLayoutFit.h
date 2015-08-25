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

typedef enum {
    HPPPLayoutVerticalPositionTop,
    HPPPLayoutVerticalPositionMiddle,
    HPPPLayoutVerticalPositionBottom
} HPPPLayoutVerticalPosition;

typedef enum {
    HPPPLayoutHorizontalPositionLeft,
    HPPPLayoutHorizontalPositionMiddle,
    HPPPLayoutHorizontalPositionRight
} HPPPLayoutHorizontalPosition;

extern NSString * const kHPPPLayoutHorizontalPositionKey;
extern NSString * const kHPPPLayoutVerticalPositionKey;

/*!
 * @abstract Layout intended to best fill the paper without stretching or cropping.
 */
@interface HPPPLayoutFit : HPPPLayout

@property (assign, nonatomic) HPPPLayoutHorizontalPosition horizontalPosition;
@property (assign, nonatomic) HPPPLayoutVerticalPosition verticalPosition;

/*!
 * @abstract Computes the rectangle that should contain the contentRect within the containerRect
 * @param contentRect The CGRect of the content to be laid out
 * @param containerRect The CGRect of the container which will receive the contentRect
 */
- (CGRect)computeRectWithContentRect:(CGRect)contentRect andContainerRect:(CGRect)containerRect;

@end
