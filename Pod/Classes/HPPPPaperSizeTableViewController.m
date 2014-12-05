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

#import "HPPPPaperSizeTableViewController.h"
#import "HPPPPaper.h"
#import "UIColor+Style.h"
#import "UITableView+Header.h"
//#import "UIViewController+Trackable.h"

@interface HPPPPaperSizeTableViewController ()

@property (strong, nonatomic) IBOutletCollection(UITableViewCell) NSArray *paperSizeCells;

@end

@implementation HPPPPaperSizeTableViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //self.trackableScreenName = @"Paper Size Screen";
    
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    
    for (UITableViewCell *cell in self.paperSizeCells) {
        if ([cell.textLabel.text isEqualToString:self.currentPaper.sizeTitle]) {
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
            break;
        }
    }
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *selectedCell = [tableView cellForRowAtIndexPath:indexPath];
    
    for (UITableViewCell *cell in self.paperSizeCells) {
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    
    selectedCell.accessoryType = UITableViewCellAccessoryCheckmark;
    
    NSString *typeTitle = ([SIZE_LETTER_TITLE  isEqual: selectedCell.textLabel.text] ? self.currentPaper.typeTitle : @"Photo Paper");
    HPPPPaper *paper = [[HPPPPaper alloc] initWithPaperSizeTitle:selectedCell.textLabel.text paperTypeTitle:typeTitle];
    
    [self.navigationController popViewControllerAnimated:YES];
    
    if ([self.delegate respondsToSelector:@selector(paperSizeTableViewController:didSelectPaper:)]) {
        [self.delegate paperSizeTableViewController:self didSelectPaper:paper];
    }
}

@end
