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

#import "MPLayoutFill.h"
#import "MPLogger.h"
#import "MPLayoutPrepStepRotate.h"
#import "MPLayoutAlgorithmFill.h"

@interface MPLayoutComposite (protected)

@property (strong, nonatomic) MPLayoutAlgorithm *algorithm;

@end

@interface MPLayoutFill()

@property (strong, nonatomic, readonly) MPLayoutPrepStepRotate *rotateStep;

@end

@implementation MPLayoutFill

- (id)initWithOrientation:(MPLayoutOrientation)orientation assetPosition:(CGRect)position;
{
    if (!CGRectEqualToRect(position, [MPLayout completeFillRectangle])) {
        MPLogError(@"The MPLayoutFill layout type only supports the complete fill asset position");
    }
    
    _rotateStep = [[MPLayoutPrepStepRotate alloc] initWithOrientation:orientation];
    MPLayoutAlgorithmFill *algorithm = [[MPLayoutAlgorithmFill alloc] init];
    return self = [super initWithAlgorithm:algorithm andPrepSteps:@[_rotateStep]];
}

- (CGRect)assetPosition
{
    return [MPLayout completeFillRectangle];
}

- (MPLayoutOrientation)orientation
{
    return self.rotateStep.orientation;
}

- (void)setBorderInches:(float)borderInches
{
    if (borderInches != 0) {
        // Have to disable border support until cropping with scaled image can be figured out -- jbt 10/13/15
        MPLogError(@"The MPLayoutFill layout type does not support non-zero border. The border specified will be ignored (%.1f).", borderInches);
    }

    [super setBorderInches:0];
}

@end
