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
    NSDictionary *userInfo = notification.userInfo;

    CGFloat height = self.textField.frame.size.height;
    
    // Start and end frame positions for the traditional keyboard
    CGRect startFrame;
    CGRect endFrame;
    [[userInfo valueForKey:UIKeyboardFrameBeginUserInfoKey] getValue:&startFrame];
    [[userInfo valueForKey:UIKeyboardFrameEndUserInfoKey] getValue:&endFrame];
    
    // The animations to perform
    void (^animations)() = ^() {
        if( endFrame.origin.y < startFrame.origin.y ) {
            self.textField.frame = CGRectMake(18, 20, self.bounds.size.width-36, height);
            self.textField.alpha = 1.0F;
        } else {
            self.textField.frame = CGRectMake(18, self.frame.size.height, self.bounds.size.width-36, height);
        }
    };
    
    // Perform the animations on the traditonal keyboard's animation curve and duration
    NSNumber *durationValue = userInfo[UIKeyboardAnimationDurationUserInfoKey];
    NSNumber *curveValue = userInfo[UIKeyboardAnimationCurveUserInfoKey];
    NSTimeInterval animationDuration = durationValue.doubleValue;
    UIViewAnimationCurve animationCurve = curveValue.intValue;
    [UIView animateWithDuration:animationDuration
                          delay:0.0
                        options:(animationCurve << 16)
                     animations:animations
                     completion:nil];
}

@end
