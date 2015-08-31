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

#import "HPPP.h"
#import "HPPPPrinter.h"
#import "HPPPPaper.h"
#import "HPPPPrintSettingsTableViewController.h"
#import "HPPPPaperSizeTableViewController.h"
#import "HPPPPaperTypeTableViewController.h"
#import "HPPPWiFiReachability.h"
#import "UITableView+HPPPHeader.h"
#import "NSBundle+HPPPLocalizable.h"

#define PRINTER_SELECTION_SECTION 0
#define PAPER_SELECTION_SECTION 1

#define PAPER_SIZE_ROW_INDEX 0
#define PAPER_TYPE_ROW_INDEX 1

@interface HPPPPrintSettingsTableViewController  () <HPPPPaperSizeTableViewControllerDelegate, HPPPPaperTypeTableViewControllerDelegate, UIPrinterPickerControllerDelegate>

@property (nonatomic, strong) HPPP *hppp;

@property (weak, nonatomic) IBOutlet UILabel *printerLabel;
@property (weak, nonatomic) IBOutlet UILabel *paperSizeLabel;
@property (weak, nonatomic) IBOutlet UILabel *paperTypeLabel;

@property (weak, nonatomic) IBOutlet UILabel *selectedPrinterLabel;
@property (weak, nonatomic) IBOutlet UILabel *selectedPaperSizeLabel;
@property (weak, nonatomic) IBOutlet UILabel *selectedPaperTypeLabel;

@property (weak, nonatomic) IBOutlet UITableViewCell *paperSizeCell;
@property (weak, nonatomic) IBOutlet UITableViewCell *paperTypeCell;
@property (weak, nonatomic) IBOutlet UITableViewCell *printerSelectCell;

@property (strong, nonatomic) UIRefreshControl *refreshControl;

@end

@implementation HPPPPrintSettingsTableViewController

NSString * const kPrintSettingsScreenName = @"Print Settings Screen";

@dynamic refreshControl;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = HPPPLocalizedString(@"Print Settings", @"Title of the Print Settings screen");
    
    self.hppp = [HPPP sharedInstance];
    
    self.paperSizeCell.backgroundColor = [self.hppp.appearance.settings objectForKey:kHPPPSelectionOptionsBackgroundColor];
    self.paperTypeCell.backgroundColor = [self.hppp.appearance.settings objectForKey:kHPPPSelectionOptionsBackgroundColor];
    self.printerSelectCell.backgroundColor = [self.hppp.appearance.settings objectForKey:kHPPPSelectionOptionsBackgroundColor];
    
    self.selectedPrinterLabel.text = self.printSettings.printerName;
    
    self.selectedPaperSizeLabel.text = self.printSettings.paper.sizeTitle;
    self.selectedPaperTypeLabel.text = self.printSettings.paper.typeTitle;
    
    self.printerLabel.font = [self.hppp.appearance.settings objectForKey:kHPPPSelectionOptionsPrimaryFont];
    self.printerLabel.textColor = [self.hppp.appearance.settings objectForKey:kHPPPSelectionOptionsPrimaryFontColor];
    self.printerLabel.text = HPPPLocalizedString(@"Printer", nil);

    self.selectedPrinterLabel.font = [self.hppp.appearance.settings objectForKey:kHPPPSelectionOptionsSecondaryFont];
    self.selectedPrinterLabel.textColor = [self.hppp.appearance.settings objectForKey:kHPPPSelectionOptionsSecondaryFontColor];
    
    self.paperSizeLabel.font = [self.hppp.appearance.settings objectForKey:kHPPPSelectionOptionsPrimaryFont];
    self.paperSizeLabel.textColor = [self.hppp.appearance.settings objectForKey:kHPPPSelectionOptionsPrimaryFontColor];
    self.paperSizeLabel.text = HPPPLocalizedString(@"Paper Size", nil);
    
    self.selectedPaperSizeLabel.font = [self.hppp.appearance.settings objectForKey:kHPPPSelectionOptionsSecondaryFont];
    self.selectedPaperSizeLabel.textColor = [self.hppp.appearance.settings objectForKey:kHPPPSelectionOptionsSecondaryFontColor];
    
    self.paperTypeLabel.font = [self.hppp.appearance.settings objectForKey:kHPPPSelectionOptionsPrimaryFont];
    self.paperTypeLabel.textColor = [self.hppp.appearance.settings objectForKey:kHPPPSelectionOptionsPrimaryFontColor];
    self.paperTypeLabel.text = HPPPLocalizedString(@"Paper Type", nil);
    
    self.selectedPaperTypeLabel.font = [self.hppp.appearance.settings objectForKey:kHPPPSelectionOptionsSecondaryFont];
    self.selectedPaperTypeLabel.textColor = [self.hppp.appearance.settings objectForKey:kHPPPSelectionOptionsSecondaryFontColor];
    
    [self updatePrinterAvailability];
    
    self.tableView.backgroundColor = [self.hppp.appearance.settings objectForKey:kHPPPBackgroundBackgroundColor];
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    
    if (IS_OS_8_OR_LATER) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleDidCheckPrinterAvailability:) name:kHPPPPrinterAvailabilityNotification object:nil];
        
        self.refreshControl = [[UIRefreshControl alloc] init];
        [self.refreshControl addTarget:self action:@selector(startRefreshing:) forControlEvents:UIControlEventValueChanged];
        [self.tableView addSubview:self.refreshControl];
    }
}

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kHPPPTrackableScreenNotification object:nil userInfo:[NSDictionary dictionaryWithObject:kPrintSettingsScreenName forKey:kHPPPTrackableScreenNameKey]];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - Pull to refresh

