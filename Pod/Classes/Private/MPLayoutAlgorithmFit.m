//
//  MPLayoutAlgorithmFit.m
//  Pods
//
//  Created by James Trask on 12/9/15.
//
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
