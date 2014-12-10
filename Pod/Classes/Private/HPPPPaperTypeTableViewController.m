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

#import "HPPPPaperTypeTableViewController.h"
#import "HPPPPaper.h"
//#import "UIViewController+Trackable.h"

@interface HPPPPaperTypeTableViewController ()

@property (strong, nonatomic) IBOutletCollection(UITableViewCell) NSArray *paperTypeCells;

@end

@implementation HPPPPaperTypeTableViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //self.trackableScreenName = @"Paper Type Screen";
    
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    
    for (UITableViewCell *cell in self.paperTypeCells) {
        if ([cell.textLabel.text isEqualToString:self.currentPaper.typeTitle]) {
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
            break;
        }
    }
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *selectedCell = [tableView cellForRowAtIndexPath:indexPath];
    
    for (UITableViewCell *cell in self.paperTypeCells) {
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    
    selectedCell.accessoryType = UITableViewCellAccessoryCheckmark;
    
    
    HPPPPaper *paper = [[HPPPPaper alloc] initWithPaperSizeTitle:self.currentPaper.sizeTitle paperTypeTitle:selectedCell.textLabel.text];
    
    [self.navigationController popViewControllerAnimated:YES];
    
    if ([self.delegate respondsToSelector:@selector(paperTypeTableViewController:didSelectPaper:)]) {
        [self.delegate paperTypeTableViewController:self didSelectPaper:paper];
    }
}

@end
