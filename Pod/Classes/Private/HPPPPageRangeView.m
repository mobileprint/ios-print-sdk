//
//  PageRangeCollectionViewController.m
//  Pods
//
//  Created by Bozo on 6/10/15.
//
//

#import "HPPPPageRangeView.h"

@interface HPPPPageRangeView () <UITextFieldDelegate>

@property (strong, nonatomic) IBOutlet UIView *containingView;
@property (weak, nonatomic) IBOutlet UIView *smokeyView;
@property (weak, nonatomic) IBOutlet UITextField *textField;
@property (strong, nonatomic) NSMutableArray *buttons;
@property (strong, nonatomic) UIView *hackView;

@end

@implementation HPPPPageRangeView

static const NSString *kBackButtonText = @"BACK";
static const NSString *kCheckButtonText = @"CHECK";
static const NSString *kAllButtonText = @"ALL";

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
    for( UIButton *button in self.buttons ) {
        [button removeFromSuperview];
    }
}

- (void)addButtons
{
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
        [button layer].borderColor = [UIColor blackColor].CGColor;
        button.backgroundColor = [UIColor whiteColor];
        [button addTarget:self action:@selector(onButtonDown:) forControlEvents:UIControlEventTouchUpInside];

        if( [buttonText isEqualToString:@"ALL"] ) {
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
        CGRect desiredFrame = self.frame;
        desiredFrame.origin.y = self.frame.origin.y + self.frame.size.height;

        [UIView animateWithDuration:0.6f animations:^{
            self.frame = desiredFrame;
            self.hackView.frame = desiredFrame;
        } completion:^(BOOL finished) {
            self.hackView = nil;
        }];
        
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

@end