- (void)startRefreshing:(UIRefreshControl *)refreshControl
{
    [[HPPPPrinter sharedInstance] checkLastPrinterUsedAvailability];
}

#pragma mark - Utils

- (void)updatePrinterAvailability
{
    [self.tableView beginUpdates];
    if (self.printSettings.printerIsAvailable){
        [self.printerSelectCell.imageView setImage:nil];
    } else {
        UIImage *warningSign = [UIImage imageNamed:@"HPPPDoNoEnter"];
        [self.printerSelectCell.imageView setImage:warningSign];
    }
    [self.tableView endUpdates];
    
    [self reloadPrinterSelectionSection];
}

- (void)reloadPrinterSelectionSection
{
    NSRange range = NSMakeRange(PRINTER_SELECTION_SECTION, 1);
    NSIndexSet *sectionToReload = [NSIndexSet indexSetWithIndexesInRange:range];
    [self.tableView reloadSections:sectionToReload withRowAnimation:UITableViewRowAnimationNone];
}

- (void)reloadPaperSelectionSection
{
    NSRange range = NSMakeRange(PAPER_SELECTION_SECTION, 1);
    NSIndexSet *sectionToReload = [NSIndexSet indexSetWithIndexesInRange:range];
    [self.tableView reloadSections:sectionToReload withRowAnimation:UITableViewRowAnimationNone];
}

#pragma mark - UITableViewDelegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == PAPER_SELECTION_SECTION) {
        if (self.printSettings.paper.paperSize == SizeLetter) {
            return 2;
        } else {
            return 1;
        }
    } else {
        return [super tableView:tableView numberOfRowsInSection:section];
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    cell.selected = NO;
    
    if (cell == self.printerSelectCell) {
        if ([[HPPPWiFiReachability sharedInstance] isWifiConnected]) {
            UIPrinterPickerController* printerPicker = [UIPrinterPickerController printerPickerControllerWithInitiallySelectedPrinter:nil];
            printerPicker.delegate = self;
            
            if( IS_IPAD ) {
                [printerPicker presentFromRect:self.printerSelectCell.frame
                                        inView:tableView
                                      animated:YES
                             completionHandler:^(UIPrinterPickerController *printerPickerController, BOOL userDidSelect, NSError *error){
                                 HPPPLogInfo(@"closed printer picker");
                             }];
            } else {
                [printerPicker presentAnimated:YES completionHandler:^(UIPrinterPickerController *printerPickerController, BOOL userDidSelect, NSError *error){
                    HPPPLogInfo(@"closed printer picker");
                }];
            }
        } else {
            [[HPPPWiFiReachability sharedInstance] noPrinterSelectAlert];
        }
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [super tableView:tableView cellForRowAtIndexPath:indexPath];
    
    if (cell.hidden == YES) {
        return 0.0f;
    }
    
    CGFloat rowHeight = 0.0f;
    
    if (indexPath.section == PAPER_SELECTION_SECTION) {
        if (indexPath.row == PAPER_SIZE_ROW_INDEX) {
            if (!self.hppp.hidePaperSizeOption) {
                rowHeight = tableView.rowHeight;
            }
        } else if (indexPath.row == PAPER_TYPE_ROW_INDEX) {
            if ((!self.hppp.hidePaperTypeOption) && (self.printSettings.paper.paperSize == SizeLetter)) {
                rowHeight = tableView.rowHeight;
            }
        }
    } else {
        rowHeight = tableView.rowHeight;
    }
    
    return rowHeight;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (section == PRINTER_SELECTION_SECTION) {
        return [super tableView:tableView heightForHeaderInSection:section];
    } else {
        return ZERO_HEIGHT;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    CGFloat height = ZERO_HEIGHT;
    
    if (section == PRINTER_SELECTION_SECTION) {
        if (self.printSettings.printerIsAvailable) {
            height = SEPARATOR_SECTION_FOOTER_HEIGHT;
        } else {
            height = PRINTER_WARNING_SECTION_FOOTER_HEIGHT;
        }
    }
    
    return height;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    UIView *footer = nil;
    
    if (section == PRINTER_SELECTION_SECTION) {
        if (!self.printSettings.printerIsAvailable) {
            footer = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, tableView.frame.size.width, PRINTER_WARNING_SECTION_FOOTER_HEIGHT)];
            UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(20.0f, 0.0f, tableView.frame.size.width - 20.0f, PRINTER_WARNING_SECTION_FOOTER_HEIGHT)];
            label.font = [self.hppp.appearance.settings objectForKey:kHPPPBackgroundPrimaryFont];
            label.textColor = [self.hppp.appearance.settings objectForKey:kHPPPBackgroundPrimaryFontColor];
            if (self.useDefaultPrinter) {
                label.text = HPPPLocalizedString(@"Default printer not currently available", nil);
            } else {
                label.text = HPPPLocalizedString(@"Recent printer not currently available", nil);
            }
            [footer addSubview:label];
        }
    }
    
    return footer;
}

