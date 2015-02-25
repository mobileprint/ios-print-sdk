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
#import "HPPPPageSettingsTableViewController.h"
#import "HPPPPaper.h"
#import "HPPPPrintPageRenderer.h"
#import "HPPPPrintSettings.h"
#import "HPPPPageView.h"
#import "HPPPPaperSizeTableViewController.h"
#import "HPPPPaperTypeTableViewController.h"
#import "HPPPPrintSettingsTableViewController.h"
#import "HPPPWiFiReachability.h"
#import "UITableView+HPPPHeader.h"
#import "UIColor+HPPPHexString.h"
#import "UIView+HPPPAnimation.h"
#import "UIImage+HPPPResize.h"
#import "UIColor+HPPPStyle.h"

#define DEFAULT_ROW_HEIGHT 44.0f

#define PRINT_FUNCTION_SECTION 0
#define PRINTER_SELECTION_SECTION 1
#define PAPER_SELECTION_SECTION 2
#define PRINT_SETTINGS_SECTION 3
#define FILTER_SECTION 4
#define SUPPORT_SECTION 5

#define PRINT_FUNCTION_ROW_INDEX 0
#define PRINTER_SELECTION_INDEX 0
#define PAPER_SIZE_ROW_INDEX 0
#define PAPER_TYPE_ROW_INDEX 1
#define PRINT_SETTINGS_ROW_INDEX 0
#define FILTER_ROW_INDEX 0

#define LAST_PRINTER_USED_SETTING @"lastPrinterUsed"
#define LAST_PRINTER_USED_URL_SETTING @"lastPrinterUrlUsed"
#define LAST_PRINTER_USED_ID_SETTING @"lastPrinterIdUsed"
#define LAST_SIZE_USED_SETTING @"lastSizeUsed"
#define LAST_TYPE_USED_SETTING @"lastTypeUsed"
#define LAST_FILTER_USED_SETTING @"lastFilterUsed"
#define SELECT_PRINTER_PROMPT @"Select Printer"

NSString * const kPageSettingsScreenName = @"Paper Settings Screen";

NSString * const kPrinterDetailsNotAvailable = @"Not Available";

@interface HPPPPageSettingsTableViewController () <UIPrintInteractionControllerDelegate, UIGestureRecognizerDelegate, HPPPPaperSizeTableViewControllerDelegate, HPPPPaperTypeTableViewControllerDelegate, HPPPPrintSettingsTableViewControllerDelegate, UIPrinterPickerControllerDelegate>


@property (weak, nonatomic) HPPPPageView *pageView;
@property (strong, nonatomic) HPPPPrintSettings *currentPrintSettings;
@property (strong, nonatomic) HPPPWiFiReachability *wifiReachability;
@property (weak, nonatomic) IBOutlet HPPPPageView *tableViewCellPageView;
@property (weak, nonatomic) IBOutlet UISwitch *blackAndWhiteModeSwitch;
@property (weak, nonatomic) IBOutlet UILabel *paperSizeSelectedLabel;
@property (weak, nonatomic) IBOutlet UILabel *paperTypeSelectedLabel;
@property (weak, nonatomic) IBOutlet UILabel *paperSizeLabel;
@property (weak, nonatomic) IBOutlet UILabel *paperTypeLabel;
@property (weak, nonatomic) IBOutlet UILabel *filterLabel;
@property (weak, nonatomic) IBOutlet UILabel *printLabel;
@property (weak, nonatomic) IBOutlet UILabel *selectPrinterLabel;
@property (weak, nonatomic) IBOutlet UILabel *selectedPrinterLabel;
@property (weak, nonatomic) IBOutlet UILabel *printSettingsLabel;
@property (weak, nonatomic) IBOutlet UILabel *printSettingsDetailLabel;

@property (weak, nonatomic) IBOutlet UITableViewCell *pageViewCell;
@property (weak, nonatomic) IBOutlet UITableViewCell *printCell;
@property (weak, nonatomic) IBOutlet UITableViewCell *selectPrinterCell;
@property (weak, nonatomic) IBOutlet UITableViewCell *paperSizeCell;
@property (weak, nonatomic) IBOutlet UITableViewCell *paperTypeCell;
@property (weak, nonatomic) IBOutlet UITableViewCell *filterCell;
@property (weak, nonatomic) IBOutlet UITableViewCell *printSettingsCell;

@property (weak, nonatomic) IBOutlet UIBarButtonItem *cancelBarButtonItem;

@property (nonatomic, strong) UIActivityIndicatorView *spinner;
@property (nonatomic, strong) HPPP *hppp;

@end

@implementation HPPPPageSettingsTableViewController

