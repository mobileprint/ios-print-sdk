//
// Hewlett-Packard Company
// All rights reserved.
//
// This file, its contents, concepts, methods, behavior, and operation
// (collectively the "Software") are protected by trade secret, patent,
// and copyright laws. The use of the Software is governed by a license
// agreement. Disclosure of the Software to third parties, in any form,
// in whole or in part, is expressly prohibited except as authorized by
// the license agreement.
//

#import "UIView+Animation.h"

@implementation UIView (Animation)

- (void)animateConstraintsWithDuration:(NSTimeInterval)duration constraints:(void (^)(void))constraints completion:(void (^)(BOOL finished))completion
{
	NSParameterAssert(constraints);
	
	[self layoutIfNeeded];
	
	constraints();
	
	[UIView animateWithDuration:duration
					 animations:^{
						 [self layoutIfNeeded];
					 }
					 completion:completion];
}

- (UIActivityIndicatorView *)addSpinner
{
    UIActivityIndicatorView *spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    
    [spinner startAnimating];
    
    [spinner setTranslatesAutoresizingMaskIntoConstraints:NO];
    
    [self addSubview:spinner];
    
    [self addConstraints:[NSLayoutConstraint
                          constraintsWithVisualFormat:@"H:|[spinner]|"
                          options:NSLayoutFormatDirectionLeadingToTrailing
                          metrics:nil
                          views:NSDictionaryOfVariableBindings(spinner)]];
    [self addConstraints:[NSLayoutConstraint
                          constraintsWithVisualFormat:@"V:|[spinner]|"
                          options:NSLayoutFormatDirectionLeadingToTrailing
                          metrics:nil
                          views:NSDictionaryOfVariableBindings(spinner)]];
    
    return spinner;
}

@end
