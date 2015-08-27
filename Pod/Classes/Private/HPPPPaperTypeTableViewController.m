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
#import "HPPP.h"
#import "HPPPPaper.h"
#import "NSBundle+HPPPLocalizable.h"


NSString * const kPaperTypeScreenName = @"Paper Type Screen";

@interface HPPPPaperTypeTableViewController ()

@property (strong, nonatomic) HPPP *hppp;
@property (strong, nonatomic) IBOutletCollection(UITableViewCell) NSArray *paperTypeCells;

@end

@implementation HPPPPaperTypeTableViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = HPPPLocalizedString(@"Paper Type", @"Title of the Paper Type screen");
    
    self.hppp = [HPPP sharedInstance];
    
    self.tableView.backgroundColor = [[HPPP sharedInstance].appearance.settings objectForKey:kHPPPBackgroundBackgroundColor];
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    
    NSArray *localizeTitleArray = @[HPPPLocalizedString(@"Plain Paper", @"Option of paper type"), HPPPLocalizedString(@"Photo Paper", @"Option of paper type")];
    
    NSInteger i = 0;
    for (UITableViewCell *cell in self.paperTypeCells) {
        cell.textLabel.font = [self.hppp.appearance.settings objectForKey:kHPPPSelectionOptionsPrimaryFont];
        cell.textLabel.textColor = [self.hppp.appearance.settings objectForKey:kHPPPSelectionOptionsPrimaryFontColor];
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
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kHPPPTrackableScreenNotification object:nil userInfo:[NSDictionary dictionaryWithObject:kPaperTypeScreenName forKey:kHPPPTrackableScreenNameKey]];
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
