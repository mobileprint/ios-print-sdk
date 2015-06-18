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

@interface HPPPPageRangeView () <UITextFieldDelegate>

@property (strong, nonatomic) IBOutlet UIView *containingView;
@property (weak, nonatomic) IBOutlet UIView *smokeyView;
@property (weak, nonatomic) IBOutlet UITextField *textField;
@property (strong, nonatomic) NSMutableArray *buttons;

@end

@implementation HPPPPageRangeView

static const NSString *kBackButtonText = @"BACK";
static const NSString *kCheckButtonText = @"CHECK";
static const NSString *kAllButtonText = @"ALL";

// TODO:
// - Need icons for the "back" and "check" buttons
// - Need to do a lot more validation on the user's input
//    - Has the user entered a valid page range
//    - Is the page range within the bounds of the document
// - There's some gobbeldy-gook in the upper right corner of the screen

- (void)initWithXibName:(NSString *)xibName
{
    [super initWithXibName:xibName];
    
    self.textField.delegate = self;
    [self addButtons];
    
    UIView *dummyView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 1, 1)];
    self.textField.inputView = dummyView; // Hide keyboard, but show blinking cursor
    
    [self.textField becomeFirstResponder];
}

- (void)dealloc
{
    [self removeButtons];
}

- (void)addButtons
{
    [self removeButtons];
    
    int buttonWidth = self.frame.size.width/4 + 1;
    int buttonHeight = .8 * buttonWidth;
    int yOrigin = self.frame.size.height - (4*buttonHeight);
    
    NSArray *buttonTitles = @[@"1", @"2", @"3", kBackButtonText, @"4", @"5", @"6", @",", @"7", @"8", @"9", @"-", @"0", kAllButtonText, kCheckButtonText];
    
    for( int i = 0, buttonOffset = 0; i<[buttonTitles count]; i++ ) {
        NSString *buttonText = [buttonTitles objectAtIndex:i];
        int row = (int)(i/4);
        int col = i%4;

        UIButton *button = [UIButton buttonWithType:UIButtonTypeSystem];
        [button setTitle:buttonText forState:UIControlStateNormal];
        [button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [button layer].borderWidth = 1.0f;
        [button layer].borderColor = [UIColor lightGrayColor].CGColor;
        button.backgroundColor = [UIColor whiteColor];
        [button addTarget:self action:@selector(onButtonDown:) forControlEvents:UIControlEventTouchUpInside];

        if( [buttonText isEqualToString:[kAllButtonText copy]] ) {
            button.frame = CGRectMake(col*buttonWidth, yOrigin + (row*buttonHeight), buttonWidth*2, buttonHeight);
            buttonOffset++;
        } else {
            button.frame = CGRectMake((col+buttonOffset)*buttonWidth, yOrigin + (row*buttonHeight), buttonWidth, buttonHeight);
        }
        
        // Make sure we have at least a 1 pixel margin on the right side.
        if( button.frame.origin.x + button.frame.size.width >= self.frame.size.width ) {
            CGRect frame = button.frame;
            int diff = (button.frame.origin.x + button.frame.size.width) - self.frame.size.width;
            frame.size.width -= diff;
            button.frame = frame;
        }

        [self.containingView addSubview:button];
        
        [self.buttons addObject:button];
    }
}

- (void)removeButtons
{
    for( UIButton *button in self.buttons ) {
        [button removeFromSuperview];
    }
}

- (IBAction)onButtonDown:(UIButton *)button
{
    
    if( [kBackButtonText isEqualToString:button.titleLabel.text] ) {
        NSMutableString *text = [NSMutableString stringWithString:self.textField.text];
        
        NSRange selectedRange = [self selectedRangeInTextView:self.textField];

        if( 0 == selectedRange.length && 0 != selectedRange.location ) {
            selectedRange.location -= 1;
            selectedRange.length = 1;
        }
        
        [text deleteCharactersInRange:selectedRange];
        self.textField.text = text;
        
    } else if( [kCheckButtonText isEqualToString:button.titleLabel.text] ) {
        
        if( self.delegate  &&  [self.delegate respondsToSelector:@selector(didSelectPageRange:pageRange:)]) {
            [self.delegate didSelectPageRange:self pageRange:[self scrubbedPageRange]];
        }
        
    } else if( [kAllButtonText isEqualToString:button.titleLabel.text] ) {
        self.textField.text = [kAllButtonText copy];
        
    } else {
        self.textField.text = [NSString stringWithFormat:@"%@%@", self.textField.text, button.titleLabel.text];
    }
}

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

- (NSString *) scrubbedPageRange
{
    NSString *scrubbedRange = self.textField.text;
    
    if( [kAllButtonText isEqualToString:self.textField.text] ) {
        scrubbedRange = @"";
    } else {
        
        // TODO: verify validity of print range
        //  - No dangling '-' or ','
        //  - All pages are valid based on the document length
        //  - properly order all ranges.  IE, '9-2' becomes '2-9'
    }
    
    return scrubbedRange;
}

- (void)finishEditing
{
    if( self.delegate  &&  [self.delegate respondsToSelector:@selector(didSelectPageRange:pageRange:)]) {
        [self.delegate didSelectPageRange:self pageRange:self.textField.text];
    }
}

@end
