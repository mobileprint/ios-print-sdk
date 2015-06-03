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

#import "HPPPLayoutFill.h"
#import "UIImage+HPPPResize.h"

@implementation HPPPLayoutFill

- (void)drawContentImage:(UIImage *)image inRect:(CGRect)rect
{
    CGRect containerRect = [self assetPositionForRect:rect];
    CGRect contentRect = CGRectMake(0, 0, image.size.width, image.size.height);
    UIImage *contentImage = image;
    if ([self rotationNeededForContent:contentRect withContainer:containerRect]) {
        contentImage = [image HPPPRotate];
        contentRect = CGRectMake(0, 0, contentImage.size.width, contentImage.size.height);
    }
    
    CGRect croppingRect  = [self computeCroppingRectWithContentRect:contentRect andContainerRect:containerRect];
    CGImageRef imageRef = CGImageCreateWithImageInRect([contentImage CGImage], croppingRect);
    UIImage *croppedImage   = [UIImage imageWithCGImage:imageRef];
    CGImageRelease(imageRef);
    
    [croppedImage drawInRect:containerRect];
}

- (void)layoutContentView:(UIView *)contentView inContainerView:(UIView *)containerView
{
    CGRect containerRect = [self assetPositionForRect:containerView.bounds];
    CGRect contentRect = contentView.bounds;
    if ([self rotationNeededForContent:contentRect withContainer:containerRect]) {
        contentRect = CGRectMake(contentRect.origin.x, contentRect.origin.y, contentRect.size.height, contentRect.size.width);
    }
    
    CGRect layoutRect = [self computeLayoutRectWithContentRect:contentRect andContainerRect:containerRect];
    [self applyConstraintsWithFrame:layoutRect toContentView:contentView inContainerView:containerView];
    [self maskContentView:contentView withContainerRect:(CGRect)containerRect];
}

- (CGRect)computeCroppingRectWithContentRect:(CGRect)contentRect andContainerRect:(CGRect)containerRect
{
    CGFloat contentAspectRatio = contentRect.size.width / contentRect.size.height;
    CGFloat containerAspectRatio = containerRect.size.width / containerRect.size.height;
    CGFloat scale = containerRect.size.width / contentRect.size.width;
    if (contentAspectRatio > containerAspectRatio) {
        scale = containerRect.size.height / contentRect.size.height;
    }
    CGFloat width = contentRect.size.width * scale;
    CGFloat height = contentRect.size.height * scale;
    CGFloat x = (width - containerRect.size.width) / 2.0 / scale;
    CGFloat y = (height - containerRect.size.height) / 2.0 / scale;
    width = contentRect.size.width;
    height = containerRect.size.height / scale;
    if (contentAspectRatio > containerAspectRatio) {
        width = containerRect.size.width / scale;
        height = contentRect.size.height;
    }
    return CGRectMake(x, y, width, height);
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

// The following was adapted from:  http://stackoverflow.com/questions/11391058/simply-mask-a-uiview-with-a-rectangle
- (void)maskContentView:(UIView *)contentView withContainerRect:(CGRect)containerRect
{
    CGRect clippingRect = CGRectMake(containerRect.origin.x - contentView.frame.origin.x, containerRect.origin.y - contentView.frame.origin.y, containerRect.size.width, containerRect.size.height);
    CAShapeLayer *maskLayer = [[CAShapeLayer alloc] init];
    CGPathRef path = CGPathCreateWithRect(clippingRect, NULL);
    maskLayer.path = path;
    CGPathRelease(path);
    contentView.layer.mask = maskLayer;
}

@end
