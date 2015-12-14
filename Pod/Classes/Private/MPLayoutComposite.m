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

#import "MPLayoutComposite.h"

@interface MPLayoutComposite()

@property (strong, nonatomic) MPLayoutAlgorithm *algorithm;
@property (strong, nonatomic) NSArray<MPLayoutPrepStep *> *prepSteps;

@end

@implementation MPLayoutComposite

- (id)initWithAlgorithm:(MPLayoutAlgorithm *)algorithm andPrepSteps:(NSArray<MPLayoutPrepStep *> *)prepSteps
{
    self = [super init];
    
    if (self) {
        self.algorithm = algorithm;
        self.prepSteps = prepSteps;
    }
    
    return self;
}

- (void)drawContentImage:(UIImage *)image inRect:(CGRect)rect
{
    UIImage *layoutImage = image;
    CGRect layoutContainer = rect;
    for (MPLayoutPrepStep *step in self.prepSteps) {
        UIImage *newImage = [step imageForImage:layoutImage inContainer:layoutContainer];
        CGRect newContainer = [step containerForImage:layoutImage inContainer:layoutContainer];
        layoutImage = newImage;
        layoutContainer = newContainer;
    }
    
    [self.algorithm drawImage:layoutImage inContainer:layoutContainer];
}

@end
