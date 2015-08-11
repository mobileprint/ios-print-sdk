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

#import "HPPPSubstitutePaperSizeTableViewController.h"
#import "HPPP.h"
#import "HPPPPaper.h"

NSString * const kSubstitutePaperSizeScreenName = @"Paper Size Screen";

@interface HPPPSubstitutePaperSizeTableViewController ()

@property (nonatomic, strong) HPPP *hppp;

@end

@implementation HPPPSubstitutePaperSizeTableViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = @"Paper Size";
    
    self.hppp = [HPPP sharedInstance];
    
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
}

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kHPPPTrackableScreenNotification object:nil userInfo:[NSDictionary dictionaryWithObject:kSubstitutePaperSizeScreenName forKey:kHPPPTrackableScreenNameKey]];
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.hppp.paperSizes.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"PaperSizeTableViewCellIdentifier"];
    
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"PaperSizeTableViewCellIdentifier"];
    }
    
    cell.textLabel.font = self.hppp.tableViewCellLabelFont;
    cell.textLabel.textColor = self.hppp.tableViewCellLabelColor;
    
    cell.textLabel.text = self.hppp.paperSizes[indexPath.row];
    
    if ([cell.textLabel.text isEqualToString:self.currentPaper.sizeTitle]) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    }
    
    return cell;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    for (NSInteger i = 0; i < self.hppp.paperSizes.count; i++) {
        UITableViewCell *cell = [tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:0]];
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    
    UITableViewCell *selectedCell = [tableView cellForRowAtIndexPath:indexPath];
    selectedCell.accessoryType = UITableViewCellAccessoryCheckmark;
    
    NSString *typeTitle = (SizeLetter == [HPPPPaper sizeFromTitle:selectedCell.textLabel.text] ? self.currentPaper.typeTitle : @"Photo Paper");
    HPPPPaper *paper = [[HPPPPaper alloc] initWithPaperSizeTitle:selectedCell.textLabel.text paperTypeTitle:typeTitle];
    
    [self.navigationController popViewControllerAnimated:YES];
    
    if ([self.delegate respondsToSelector:@selector(paperSizeTableViewController:didSelectPaper:)]) {
        [self.delegate paperSizeTableViewController:self didSelectPaper:paper];
    }
}

@end
