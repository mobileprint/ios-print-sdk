//
//  PageRangeCollectionViewController.m
//  Pods
//
//  Created by Bozo on 6/10/15.
//
//

#import "HPPPPageRangeView.h"

@interface HPPPPageRangeView ()

@property (weak, nonatomic) IBOutlet UIView *smokeyView;

@end

@implementation HPPPPageRangeView

static NSString * const reuseIdentifier = @"Cell";

- (void)initWithXibName:(NSString *)xibName
{
    [super initWithXibName:xibName];
    
    [self addButtons];
}
- (void)addButtons
{
    int buttonWidth = self.frame.size.width/4 + 1;
    int buttonHeight = .8 * buttonWidth;
    int yOrigin = self.frame.size.height - (4*buttonHeight);
    
    NSArray *buttonTitles = @[@"1", @"2", @"3", @"BACK", @"4", @"5", @"6", @",", @"7", @"8", @"9", @"-", @"0", @"ALL", @"CHECK"];
    
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
        button.opaque = YES;

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

        [self.smokeyView addSubview:button];
        NSLog(@"Button: %@", button);
    }
}

@end
