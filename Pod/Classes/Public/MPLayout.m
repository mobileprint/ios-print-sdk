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

#import "MPLayout.h"
#import "MPLayoutPaperView.h"

@implementation MPLayout

#pragma mark - Initialization

- (id)initWithOrientation:(MPLayoutOrientation)orientation assetPosition:(CGRect)position;
{
    return [self initWithOrientation:orientation assetPosition:position shouldRotate:YES];
}

- (id)initWithOrientation:(MPLayoutOrientation)orientation assetPosition:(CGRect)position shouldRotate:(BOOL)shouldRotate
{
    self = [super init];
    if (self) {
        _orientation = orientation;
        _assetPosition = CGRectStandardize(position);
        _borderInches = 0.0;
    }
    return self;
}

+ (NSString *)layoutType
{
    return NSStringFromClass([self class]);
}

+ (CGRect)completeFillRectangle
{
    return CGRectMake(0, 0, 100, 100);
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

+ (void)preparePaperView:(MPLayoutPaperView *)paperView withPaper:(MPPaper *)paper
{
    CGFloat referenceWidth = paper.width;
    CGFloat paperAspectRatio = paper.width / paper.height;
    MPLayoutOrientation orientation = [MPLayout paperOrientationForImage:paperView.image andLayout:paperView.layout];
    CGFloat height = 100.0f;
    CGFloat width = height * paperAspectRatio;
    if (MPLayoutOrientationLandscape == orientation) {
        width = 100.f;
        height = width * paperAspectRatio;
        referenceWidth = paper.height;
    }
    paperView.referenceWidthInches = referenceWidth;
    paperView.frame = CGRectMake(0, 0, width, height);
}

+ (void)preparePaperView:(MPLayoutPaperView *)paperView withPaper:(MPPaper *)paper image:(UIImage *)image layout:(MPLayout *)layout
{
    paperView.image = image;
    paperView.layout = layout;
    [self preparePaperView:paperView withPaper:paper];
}

+ (MPLayoutOrientation)paperOrientationForImage:(UIImage *)image andLayout:(MPLayout *)layout
{
    MPLayoutOrientation orientation = MPLayoutOrientationPortrait;
    if (MPLayoutOrientationLandscape == layout.orientation || (MPLayoutOrientationPortrait != layout.orientation && image.size.width > image.size.height)) {
        orientation = MPLayoutOrientationLandscape;
    }
    return orientation;
}

@end