#pragma mark - UIView

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.hppp = [HPPP sharedInstance];
    
    self.navigationController.interactivePopGestureRecognizer.delegate = self;
    
    self.tableView.rowHeight = DEFAULT_ROW_HEIGHT;
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    
    if (IS_IPAD && IS_OS_8_OR_LATER) {
        self.tableView.tableHeaderView = [[UIView alloc] initWithFrame:CGRectZero];
    }
    
    self.printLabel.font = self.hppp.tableViewCellLabelFont;
    self.printSettingsLabel.font = self.hppp.tableViewCellLabelFont;
    self.printSettingsDetailLabel.font = self.hppp.rulesLabelFont;
    self.selectPrinterLabel.font = self.hppp.tableViewCellLabelFont;
    self.selectedPrinterLabel.font = self.hppp.tableViewCellLabelFont;
    self.paperSizeLabel.font = self.hppp.tableViewCellLabelFont;
    self.paperTypeLabel.font = self.hppp.tableViewCellLabelFont;
    self.filterLabel.font = self.hppp.tableViewCellLabelFont;
    
    self.paperSizeSelectedLabel.font = self.hppp.tableViewCellLabelFont;
    self.paperTypeSelectedLabel.font = self.hppp.tableViewCellLabelFont;
    
    self.printLabel.textColor = self.hppp.tableViewCellLinkLabelColor;
    
    self.paperSizeSelectedLabel.textColor = self.hppp.tableViewCellValueColor;
    self.paperTypeSelectedLabel.textColor = self.hppp.tableViewCellValueColor;
    
    self.pageViewCell.backgroundColor = [UIColor HPPPHPGrayBackgroundColor];
    
    HPPPPaper *paper = [[HPPPPaper alloc] initWithPaperSize:Size4x6  paperType:Photo];
    self.currentPrintSettings = [HPPPPrintSettings alloc];
    self.currentPrintSettings.paper = paper;
    self.currentPrintSettings.printerName = SELECT_PRINTER_PROMPT;
    self.currentPrintSettings.printerIsAvailable = YES;
    
    [self loadLastUsed];
    
    if (self.hppp.hideBlackAndWhiteOption) {
        self.filterCell.hidden = YES;
    }
    
    [self reloadPaperSelectionSection];
    
    [self prepareUiForIosVersion];
    [self updatePrintSettingsUI];
    [self checkLastPrinterUsedAvailability];
    [self updatePageSettingsUI];
    
    if ([self.dataSource respondsToSelector:@selector(pageSettingsTableViewControllerRequestImageForPaper:withCompletion:)]) {
        self.spinner = [self.pageView HPPPAddSpinner];
        self.spinner.activityIndicatorViewStyle = UIActivityIndicatorViewStyleGray;
        [self.dataSource pageSettingsTableViewControllerRequestImageForPaper:self.currentPrintSettings.paper withCompletion:^(UIImage *image) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.spinner removeFromSuperview];
                if (image) {
                    self.image = image;
                    [self configurePageView];
                }
            });
        }];
    } else {
        [self configurePageView];
    }
}

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:HPPP_TRACKABLE_SCREEN_NOTIFICATION object:nil userInfo:[NSDictionary dictionaryWithObject:kPageSettingsScreenName forKey:kHPPPTrackableScreenNameKey]];
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    if (IS_SPLIT_VIEW_CONTROLLER_IMPLEMENTATION) {
        self.pageView = self.pageViewController.pageView;
        self.pageView.image = self.image;
        
        __weak HPPPPageSettingsTableViewController *weakSelf = self;
        
        [self setPaperSize:self.pageView animated:NO completion:^{
            if (weakSelf.blackAndWhiteModeSwitch.on) {
                weakSelf.tableView.userInteractionEnabled = NO;
                [weakSelf.pageView setBlackAndWhiteWithCompletion:^{
                    weakSelf.tableView.userInteractionEnabled = YES;
                }];
            }
        }];
    }
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)orientation duration:(NSTimeInterval)duration
{
    if (IS_SPLIT_VIEW_CONTROLLER_IMPLEMENTATION) {
        [self setPaperSize:self.pageView animated:NO completion:nil];
    }
}

#pragma mark - Configure UI

- (void)configurePageView
{
    if (!IS_SPLIT_VIEW_CONTROLLER_IMPLEMENTATION) {
        self.pageView = self.tableViewCellPageView;
        self.pageView.image = self.image;
        
        __weak HPPPPageSettingsTableViewController *weakSelf = self;
        [self setPaperSize:self.pageView animated:YES completion:^{
            if (!weakSelf.hppp.hideBlackAndWhiteOption) {
                if (weakSelf.blackAndWhiteModeSwitch.on) {
                    weakSelf.tableView.userInteractionEnabled = NO;
                    [weakSelf.pageView setBlackAndWhiteWithCompletion:^{
                        weakSelf.tableView.userInteractionEnabled = YES;
                    }];
                }
            }
        }];
        
        self.wifiReachability = [[HPPPWiFiReachability alloc] init];
        [self.wifiReachability start:self.printCell label:self.printLabel];
    }
}

