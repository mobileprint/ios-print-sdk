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
#import "MPLayoutPrepStepAdjust.h"
#import "MPLayoutPrepStepRotate.h"
#import "MPLayoutAlgorithmStretch.h"

@interface MPLayoutStretch()

@property (strong, nonatomic, readonly) MPLayoutPrepStepAdjust *adjustStep;
@property (strong, nonatomic, readonly) MPLayoutPrepStepRotate *rotateStep;

@end

@implementation MPLayoutStretch

- (id)initWithOrientation:(MPLayoutOrientation)orientation assetPosition:(CGRect)position;
{
    return [self initWithOrientation:orientation assetPosition:position shouldRotate:YES];
}

- (id)initWithOrientation:(MPLayoutOrientation)orientation assetPosition:(CGRect)position shouldRotate:(BOOL)shouldRotate
{
    MPLayoutAlgorithmStretch *algorithm = [[MPLayoutAlgorithmStretch alloc] init];
    
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

@end
