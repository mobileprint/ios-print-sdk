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

#import "MPView.h"
#import "MP.h"

@implementation MPView

- (id)init
{
    self = [super init];
    if (self) {
        [self initWithXibName:[self xibName]];
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self initWithXibName:[self xibName]];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self initWithXibName:[self xibName]];
    }
    
    return self;
}

- (void)initWithXibName:(NSString *)xibName
{
    UIView *containerView = [[[NSBundle bundleForClass:[MP class]] loadNibNamed:xibName owner:self options:nil] lastObject];
    
    [containerView setTranslatesAutoresizingMaskIntoConstraints:NO];
    
    [self addSubview:containerView];
    
    [self addConstraints:[NSLayoutConstraint
                          constraintsWithVisualFormat:@"H:|[containerView]|"
                          options:NSLayoutFormatDirectionLeadingToTrailing
                          metrics:nil
                          views:NSDictionaryOfVariableBindings(containerView)]];
    [self addConstraints:[NSLayoutConstraint
                          constraintsWithVisualFormat:@"V:|[containerView]|"
                          options:NSLayoutFormatDirectionLeadingToTrailing
                          metrics:nil
                          views:NSDictionaryOfVariableBindings(containerView)]];
    self.backgroundColor = [UIColor clearColor];
}

- (NSString *)xibName
{
    return NSStringFromClass(self.class);
}


@end