- (void)setSelectedPaper:(HPPPPaper *)selectedPaperSize
{
    _currentPrintSettings.paper = selectedPaperSize;
    self.paperSizeSelectedLabel.text = [NSString stringWithFormat:@"%@ x %@", _currentPrintSettings.paper.paperWidthTitle, _currentPrintSettings.paper.paperHeightTitle];
    self.paperTypeSelectedLabel.text = _currentPrintSettings.paper.typeTitle;
}

- (void)loadLastUsed
{
    self.currentPrintSettings.paper = [self lastPaperUsed];
    
    NSString *lastPrinter = [[NSUserDefaults standardUserDefaults] objectForKey:LAST_PRINTER_USED_SETTING];
    self.currentPrintSettings.printerName = lastPrinter;
    
    NSString *lastPrinterUrl = [[NSUserDefaults standardUserDefaults] objectForKey:LAST_PRINTER_USED_URL_SETTING];
    self.currentPrintSettings.printerUrl = [NSURL URLWithString:lastPrinterUrl];
    
    if (IS_OS_8_OR_LATER) {
        NSNumber *lastFilterUsed = [[NSUserDefaults standardUserDefaults] objectForKey:LAST_FILTER_USED_SETTING];
        if (lastFilterUsed != nil) {
            self.blackAndWhiteModeSwitch.on = lastFilterUsed.boolValue;
        }
	}
    NSString *lastPrinterId = [[NSUserDefaults standardUserDefaults] objectForKey:LAST_PRINTER_USED_ID_SETTING];
    self.currentPrintSettings.printerId = lastPrinterId;
}

- (HPPPPaper *)lastPaperUsed
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    NSNumber *lastSizeUsed = [defaults objectForKey:LAST_SIZE_USED_SETTING];
    NSNumber *lastTypeUsed = [defaults objectForKey:LAST_TYPE_USED_SETTING];
    
    PaperSize paperSize = (PaperSize)self.hppp.initialPaperSize;
    if (lastSizeUsed) {
        paperSize = (PaperSize)[lastSizeUsed integerValue];
    }
    
    PaperType paperType = SizeLetter == paperSize ? Plain : Photo;
    if (SizeLetter == paperSize && lastTypeUsed) {
        paperType = (PaperType)[lastTypeUsed integerValue];
    }
    
    return [[HPPPPaper alloc] initWithPaperSize:paperSize paperType:paperType];
}

// Hide or show UI that will always be hidden or shown based on the iOS version
- (void) prepareUiForIosVersion
{
    if (!IS_OS_8_OR_LATER){
        self.selectPrinterCell.hidden = YES;
        self.printSettingsCell.hidden = YES;
    }
}

// Hide or show UI based on current print settings
- (void)updatePageSettingsUI
{
    // This block of beginUpdates-endUpdates is required to refresh the tableView while it is currently being displayed on screen
    [self.tableView beginUpdates];
    if (IS_OS_8_OR_LATER){
        if (self.currentPrintSettings.printerName == nil){
            self.selectPrinterCell.hidden = NO;
            self.paperSizeCell.hidden = NO;
            self.printSettingsCell.hidden = YES;
            self.paperTypeCell.hidden = (self.currentPrintSettings.paper.paperSize == SizeLetter) ? NO : YES;
        } else {
            self.selectPrinterCell.hidden = YES;
            self.paperSizeCell.hidden = YES;
            self.paperTypeCell.hidden = YES;
            self.printSettingsCell.hidden = NO;
        }
        if (self.currentPrintSettings.printerIsAvailable){
            [self printerIsAvailable];
        } else {
            [self printerNotAvailable];
        }
    } else {
        self.paperTypeCell.hidden = (self.currentPrintSettings.paper.paperSize == SizeLetter) ? NO : YES;
    }
    [self.tableView endUpdates];
}

