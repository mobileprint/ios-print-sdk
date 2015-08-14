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

#import <Foundation/Foundation.h>
#import "HPPPPrintSettings.h"
#import "HPPPPrintItem.h"

#import "HPPPPageRangeView.h"
#import "HPPPPrintSettingsTableViewController.h"
#import "HPPPPaperSizeTableViewController.h"
#import "HPPPPaperTypeTableViewController.h"

#import "HPPPPageSettingsTableViewController.h"

@interface HPPPPrintSettingsDelegateManager : NSObject
    <HPPPPageRangeViewDelegate,
     HPPPPrintSettingsTableViewControllerDelegate,
     HPPPPaperSizeTableViewControllerDelegate,
     HPPPPaperTypeTableViewControllerDelegate,
     UIPrinterPickerControllerDelegate>

@property (weak, nonatomic) HPPPPageSettingsTableViewController *vc;
@property (nonatomic, weak) id<HPPPPrintDataSource> dataSource;

@property (strong, nonatomic) HPPPPrintSettings *currentPrintSettings;
@property (strong, nonatomic) HPPPPrintItem *printItem;

@property (strong, nonatomic) HPPPPageRange *pageRange;
@property (assign, nonatomic) NSInteger numCopies;
@property (assign, nonatomic) BOOL blackAndWhite;

@property (strong, nonatomic) NSString *printLabelText;
@property (strong, nonatomic) NSString *numCopiesLabelText;
@property (strong, nonatomic) NSString *printJobSummaryText;
@property (strong, nonatomic) NSString *pageRangeText;

- (BOOL)allPagesSelected;
- (BOOL)noPagesSelected;
- (void)includePageInPageRange:(BOOL)includePage pageNumber:(NSInteger)pageNumber;
- (void)loadLastUsed;
- (void)setLastOptionsUsedWithPrintController:(UIPrintInteractionController *)printController;

@end
