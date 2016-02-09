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
 * @abstract A base class representing a step in preparing the content and/or container prior to laying out the page
 */
@interface MPLayoutPrepStep : NSObject <NSCoding>

/*!
 * @abstract Provides an opportunity to modify the image prior to layout
 * @param image The image to be laid out
 * @param containerRect The container that will hold the image
 * @returns A potentially modified image to be passed to the next step
 */
- (UIImage *)imageForImage:(UIImage *)image inContainer:(CGRect)containerRect;

/*!
 * @abstract Provides an opportunity to modify the content rectangle prior to layout
 * @param contentRect The content rectangle to be laid out
 * @param containerRect The container that will hold the content
 * @returns A potentially modified content rectangle to be passed to the next step
 */
- (CGRect)contentRectForContent:(CGRect)contentRect inContainer:(CGRect)containerRect;

/*!
 * @abstract Provides an opportunity to modify the container rectangle prior to layout
 * @param contentRect The content rectangle to be laid out
 * @param containerRect The container that will hold the content
 * @returns A potentially modified container rectangle to be passed to the next step
 */
- (CGRect)containerRectForContent:(CGRect)contentRect inContainer:(CGRect)containerRect;

@end
