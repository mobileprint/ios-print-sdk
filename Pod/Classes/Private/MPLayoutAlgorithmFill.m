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

#import "MPLayoutAlgorithmFill.h"

@implementation MPLayoutAlgorithmFill

- (void)drawImage:(UIImage *)image inContainer:(CGRect)containerRect
{
    CGRect contentRect = CGRectMake(0, 0, image.size.width, image.size.height);
    [image drawInRect:[self computeLayoutRectWithContentRect:contentRect andContainerRect:containerRect]];
}

- (CGRect)computeLayoutRectWithContentRect:(CGRect)contentRect andContainerRect:(CGRect)containerRect
{
    CGFloat contentAspectRatio = contentRect.size.width / contentRect.size.height;
    CGFloat containerAspectRatio = containerRect.size.width / containerRect.size.height;
    CGFloat scale = containerRect.size.width / contentRect.size.width;
    if (contentAspectRatio > containerAspectRatio) {
        scale = containerRect.size.height / contentRect.size.height;
    }
    CGFloat width = contentRect.size.width * scale;
    CGFloat height = contentRect.size.height * scale;
    CGFloat x = containerRect.origin.x - (width - containerRect.size.width) / 2.0;
    CGFloat y = containerRect.origin.y -  (height - containerRect.size.height) / 2.0;
    return CGRectMake(x, y, width, height);
}

@end
