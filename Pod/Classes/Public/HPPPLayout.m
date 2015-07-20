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

#import "HPPPLayout.h"
#import "HPPPLayoutPaperView.h"

@implementation HPPPLayout

#pragma mark - Initialization

- (id)initWithOrientation:(HPPPLayoutOrientation)orientation assetPosition:(CGRect)position allowContentRotation:(BOOL)allowRotation;
{
    self = [super init];
    if (self) {
        _orientation = orientation;
        _assetPosition = CGRectStandardize(position);
        _allowContentRotation = allowRotation;
    }
    return self;
}

+ (CGRect)completeFillRectangle
{
    return CGRectMake(0, 0, 100, 100);
}

- (CGRect)assetPositionForRect:(CGRect)rect
{
    return CGRectMake(
                      rect.origin.x + rect.size.width * self.assetPosition.origin.x / 100.0f,
                      rect.origin.y + rect.size.height * self.assetPosition.origin.y / 100.0f,
                      rect.size.width * self.assetPosition.size.width / 100.0f,
                      rect.size.height * self.assetPosition.size.height / 100.0f);
}

#pragma mark -- Layout

- (void)drawContentImage:(UIImage *)image inRect:(CGRect)rect
{
    NSAssert(NO, @"%@ is intended to be an abstract class", NSStringFromClass(self.class));
}

- (void)layoutContentView:(UIView *)contentView inContainerView:(UIView *)containerView
{
    NSAssert(NO, @"%@ is intended to be an abstract class", NSStringFromClass(self.class)); 
}

- (BOOL)rotationNeededForContent:(CGRect)contentRect withContainer:(CGRect)containerRect
{
    BOOL contentIsSquare = (CGFLOAT_MIN <= (contentRect.size.width - contentRect.size.height));
    BOOL containerIsSquare = (CGFLOAT_MIN <= (containerRect.size.width - containerRect.size.height));
    
    BOOL rotationNeeded = NO;
    if (!contentIsSquare && !containerIsSquare) {
        BOOL contentIsPortrait = (contentRect.size.width < contentRect.size.height);
        BOOL contentIsLandscape = !contentIsPortrait;
        
        BOOL containerIsPortrait = (containerRect.size.width < containerRect.size.height);
        BOOL containerIsLandscape = !containerIsPortrait;
        
        BOOL contentMatchesContainer = ((contentIsPortrait && containerIsPortrait) || (contentIsLandscape && containerIsLandscape));

        if (self.allowContentRotation) {
            if (HPPPLayoutOrientationBestFit == self.orientation) {
                rotationNeeded = !contentMatchesContainer;
            } else if (HPPPLayoutOrientationPortrait == self.orientation || (HPPPLayoutOrientationMatchContainer == self.orientation && containerIsPortrait)) {
                rotationNeeded = containerIsLandscape;
            } else if (HPPPLayoutOrientationLandscape == self.orientation || (HPPPLayoutOrientationMatchContainer == self.orientation && containerIsLandscape)) {
                rotationNeeded = containerIsPortrait;
            }
        }
    }
    
    return rotationNeeded;
}

+ (void)preparePaperView:(HPPPLayoutPaperView *)paperView withPaper:(HPPPPaper *)paper
{
    CGFloat paperAspectRatio = paper.width / paper.height;
    HPPPLayoutOrientation orientation = [HPPPLayout paperOrientationForimage:paperView.image andLayout:paperView.layout];
    CGFloat height = 100.0f;
    CGFloat width = height * paperAspectRatio;
    if (HPPPLayoutOrientationLandscape == orientation) {
        width = 100.f;
        height = width * paperAspectRatio;
    }
    paperView.frame = CGRectMake(0, 0, width, height);
}

+ (void)preparePaperView:(HPPPLayoutPaperView *)paperView withPaper:(HPPPPaper *)paper image:(UIImage *)image layout:(HPPPLayout *)layout
{
    paperView.image = image;
    paperView.layout = layout;
    [self preparePaperView:paperView withPaper:paper];
}

+ (HPPPLayoutOrientation)paperOrientationForimage:(UIImage *)image andLayout:(HPPPLayout *)layout
{
    HPPPLayoutOrientation orientation = HPPPLayoutOrientationPortrait;
    if (HPPPLayoutOrientationLandscape == layout.orientation || (HPPPLayoutOrientationPortrait != layout.orientation && image.size.width > image.size.height)) {
        orientation = HPPPLayoutOrientationLandscape;
    }
    return orientation;
}

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

@end
