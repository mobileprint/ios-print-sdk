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

#import "HPPPKeyboardView.h"

@interface HPPPKeyboardView () <UITextFieldDelegate>

@property (strong, nonatomic) IBOutlet UIView *containingView;
@property (weak, nonatomic) IBOutlet UIView *smokeyView;
@property (weak, nonatomic) IBOutlet UITextField *textField;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *smokeyViewHeightConstraint;

@end

@implementation HPPPKeyboardView

//TODO: As you can see, this view needs some work
// - No microphone button next to the text field
// - text field is too wide
// - no "check" icon on the return button
// - ... I'm sure you'll find more items 

- (void)initWithXibName:(NSString *)xibName
{
    [super initWithXibName:xibName];
    
    self.textField.delegate = self;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillHideNotification object:nil];
}

- (void)displayKeyboard
{
    [self.textField becomeFirstResponder];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [self finishEditing];
    
    return FALSE;
}

- (void)finishEditing
{
    if( self.delegate  &&  [self.delegate respondsToSelector:@selector(didFinishEnteringText:text:)]) {
        [self.delegate didFinishEnteringText:self text:self.textField.text];
        [self.textField resignFirstResponder];
    }
}

-(void) keyboardWillShow:(NSNotification*)notification {
    
    CGFloat height = self.textField.frame.size.height;
    
    CGRect endFrame;
    NSTimeInterval animationDuration;
    [[[notification userInfo] valueForKey:UIKeyboardFrameEndUserInfoKey] getValue:&endFrame];
    [[[notification userInfo] objectForKey:UIKeyboardAnimationDurationUserInfoKey] getValue:&animationDuration];
    
    endFrame = [self convertRect:endFrame fromView:nil];
    float y = (endFrame.origin.y > self.bounds.size.height ? self.bounds.size.height-height : endFrame.origin.y-height);
    
    [UIView animateWithDuration:animationDuration animations:^{
        self.textField.frame = CGRectMake(0, y, self.bounds.size.width, height);
    }];
}

@end
