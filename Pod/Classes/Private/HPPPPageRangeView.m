//
//  PageRangeCollectionViewController.m
//  Pods
//
//  Created by Bozo on 6/10/15.
//
//

<<<<<<< HEAD
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
=======
#import "PageRangeCollectionViewController.h"

@interface PageRangeCollectionViewController ()

@end

@implementation PageRangeCollectionViewController

static NSString * const reuseIdentifier = @"Cell";

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Register cell classes
    [self.collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:reuseIdentifier];
    
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark <UICollectionViewDataSource>

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
#warning Incomplete method implementation -- Return the number of sections
    return 0;
}


- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
#warning Incomplete method implementation -- Return the number of items in the section
    return 0;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:reuseIdentifier forIndexPath:indexPath];
    
    // Configure the cell
    
    return cell;
}

#pragma mark <UICollectionViewDelegate>

/*
// Uncomment this method to specify if the specified item should be highlighted during tracking
- (BOOL)collectionView:(UICollectionView *)collectionView shouldHighlightItemAtIndexPath:(NSIndexPath *)indexPath {
	return YES;
}
*/

/*
// Uncomment this method to specify if the specified item should be selected
- (BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}
*/

/*
// Uncomment these methods to specify if an action menu should be displayed for the specified item, and react to actions performed on the item
- (BOOL)collectionView:(UICollectionView *)collectionView shouldShowMenuForItemAtIndexPath:(NSIndexPath *)indexPath {
	return NO;
}

- (BOOL)collectionView:(UICollectionView *)collectionView canPerformAction:(SEL)action forItemAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender {
	return NO;
}

- (void)collectionView:(UICollectionView *)collectionView performAction:(SEL)action forItemAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender {
	
}
*/
>>>>>>> 1990ee29c4fbc5fadc2bb7576777f90fbc270b2e

@end
