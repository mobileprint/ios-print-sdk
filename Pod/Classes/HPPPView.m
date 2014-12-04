//
//  HPPPView.m
//  Pods
//
//  Created by Andre Gatti on 12/3/14.
//
//

#import "HPPPView.h"

@implementation HPPPView

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        self.backgroundColor = [UIColor blueColor];
    }
    
    return self;
}

-(instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor yellowColor];
    }
    
    return self;
}

@end
