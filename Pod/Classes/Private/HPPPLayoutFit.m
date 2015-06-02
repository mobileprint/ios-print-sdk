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

#import "HPPPLayoutFit.h"
#import "UIImage+HPPPResize.h"

@implementation HPPPLayoutFit

- (void)drawContentImage:(UIImage *)image inRect:(CGRect)rect
{
    CGRect containerRect = [self assetPositionForRect:rect];
    CGRect contentRect = CGRectMake(0, 0, image.size.width, image.size.height);
    UIImage *contentImage = image;
    if ([self rotationNeededForContent:contentRect withContainer:containerRect]) {
        contentImage = [image HPPPRotate];
        contentRect = CGRectMake(0, 0, contentImage.size.width, contentImage.size.height);
    }
    [contentImage drawInRect:[self computeRectWithContentRect:contentRect andContainerRect:containerRect]];
}


- (void)layoutContentView:(UIView *)contentView inContainerView:(UIView *)containerView
{
    CGRect containerRect = [self assetPositionForRect:containerView.bounds];
    CGRect contentRect = contentView.bounds;
    if ([self rotationNeededForContent:contentRect withContainer:containerRect]) {
        contentRect = CGRectMake(contentRect.origin.x, contentRect.origin.y, contentRect.size.height, contentRect.size.width);
    }
    
    CGRect contentframe = [self computeRectWithContentRect:contentRect andContainerRect:containerRect];
    
    [self applyConstraintsWithFrame:contentframe toContentView:contentView inContainerView:containerView];
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
    return CGRectMake(x, y, width, height);
}

@end
