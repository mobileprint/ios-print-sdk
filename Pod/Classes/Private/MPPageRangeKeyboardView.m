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

#import "MP.h"
#import "MPPageRangeKeyboardView.h"
#import "UIColor+MPStyle.h"
#import "NSBundle+MPLocalizable.h"


@interface MPPageRangeKeyboardView ()

@property (weak, nonatomic) UITextField *textField;
@property (assign, nonatomic) NSInteger maxPageNum;

@property (strong, nonatomic) NSMutableArray *buttons;
@property (strong, nonatomic) NSString *pageRangeString;
@property (strong, nonatomic) UIView *buttonContainer;
@property (assign, nonatomic) int buttonContainerOriginY;
@property (strong, nonatomic) MP* mp;

@end

@implementation MPPageRangeKeyboardView

NSString *kPageRangeAllPages = @"All";
NSString *kPageRangeNoPages = @"No pages selected";

static NSString *kBackButtonText;
static NSString *kCheckButtonText;
static NSString *kAllButtonText;
static NSString *kAllPagesIndicator;
static NSString *kPlaceholderText;

- (id)initWithFrame:(CGRect)frame textField:(UITextField *)textField maxPageNum:(NSInteger)maxPageNum
{
    return [((MPPageRangeKeyboardView *)[super initWithFrame:frame]) loadView:textField maxPageNum:maxPageNum];
}

- (id) loadView:(UITextField *)textField maxPageNum:(NSInteger)maxPageNum
{
    kPageRangeAllPages = MPLocalizedString(kPageRangeAllPages, @"Specifies that all pages will be selected");
    kPageRangeNoPages = MPLocalizedString(kPageRangeNoPages, @"Specifies that no pages are selected for printing");

    kBackButtonText = @"⌫";
    kCheckButtonText = MPLocalizedString(@"Done", @"Used on a button for closing the dialog");
    kAllButtonText = MPLocalizedString(@"ALL", @"Text used on a button that selects all pages for printing");
    kAllPagesIndicator = @"";
    kPlaceholderText = MPLocalizedString(@"e.g. 1,3-5", @"Text used to give an example of how to enter a page range");

    self.textField = textField;
    self.textField.placeholder = kPlaceholderText;
    self.buttons = [[NSMutableArray alloc] init];
    self.buttonContainer = [[UIView alloc] init];
    [self addSubview:self.buttonContainer];
    self.maxPageNum = maxPageNum;
    self.mp = [MP sharedInstance];
    
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
    NSArray *buttonTitles = @[@"1", @"2", @"3", @"4", @"5", @"6", @",", kBackButtonText, @"7", @"8", @"9", @"0",kAllButtonText, @"-", kCheckButtonText];
    
    [self layoutButtons:buttonTitles buttonsPerRow:8 wideAllButton:TRUE];
}

- (void)addButtonsPortrait
{
    NSArray *buttonTitles = @[@"1", @"2", @"3", kBackButtonText, @"4", @"5", @"6", @",", @"7", @"8", @"9", @"-", @"0", kAllButtonText, kCheckButtonText];

    [self layoutButtons:buttonTitles buttonsPerRow:4 wideAllButton:TRUE];
}

- (void)layoutButtons:(NSArray *)buttonTitles buttonsPerRow:(NSInteger)buttonsPerRow wideAllButton:(BOOL)doubleWideAllButton
{
    // The keyboard will take the width of the entire screen, not just our frame
    CGRect screenFrame = [self screenFrame];
                    
    UIFont *baseFont = [self.mp.appearance.settings objectForKey:kMPSelectionOptionsPrimaryFont];
    
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
        [button setTitleColor:[self.mp.appearance.settings objectForKey:kMPSelectionOptionsPrimaryFontColor] forState:UIControlStateNormal];
        button.titleLabel.font = [baseFont fontWithSize:baseFont.pointSize+2];
        [button layer].borderWidth = 1.0f;
        [button layer].borderColor = [[self.mp.appearance.settings objectForKey:kMPGeneralTableSeparatorColor] CGColor];
        button.backgroundColor = [self.mp.appearance.settings objectForKey:kMPSelectionOptionsBackgroundColor];
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
                button.backgroundColor = [self.mp.appearance.settings objectForKey:kMPMainActionBackgroundColor];
                [button setTitleColor:[self.mp.appearance.settings objectForKey:kMPMainActionActiveLinkFontColor] forState:UIControlStateNormal];
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

#pragma mark - Preparing for display

- (BOOL)prepareForDisplay
{
    [self addButtons];
    
    if( NSOrderedSame == [self.textField.text caseInsensitiveCompare:kAllButtonText] ||
       NSOrderedSame == [self.textField.text caseInsensitiveCompare:kPageRangeNoPages]) {
        self.pageRangeString = kAllPagesIndicator;
    } else {
        self.pageRangeString = self.textField.text;
    }
    
    self.textField.text = self.pageRangeString;
    
    UITextPosition *newPosition = [self.textField positionFromPosition:[self.textField beginningOfDocument] offset:self.textField.text.length];
    self.textField.selectedTextRange = [self.textField textRangeFromPosition:newPosition toPosition:newPosition];

    
    return YES;
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
    self.textField.text = self.pageRangeString;
    [self.textField resignFirstResponder];
}

- (void)commitEditing
{
    NSString *finalRange = self.textField.text;
    
    if( [finalRange isEqualToString:kAllButtonText]  ||  [finalRange isEqualToString:kAllPagesIndicator] ) {
        finalRange = kPageRangeAllPages;
    }
    
    MPPageRange *pageRange = [[MPPageRange alloc] initWithString:finalRange allPagesIndicator:kPageRangeAllPages maxPageNum:self.maxPageNum sortAscending:TRUE];
    
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

#pragma mark - Utils
- (CGRect)screenFrame
{
    CGRect screenFrame = [UIScreen mainScreen].bounds;
    
    // iOS8 and later adjust the mainScreen bounds based on orientation
    //  In order to support iOS 7, we add this special case
    if (!IS_OS_8_OR_LATER  &&  IS_LANDSCAPE) {
        CGSize screenSize = [UIScreen mainScreen].bounds.size;
        screenFrame.size = CGSizeMake(screenSize.height, screenSize.width);
    }
    
    return screenFrame;
}

@end
