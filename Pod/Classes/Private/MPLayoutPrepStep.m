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

#import "MPLayoutPrepStep.h"

@implementation MPLayoutPrepStep

#pragma mark - Layout

- (UIImage *)imageForImage:(UIImage *)image inContainer:(CGRect)containerRect
{
    return image;
//    NSAssert(NO, @"%@ is intended to be an abstract class", NSStringFromClass(self.class));
//    return nil;
}

- (CGRect)contentRectForContent:(CGRect)contentRect inContainer:(CGRect)containerRect
{
    return contentRect;
//    NSAssert(NO, @"%@ is intended to be an abstract class", NSStringFromClass(self.class));
//    return CGRectZero;
}

- (CGRect)containerRectForContent:(CGRect)contentRect inContainer:(CGRect)containerRect
{
    return containerRect;
//    NSAssert(NO, @"%@ is intended to be an abstract class", NSStringFromClass(self.class));
//    return CGRectZero;
}

@end