// Update the Paper Size, Paper Type, and Select Printer cells
- (void)updatePrintSettingsUI
{
    self.paperSizeSelectedLabel.text = self.currentPrintSettings.paper.sizeTitle;
    self.paperTypeSelectedLabel.text = self.currentPrintSettings.paper.typeTitle;
    self.selectedPrinterLabel.text = self.currentPrintSettings.printerName == nil ? SELECT_PRINTER_PROMPT : self.currentPrintSettings.printerName;
    
    NSString *displayedPrinterName = [self.selectedPrinterLabel.text isEqualToString:SELECT_PRINTER_PROMPT] ? @"" : [NSString stringWithFormat:@", %@", self.selectedPrinterLabel.text];
    
    self.printSettingsDetailLabel.text = [NSString stringWithFormat:@"%@, %@ %@", self.paperSizeSelectedLabel.text, self.paperTypeSelectedLabel.text, displayedPrinterName];
}

- (UIPrintInteractionController*)getSharedPrintInteractionController
{
    UIPrintInteractionController *controller = [UIPrintInteractionController sharedPrintController];
    
    if (nil != controller) {
        controller.delegate = self;
    }
    
    return controller;
}

- (void)showPrinterSelection:(UITableView *)tableView withCompletion:(void (^)(BOOL userDidSelect))completion
{
    UIPrinterPickerController *printerPicker = [UIPrinterPickerController printerPickerControllerWithInitiallySelectedPrinter:nil];
    printerPicker.delegate = self;
    
    if( IS_IPAD ) {
        [printerPicker presentFromRect:self.selectPrinterCell.frame
                                inView:tableView
                              animated:YES
                     completionHandler:^(UIPrinterPickerController *printerPickerController, BOOL userDidSelect, NSError *error){
                         if (completion){
                             completion(userDidSelect);
                         }
                     }];
    } else {
        [printerPicker presentAnimated:YES completionHandler:^(UIPrinterPickerController *printerPickerController, BOOL userDidSelect, NSError *error){
            if (completion){
                completion(userDidSelect);
            }
        }];
    }
}

- (void)reloadPrinterSelectionSection
{
    NSRange range = NSMakeRange(PRINT_SETTINGS_SECTION, 1);
    NSIndexSet *sectionToReload = [NSIndexSet indexSetWithIndexesInRange:range];
    [self.tableView reloadSections:sectionToReload withRowAnimation:UITableViewRowAnimationNone];
}

- (void)reloadPaperSelectionSection
{
    NSRange range = NSMakeRange(PAPER_SELECTION_SECTION, 1);
    NSIndexSet *sectionToReload = [NSIndexSet indexSetWithIndexesInRange:range];
    [self.tableView reloadSections:sectionToReload withRowAnimation:UITableViewRowAnimationNone];
}

#pragma mark - Printer availability

- (void)printerNotAvailable
{
    // This block of beginUpdates-endUpdates is required to refresh the tableView while it is currently being displayed on screen
    [self.tableView beginUpdates];
    UIImage *warningSign = [UIImage imageNamed:@"HPPPDoNoEnter"];
    [self.printSettingsCell.imageView setImage:warningSign];
    self.currentPrintSettings.printerIsAvailable = NO;
    [self.tableView endUpdates];
}

- (void)printerIsAvailable
{
    // This block of beginUpdates-endUpdates is required to refresh the tableView while it is currently being displayed on screen
    [self.tableView beginUpdates];
    [self.printSettingsCell.imageView setImage:nil];
    self.currentPrintSettings.printerIsAvailable = YES;
    [self.tableView endUpdates];
}

- (void)checkLastPrinterUsedAvailability
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        
        NSString *lastPrinterUrl = [[NSUserDefaults standardUserDefaults] objectForKey:LAST_PRINTER_USED_URL_SETTING];
        NSLog(@"Searching for printer %@", lastPrinterUrl);
        
        if( nil != lastPrinterUrl ) {
            UIPrinter *printerFromUrl = [UIPrinter printerWithURL:[NSURL URLWithString:lastPrinterUrl]];
            [printerFromUrl contactPrinter:^(BOOL available) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    if ( available ) {
                        [self setPrinterDetails:printerFromUrl];
                        [self printerIsAvailable];
                        NSLog(@"The selected printer was contacted using its URL: %@", lastPrinterUrl);
                    } else {
                        [self printerNotAvailable];
                        NSLog(@"Unable to contact printer %@", lastPrinterUrl);
                    }
                    
                    [self reloadPrinterSelectionSection];
                });
            }];
        }
    });
}

#pragma mark - Button actions

- (IBAction)cancelButtonTapped:(id)sender
{
    if ([self.delegate respondsToSelector:@selector(pageSettingsTableViewControllerDidCancelPrintFlow:)]) {
        [self.delegate pageSettingsTableViewControllerDidCancelPrintFlow:self];
    }
}

