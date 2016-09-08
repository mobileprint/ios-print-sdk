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

#import "MP.h"
#import "MPPrinter.h"
#import "MPPaper.h"
#import "MPPrintSettingsTableViewController.h"
#import "MPPaperSizeTableViewController.h"
#import "MPPaperTypeTableViewController.h"
#import "MPWiFiReachability.h"
#import "UITableView+MPHeader.h"
#import "NSBundle+MPLocalizable.h"
#import "UIImage+MPBundle.h"

#define PRINTER_SELECTION_SECTION 0
#define PAPER_SELECTION_SECTION 1

#define PAPER_SIZE_ROW_INDEX 0
#define PAPER_TYPE_ROW_INDEX 1

@interface MPPrintSettingsTableViewController  () <MPPaperSizeTableViewControllerDelegate, MPPaperTypeTableViewControllerDelegate, UIPrinterPickerControllerDelegate>

@property (nonatomic, strong) MP *mp;

@property (weak, nonatomic) IBOutlet UILabel *printerLabel;
@property (weak, nonatomic) IBOutlet UILabel *paperSizeLabel;
@property (weak, nonatomic) IBOutlet UILabel *paperTypeLabel;

@property (weak, nonatomic) IBOutlet UILabel *selectedPrinterLabel;
@property (weak, nonatomic) IBOutlet UILabel *selectedPaperSizeLabel;
@property (weak, nonatomic) IBOutlet UILabel *selectedPaperTypeLabel;

@property (weak, nonatomic) IBOutlet UITableViewCell *paperSizeCell;
@property (weak, nonatomic) IBOutlet UITableViewCell *paperTypeCell;
@property (weak, nonatomic) IBOutlet UITableViewCell *printerSelectCell;

@end

@implementation MPPrintSettingsTableViewController

NSString * const kPrintSettingsScreenName = @"Print Settings Screen";

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = MPLocalizedString(@"Print Settings", @"Title of the print settings screen");
    
    self.mp = [MP sharedInstance];
    
    self.paperSizeCell.backgroundColor = [self.mp.appearance.settings objectForKey:kMPSelectionOptionsBackgroundColor];
    self.paperSizeCell.accessoryView = [[UIImageView alloc] initWithImage:[self.mp.appearance.settings objectForKey:kMPSelectionOptionsDisclosureIndicatorImage]];
    
    self.paperTypeCell.backgroundColor = [self.mp.appearance.settings objectForKey:kMPSelectionOptionsBackgroundColor];
    self.paperTypeCell.accessoryView = [[UIImageView alloc] initWithImage:[self.mp.appearance.settings objectForKey:kMPSelectionOptionsDisclosureIndicatorImage]];
    
    self.printerSelectCell.backgroundColor = [self.mp.appearance.settings objectForKey:kMPSelectionOptionsBackgroundColor];
    
    self.selectedPrinterLabel.text = self.printSettings.printerName;
    
    self.selectedPaperSizeLabel.text = self.printSettings.paper.sizeTitle;
    self.selectedPaperTypeLabel.text = self.printSettings.paper.typeTitle;
    
    self.printerLabel.font = [self.mp.appearance.settings objectForKey:kMPSelectionOptionsPrimaryFont];
    self.printerLabel.textColor = [self.mp.appearance.settings objectForKey:kMPSelectionOptionsPrimaryFontColor];
    self.printerLabel.text = MPLocalizedString(@"Printer", nil);

    self.selectedPrinterLabel.font = [self.mp.appearance.settings objectForKey:kMPSelectionOptionsSecondaryFont];
    self.selectedPrinterLabel.textColor = [self.mp.appearance.settings objectForKey:kMPSelectionOptionsSecondaryFontColor];
    
    self.paperSizeLabel.font = [self.mp.appearance.settings objectForKey:kMPSelectionOptionsPrimaryFont];
    self.paperSizeLabel.textColor = [self.mp.appearance.settings objectForKey:kMPSelectionOptionsPrimaryFontColor];
    self.paperSizeLabel.text = MPLocalizedString(@"Paper Size", nil);
    
    self.selectedPaperSizeLabel.font = [self.mp.appearance.settings objectForKey:kMPSelectionOptionsSecondaryFont];
    self.selectedPaperSizeLabel.textColor = [self.mp.appearance.settings objectForKey:kMPSelectionOptionsSecondaryFontColor];
    
    self.paperTypeLabel.font = [self.mp.appearance.settings objectForKey:kMPSelectionOptionsPrimaryFont];
    self.paperTypeLabel.textColor = [self.mp.appearance.settings objectForKey:kMPSelectionOptionsPrimaryFontColor];
    self.paperTypeLabel.text = MPLocalizedString(@"Paper Type", nil);
    
    self.selectedPaperTypeLabel.font = [self.mp.appearance.settings objectForKey:kMPSelectionOptionsSecondaryFont];
    self.selectedPaperTypeLabel.textColor = [self.mp.appearance.settings objectForKey:kMPSelectionOptionsSecondaryFontColor];
    
    [self updatePrinterAvailability];
    
    self.tableView.backgroundColor = [self.mp.appearance.settings objectForKey:kMPGeneralBackgroundColor];
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    self.tableView.separatorColor = [self.mp.appearance.settings objectForKey:kMPGeneralTableSeparatorColor];
    
    if (IS_OS_8_OR_LATER) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleDidCheckPrinterAvailability:) name:kMPPrinterAvailabilityNotification object:nil];
    }
}

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kMPTrackableScreenNotification object:nil userInfo:[NSDictionary dictionaryWithObject:kPrintSettingsScreenName forKey:kMPTrackableScreenNameKey]];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - Utils

