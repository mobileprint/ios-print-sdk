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

#pragma mark - Layout

- (void)drawImage:(UIImage *)image inContainer:(CGRect)containerRect
{
    CGRect computedRect = [self getContainerForImage:image inContainer:containerRect];
    
    MPLogDebug(@"~~~~~~~~~~~~~~~~~~~~~");
    MPLogDebug(@"LAYOUT ALGORITHM FILL");
    MPLogDebug(@"~~~~~~~~~~~~~~~~~~~~~");
    [[MPLogger sharedInstance] logSize:image.size withName:@"IMAGE"];
    [[MPLogger sharedInstance] logRect:containerRect withName:@"CONTAINER"];
    [[MPLogger sharedInstance] logRect:computedRect withName:@"LAYOUT"];
    MPLogDebug(@"~~~~~~~~~~~~~~~~~~~~~");
    
    [image drawInRect:computedRect];
}

- (CGRect)getContainerForImage:(UIImage *)image inContainer:(CGRect)containerRect
{
    CGRect contentRect = CGRectMake(0, 0, image.size.width, image.size.height);
    return [self computeLayoutRectWithContentRect:contentRect andContainerRect:containerRect];
}

- (void)resizeContentView:(UIView *)contentView containerView:(UIView *)containerView contentRect:(CGRect)contentRect containerRect:(CGRect)containerRect
{
    CGRect layoutRect = [self computeLayoutRectWithContentRect:contentRect andContainerRect:containerRect];
    [self applyConstraintsWithFrame:layoutRect toContentView:contentView inContainerView:containerView];
    [self maskContentView:contentView withContainerRect:(CGRect)containerRect];
}

#pragma mark - Computation

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
