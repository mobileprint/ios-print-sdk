//
// Hewlett-Packard Company
// All rights reserved.
//
// This file, its contents, concepts, methods, behavior, and operation
// (collectively the "Software") are protected by trade secret, patent,
// and copyright laws. The use of the Software is governed by a license
// agreement. Disclosure of the Software to third parties, in any form,
// in whole or in part, is expressly prohibited except as authorized by
// the

#import "HPPPDefaultSettingsTableViewController.h"
#import "HPPPDefaultSettingsManager.h"

@interface HPPPDefaultSettingsTableViewController ()

@property (weak, nonatomic) IBOutlet UITableViewCell *printerNameCell;
@property (weak, nonatomic) IBOutlet UITableViewCell *printerUrlCell;
@property (weak, nonatomic) IBOutlet UITableViewCell *printerNetworkCell;
@property (weak, nonatomic) IBOutlet UITableViewCell *printerModelCell;
@property (weak, nonatomic) IBOutlet UITableViewCell *paperSizeCell;
@property (weak, nonatomic) IBOutlet UITableViewCell *paperTypeCell;

@end

@implementation HPPPDefaultSettingsTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.clearsSelectionOnViewWillAppear = NO;
    
    HPPPDefaultSettingsManager *defaults = [HPPPDefaultSettingsManager sharedInstance];
    HPPPPrintSettings *settings = defaults.defaultPrintSettings;
    
    self.printerNameCell.detailTextLabel.text = settings.printerName;
    self.printerUrlCell.detailTextLabel.text = [NSString stringWithFormat:@"%@", settings.printerUrl];
    self.printerNetworkCell.detailTextLabel.text = defaults.defaultPrinterNetwork;
    self.printerModelCell.detailTextLabel.text = settings.printerModel;
    self.paperSizeCell.detailTextLabel.text = settings.paper.sizeTitle;
    self.paperTypeCell.detailTextLabel.text = settings.paper.typeTitle;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return 6;
}

- (IBAction)doneButtonTapped:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

/*
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:<#@"reuseIdentifier"#> forIndexPath:indexPath];
    
    // Configure the cell...
    
    return cell;
}
*/

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
