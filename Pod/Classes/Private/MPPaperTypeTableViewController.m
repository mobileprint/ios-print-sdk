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

#import "MPPaperTypeTableViewController.h"
#import "MP.h"
#import "MPPaper.h"
#import "NSBundle+MPLocalizable.h"


NSString * const kPaperTypeScreenName = @"Paper Type Screen";

@interface MPPaperTypeTableViewController ()

@property (strong, nonatomic) MP *mp;

@end

@implementation MPPaperTypeTableViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = MPLocalizedString(@"Paper Type", @"Title of the Paper Type screen");
    
    self.mp = [MP sharedInstance];
    
    self.tableView.backgroundColor = [[MP sharedInstance].appearance.settings objectForKey:kMPGeneralBackgroundColor];
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    self.tableView.separatorColor = [[MP sharedInstance].appearance.settings objectForKey:kMPGeneralTableSeparatorColor];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kMPTrackableScreenNotification object:nil userInfo:[NSDictionary dictionaryWithObject:kPaperTypeScreenName forKey:kMPTrackableScreenNameKey]];
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [[self uniqueTypeTitles] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"PaperTypeTableViewCellIdentifier"];
    
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"PaperTypeTableViewCellIdentifier"];
    }
    
    cell.backgroundColor = [self.mp.appearance.settings objectForKey:kMPSelectionOptionsBackgroundColor];
    cell.textLabel.font = [self.mp.appearance.settings objectForKey:kMPSelectionOptionsPrimaryFont];
    cell.textLabel.textColor = [self.mp.appearance.settings objectForKey:kMPSelectionOptionsPrimaryFontColor];
    
    cell.textLabel.text = [self uniqueTypeTitles][indexPath.row];
    
    if ([cell.textLabel.text isEqualToString:self.currentPaper.typeTitle]) {
        cell.accessoryView = [[UIImageView alloc] initWithImage:[self.mp.appearance.settings objectForKey:kMPSelectionOptionsCheckmarkImage]];
    }
    
    return cell;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    for (NSInteger i = 0; i < [[self uniqueTypeTitles] count]; i++) {
        UITableViewCell *cell = [tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:0]];
        cell.accessoryView = nil;
    }
    
    UITableViewCell *selectedCell = [tableView cellForRowAtIndexPath:indexPath];
    selectedCell.accessoryView = [[UIImageView alloc] initWithImage:[self.mp.appearance.settings objectForKey:kMPSelectionOptionsCheckmarkImage]];
    
    MPPaper *paper = [[MPPaper alloc] initWithPaperSizeTitle:self.currentPaper.sizeTitle paperTypeTitle:selectedCell.textLabel.text];
    
    [self.navigationController popViewControllerAnimated:YES];
    
    if ([self.delegate respondsToSelector:@selector(paperTypeTableViewController:didSelectPaper:)]) {
        [self.delegate paperTypeTableViewController:self didSelectPaper:paper];
    }
}

- (NSArray *)uniqueTypeTitles
{
    NSMutableArray *typeTitles = [NSMutableArray array];
    if (self.currentPaper) {
        for (NSNumber *paperType in [self.currentPaper supportedTypes]) {
            [typeTitles addObject:[MPPaper titleFromType:[paperType unsignedIntegerValue]]];
        }
    } else {
        for (MPPaper *paper in [MP sharedInstance].supportedPapers) {
            if (![typeTitles containsObject:paper.typeTitle]) {
                [typeTitles addObject:paper.typeTitle];
            }
        }
    }
    return typeTitles;
}

@end
