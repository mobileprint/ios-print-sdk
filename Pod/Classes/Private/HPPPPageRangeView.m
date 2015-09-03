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

#import "HPPP.h"
#import "HPPPPageRangeView.h"
#import "UIColor+HPPPStyle.h"

@interface HPPPPageRangeView () <UITextFieldDelegate>

@property (strong, nonatomic) IBOutlet UIView *containingView;
@property (weak, nonatomic) IBOutlet UITextField *textField;
@property (strong, nonatomic) NSMutableArray *buttons;
@property (strong, nonatomic) NSString *pageRangeString;
@property (strong, nonatomic) UIView *buttonContainer;
@property (assign, nonatomic) int buttonContainerOriginY;
@property (strong, nonatomic) HPPP *hppp;

@end

@implementation HPPPPageRangeView

NSString * const kPageRangeAllPages = @"All";
NSString * const kPageRangeNoPages = @"No pages selected";

static NSString *kBackButtonText = @"⌫";
static NSString *kCheckButtonText = @"Done";
static NSString *kAllButtonText = @"ALL";
static NSString *kAllPagesIndicator = @"";
static NSString *kPlaceholderText = @"e.g. 1,3-5";

- (void)initWithXibName:(NSString *)xibName
{
    [super initWithXibName:xibName];
    
    self.textField.delegate = self;
    self.textField.placeholder = kPlaceholderText;
    self.buttons = [[NSMutableArray alloc] init];
    self.buttonContainer = [[UIView alloc] init];
    [self addSubview:self.buttonContainer];
    self.hppp = [HPPP sharedInstance];
}

- (void)dealloc
{
    [self removeButtons];
}

- (void)refreshLayout:(CGRect)newFrame
{
    if( self.frame.size.width != newFrame.size.width ) {
        self.frame = newFrame;
        [self addButtons];
    
        [self setNeedsLayout];
        [self layoutIfNeeded];
    }
}

- (void)addButtons
{
    [self removeButtons];

    if( IS_LANDSCAPE ) {
        [self addButtonsLandscape];
    } else {
        [self addButtonsPortrait];
    }
}

- (void)addButtonsLandscape
{
    NSLog(@"Adding landscape buttons: %@", self);
    NSArray *buttonTitles = @[@"1", @"2", @"3", @"4", @"5", @"6", @",", kBackButtonText, @"7", @"8", @"9", @"0",kAllButtonText, @"-", kCheckButtonText];
    
    [self layoutButtons:buttonTitles buttonsPerRow:8 wideAllButton:TRUE];
}

- (void)addButtonsPortrait
{
    NSLog(@"Adding portrait buttons: %@", self);
    NSArray *buttonTitles = @[@"1", @"2", @"3", kBackButtonText, @"4", @"5", @"6", @",", @"7", @"8", @"9", @"-", @"0", kAllButtonText, kCheckButtonText];

    [self layoutButtons:buttonTitles buttonsPerRow:4 wideAllButton:TRUE];
}

