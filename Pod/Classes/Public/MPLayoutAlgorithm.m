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

#import "MPLayoutAlgorithm.h"

@implementation MPLayoutAlgorithm

#pragma mark - Layout

- (void)drawImage:(UIImage *)image inContainer:(CGRect)containerRect
{
    NSAssert(NO, @"%@ is intended to be an abstract class", NSStringFromClass(self.class));
}

- (CGRect)getContainerForImage:(UIImage *)image inContainer:(CGRect)containerRect
{
    NSAssert(NO, @"%@ is intended to be an abstract class", NSStringFromClass(self.class));
    
    return CGRectMake(0.0, 0.0, 0.0, 0.0);
}

- (void)resizeContentView:(UIView *)contentView containerView:(UIView *)containerView contentRect:(CGRect)contentRect containerRect:(CGRect)containerRect
{
    NSAssert(NO, @"%@ is intended to be an abstract class", NSStringFromClass(self.class));
}

#pragma mark - Computation

- (void)applyConstraintsWithFrame:(CGRect)frame toContentView:(UIView *)contentView inContainerView:(UIView *)containerView
{
    contentView.autoresizingMask = UIViewAutoresizingNone;
    [contentView setTranslatesAutoresizingMaskIntoConstraints:NO];
    
    NSMutableArray *contentConstraints = [NSMutableArray arrayWithArray:contentView.constraints];
    for (NSLayoutConstraint *constraint in containerView.constraints) {
        if (constraint.firstItem == contentView || constraint.secondItem == contentView) {
            [contentConstraints addObject:constraint];
        }
    }
    
    if ([NSLayoutConstraint respondsToSelector:@selector(deactivateConstraints:)]) {
        [NSLayoutConstraint deactivateConstraints:contentConstraints];
    } else {
        [containerView removeConstraints:contentConstraints];
    }
    
    
    [contentView removeConstraints:contentView.constraints];
    [containerView removeConstraints:containerView.constraints];
    
    NSDictionary *views = @{ @"contentView":contentView, @"containerView":containerView };
    NSDictionary *values = @{
                             @"x":[NSNumber numberWithFloat:frame.origin.x],
                             @"y":[NSNumber numberWithFloat:frame.origin.y],
                             @"width":[NSNumber numberWithFloat:frame.size.width],
                             @"height":[NSNumber numberWithFloat:frame.size.height]
                             };
    
    NSArray *horizontalConstraints = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-x-[contentView(width)]" options:0 metrics:values views:views];
    NSArray *verticalConstraints = [NSLayoutConstraint constraintsWithVisualFormat:@"V:|-y-[contentView(height)]" options:0 metrics:values views:views];
    contentConstraints = [NSMutableArray arrayWithArray:horizontalConstraints];
    [contentConstraints addObjectsFromArray:verticalConstraints];
    
    if ([NSLayoutConstraint respondsToSelector:@selector(activateConstraints:)]) {
        [NSLayoutConstraint activateConstraints:contentConstraints];
    } else {
        [containerView addConstraints:contentConstraints];
    }
    
    [containerView setNeedsUpdateConstraints];
    [containerView updateConstraintsIfNeeded];
    [contentView setNeedsLayout];
    [contentView setNeedsDisplay];
    [containerView setNeedsLayout];
    [containerView layoutIfNeeded];
}

#pragma mark - NSCoding interface

- (void)encodeWithCoder:(NSCoder *)encoder
{
}

- (id)initWithCoder:(NSCoder *)decoder
{
    return [super init];
}

@end
