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

#import "HPPPPageRangeView.h"
#import "HPPPPageRange.h"
#import "UIColor+HPPPStyle.h"

@interface HPPPPageRangeView () <UITextFieldDelegate>

@property (strong, nonatomic) IBOutlet UIView *containingView;
@property (weak, nonatomic) IBOutlet UITextField *textField;
@property (strong, nonatomic) NSMutableArray *buttons;
@property (strong, nonatomic) NSString *pageRange;
@property (strong, nonatomic) UIView *buttonContainer;
@property (assign, nonatomic) int buttonContainerOriginY;

@end

@implementation HPPPPageRangeView

static NSString *kBackButtonText = @"⌫";
static NSString *kCheckButtonText = @"Done";//@"✔︎";
static NSString *kAllButtonText = @"ALL";
static NSString *kAllPagesIndicator = @"";
static NSString *kPlaceholderText = @"e.g. 1,3-5";

- (void)initWithXibName:(NSString *)xibName
{
    [super initWithXibName:xibName];
    
    self.textField.delegate = self;
    self.textField.placeholder = kPlaceholderText;
}

- (void)dealloc
{
    [self removeButtons];
}

- (void)addButtons
{
    UIView *dummyView = [[UIView alloc] initWithFrame:CGRectMake(self.frame.size.width, self.frame.size.height, 1, 1)];
    self.textField.inputView = dummyView; // Hide keyboard, but show blinking cursor

    [self removeButtons];
    
    int buttonWidth = self.frame.size.width/4 + 1;
    int buttonHeight = .8 * buttonWidth;
    self.buttonContainerOriginY = self.frame.size.height - (4*buttonHeight);

    self.buttonContainer = [[UIView alloc] initWithFrame:CGRectMake(0, self.buttonContainerOriginY, self.frame.size.width, self.frame.size.height - self.buttonContainerOriginY)];
    [self addSubview:self.buttonContainer];
    
    NSArray *buttonTitles = @[@"1", @"2", @"3", kBackButtonText, @"4", @"5", @"6", @",", @"7", @"8", @"9", @"-", @"0", kAllButtonText, kCheckButtonText];
    
    int yOrigin = 0;
    for( int i = 0, buttonOffset = 0; i<[buttonTitles count]; i++ ) {
        NSString *buttonText = [buttonTitles objectAtIndex:i];
        int row = (int)(i/4);
        int col = i%4;

        UIButton *button = [UIButton buttonWithType:UIButtonTypeSystem];
        [button setTitle:buttonText forState:UIControlStateNormal];
        [button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        button.titleLabel.font = [UIFont fontWithName:@"Helvetica Neue" size:24];
        [button layer].borderWidth = 1.0f;
        [button layer].borderColor = [UIColor lightGrayColor].CGColor;
        button.backgroundColor = [UIColor whiteColor];
        [button addTarget:self action:@selector(onButtonDown:) forControlEvents:UIControlEventTouchUpInside];

        if( [buttonText isEqualToString:[kAllButtonText copy]] ) {
            button.frame = CGRectMake(col*buttonWidth, yOrigin + (row*buttonHeight), buttonWidth*2, buttonHeight);
            buttonOffset++;
        } else {
            if( [buttonText isEqualToString:[kCheckButtonText copy]] ) {
                button.backgroundColor = [UIColor HPPPHPBlueColor];
                [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            }
            button.frame = CGRectMake((col+buttonOffset)*buttonWidth, yOrigin + (row*buttonHeight), buttonWidth, buttonHeight);
        }
        
        // Make sure we have at least a 1 pixel margin on the right side.
        if( button.frame.origin.x + button.frame.size.width >= self.frame.size.width ) {
            CGRect frame = button.frame;
            int diff = (button.frame.origin.x + button.frame.size.width) - self.frame.size.width;
            frame.size.width -= diff;
            button.frame = frame;
        }

        [self.buttonContainer addSubview:button];
        
        [self.buttons addObject:button];
    }
    
    // now place the button container out of view
    CGRect frame = self.buttonContainer.frame;
    frame.origin.y = self.frame.size.height;
    self.buttonContainer.frame = frame;
}

- (void)removeButtons
{
    for( UIButton *button in self.buttons ) {
        [button removeFromSuperview];
    }
    
    [self.buttonContainer removeFromSuperview];
}

#pragma mark - HPPPEditView implementation

- (void)prepareForDisplay:(NSString *)initialText
{
    [self addButtons];

    if( NSOrderedSame == [initialText caseInsensitiveCompare:kAllButtonText] ) {
        self.pageRange = kAllPagesIndicator;
    } else {
        self.pageRange = initialText;
    }

    self.textField.alpha = 0.0F;
    self.textField.text = self.pageRange;

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillMove:) name:UIKeyboardWillChangeFrameNotification object:nil];
}

