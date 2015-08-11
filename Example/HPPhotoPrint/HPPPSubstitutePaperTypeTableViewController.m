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

#import "HPPPSubstitutePaperTypeTableViewController.h"
#import "HPPP.h"
#import "HPPPPaper.h"


NSString * const kSubstitutePaperTypeScreenName = @"Paper Type Screen";

@interface HPPPSubstitutePaperTypeTableViewController ()

@property (strong, nonatomic) HPPP *hppp;
@property (strong, nonatomic) IBOutletCollection(UITableViewCell) NSArray *paperTypeCells;

@end

@implementation HPPPSubstitutePaperTypeTableViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = @"Paper Type";
    
    self.hppp = [HPPP sharedInstance];
    
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    
    NSArray *localizeTitleArray = @[@"Plain Paper", @"Photo Paper"];
    
    NSInteger i = 0;
    for (UITableViewCell *cell in self.paperTypeCells) {
        cell.textLabel.font = self.hppp.tableViewCellLabelFont;
        cell.textLabel.textColor = self.hppp.tableViewCellLabelColor;
        cell.textLabel.text = [localizeTitleArray objectAtIndex:i];
        i ++;
        
        if ([cell.textLabel.text isEqualToString:self.currentPaper.typeTitle]) {
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
        }
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kHPPPTrackableScreenNotification object:nil userInfo:[NSDictionary dictionaryWithObject:kSubstitutePaperTypeScreenName forKey:kHPPPTrackableScreenNameKey]];
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    for (UITableViewCell *cell in self.paperTypeCells) {
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    
    UITableViewCell *selectedCell = [tableView cellForRowAtIndexPath:indexPath];
    selectedCell.accessoryType = UITableViewCellAccessoryCheckmark;
    
    
    HPPPPaper *paper = [[HPPPPaper alloc] initWithPaperSizeTitle:self.currentPaper.sizeTitle paperTypeTitle:selectedCell.textLabel.text];
    
    [self.navigationController popViewControllerAnimated:YES];
    
    if ([self.delegate respondsToSelector:@selector(paperTypeTableViewController:didSelectPaper:)]) {
        [self.delegate paperTypeTableViewController:self didSelectPaper:paper];
    }
}

@end