#pragma mark - UIPrinterPickerControllerDelegate

- (void)printerPickerControllerDidDismiss:(UIPrinterPickerController *)printerPickerController
{
    UIPrinter *selectedPrinter = printerPickerController.selectedPrinter;
    
    if (selectedPrinter != nil){
        self.selectedPrinterLabel.text = selectedPrinter.displayName;
        self.printSettings.printerName = selectedPrinter.displayName;
        self.printSettings.printerUrl = selectedPrinter.URL;
        self.printSettings.printerModel = selectedPrinter.makeAndModel;
        self.printSettings.printerLocation = selectedPrinter.displayLocation;
        self.printSettings.printerIsAvailable = YES;
        
        [self updatePrinterAvailability];
        
        if ([self.delegate respondsToSelector:@selector(printSettingsTableViewController:didChangePrintSettings:)]) {
            [self.delegate printSettingsTableViewController:self didChangePrintSettings:self.printSettings];
        }
    }
}

#pragma mark - HPPPPaperSizeTableViewControllerDelegate

- (void)paperSizeTableViewController:(HPPPPaperSizeTableViewController *)paperSizeTableViewController didSelectPaper:(HPPPPaper *)paper
{
    self.printSettings.paper = paper;
    
    [self reloadPaperSelectionSection];
    
    self.selectedPaperSizeLabel.text = paper.sizeTitle;
    
    // This block of beginUpdates-endUpdates is required to refresh the tableView while it is currently being displayed on screen
    [self.tableView beginUpdates];
    if (paper.paperSize == SizeLetter) {
        self.printSettings.paper.paperType = Plain;
        self.printSettings.paper.typeTitle = [HPPPPaper titleFromType:Plain];
        self.selectedPaperTypeLabel.text = self.printSettings.paper.typeTitle;
        
    } else {
        self.printSettings.paper.paperType = Photo;
        self.printSettings.paper.typeTitle = [HPPPPaper titleFromType:Photo];
        self.selectedPaperTypeLabel.text = self.printSettings.paper.typeTitle;
    }
    [self.tableView endUpdates];
    
    if ([self.delegate respondsToSelector:@selector(printSettingsTableViewController:didChangePrintSettings:)]) {
        [self.delegate printSettingsTableViewController:self didChangePrintSettings:self.printSettings];
    }
}

#pragma mark - HPPPPaperTypeTableViewControllerDelegate

- (void)paperTypeTableViewController:(HPPPPaperTypeTableViewController *)paperTypeTableViewController didSelectPaper:(HPPPPaper *)paper
{
    self.printSettings.paper = paper;
    self.selectedPaperTypeLabel.text = paper.typeTitle;
    
    
    if ([self.delegate respondsToSelector:@selector(printSettingsTableViewController:didChangePrintSettings:)]) {
        [self.delegate printSettingsTableViewController:self didChangePrintSettings:self.printSettings];
    }
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"PaperSizeSegue"]) {
        
        HPPPPaperSizeTableViewController *vc = (HPPPPaperSizeTableViewController *)segue.destinationViewController;
        vc.currentPaper = self.printSettings.paper;
        vc.delegate = self;
    } else if ([segue.identifier isEqualToString:@"PaperTypeSegue"]) {
        
        HPPPPaperTypeTableViewController *vc = (HPPPPaperTypeTableViewController *)segue.destinationViewController;
        vc.currentPaper = self.printSettings.paper;
        vc.delegate = self;
    }
}

#pragma mark - Notifications

- (void)handleDidCheckPrinterAvailability:(NSNotification *)notification
{
    BOOL available = [[notification.userInfo objectForKey:kHPPPPrinterAvailableKey] boolValue];
    
    self.printSettings.printerIsAvailable = available;
    
    [self updatePrinterAvailability];
    
    if (IS_OS_8_OR_LATER) {
        if (self.refreshControl.refreshing) {
            [self.refreshControl endRefreshing];
        }
    }
}

@end
