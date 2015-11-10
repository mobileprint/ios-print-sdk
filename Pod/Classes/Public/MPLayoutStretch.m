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

#import "MPLayoutStretch.h"
#import "UIImage+MPResize.h"

@implementation MPLayoutStretch

- (void)drawContentImage:(UIImage *)image inRect:(CGRect)rect
{
    UIImage *contentImage = image;
    CGRect contentRect = CGRectMake(0, 0, image.size.width, image.size.height);
    CGRect containerRect = [self assetPositionForRect:rect];
    if ([self rotationNeededForContent:contentRect withContainer:containerRect]) {
        contentImage = [image MPRotate];
    }
    [contentImage drawInRect:containerRect];
}

- (void)layoutContentView:(UIView *)contentView inContainerView:(UIView *)containerView
{
    CGRect contentRect = [self assetPositionForRect:containerView.bounds];
    [self applyConstraintsWithFrame:contentRect toContentView:contentView inContainerView:containerView];
}

@end