- (void)updatePrinterAvailability
{
    [self.tableView beginUpdates];
    if (self.printSettings.printerIsAvailable){
        [self.printerSelectCell.imageView setImage:nil];
    } else {
        UIImage *warningSign = [UIImage imageResource:@"MPDoNoEnter" ofType:@"png"];
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
        if ([[self.printSettings.paper supportedTypes] count] > 1) {
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
        if ([[MPWiFiReachability sharedInstance] isWifiConnected]) {
            UIPrinterPickerController* printerPicker = [UIPrinterPickerController printerPickerControllerWithInitiallySelectedPrinter:nil];
            printerPicker.delegate = self;
            
            if( !self.splitViewController.isCollapsed ) {
                [printerPicker presentFromRect:self.printerSelectCell.frame
                                        inView:tableView
                                      animated:YES
                             completionHandler:^(UIPrinterPickerController *printerPickerController, BOOL userDidSelect, NSError *error){
                                 MPLogInfo(@"closed printer picker");
                             }];
            } else {
                [printerPicker presentAnimated:YES completionHandler:^(UIPrinterPickerController *printerPickerController, BOOL userDidSelect, NSError *error){
                    MPLogInfo(@"closed printer picker");
                }];
            }
        } else {
            [[MPWiFiReachability sharedInstance] noPrinterSelectAlert];
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
            if (!self.mp.hidePaperSizeOption) {
                rowHeight = tableView.rowHeight;
            }
        } else if (indexPath.row == PAPER_TYPE_ROW_INDEX) {
            if (!self.mp.hidePaperTypeOption && [[self.printSettings.paper supportedTypes] count] > 1) {
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
            label.font = [self.mp.appearance.settings objectForKey:kMPGeneralBackgroundPrimaryFont];
            label.textColor = [self.mp.appearance.settings objectForKey:kMPGeneralBackgroundPrimaryFontColor];
            if (self.useDefaultPrinter) {
                label.text = MPLocalizedString(@"Default printer not currently available", nil);
            } else {
                label.text = MPLocalizedString(@"Recent printer not currently available", nil);
            }
            [footer addSubview:label];
        }
    }
    
    return footer;
}

#pragma mark - UIPrinterPickerControllerDelegate

- (UIViewController *)printerPickerControllerParentViewController:(UIPrinterPickerController *)printerPickerController
{
    UIViewController *retVal = nil;
    
    if( self.splitViewController.isCollapsed ) {
        retVal = self;
    }
    
    return retVal;
}

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
        
        self.selectedPaperSizeLabel.text = self.printSettings.paper.sizeTitle;
        [self.tableView reloadData];
    }
}

#pragma mark - MPPaperSizeTableViewControllerDelegate

- (void)paperSizeTableViewController:(MPPaperSizeTableViewController *)paperSizeTableViewController didSelectPaper:(MPPaper *)paper
{
    MPPaper *originalPaper = self.printSettings.paper;
    MPPaper *newPaper = paper;
    if (![[originalPaper supportedTypes] isEqualToArray:[newPaper supportedTypes]]) {
        NSUInteger defaultType = [[MPPaper defaultTypeForSize:paper.paperSize] unsignedIntegerValue];
        newPaper = [[MPPaper alloc] initWithPaperSize:paper.paperSize paperType:defaultType];
    }
    
    self.printSettings.paper = newPaper;
    
    // This block of beginUpdates-endUpdates is required to refresh the tableView while it is currently being displayed on screen
    [self.tableView beginUpdates];

    self.selectedPaperSizeLabel.text = self.printSettings.paper.sizeTitle;
    self.selectedPaperTypeLabel.text = self.printSettings.paper.typeTitle;
    [self reloadPaperSelectionSection];

    [self.tableView endUpdates];
    
    if ([self.delegate respondsToSelector:@selector(printSettingsTableViewController:didChangePrintSettings:)]) {
        [self.delegate printSettingsTableViewController:self didChangePrintSettings:self.printSettings];
    }
}

#pragma mark - MPPaperTypeTableViewControllerDelegate

- (void)paperTypeTableViewController:(MPPaperTypeTableViewController *)paperTypeTableViewController didSelectPaper:(MPPaper *)paper
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
        
        MPPaperSizeTableViewController *vc = (MPPaperSizeTableViewController *)segue.destinationViewController;
        vc.currentPaper = self.printSettings.paper;
        vc.delegate = self;
    } else if ([segue.identifier isEqualToString:@"PaperTypeSegue"]) {
        
        MPPaperTypeTableViewController *vc = (MPPaperTypeTableViewController *)segue.destinationViewController;
        vc.currentPaper = self.printSettings.paper;
        vc.delegate = self;
    }
}

#pragma mark - Notifications

- (void)handleDidCheckPrinterAvailability:(NSNotification *)notification
{
    MPLogInfo(@"handleDidCheckPrinterAvailability: %@", notification);

    BOOL available = [[notification.userInfo objectForKey:kMPPrinterAvailableKey] boolValue];
    
    self.printSettings.printerIsAvailable = available;
    
    [self updatePrinterAvailability];
}

@end
