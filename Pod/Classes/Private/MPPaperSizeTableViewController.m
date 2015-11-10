//
// HP Inc.
// All rights reserved.
//
// This file, its contents, concepts, methods, behavior, and operation
// (collectively the "Software") are protected by trade secret, patent,
// and copyright laws. The use of the Software is governed by a license
// agreement. Disclosure of the Software to third parties, in any form,
// in whole or in part, is expressly prohibited except as authorized by
// the license agreement.
//

#import "MPPaperSizeTableViewController.h"
#import "MP.h"
#import "MPPaper.h"
#import "UIColor+MPStyle.h"
#import "UITableView+MPHeader.h"
#import "NSBundle+MPLocalizable.h"

NSString * const kPaperSizeScreenName = @"Paper Size Screen";

@interface MPPaperSizeTableViewController ()

@property (nonatomic, strong) MP *mp;

@end

@implementation MPPaperSizeTableViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = MPLocalizedString(@"Paper Size", @"Title of the Paper Size screen");
    
    self.mp = [MP sharedInstance];
    
    self.tableView.backgroundColor = [[MP sharedInstance].appearance.settings objectForKey:kMPGeneralBackgroundColor];
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    self.tableView.separatorColor = [[MP sharedInstance].appearance.settings objectForKey:kMPGeneralTableSeparatorColor];
}

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kMPTrackableScreenNotification object:nil userInfo:[NSDictionary dictionaryWithObject:kPaperSizeScreenName forKey:kMPTrackableScreenNameKey]];
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [[self uniqueSizeTitles] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"PaperSizeTableViewCellIdentifier"];
    
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"PaperSizeTableViewCellIdentifier"];
    }
    
    cell.backgroundColor = [self.mp.appearance.settings objectForKey:kMPSelectionOptionsBackgroundColor];
    cell.textLabel.font = [self.mp.appearance.settings objectForKey:kMPSelectionOptionsPrimaryFont];
    cell.textLabel.textColor = [self.mp.appearance.settings objectForKey:kMPSelectionOptionsPrimaryFontColor];
    
    cell.textLabel.text = [self uniqueSizeTitles][indexPath.row];
    
    if ([cell.textLabel.text isEqualToString:self.currentPaper.sizeTitle]) {
        cell.accessoryView = [[UIImageView alloc] initWithImage:[self.mp.appearance.settings objectForKey:kMPSelectionOptionsCheckmarkImage]];
    }
    
    return cell;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    for (NSInteger i = 0; i < [[self uniqueSizeTitles] count]; i++) {
        UITableViewCell *cell = [tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:0]];
        cell.accessoryView = nil;
    }
    
    UITableViewCell *selectedCell = [tableView cellForRowAtIndexPath:indexPath];
    selectedCell.accessoryView = [[UIImageView alloc] initWithImage:[self.mp.appearance.settings objectForKey:kMPSelectionOptionsCheckmarkImage]];
    
    NSUInteger selectedSize = [MPPaper sizeFromTitle:selectedCell.textLabel.text];
    NSUInteger defaultSize = [[MPPaper defaultTypeForSize:selectedSize] unsignedIntegerValue];
    MPPaper *paper = [[MPPaper alloc] initWithPaperSize:selectedSize paperType:defaultSize];
    if ([paper supportsType:self.currentPaper.paperType]) {
        paper = [[MPPaper alloc] initWithPaperSize:selectedSize paperType:self.currentPaper.paperType];
    }
    
    [self.navigationController popViewControllerAnimated:YES];
    
    if ([self.delegate respondsToSelector:@selector(paperSizeTableViewController:didSelectPaper:)]) {
        [self.delegate paperSizeTableViewController:self didSelectPaper:paper];
    }
}

- (NSArray *)uniqueSizeTitles
{
    NSMutableArray *sizeTitles = [NSMutableArray array];
    for (MPPaper *paper in [MP sharedInstance].supportedPapers) {
        if (![sizeTitles containsObject:paper.sizeTitle]) {
            [sizeTitles addObject:paper.sizeTitle];
        }
    }
    return sizeTitles;
}

@end
