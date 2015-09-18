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

@end

@implementation HPPPPaperTypeTableViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = HPPPLocalizedString(@"Paper Type", @"Title of the Paper Type screen");
    
    self.hppp = [HPPP sharedInstance];
    
    self.tableView.backgroundColor = [[HPPP sharedInstance].appearance.settings objectForKey:kHPPPGeneralBackgroundColor];
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    self.tableView.separatorColor = [[HPPP sharedInstance].appearance.settings objectForKey:kHPPPGeneralTableSeparatorColor];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kHPPPTrackableScreenNotification object:nil userInfo:[NSDictionary dictionaryWithObject:kPaperTypeScreenName forKey:kHPPPTrackableScreenNameKey]];
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
    
    cell.backgroundColor = [self.hppp.appearance.settings objectForKey:kHPPPSelectionOptionsBackgroundColor];
    cell.textLabel.font = [self.hppp.appearance.settings objectForKey:kHPPPSelectionOptionsPrimaryFont];
    cell.textLabel.textColor = [self.hppp.appearance.settings objectForKey:kHPPPSelectionOptionsPrimaryFontColor];
    
    cell.textLabel.text = [self uniqueTypeTitles][indexPath.row];
    
    if ([cell.textLabel.text isEqualToString:self.currentPaper.typeTitle]) {
        cell.accessoryView = [[UIImageView alloc] initWithImage:[self.hppp.appearance.settings objectForKey:kHPPPSelectionOptionsCheckmarkImage]];
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
    selectedCell.accessoryView = [[UIImageView alloc] initWithImage:[self.hppp.appearance.settings objectForKey:kHPPPSelectionOptionsCheckmarkImage]];
    
    HPPPPaper *paper = [[HPPPPaper alloc] initWithPaperSizeTitle:self.currentPaper.sizeTitle paperTypeTitle:selectedCell.textLabel.text];
    
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
            [typeTitles addObject:[HPPPPaper titleFromType:[paperType unsignedIntegerValue]]];
        }
    } else {
        for (HPPPPaper *paper in [HPPP sharedInstance].supportedPapers) {
            if (![typeTitles containsObject:paper.typeTitle]) {
                [typeTitles addObject:paper.typeTitle];
            }
        }
    }
    return typeTitles;
}

@end