- (void)layoutButtons:(NSArray *)buttonTitles buttonsPerRow:(NSInteger)buttonsPerRow wideAllButton:(BOOL)doubleWideAllButton
{
    UIView *dummyView = [[UIView alloc] initWithFrame:CGRectMake(self.frame.size.width, self.frame.size.height, 1, 1)];
    self.textField.inputView = dummyView; // Hide keyboard, but show blinking cursor
    UIFont *baseFont = [self.hppp.appearance.settings objectForKey:kHPPPSelectionOptionsPrimaryFont];
    
    int buttonWidth = self.frame.size.width/buttonsPerRow + 1;
    int buttonHeight = .8 * buttonWidth;
    self.buttonContainerOriginY = self.frame.size.height - (((buttonTitles.count+doubleWideAllButton)/buttonsPerRow)*buttonHeight);

    self.buttonContainer.frame = CGRectMake(0, self.buttonContainerOriginY, self.frame.size.width, self.frame.size.height - self.buttonContainerOriginY);
    
    int yOrigin = 0;
    for( int i = 0, buttonOffset = 0; i<[buttonTitles count]; i++ ) {
        NSString *buttonText = [buttonTitles objectAtIndex:i];
        int row = (int)(i/buttonsPerRow);
        int col = i%buttonsPerRow;

        UIButton *button = [UIButton buttonWithType:UIButtonTypeSystem];
        [button setTitle:buttonText forState:UIControlStateNormal];
        [button setTitleColor:[self.hppp.appearance.settings objectForKey:kHPPPSelectionOptionsPrimaryFontColor] forState:UIControlStateNormal];
        button.titleLabel.font = [baseFont fontWithSize:baseFont.pointSize+2];
        [button layer].borderWidth = 1.0f;
        [button layer].borderColor = [[self.hppp.appearance.settings objectForKey:kHPPPSelectionOptionsStrokeColor] CGColor];
        button.backgroundColor = [self.hppp.appearance.settings objectForKey:kHPPPSelectionOptionsBackgroundColor];
        [button addTarget:self action:@selector(onButtonDown:) forControlEvents:UIControlEventTouchUpInside];

        if( [buttonText isEqualToString:[kAllButtonText copy]] ) {
            NSInteger width = buttonWidth;
            if( doubleWideAllButton ) {
                width = buttonWidth*2;
                buttonOffset++;
            }
            button.titleLabel.font = baseFont;
            button.frame = CGRectMake(col*buttonWidth, yOrigin + (row*buttonHeight), width, buttonHeight);
        } else {
            if( [buttonText isEqualToString:[kCheckButtonText copy]] ) {
                button.titleLabel.font = baseFont;
                button.backgroundColor = [self.hppp.appearance.settings objectForKey:kHPPPMainActionBackgroundColor];
                [button setTitleColor:[self.hppp.appearance.settings objectForKey:kHPPPMainActionActiveLinkFontColor] forState:UIControlStateNormal];
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
}

#pragma mark - HPPPEditView implementation

- (void)prepareForDisplay:(NSString *)initialText
{
    [self addButtons];

    if( NSOrderedSame == [initialText caseInsensitiveCompare:kAllButtonText] ) {
        self.pageRangeString = kAllPagesIndicator;
    } else {
        self.pageRangeString = initialText;
    }

    self.textField.alpha = 0.0F;
    self.textField.text = self.pageRangeString;
    self.textField.backgroundColor = [self.hppp.appearance.settings objectForKey:kHPPPFormFieldBackgroundColor];
    self.textField.font = [self.hppp.appearance.settings objectForKey:kHPPPFormFieldPrimaryFont];
    self.textField.textColor = [self.hppp.appearance.settings objectForKey:kHPPPFormFieldPrimaryFontColor];

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
    self.textField.text = self.pageRangeString;
    
    [self.textField resignFirstResponder];
}

- (void)commitEditing
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];

    NSString *finalRange = self.textField.text;
    
    if( [finalRange isEqualToString:kAllButtonText]  ||  [finalRange isEqualToString:kAllPagesIndicator] ) {
        finalRange = kPageRangeAllPages;
    }
    
    HPPPPageRange *pageRange = [[HPPPPageRange alloc] initWithString:finalRange allPagesIndicator:kPageRangeAllPages maxPageNum:self.maxPageNum sortAscending:TRUE];

    if( self.delegate  &&  [self.delegate respondsToSelector:@selector(didSelectPageRange:pageRange:)]) {
        [self.delegate didSelectPageRange:self pageRange:pageRange];
    }

    [self.textField resignFirstResponder];
    self.pageRangeString = pageRange.range;
}

#pragma mark - Button handler

- (IBAction)onButtonDown:(UIButton *)button
{
    if( [kBackButtonText isEqualToString:button.titleLabel.text] ) {
        if( ![kAllButtonText isEqualToString:self.textField.text] ) {
            [self replaceCurrentRange:@"" forceDeletion:TRUE];
            if( self.textField.text.length == 0 ) {
                self.textField.text = [kAllButtonText copy];
            }
        }
    } else if( [kCheckButtonText isEqualToString:button.titleLabel.text] ) {
        
        [self commitEditing];
        
    } else if( [kAllButtonText isEqualToString:button.titleLabel.text] ) {
        self.textField.text = kAllButtonText;
        
    } else {
        if( [kAllPagesIndicator isEqualToString:self.textField.text] ||
            [kAllButtonText isEqualToString:self.textField.text]) {
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
