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

@property (weak, nonatomic) UITextField *textField;
@property (assign, nonatomic) NSInteger maxPageNum;

@property (strong, nonatomic) NSMutableArray *buttons;
@property (strong, nonatomic) NSString *pageRangeString;
@property (strong, nonatomic) UIView *buttonContainer;
@property (assign, nonatomic) int buttonContainerOriginY;
@property (strong, nonatomic) HPPP* hppp;

@end

@implementation HPPPPageRangeView

NSString * const kPageRangeAllPages = @"All";
NSString * const kPageRangeNoPages = @"No pages selected";

static NSString *kBackButtonText = @"⌫";
static NSString *kCheckButtonText = @"Done";
static NSString *kAllButtonText = @"ALL";
static NSString *kAllPagesIndicator = @"";
static NSString *kPlaceholderText = @"e.g. 1,3-5";

- (id)initWithFrame:(CGRect)frame textField:(UITextField *)textField maxPageNum:(NSInteger)maxPageNum
{
    return [((HPPPPageRangeView *)[super initWithFrame:frame]) loadView:textField maxPageNum:maxPageNum];
}

- (id) loadView:(UITextField *)textField maxPageNum:(NSInteger)maxPageNum
{
    self.textField = textField;
    self.textField.delegate = self;
    self.textField.placeholder = kPlaceholderText;
    self.buttons = [[NSMutableArray alloc] init];
    self.buttonContainer = [[UIView alloc] init];
    [self addSubview:self.buttonContainer];
    self.maxPageNum = maxPageNum;
    self.hppp = [HPPP sharedInstance];
    
    return self;
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

#pragma mark - Button layouts

- (void)addButtons
{
    [self removeButtons];

    if( IS_LANDSCAPE || IS_IPAD ) {
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
    // The keyboard will take the width of the entire screen, not just our frame
    CGRect screenFrame = [[UIScreen mainScreen] bounds];
                    
    UIFont *baseFont = [self.hppp.appearance.settings objectForKey:kHPPPSelectionOptionsPrimaryFont];
    
    int buttonWidth = screenFrame.size.width/buttonsPerRow + 1;
    int buttonHeight = .8 * buttonWidth;
    self.buttonContainerOriginY = 0;
    int buttonContainerHeight = self.frame.size.height - (((buttonTitles.count+doubleWideAllButton)/buttonsPerRow)*buttonHeight);

    self.frame = CGRectMake(0, self.buttonContainerOriginY, screenFrame.size.width, self.frame.size.height - buttonContainerHeight);
    self.buttonContainer.frame = self.frame;
    
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
        [button layer].borderColor = [[self.hppp.appearance.settings objectForKey:kHPPPGeneralTableSeparatorColor] CGColor];
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
        if( button.frame.origin.x + button.frame.size.width >= screenFrame.size.width ) {
            CGRect frame = button.frame;
            int diff = (button.frame.origin.x + button.frame.size.width) - screenFrame.size.width;
            frame.size.width -= diff;
            button.frame = frame;
        }

        [self.buttonContainer addSubview:button];
        
        [self.buttons addObject:button];
    }
}

- (void)removeButtons
{
    for( UIButton *button in self.buttons ) {
        [button removeFromSuperview];
    }
}

#pragma mark - UITextField delegate

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    [self addButtons];
    
    if( NSOrderedSame == [textField.text caseInsensitiveCompare:kAllButtonText] ||
       NSOrderedSame == [textField.text caseInsensitiveCompare:kPageRangeNoPages]) {
        self.pageRangeString = kAllPagesIndicator;
    } else {
        self.pageRangeString = textField.text;
    }
    
    self.textField.text = self.pageRangeString;
    
    UITextPosition *newPosition = [self.textField positionFromPosition:[self.textField beginningOfDocument] offset:self.textField.text.length];
    self.textField.selectedTextRange = [self.textField textRangeFromPosition:newPosition toPosition:newPosition];

    
    return YES;
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    [self commitEditing];
}

#pragma mark - Button handler

- (IBAction)onButtonDown:(UIButton *)button
{
    if( [kBackButtonText isEqualToString:button.titleLabel.text] ) {
        if( ![kAllButtonText isEqualToString:self.textField.text] &&
            [self.textField.text length] > 0 ) {
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

#pragma mark - Text commits and cancels

- (void)cancelEditing
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    self.textField.text = self.pageRangeString;
    
    [self.textField resignFirstResponder];
}

- (void)commitEditing
{
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

@end
