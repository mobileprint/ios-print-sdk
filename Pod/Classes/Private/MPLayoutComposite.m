//
//  MPLayoutComposite.m
//  Pods
//
//  Created by James Trask on 12/9/15.
//
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
