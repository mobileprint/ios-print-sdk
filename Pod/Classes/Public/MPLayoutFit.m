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
    _adjustStep = [[MPLayoutPrepStepAdjust alloc] initWithAdjustment:position];
    _rotateStep = [[MPLayoutPrepStepRotate alloc] initWithOrientation:orientation];
    MPLayoutAlgorithmFit *algorithm = [[MPLayoutAlgorithmFit alloc] init];
    _horizontalPosition = algorithm.horizontalPosition;
    _verticalPosition = algorithm.verticalPosition;
    return self = [super initWithAlgorithm:algorithm andPrepSteps:@[_adjustStep, _rotateStep]];
}

- (CGRect)assetPosition
{
    return self.adjustStep.adjustment;
}

- (MPLayoutOrientation)orientation
{
    return self.rotateStep.orientation;
}

- (void)setHorizontalPosition:(MPLayoutHorizontalPosition)horizontalPosition
{
    _horizontalPosition = horizontalPosition;
    MPLayoutAlgorithmFit *algorithm = [[MPLayoutAlgorithmFit alloc] initWithHorizontalPosition:_horizontalPosition andVerticalPosition:_verticalPosition];
    self.algorithm = algorithm;
}

- (void)setVeritcalPosition:(MPLayoutVerticalPosition)verticalPosition
{
    _verticalPosition = verticalPosition;
    MPLayoutAlgorithmFit *algorithm = [[MPLayoutAlgorithmFit alloc] initWithHorizontalPosition:_horizontalPosition andVerticalPosition:_verticalPosition];
    self.algorithm = algorithm;
}

@end
