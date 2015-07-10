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
@property (weak, nonatomic) IBOutlet UITextField *textField;

@end

@implementation HPPPKeyboardView

- (void)initWithXibName:(NSString *)xibName
{
    [super initWithXibName:xibName];
    
    self.textField.delegate = self;
}

#pragma mark - HPPPEditView implementation

- (void)prepareForDisplay:(NSString *)initialText
{
    self.textField.text = initialText;
    self.textField.alpha = 0.0F;

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillMove:) name:UIKeyboardWillChangeFrameNotification object:nil];
}

- (void)beginEditing {
    [self.textField becomeFirstResponder];
}

- (void)cancelEditing {
    [[NSNotificationCenter defaultCenter] removeObserver:self];

    [self.textField resignFirstResponder];
}

- (void)commitEditing
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];

    if( self.delegate  &&  [self.delegate respondsToSelector:@selector(didFinishEnteringText:text:)]) {
        [self.delegate didFinishEnteringText:self text:self.textField.text];
    }

    [self.textField resignFirstResponder];
}

#pragma mark - Keyboard handlers

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [self commitEditing];
    
    return FALSE;
}

-(void) keyboardWillMove:(NSNotification *)notification
{
    CGFloat height = self.textField.frame.size.height;
    
    CGRect startFrame;
    CGRect endFrame;
    NSTimeInterval animationDuration;
    [[[notification userInfo] valueForKey:UIKeyboardFrameBeginUserInfoKey] getValue:&startFrame];
    [[[notification userInfo] valueForKey:UIKeyboardFrameEndUserInfoKey] getValue:&endFrame];
    [[[notification userInfo] objectForKey:UIKeyboardAnimationDurationUserInfoKey] getValue:&animationDuration];
    
    if( endFrame.origin.y < startFrame.origin.y ) {
        [UIView animateWithDuration:animationDuration animations:^{
            self.textField.frame = CGRectMake(18, 20, self.bounds.size.width-36, height);
            self.textField.alpha = 1.0F;
        }];
    } else {
        [UIView animateWithDuration:animationDuration animations:^{
            self.textField.frame = CGRectMake(18, self.frame.size.height, self.bounds.size.width-36, height);
        }];
    }
}

@end
