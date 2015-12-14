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

#import "MPLayoutAlgorithmFit.h"

@implementation MPLayoutAlgorithmFit

- (void)drawImage:(UIImage *)image inContainer:(CGRect)containerRect
{
    CGRect contentRect = CGRectMake(0, 0, image.size.width, image.size.height);
    [image drawInRect:[self computeRectWithContentRect:contentRect andContainerRect:containerRect]];
}

- (CGRect)computeRectWithContentRect:(CGRect)contentRect andContainerRect:(CGRect)containerRect
{
    CGFloat contentAspectRatio = contentRect.size.width / contentRect.size.height;
    CGFloat containerAspectRatio = containerRect.size.width / containerRect.size.height;
    CGFloat width = containerRect.size.height * contentAspectRatio;
    CGFloat height = containerRect.size.height;
    if (contentAspectRatio > containerAspectRatio) {
        width = containerRect.size.width;
        height = containerRect.size.width / contentAspectRatio;
    }
    CGFloat x = containerRect.origin.x + (containerRect.size.width - width) / 2.0;
    CGFloat y = containerRect.origin.y + (containerRect.size.height - height) / 2.0;
    
    if( MPLayoutAlgorithmFitTop == self.verticalPosition ) {
        y = containerRect.origin.y;
    } else if( MPLayoutAlgorithmFitBottom == self.verticalPosition ) {
        y = containerRect.origin.y + containerRect.size.height - height;
    }
    
    if( MPLayoutAlgorithmFitLeft == self.horizontalPosition ) {
        x = containerRect.origin.x;
    } else if( MPLayoutAlgorithmFitRight == self.horizontalPosition ) {
        x = containerRect.origin.x + containerRect.size.width - width;
    }
    
    return CGRectMake(x, y, width, height);
}

@end
