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

#import "MPLayoutFit.h"
#import "UIImage+MPResize.h"

@implementation MPLayoutFit

NSString * const kMPLayoutHorizontalPositionKey = @"kMPLayoutHorizontalPositionKey";
NSString * const kMPLayoutVerticalPositionKey = @"kMPLayoutVerticalPositionKey";

- (id)initWithOrientation:(MPLayoutOrientation)orientation assetPosition:(CGRect)position;
{
    self = [super initWithOrientation:orientation assetPosition:position];
    if (self) {
        _horizontalPosition = MPLayoutHorizontalPositionMiddle;
        _verticalPosition = MPLayoutVerticalPositionMiddle;
    }
    return self;
}

- (void)drawContentImage:(UIImage *)image inRect:(CGRect)rect
{
    CGRect containerRect = [self assetPositionForRect:rect];
    CGRect contentRect = CGRectMake(0, 0, image.size.width, image.size.height);
    UIImage *contentImage = image;
    if ([self rotationNeededForContent:contentRect withContainer:containerRect]) {
        contentImage = [image MPRotate];
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
    
    if( MPLayoutVerticalPositionTop == self.verticalPosition ) {
        y = containerRect.origin.y;
    } else if( MPLayoutVerticalPositionBottom == self.verticalPosition ) {
        y = containerRect.origin.y + containerRect.size.height - height;
    }
    
    if( MPLayoutHorizontalPositionLeft == self.horizontalPosition ) {
        x = containerRect.origin.x;
    } else if( MPLayoutHorizontalPositionRight == self.horizontalPosition ) {
        x = containerRect.origin.x + containerRect.size.width - width;
    }
    
    return CGRectMake(x, y, width, height);
}

@end
