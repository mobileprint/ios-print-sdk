//
//  MPLayoutPrepStep.m
//  Pods
//
//  Created by James Trask on 12/9/15.
//
//

#import "MPLayoutPrepStep.h"

@implementation MPLayoutPrepStep

- (id)initWithLayout:(MPLayout *)layout
{
    self = [super init];
    
    if (self) {
        _layout = layout;
    }
    
    return self;
}

- (UIImage *)imageForImage:(UIImage *)image inContainer:(CGRect)containerRect
{
    NSAssert(NO, @"%@ is intended to be an abstract class", NSStringFromClass(self.class));
    return nil;
}

- (CGRect)containerForImage:(UIImage *)image inContainer:(CGRect)containerRect
{
    NSAssert(NO, @"%@ is intended to be an abstract class", NSStringFromClass(self.class));
    return CGRectZero;
}

@end