- (void)displaySystemPrintFromView:(UIView *)view
{
    // Obtain the shared UIPrintInteractionController
    UIPrintInteractionController *controller = [self getSharedPrintInteractionController];
    
    if (!controller) {
        NSLog(@"Couldn't get shared UIPrintInteractionController!");
        return;
    }
    
    [self createPrintJob:controller];
    
    UIPrintInteractionCompletionHandler completionHandler = ^(UIPrintInteractionController *printController, BOOL completed, NSError *error) {
        
        [self printCompleted:printController isCompleted:completed printError:error];
    };
    
    if (IS_IPAD) {
        self.cancelBarButtonItem.enabled = NO;
        [controller presentFromRect:view.frame inView:self.view animated:YES completionHandler:completionHandler];
    } else {
        [controller presentAnimated:YES completionHandler:completionHandler];
    }
    
}

#pragma mark - UIPrintInteractionControllerDelegate

- (UIViewController *)printInteractionControllerParentViewController:(UIPrintInteractionController *)printInteractionController
{
    return nil;
}

- (UIPrintPaper *)printInteractionController:(UIPrintInteractionController *)printInteractionController choosePaper:(NSArray *)paperList
{
    UIPrintPaper * paper = [UIPrintPaper bestPaperForPageSize:[self.currentPrintSettings.paper printerPaperSize] withPapersFromArray:paperList];
    return paper;
}

#pragma mark - Switch actions

- (IBAction)blackAndWhiteSwitchToggled:(id)sender
{
    [self applyFilter];
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:[NSNumber numberWithInteger:self.blackAndWhiteModeSwitch.on] forKey:LAST_FILTER_USED_SETTING];
    [defaults synchronize];
}

- (void)applyFilter
{
    if (self.blackAndWhiteModeSwitch.on) {
        self.tableView.userInteractionEnabled = NO;
        [self.pageView setBlackAndWhiteWithCompletion:^{
            self.tableView.userInteractionEnabled = YES;
        }];
    } else {
        [self.pageView setColorWithCompletion:nil];
    }
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if (self.hppp.supportActions.count != 0)
        return [super numberOfSectionsInTableView:tableView];
    else
        return ([super numberOfSectionsInTableView:tableView] - 1);
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == SUPPORT_SECTION) {
        return self.hppp.supportActions.count;
    } else if (section == PAPER_SELECTION_SECTION) {
        if (self.currentPrintSettings.paper.paperSize == SizeLetter) {
            return 2;
        } else {
            return 1;
        }
    } else {
        return [super tableView:tableView numberOfRowsInSection:section];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell;
    
    if (indexPath.section != SUPPORT_SECTION) {
        cell = [super tableView:tableView cellForRowAtIndexPath:indexPath];
        
    } else {
        cell = [tableView dequeueReusableCellWithIdentifier:@"ActionTableViewCellIdentifier"];
        
        if (!cell) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"ActionTableViewCellIdentifier"];
        }
        
        cell.textLabel.font = self.hppp.tableViewCellLabelFont;
        cell.textLabel.textColor = self.hppp.tableViewCellLinkLabelColor;
        HPPPSupportAction *action = self.hppp.supportActions[indexPath.row];
        cell.imageView.image = action.icon;
        cell.textLabel.text = action.title;
    }
    
    return cell;
}



