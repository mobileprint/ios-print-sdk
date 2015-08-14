//
//  HPPPPrintSettingsDelegateManager.h
//  Pods
//
//  Created by Bozo on 8/11/15.
//
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