- (void)beginEditing
{
    UITextPosition *newPosition = [self.textField positionFromPosition:0 offset:self.textField.text.length];
    self.textField.selectedTextRange = [self.textField textRangeFromPosition:newPosition toPosition:newPosition];
    
    [self.textField becomeFirstResponder];
}

- (void)cancelEditing
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    self.textField.text = self.pageRange;
    
    [self.textField resignFirstResponder];
}

- (void)commitEditing
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];

    NSString *cleanPageRange = [HPPPPageRange cleanPageRange:self.textField.text allPagesIndicator:kAllButtonText maxPageNum:self.maxPageNum];

    if( self.delegate  &&  [self.delegate respondsToSelector:@selector(didSelectPageRange:pageRange:)]) {
        [self.delegate didSelectPageRange:self pageRange:cleanPageRange];
    }

    [self.textField resignFirstResponder];
    self.pageRange = cleanPageRange;
}

#pragma mark - Button handler

- (IBAction)onButtonDown:(UIButton *)button
{
    if( [kBackButtonText isEqualToString:button.titleLabel.text] ) {
        [self replaceCurrentRange:@"" forceDeletion:TRUE];
        if( self.textField.text.length == 0 ) {
            self.textField.text = [kAllButtonText copy];
        }
    } else if( [kCheckButtonText isEqualToString:button.titleLabel.text] ) {
        
        [self commitEditing];
        
    } else if( [kAllButtonText isEqualToString:button.titleLabel.text] ) {
        self.textField.text = kAllButtonText;
        
    } else {
        if( [kAllPagesIndicator isEqualToString:self.textField.text] ) {
            self.textField.text = @"";
        }
        
        [self replaceCurrentRange:button.titleLabel.text forceDeletion:FALSE];
    }
}

#pragma mark - Text eval and modification

- (NSRange) selectedRangeInTextView:(UITextField*)textView
{
    UITextPosition* beginning = textView.beginningOfDocument;
    
    UITextRange* selectedRange = textView.selectedTextRange;
    UITextPosition* selectionStart = selectedRange.start;
    UITextPosition* selectionEnd = selectedRange.end;
    
    const NSInteger location = [textView offsetFromPosition:beginning toPosition:selectionStart];
    const NSInteger length = [textView offsetFromPosition:selectionStart toPosition:selectionEnd];
    
    return NSMakeRange(location, length);
}

- (void) replaceCurrentRange:(NSString *)string forceDeletion:(BOOL)forceDeletion
{
    NSMutableString *text = [NSMutableString stringWithString:self.textField.text];
    
    NSRange selectedRange = [self selectedRangeInTextView:self.textField];
    UITextRange *selectedTextRange = [self.textField selectedTextRange];
    
    if( forceDeletion  &&  0 == selectedRange.length  &&  0 != selectedRange.location ) {
        selectedRange.location -= 1;
        selectedRange.length = 1;
    }
    
    [text deleteCharactersInRange:selectedRange];
    
    [text insertString:string atIndex:selectedRange.location];
    
    self.textField.text = text;
    
    if( forceDeletion  &&  1 == selectedRange.length ) {
        UITextPosition *newPosition = [self.textField positionFromPosition:selectedTextRange.start offset:-1];
        self.textField.selectedTextRange = [self.textField textRangeFromPosition:newPosition toPosition:newPosition];
    } else {
        UITextPosition *newPosition = [self.textField positionFromPosition:selectedTextRange.start offset:string.length];
        self.textField.selectedTextRange = [self.textField textRangeFromPosition:newPosition toPosition:newPosition];
    }
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
            self.buttonContainer.frame = CGRectMake(0, self.buttonContainerOriginY, self.bounds.size.width, self.bounds.size.height - self.buttonContainerOriginY);
            self.textField.alpha = 1.0F;
        } else {
            self.textField.frame = CGRectMake(18, self.frame.size.height, self.bounds.size.width-36, height);
            self.buttonContainer.frame = CGRectMake(0, self.frame.size.height, self.bounds.size.width, height);
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
