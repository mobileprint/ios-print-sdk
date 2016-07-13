//
//  MPBTAutoOffTableViewController.m
//  Pods
//
//  Created by Susy Snowflake on 7/12/16.
//
//

#import "MPBTAutoOffTableViewController.h"
#import "MPBTSprocket.h"
#import "MP.h"
#import "NSBundle+MPLocalizable.h"

@interface MPBTAutoOffTableViewController ()

@property (strong, nonatomic) NSArray *autoOffTitles;
@property (strong, nonatomic) NSArray *autoOffValues;

@end

@implementation MPBTAutoOffTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.tableView.backgroundColor = [[MP sharedInstance].appearance.settings objectForKey:kMPGeneralBackgroundColor];
    self.tableView.tableHeaderView.backgroundColor = self.tableView.backgroundColor;
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    self.tableView.separatorColor = [[MP sharedInstance].appearance.settings objectForKey:kMPGeneralTableSeparatorColor];
    
    self.autoOffTitles = @[MPLocalizedString(@"Never", @"Indicates that the device will never power off"),
                           [MPBTSprocket autoPowerOffIntervalString:MantaAutoOffTenMin],
                           [MPBTSprocket autoPowerOffIntervalString:MantaAutoOffFiveMin],
                           [MPBTSprocket autoPowerOffIntervalString:MantaAutoOffThreeMin]];
    
    self.autoOffValues = @[[NSNumber numberWithInt:MantaAutoOffAlwaysOn],
                           [NSNumber numberWithInt:MantaAutoOffTenMin],
                           [NSNumber numberWithInt:MantaAutoOffFiveMin],
                           [NSNumber numberWithInt:MantaAutoOffThreeMin]];

    UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"Back"]
                                                                   style:UIBarButtonItemStylePlain
                                                                  target:self
                                                                  action:@selector(didPressBack)];
    self.navigationItem.leftBarButtonItem = backButton;
    self.title = MPLocalizedString(@"Auto Off", @"Title with options for turning the device off automatically after a certain amount of time");
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)didPressBack
{
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - Getters/Setters

- (void)setCurrentAutoOffValue:(MantaAutoPowerOffInterval)currentAutoOffValue
{
    _currentAutoOffValue = currentAutoOffValue;
    
    [self.tableView reloadData];
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.delegate  &&  [self.delegate respondsToSelector:@selector(didSelectAutoOffInterval:)]) {
        NSInteger rowValue = ((NSNumber *)(self.autoOffValues[indexPath.row])).integerValue;
        [self.delegate didSelectAutoOffInterval:rowValue];
        [self.navigationController popViewControllerAnimated:YES];
    }
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.autoOffTitles.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MPBTAutoOffCell" forIndexPath:indexPath];
    
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"MPBTAutoOffCell"];
    }
    
    cell.backgroundColor = [[MP sharedInstance].appearance.settings objectForKey:kMPSelectionOptionsBackgroundColor];
    cell.textLabel.font = [[MP sharedInstance].appearance.settings objectForKey:kMPSelectionOptionsPrimaryFont];
    cell.textLabel.textColor = [[MP sharedInstance].appearance.settings objectForKey:kMPSelectionOptionsPrimaryFontColor];
    
    cell.textLabel.text = self.autoOffTitles[indexPath.row];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    NSInteger rowValue = ((NSNumber *)(self.autoOffValues[indexPath.row])).integerValue;
    if (rowValue == self.currentAutoOffValue) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    } else {
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    
    return cell;

}


/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