#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    CGFloat height = ZERO_HEIGHT;
    
    if (section == SUPPORT_SECTION) {
        if (self.hppp.supportActions.count != 0) {
            height = HEADER_HEIGHT;
        }
    }
    
    return height;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    CGFloat height = ZERO_HEIGHT;
    
    if (section == PRINT_FUNCTION_SECTION) {
        height = SEPARATOR_SECTION_FOOTER_HEIGHT;
    } else if (IS_OS_8_OR_LATER && ((section == PRINTER_SELECTION_SECTION) || (section == PAPER_SELECTION_SECTION))) {
        if ((!self.hppp.hidePaperTypeOption) && (self.currentPrintSettings.printerUrl == nil)) {
            height = SEPARATOR_SECTION_FOOTER_HEIGHT;
        }
    } else if (IS_OS_8_OR_LATER && (section == PRINT_SETTINGS_SECTION)) {
        if (self.currentPrintSettings.printerUrl != nil) {
            if (self.currentPrintSettings.printerIsAvailable) {
                height = SEPARATOR_SECTION_FOOTER_HEIGHT;
            } else {
                height = PRINTER_WARNING_SECTION_FOOTER_HEIGHT;
            }
        }
    }
    
    return height;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    cell.selected = NO;
    
    if (indexPath.section == SUPPORT_SECTION) {
        HPPPSupportAction *action = self.hppp.supportActions[indexPath.row];
        if (action.url) {
            [[UIApplication sharedApplication] openURL:action.url];
        } else {
            [self presentViewController:action.viewController animated:YES completion:nil];
        }
    } else if (cell == self.selectPrinterCell) {
        [self showPrinterSelection:tableView withCompletion:nil];
    } else if (cell == self.printCell){
        [self oneTouchPrint:tableView];
    }
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *header = nil;
    
    if (section == SUPPORT_SECTION) {
        if (self.hppp.supportActions.count != 0) {
            header = [tableView HPPPHeaderViewForSupportSection];
        }
    }
    
    return header;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    UIView *footer = nil;
    
    if (IS_OS_8_OR_LATER) {
        if (section == PRINT_SETTINGS_SECTION) {
            if ((self.currentPrintSettings.printerUrl != nil) && !self.currentPrintSettings.printerIsAvailable) {
                footer = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, tableView.frame.size.width, PRINTER_WARNING_SECTION_FOOTER_HEIGHT)];
                
                UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(20.0f, 0.0f, tableView.frame.size.width - 20.0f, PRINTER_WARNING_SECTION_FOOTER_HEIGHT)];
                label.font = self.hppp.rulesLabelFont;
                label.textColor = [UIColor grayColor];
                label.text = @"Recent printer not currently available";
                [footer addSubview:label];
            }
        }
    }
    
    return footer;
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
            if ((!self.hppp.hidePaperTypeOption) && (self.currentPrintSettings.paper.paperSize == SizeLetter)) {
                rowHeight = tableView.rowHeight;
            }
        }
    } else if (indexPath.section == FILTER_SECTION) {
        if (!([HPPP sharedInstance].hideBlackAndWhiteOption)) {
            rowHeight = self.tableView.rowHeight;
        }
    } else {
        rowHeight = tableView.rowHeight;
    }
    
    return rowHeight;
}

#pragma mark - Printing

- (void)oneTouchPrint:(UITableView *)tableView
{
    if (IS_OS_8_OR_LATER) {
        if (self.currentPrintSettings.printerUrl == nil ||
            !self.currentPrintSettings.printerIsAvailable  ){
            [self showPrinterSelection:tableView withCompletion:^(BOOL userDidSelect){
                if (userDidSelect) {
                    [self doPrint];
                }
            }];
        } else {
            [self doPrint];
        }
    } else {
        [self displaySystemPrintFromView:self.printCell];
    }
}

- (void)doPrint
{
    if (self.currentPrintSettings.printerUrl != nil){
        UIPrintInteractionController *controller = [self getSharedPrintInteractionController];
        if (!controller) {
            NSLog(@"Couldn't get shared UIPrintInteractionController!");
            return;
        }
        
        [self createPrintJob:controller];
        
        UIPrinter* printer = [UIPrinter printerWithURL:self.currentPrintSettings.printerUrl];
        
        [controller printToPrinter:printer completionHandler:^(UIPrintInteractionController *printController, BOOL completed, NSError *error) {
            
            [self printCompleted:printController isCompleted:completed printError:error];
        }];
    }
}

- (void)createPrintJob:(UIPrintInteractionController *)controller
{
    // Obtain a printInfo so that we can set our printing defaults.
    UIPrintInfo *printInfo = [UIPrintInfo printInfo];
    
    UIImage *image = nil;
    
    if ([self.image HPPPIsPortraitImage] || (self.currentPrintSettings.paper.paperSize == SizeLetter)) {
        image = self.image;
    } else {
        image = [self.image HPPPRotate];
    }
    
    // The path to the image may or may not be a good name for our print job
    // but that's all we've got.
    printInfo.jobName = @"PhotoGram";
    
    printInfo.printerID = self.currentPrintSettings.printerId;
    
    // This application prints photos. UIKit will pick a paper size and print
    // quality appropriate for this content type.
    BOOL photoPaper = (self.currentPrintSettings.paper.paperSize != SizeLetter) || (self.currentPrintSettings.paper.paperType == Photo);
    BOOL color = !self.blackAndWhiteModeSwitch.on;
    
    if (photoPaper && color) {
        printInfo.outputType = UIPrintInfoOutputPhoto;
    } else if (photoPaper && !color) {
        printInfo.outputType = UIPrintInfoOutputPhotoGrayscale;
    } else if (!photoPaper && color) {
        printInfo.outputType = UIPrintInfoOutputGeneral;
    } else {
        printInfo.outputType = UIPrintInfoOutputGrayscale;
    }
    
    HPPPPrintPageRenderer *renderer = [[HPPPPrintPageRenderer alloc] initWithImage:image];
    controller.printPageRenderer = renderer;
    
    // Use this printInfo for this print job.
    controller.printInfo = printInfo;
}

