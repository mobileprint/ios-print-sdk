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
#import "UIColor+HPPPStyle.h"

@interface HPPPPageRangeView () <UITextFieldDelegate>

@property (strong, nonatomic) IBOutlet UIView *containingView;
@property (weak, nonatomic) IBOutlet UIView *smokeyView;
@property (weak, nonatomic) IBOutlet UITextField *textField;
@property (strong, nonatomic) NSMutableArray *buttons;

@end

@implementation HPPPPageRangeView

static const NSString *kBackButtonText = @"⌫";
static const NSString *kCheckButtonText = @"✔︎";
static const NSString *kAllButtonText = @"ALL";

- (void)initWithXibName:(NSString *)xibName
{
    [super initWithXibName:xibName];
    
    self.textField.delegate = self;
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
            if( [buttonText isEqualToString:[kCheckButtonText copy]] ) {
                [button setTitleColor:[UIColor HPPPHPBlueColor] forState:UIControlStateNormal];
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
        [self replaceCurrentRange:@"" forceDeletion:TRUE];
    } else if( [kCheckButtonText isEqualToString:button.titleLabel.text] ) {
        
        if( self.delegate  &&  [self.delegate respondsToSelector:@selector(didSelectPageRange:pageRange:)]) {
            [self.delegate didSelectPageRange:self pageRange:[self scrubbedPageRange]];
        }
        
    } else if( [kAllButtonText isEqualToString:button.titleLabel.text] ) {
        self.textField.text = [kAllButtonText copy];
        
    } else {
        if( [kAllButtonText isEqualToString:self.textField.text] ) {
            self.textField.text = @"";
        }
        
        [self replaceCurrentRange:button.titleLabel.text forceDeletion:FALSE];
    }
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

- (void) setCursorPosition
{
    UITextPosition *newPosition = [self.textField positionFromPosition:0 offset:self.textField.text.length];
    self.textField.selectedTextRange = [self.textField textRangeFromPosition:newPosition toPosition:newPosition];

    [self.textField becomeFirstResponder];
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
        // No ",-"... replace with ","
        // No "-,"... replace with ","
        // No "--"... replace with "-"
        // No ",,"... replace with ","
        // No strings starting or ending with "," or "-"
        // Rplace all page numbers of 0 with 1
        // Replace all page numbers greater than the doc length with the doc length
        // No "%d1-%d2-%d3"... replace with "%d1-%d3"
        
        scrubbedRange = [scrubbedRange stringByReplacingOccurrencesOfString:@",-" withString:@","];
        scrubbedRange = [scrubbedRange stringByReplacingOccurrencesOfString:@"-," withString:@","];
        scrubbedRange = [scrubbedRange stringByReplacingOccurrencesOfString:@",," withString:@","];
        scrubbedRange = [scrubbedRange stringByReplacingOccurrencesOfString:@"--" withString:@"-"];
        
        // The first page is 1, not 0
        scrubbedRange = [scrubbedRange stringByReplacingOccurrencesOfString:@"-0-" withString:@"-1-"];
        scrubbedRange = [scrubbedRange stringByReplacingOccurrencesOfString:@",0," withString:@",1,"];
        scrubbedRange = [scrubbedRange stringByReplacingOccurrencesOfString:@"-0," withString:@"-1,"];
        scrubbedRange = [scrubbedRange stringByReplacingOccurrencesOfString:@",0-" withString:@",1-"];
        
        scrubbedRange = [scrubbedRange stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"-,"]];
        scrubbedRange = [self replaceOutOfBoundsPageNumbers:scrubbedRange];
        scrubbedRange = [self replaceBadDashUsage:scrubbedRange];
    
        if( ![self.textField.text isEqualToString:scrubbedRange] ) {
            self.textField.text = scrubbedRange;
            
            // keep calling this function until it makes no modification
            scrubbedRange = [self scrubbedPageRange];
        }
    }
    
    return scrubbedRange;
}

- (void)finishEditing
{
    if( self.delegate  &&  [self.delegate respondsToSelector:@selector(didSelectPageRange:pageRange:)]) {
        [self.delegate didSelectPageRange:self pageRange:[self scrubbedPageRange]];
    }
}

- (NSArray *)getNumsFromString:(NSString *)string
{
    NSMutableArray *returnArray = nil;
    
    NSRange range = NSMakeRange(0,[string length]);
    
    NSRegularExpression *regex = [self regularExpressionWithString:@"\\d+" options:nil];
    NSArray *matches = [regex matchesInString:string options:NSMatchingReportCompletion range:range];
    
    if( matches  &&  0 < matches.count ) {
        returnArray = [[NSMutableArray alloc] init];
        
        for( NSTextCheckingResult *pageNumRes in matches ) {
            NSString *pageNumStr = [string substringWithRange:pageNumRes.range];
            [returnArray addObject:[NSNumber numberWithInteger:[pageNumStr integerValue]]];
        }
    }

    return returnArray;
}

- (NSRegularExpression *)regularExpressionWithString:(NSString *)pattern options:(NSDictionary *)options
{
    // Create a regular expression
    NSError *error = NULL;
    NSRegularExpressionOptions regexOptions = NSRegularExpressionCaseInsensitive;
    
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:pattern options:regexOptions error:&error];
    if (error)
    {
        NSLog(@"Couldn't create regex with given string and options");
    }
    
    return regex;
}

- (NSString *)replaceBadDashUsage:(NSString *)string
{
    NSMutableString *scrubbedString = [string mutableCopy];

    NSRange range = NSMakeRange(0,[string length]);
    
    NSRegularExpression *regex = [self regularExpressionWithString:@"(\\d+)-(\\d+)-(\\d+)" options:nil];
    [regex replaceMatchesInString:scrubbedString options:0 range:range withTemplate:@"$1-$3"];

    return scrubbedString;
}

- (NSString *)replaceOutOfBoundsPageNumbers:(NSString *)string
{
    BOOL corrected = FALSE;
    NSString *scrubbedString = string;
    
    NSArray *matches = [self getNumsFromString:string];
    if( matches  &&  0 < matches.count ) {
        for( NSNumber *pageNumber in matches ) {
            NSInteger pageNum = [pageNumber integerValue];
            if( pageNum > self.maxPageNum ) {
                NSLog(@"error-- page num out of range: %ld, Word on Mac responds poorly in this scenario... what should we do?", (long)pageNum);
                scrubbedString = [scrubbedString stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@"%ld", pageNum] withString:[NSString stringWithFormat:@"%ld", self.maxPageNum]];
                corrected = TRUE;
                break;
            } else if ( 0 == pageNum ) {
                NSLog(@"error-- 0 page num");
            }
        }
        
        if( corrected ) {
            scrubbedString = [self replaceOutOfBoundsPageNumbers:scrubbedString];
        }
    }
    
    return scrubbedString;
}

@end
