//
//  MPLayoutAlgorithm.m
//  Pods
//
//  Created by James Trask on 12/9/15.
//
//

#import "MPLayoutAlgorithm.h"

@implementation MPLayoutAlgorithm

- (id)initWithLayout:(MPLayout *)layout
{
    self =[super init];
    
    if (self) {
        _layout = layout;
    }
    
    return self;
}

- (void)drawImage:(UIImage *)image inContainer:(CGRect)containerRect
{
    NSAssert(NO, @"%@ is intended to be an abstract class", NSStringFromClass(self.class));
}

@end