- (void)printCompleted:(UIPrintInteractionController *)printController isCompleted:(BOOL)completed printError:(NSError *)error
{
    [self setLastOptionsUsedWithPrintController:printController];
    
    if (error) {
        NSLog(@"FAILED! due to error in domain %@ with error code %ld", error.domain, (long)error.code);
    }
    
    if (completed) {
        if ([self.delegate respondsToSelector:@selector(pageSettingsTableViewControllerDidFinishPrintFlow:)]) {
            [self.delegate pageSettingsTableViewControllerDidFinishPrintFlow:self];
        }
    }
    
    if (IS_IPAD) {
        self.cancelBarButtonItem.enabled = YES;
    }
}

- (void)setLastOptionsUsedWithPrintController:(UIPrintInteractionController *)printController;
{
    NSMutableDictionary *lastOptionsUsed = [NSMutableDictionary dictionary];
    [lastOptionsUsed setValue:self.currentPrintSettings.paper.typeTitle forKey:kHPPPPaperTypeId];
    [lastOptionsUsed setValue:self.currentPrintSettings.paper.sizeTitle forKey:kHPPPPaperSizeId];
    [lastOptionsUsed setValue:[NSNumber numberWithBool:self.blackAndWhiteModeSwitch.on] forKey:kHPPPBlackAndWhiteFilterId];

    NSString * printerID = printController.printInfo.printerID;
    if (printerID) {
        [lastOptionsUsed setValue:printerID forKey:kHPPPPrinterId];
        if ([printerID isEqualToString:self.currentPrintSettings.printerUrl.absoluteString]) {
            [lastOptionsUsed setValue:self.currentPrintSettings.printerName forKey:kHPPPPrinterDisplayName];
            [lastOptionsUsed setValue:self.currentPrintSettings.printerLocation forKey:kHPPPPrinterDisplayLocation];
            [lastOptionsUsed setValue:self.currentPrintSettings.printerModel forKey:kHPPPPrinterMakeAndModel];
        } else {
            [lastOptionsUsed setValue:kPrinterDetailsNotAvailable forKey:kHPPPPrinterDisplayName];
            [lastOptionsUsed setValue:kPrinterDetailsNotAvailable forKey:kHPPPPrinterDisplayLocation];
            [lastOptionsUsed setValue:kPrinterDetailsNotAvailable forKey:kHPPPPrinterMakeAndModel];
        }
    }
    [HPPP sharedInstance].lastOptionsUsed = [NSDictionary dictionaryWithDictionary:lastOptionsUsed];
    
    self.currentPrintSettings.printerId = printerID;
    NSUserDefaults * defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:self.currentPrintSettings.printerId forKey:LAST_PRINTER_USED_ID_SETTING];
    [defaults synchronize];

}

- (void)setPrinterDetails:(UIPrinter *)printer
{
    self.currentPrintSettings.printerUrl = printer.URL;
    self.currentPrintSettings.printerName = printer.displayName;
    self.currentPrintSettings.printerLocation = printer.displayLocation;
    self.currentPrintSettings.printerModel = printer.makeAndModel;
}

#pragma mark - HPPPPrintSettingsTableViewControllerDelegate

- (void)printSettingsTableViewController:(HPPPPrintSettingsTableViewController *)printSettingsTableViewController didChangePrintSettings:(HPPPPrintSettings *)printSettings
{
    self.currentPrintSettings.printerName = printSettings.printerName;
    self.currentPrintSettings.printerUrl = printSettings.printerUrl;
    self.currentPrintSettings.printerIsAvailable = printSettings.printerIsAvailable;
    
    NSUserDefaults * defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:printSettings.printerUrl.absoluteString forKey:LAST_PRINTER_USED_URL_SETTING];
    [defaults setObject:printSettings.printerName forKey:LAST_PRINTER_USED_SETTING];
    [defaults setObject:printSettings.printerId forKey:LAST_PRINTER_USED_ID_SETTING];
    [defaults synchronize];
    
    [self paperSizeTableViewController:(HPPPPaperSizeTableViewController *)printSettingsTableViewController didSelectPaper:printSettings.paper];
    
    [self paperTypeTableViewController:(HPPPPaperTypeTableViewController *)printSettingsTableViewController didSelectPaper:printSettings.paper];
}

#pragma mark - HPPPPaperSizeTableViewControllerDelegate

