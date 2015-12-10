//
//  MPLayoutComposite.h
//  Pods
//
//  Created by James Trask on 12/9/15.
//
//

#import "MPLayoutPrepStep.h"
#import "MPLayoutAlgorithm.h"

@interface MPLayoutComposite : MPLayout

- (id)initWithAlgorithm:(MPLayoutAlgorithm *)algorithm andPrepSteps:(NSArray<MPLayoutPrepStep *> *)prepSteps;

@end
