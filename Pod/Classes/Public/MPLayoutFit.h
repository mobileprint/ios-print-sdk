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
#import "MPLayoutComposite.h"

/*!
 * @abstract Layout intended to best fill the paper without stretching or cropping.
 */
@interface MPLayoutFit : MPLayoutComposite

/*!
 * @abstract The desired horizontal position for the content.  The default value is MPLayoutHorizontalPositionMiddle.
 */
@property (assign, nonatomic) MPLayoutHorizontalPosition horizontalPosition;

/*!
 * @abstract The desired vertical position for the content.  The default value is MPLayoutVerticalPositionMiddle.
 */
@property (assign, nonatomic) MPLayoutVerticalPosition verticalPosition;

@end
