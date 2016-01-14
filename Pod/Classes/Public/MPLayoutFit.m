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
#import "MPLayoutPrepStepAdjust.h"
#import "MPLayoutPrepStepRotate.h"
#import "MPLayoutAlgorithmFit.h"

@interface MPLayoutComposite (protected)

@property (strong, nonatomic) MPLayoutAlgorithm *algorithm;

@end

@interface MPLayoutFit()

@property (strong, nonatomic, readonly) MPLayoutPrepStepAdjust *adjustStep;
@property (strong, nonatomic, readonly) MPLayoutPrepStepRotate *rotateStep;

@end

@implementation MPLayoutFit

- (id)initWithOrientation:(MPLayoutOrientation)orientation assetPosition:(CGRect)position;
{
    return [self initWithOrientation:orientation assetPosition:position shouldRotate:YES];
}

- (id)initWithOrientation:(MPLayoutOrientation)orientation assetPosition:(CGRect)position shouldRotate:(BOOL)shouldRotate
{
    MPLayoutAlgorithmFit *algorithm = [[MPLayoutAlgorithmFit alloc] init];
    
    _adjustStep = [[MPLayoutPrepStepAdjust alloc] initWithAdjustment:position];
    _rotateStep = [[MPLayoutPrepStepRotate alloc] initWithOrientation:orientation];
    NSArray *prepSteps = shouldRotate ? @[ _adjustStep, _rotateStep ] : @[ _adjustStep ];
    
    return self = [super initWithAlgorithm:algorithm andPrepSteps:prepSteps];
}

- (CGRect)assetPosition
{
    return self.adjustStep.adjustment;
}

- (MPLayoutOrientation)orientation
{
    return self.rotateStep.orientation;
}

#pragma mark - Position properties

- (MPLayoutHorizontalPosition)horizontalPosition
{
    MPLayoutAlgorithmFit *fitAlgorithm = (MPLayoutAlgorithmFit *)self.algorithm;
    return fitAlgorithm.horizontalPosition;
}

- (void)setHorizontalPosition:(MPLayoutHorizontalPosition)horizontalPosition
{
    MPLayoutAlgorithmFit *currentAlgorithm = (MPLayoutAlgorithmFit *)self.algorithm;
    MPLayoutAlgorithmFit *newAlgorithm = [[MPLayoutAlgorithmFit alloc] initWithHorizontalPosition:horizontalPosition andVerticalPosition:currentAlgorithm.verticalPosition];
    self.algorithm = newAlgorithm;
}

- (MPLayoutVerticalPosition)verticalPosition
{
    MPLayoutAlgorithmFit *fitAlgorithm = (MPLayoutAlgorithmFit *)self.algorithm;
    return fitAlgorithm.verticalPosition;
}

- (void)setVerticalPosition:(MPLayoutVerticalPosition)verticalPosition
{
    MPLayoutAlgorithmFit *currentAlgorithm = (MPLayoutAlgorithmFit *)self.algorithm;
    MPLayoutAlgorithmFit *newAlgorithm = [[MPLayoutAlgorithmFit alloc] initWithHorizontalPosition:currentAlgorithm.horizontalPosition andVerticalPosition:verticalPosition];
    self.algorithm = newAlgorithm;
}

#pragma mark - Rotation handling

- (MPLayoutAlgorithm *)prepareAlgorithm:(UIImage *)image inRect:(CGRect)rect
{
    MPLayoutAlgorithmFit *originalAlgorithm = (MPLayoutAlgorithmFit *)self.algorithm;
    MPLayoutHorizontalPosition rotatedHorizontalPosition = [self rotatedVerticalPosition:self.verticalPosition];
    MPLayoutVerticalPosition rotatedVerticalPosition = [self rotatedHorizontalPosition:self.horizontalPosition];
    MPLayoutAlgorithmFit *rotatedAlgortihm = [[MPLayoutAlgorithmFit alloc] initWithHorizontalPosition:rotatedHorizontalPosition andVerticalPosition:rotatedVerticalPosition];
    
    [self.rotateStep imageForImage:image inContainer:rect];
    if (self.rotateStep.rotated) {
        self.algorithm = rotatedAlgortihm;
    }
    
    return originalAlgorithm;
}

- (void)drawContentImage:(UIImage *)image inRect:(CGRect)rect
{
    MPLayoutAlgorithm *originalAlgorithm = [self prepareAlgorithm:image inRect:rect];
    [super drawContentImage:image inRect:rect];
    self.algorithm = originalAlgorithm;
}

- (CGRect)contentImageLocation:(UIImage *)image inRect:(CGRect)rect
{
    MPLayoutAlgorithm *originalAlgorithm = [self prepareAlgorithm:image inRect:rect];
    CGRect layoutContainer = [super contentImageLocation:image inRect:rect];
    self.algorithm = originalAlgorithm;
    
    return layoutContainer;
}

- (void)layoutContentView:(UIView *)contentView inContainerView:(UIView *)containerView
{
    MPLayoutAlgorithmFit *originalAlgorithm = (MPLayoutAlgorithmFit *)self.algorithm;
    MPLayoutHorizontalPosition rotatedHorizontalPosition = [self rotatedVerticalPosition:self.verticalPosition];
    MPLayoutVerticalPosition rotatedVerticalPosition = [self rotatedHorizontalPosition:self.horizontalPosition];
    MPLayoutAlgorithmFit *rotatedAlgortihm = [[MPLayoutAlgorithmFit alloc] initWithHorizontalPosition:rotatedHorizontalPosition andVerticalPosition:rotatedVerticalPosition];
    
    [self.rotateStep contentRectForContent:contentView.bounds inContainer:containerView.bounds];
    if (self.rotateStep.rotated) {
        self.algorithm = rotatedAlgortihm;
    }
    
    [super layoutContentView:contentView inContainerView:containerView];
    
    self.algorithm = originalAlgorithm;
}

- (MPLayoutHorizontalPosition)rotatedVerticalPosition:(MPLayoutVerticalPosition)verticalPosition
{
    MPLayoutHorizontalPosition rotatedPosition = MPLayoutHorizontalPositionMiddle;
    if (MPLayoutVerticalPositionTop == verticalPosition) {
        rotatedPosition = MPLayoutHorizontalPositionLeft;
    } else if (MPLayoutVerticalPositionBottom == verticalPosition) {
        rotatedPosition = MPLayoutHorizontalPositionRight;
    }
    return rotatedPosition;
}

- (MPLayoutVerticalPosition)rotatedHorizontalPosition:(MPLayoutHorizontalPosition)horizontalPosition
{
    MPLayoutVerticalPosition rotatedPosition = MPLayoutVerticalPositionMiddle;
    if (MPLayoutHorizontalPositionLeft == horizontalPosition) {
        rotatedPosition = MPLayoutVerticalPositionBottom;
    } else if (MPLayoutHorizontalPositionRight == horizontalPosition) {
        rotatedPosition = MPLayoutVerticalPositionTop;
    }
    return rotatedPosition;
}

@end