- (void)paperSizeTableViewController:(HPPPPaperSizeTableViewController *)paperSizeTableViewController didSelectPaper:(HPPPPaper *)paper
{
    if (self.currentPrintSettings.paper.paperSize != SizeLetter && paper.paperSize == SizeLetter){
        paper.paperType = Plain;
        paper.typeTitle = [HPPPPaper titleFromType:Plain];
    } else if (self.currentPrintSettings.paper.paperSize == SizeLetter && paper.paperSize != SizeLetter){
        paper.paperType = Photo;
        paper.typeTitle = [HPPPPaper titleFromType:Photo];
    }
    self.currentPrintSettings.paper = paper;
    
    [self reloadPaperSelectionSection];
    
    [self updatePageSettingsUI];
    [self updatePrintSettingsUI];
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:[NSNumber numberWithInteger:self.currentPrintSettings.paper.paperSize] forKey:LAST_SIZE_USED_SETTING];
    [defaults synchronize];
    
    if ([self.dataSource respondsToSelector:@selector(pageSettingsTableViewControllerRequestImageForPaper:withCompletion:)]) {
        self.spinner = [self.pageView HPPPAddSpinner];
        self.spinner.activityIndicatorViewStyle = UIActivityIndicatorViewStyleGray;
        [self.dataSource pageSettingsTableViewControllerRequestImageForPaper:paper withCompletion:^(UIImage *image) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (image) {
                    self.image = image;
                    self.pageView.image = image;
                    __weak HPPPPageSettingsTableViewController *weakSelf = self;
                    [self setPaperSize:self.pageView animated:(!IS_SPLIT_VIEW_CONTROLLER_IMPLEMENTATION) completion:^{
                        if (weakSelf.blackAndWhiteModeSwitch.on) {
                            weakSelf.tableView.userInteractionEnabled = NO;
                            [weakSelf.pageView setBlackAndWhiteWithCompletion:^{
                                weakSelf.tableView.userInteractionEnabled = YES;
                            }];
                        }
                    }];
                }
                
                [self.spinner removeFromSuperview];
            });
        }];
    } else {
        [self setPaperSize:self.pageView animated:(!IS_SPLIT_VIEW_CONTROLLER_IMPLEMENTATION) completion:nil];
    }
}

- (void)setPaperSize:(HPPPPageView *)pageView animated:(BOOL)animated completion:(void (^)(void))completion
{
    self.tableView.userInteractionEnabled = NO;
    
    [pageView setPaperSize:self.currentPrintSettings.paper animated:animated completion:^{
        self.tableView.userInteractionEnabled = YES;
        if (completion) {
            completion();
        }
    }];
}

#pragma mark - HPPPPaperTypeTableViewControllerDelegate

- (void)paperTypeTableViewController:(HPPPPaperTypeTableViewController *)paperTypeTableViewController didSelectPaper:(HPPPPaper *)paper
{
    self.currentPrintSettings.paper = paper;
    [self updatePrintSettingsUI];
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:[NSNumber numberWithInteger:self.currentPrintSettings.paper.paperType] forKey:LAST_TYPE_USED_SETTING];
    [defaults synchronize];
}

#pragma mark - UIGestureRecognizerDelegate

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer
{
    return NO;
}

#pragma mark - UIPrinterPickerControllerDelegate

- (void)printerPickerControllerDidDismiss:(UIPrinterPickerController *)printerPickerController
{
    UIPrinter* selectedPrinter = printerPickerController.selectedPrinter;
    
    if (selectedPrinter != nil){
        NSLog(@"Selected Printer: %@", selectedPrinter.URL);
        
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        [defaults setObject:selectedPrinter.URL.absoluteString forKey:LAST_PRINTER_USED_URL_SETTING];
        [defaults setObject:selectedPrinter.displayName forKey:LAST_PRINTER_USED_SETTING];
        [defaults setObject:self.currentPrintSettings.printerId forKey:LAST_PRINTER_USED_ID_SETTING];
        [defaults synchronize];
        
        self.currentPrintSettings.printerIsAvailable = YES;
        [self setPrinterDetails:selectedPrinter];
        [self updatePageSettingsUI];
        [self updatePrintSettingsUI];
    }
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"PrintSettingsSegue"]) {
        
        HPPPPrintSettingsTableViewController *vc = (HPPPPrintSettingsTableViewController *)segue.destinationViewController;
        vc.printSettings = self.currentPrintSettings;
        vc.delegate = self;
    } else if ([segue.identifier isEqualToString:@"PaperSizeSegue"]) {
        
        HPPPPaperSizeTableViewController *vc = (HPPPPaperSizeTableViewController *)segue.destinationViewController;
        vc.currentPaper = self.currentPrintSettings.paper;
        vc.delegate = self;
    } else if ([segue.identifier isEqualToString:@"PaperTypeSegue"]) {
        
        HPPPPaperTypeTableViewController *vc = (HPPPPaperTypeTableViewController *)segue.destinationViewController;
        vc.currentPaper = self.currentPrintSettings.paper;
        vc.delegate = self;
    }
}

@end
