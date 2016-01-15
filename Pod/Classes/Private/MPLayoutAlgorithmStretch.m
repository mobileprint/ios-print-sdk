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

#import "MPLayoutAlgorithmStretch.h"

@implementation MPLayoutAlgorithmStretch

#pragma mark - Layout

- (void)drawImage:(UIImage *)image inContainer:(CGRect)containerRect
{
    [image drawInRect:[self getContainerForImage:image inContainer:containerRect]];
}

- (CGRect)getContainerForImage:(UIImage *)image inContainer:(CGRect)containerRect
{
    return containerRect;
}

- (void)resizeContentView:(UIView *)contentView containerView:(UIView *)containerView contentRect:(CGRect)contentRect containerRect:(CGRect)containerRect
{
    [self applyConstraintsWithFrame:containerRect toContentView:contentView inContainerView:containerView];
}

@end
