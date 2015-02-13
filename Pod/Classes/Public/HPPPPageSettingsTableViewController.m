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
#define SEPARATOR_ROW_HEIGHT 15.0f
#define PRINTER_STATUS_ROW_HEIGHT 25.0f

#define PAPER_SECTION 0
#define SUPPORT_SECTION 1

#define NUMBER_OF_ROWS_IN_PAPER_SECTION 4

#define PAPER_SHOW_INDEX 0
#define PRINT_INDEX 1
#define SEPARATOR_UNDER_PRINT_INDEX 2
#define PRINTER_SELECT_INDEX 3
#define SEPARATOR_UNDER_SELECT_PRINTER_INDEX 4
#define PAPER_SIZE_INDEX 5
#define PAPER_TYPE_INDEX 6
#define SEPARATOR_UNDER_PAPER_TYPE_INDEX 7
#define FILTER_INDEX 8
#define PRINT_SETTINGS_INDEX 9
#define PRINTER_STATUS_INDEX 10

#define LAST_PRINTER_USED_SETTING @"lastPrinterUsed"
#define LAST_PRINTER_USED_URL_SETTING @"lastPrinterUrlUsed"
#define LAST_SIZE_USED_SETTING @"lastSizeUsed"
#define LAST_TYPE_USED_SETTING @"lastTypeUsed"
#define LAST_FILTER_USED_SETTING @"lastFilterUsed"
#define SELECT_PRINTER_PROMPT @"Select Printer"

NSString * const kPageSettingsScreenName = @"Paper Settings Screen";

@interface HPPPPageSettingsTableViewController () <UIPrintInteractionControllerDelegate, UIGestureRecognizerDelegate, HPPPPaperSizeTableViewControllerDelegate, HPPPPaperTypeTableViewControllerDelegate, HPPPPrintSettingsTableViewControllerDelegate, HPPPPageViewControllerDelegate, UIPrinterPickerControllerDelegate>


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
@property (weak, nonatomic) IBOutlet UILabel *printerStatusLabel;

@property (weak, nonatomic) IBOutlet UITableViewCell *pageViewCell;
@property (weak, nonatomic) IBOutlet UITableViewCell *paperSizeCell;
@property (weak, nonatomic) IBOutlet UITableViewCell *paperTypeCell;
@property (weak, nonatomic) IBOutlet UITableViewCell *learnMoreCell;
@property (weak, nonatomic) IBOutlet UITableViewCell *filterCell;
@property (weak, nonatomic) IBOutlet UITableViewCell *printSettingsCell;
@property (weak, nonatomic) IBOutlet UITableViewCell *selectPrinterCell;
@property (weak, nonatomic) IBOutlet UITableViewCell *printCell;
@property (weak, nonatomic) IBOutlet UITableViewCell *separatorUnderPrintCell;
@property (weak, nonatomic) IBOutlet UITableViewCell *separatorUnderSelectPrinterCell;
@property (weak, nonatomic) IBOutlet UITableViewCell *separatorUnderPaperTypeCell;
@property (weak, nonatomic) IBOutlet UITableViewCell *printerStatusCell;

@property (weak, nonatomic) IBOutlet UIBarButtonItem *printBarButtonItem;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *cancelBarButtonItem;

@property (nonatomic, strong) UIActivityIndicatorView *spinner;
@property (nonatomic, strong) HPPP *hppp;

@end

@implementation HPPPPageSettingsTableViewController


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.hppp = [HPPP sharedInstance];
    
    self.navigationController.interactivePopGestureRecognizer.delegate = self;
    
    self.tableView.rowHeight = DEFAULT_ROW_HEIGHT;
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    
    self.printLabel.font = self.hppp.tableViewCellLabelFont;
    self.printSettingsLabel.font = self.hppp.tableViewCellLabelFont;
    self.printSettingsDetailLabel.font = self.hppp.rulesLabelFont;
    self.printerStatusLabel.font = self.hppp.rulesLabelFont;
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

- (void)configurePageView
{
    if (IS_SPLIT_VIEW_CONTROLLER_IMPLEMENTATION) {
        self.navigationItem.rightBarButtonItem = nil;
        self.pageViewController.delegate = self;
    } else {
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
        [self.wifiReachability start:self.printBarButtonItem];
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
    
    NSNumber *lastFilterUsed = [[NSUserDefaults standardUserDefaults] objectForKey:LAST_FILTER_USED_SETTING];
    if (lastFilterUsed != nil) {
        self.blackAndWhiteModeSwitch.on = lastFilterUsed.boolValue;
    }
}

- (HPPPPaper *)lastPaperUsed
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    NSNumber *lastSizeUsed = [defaults objectForKey:LAST_SIZE_USED_SETTING];
    NSNumber *lastTypeUsed = [defaults objectForKey:LAST_TYPE_USED_SETTING];
    
    HPPPPaper *result;
    
    if (lastSizeUsed != nil) {
        result = [[HPPPPaper alloc] initWithPaperSize:(PaperSize)lastSizeUsed.integerValue paperType:(PaperType)lastTypeUsed.integerValue];
    } else {
        result = [[HPPPPaper alloc] initWithPaperSize:(PaperSize)self.hppp.initialPaperSize paperType:(PaperType)self.hppp.defaultPaperType];
    }
    
    return result;
}

// Hide or show UI that will always be hidden or shown based on the iOS version
- (void) prepareUiForIosVersion
{
    if (IS_OS_8_OR_LATER){
        self.navigationItem.rightBarButtonItems = nil;
        self.printCell.hidden = NO;
        self.separatorUnderPrintCell.hidden = NO;
    } else {
        self.printCell.hidden = YES;
        self.separatorUnderPrintCell.hidden = YES;
        self.selectPrinterCell.hidden = YES;
        self.separatorUnderSelectPrinterCell.hidden = YES;
        self.printSettingsCell.hidden = YES;
        self.printerStatusCell.hidden = YES;
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
            self.separatorUnderSelectPrinterCell.hidden = NO;
            self.paperSizeCell.hidden = NO;
            self.printSettingsCell.hidden = YES;
            self.paperTypeCell.hidden = (self.currentPrintSettings.paper.paperSize == SizeLetter) ? NO : YES;
            self.printerStatusCell.hidden = YES;
        } else {
            self.selectPrinterCell.hidden = YES;
            self.separatorUnderSelectPrinterCell.hidden = YES;
            self.paperSizeCell.hidden = YES;
            self.paperTypeCell.hidden = YES;
            self.separatorUnderPaperTypeCell.hidden = YES;
            self.printSettingsCell.hidden = NO;
            self.printerStatusCell.hidden = (self.currentPrintSettings.printerIsAvailable) ? YES : NO;
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

- (void)printerNotAvailable
{
    // This block of beginUpdates-endUpdates is required to refresh the tableView while it is currently being displayed on screen
    [self.tableView beginUpdates];
    UIImage *warningSign = [UIImage imageNamed:@"HPPPDoNoEnter"];
    [self.printSettingsCell.imageView setImage:warningSign];
    self.currentPrintSettings.printerIsAvailable = NO;
    self.printerStatusCell.hidden = NO;
    [self.tableView endUpdates];
}

- (void)printerIsAvailable
{
    // This block of beginUpdates-endUpdates is required to refresh the tableView while it is currently being displayed on screen
    [self.tableView beginUpdates];
    [self.printSettingsCell.imageView setImage:nil];
    self.currentPrintSettings.printerIsAvailable = YES;
    self.printerStatusCell.hidden = YES;
    [self.tableView endUpdates];
}

- (void)checkLastPrinterUsedAvailability
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        
        NSString *lastPrinterUrl = [[NSUserDefaults standardUserDefaults] objectForKey:LAST_PRINTER_USED_URL_SETTING];
        NSLog(@"Searching for printer %@", lastPrinterUrl);
        
        if( nil != lastPrinterUrl ) {
            UIPrinter* printerFromUrl = [UIPrinter printerWithURL:[NSURL URLWithString:lastPrinterUrl]];
            [printerFromUrl contactPrinter:^(BOOL available) {
                if( available ) {
                    [self printerIsAvailable];
                    NSLog(@"The selected printer was contacted using its URL: %@", lastPrinterUrl);                }
                else {
                    [self printerNotAvailable];
                    NSLog(@"Unable to contact printer %@", lastPrinterUrl);
                }
            }];
        }
    });
}

#pragma mark - Button actions

- (IBAction)cancelButtonTapped:(id)sender
{
    [HPPP sharedInstance].lastOptionsUsed = [NSDictionary dictionary];
    
    if ([self.delegate respondsToSelector:@selector(pageSettingsTableViewControllerDidCancelPrintFlow:)]) {
        [self.delegate pageSettingsTableViewControllerDidCancelPrintFlow:self];
    }
}

- (IBAction)printButtonTapped:(id)sender
{
    [self displaySystemPrintFromBarButtonItem:self.printBarButtonItem];
}

- (void)displaySystemPrintFromBarButtonItem:(UIBarButtonItem *)barButtonItem
{
    // Obtain the shared UIPrintInteractionController
    UIPrintInteractionController *controller = [UIPrintInteractionController sharedPrintController];
    
    if (!controller) {
        NSLog(@"Couldn't get shared UIPrintInteractionController!");
        return;
    }
    
    controller.delegate = self;
    
    [self createPrintJob:controller];

    UIPrintInteractionCompletionHandler completionHandler = ^(UIPrintInteractionController *printController, BOOL completed, NSError *error) {
        
        [self printCompleted:printController isCompleted:completed printError:error];
    };
    
    if (IS_IPAD) {
        self.cancelBarButtonItem.enabled = NO;
        [controller presentFromBarButtonItem:barButtonItem animated:YES completionHandler:completionHandler];
    } else {
        [controller presentAnimated:YES completionHandler:completionHandler];
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
    
    printInfo.printerID = self.currentPrintSettings.printerName;
    
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
    if (error) {
        NSLog(@"FAILED! due to error in domain %@ with error code %ld", error.domain, (long)error.code);
    }
    
    if (completed) {
        NSMutableDictionary *lastOptionsUsed = [NSMutableDictionary dictionary];
        [lastOptionsUsed setValue:self.paperTypeSelectedLabel.text forKey:kHPPPPaperTypeId];
        [lastOptionsUsed setValue:self.paperSizeSelectedLabel.text forKey:kHPPPPaperSizeId];
        [lastOptionsUsed setValue:[NSNumber numberWithBool:self.blackAndWhiteModeSwitch.on] forKey:kHPPPBlackAndWhiteFilterId];
        [lastOptionsUsed setValue:self.currentPrintSettings.printerName forKey:kHPPPPrinterId];
        
        [HPPP sharedInstance].lastOptionsUsed = [NSDictionary dictionaryWithDictionary:lastOptionsUsed];
        
        if ([self.delegate respondsToSelector:@selector(pageSettingsTableViewControllerDidFinishPrintFlow:)]) {
            [self.delegate pageSettingsTableViewControllerDidFinishPrintFlow:self];
        }
    }
    
    if (IS_IPAD) {
        self.cancelBarButtonItem.enabled = YES;
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
        return 2; // Paper Section + Support Section
    else
        return 1; // Paper Section
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == SUPPORT_SECTION) {
        return self.hppp.supportActions.count;
    } else {
        return [super tableView:tableView numberOfRowsInSection:section];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell;
    
    if (indexPath.section == PAPER_SECTION) {
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
    CGFloat height = 0.0f;
    
    if (section == SUPPORT_SECTION) {
        if (self.hppp.supportActions.count != 0) {
            height = HEADER_HEIGHT;
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

- (void)showPrinterSelection:(UITableView *)tableView withCompletion:(void (^)(void))completion
{
    UIPrinterPickerController* printerPicker = [UIPrinterPickerController printerPickerControllerWithInitiallySelectedPrinter:nil];
    printerPicker.delegate = self;
    
    if( IS_IPAD ) {
        [printerPicker presentFromRect:self.selectPrinterCell.frame
                                inView:tableView
                              animated:YES
                     completionHandler:^(UIPrinterPickerController *printerPickerController, BOOL userDidSelect, NSError *error){
                         if (completion){
                             completion();
                         }
                     }];
    } else {
        [printerPicker presentAnimated:YES completionHandler:^(UIPrinterPickerController *printerPickerController, BOOL userDidSelect, NSError *error){
            if (completion){
                completion();
            }
        }];
    }
}

- (void)oneTouchPrint:(UITableView *)tableView
{
    if (self.currentPrintSettings.printerUrl == nil){
        [self showPrinterSelection:tableView withCompletion:^(void){
            [self doPrint];
        }];
    } else {
        [self doPrint];
    }
}

- (void)doPrint
{
    if (self.currentPrintSettings.printerUrl != nil){
        UIPrintInteractionController *controller = [UIPrintInteractionController sharedPrintController];
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

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [super tableView:tableView cellForRowAtIndexPath:indexPath];
    if (cell.hidden == YES){
        return 0.0f;
    }
    
    CGFloat rowHeight = 0.0f;
    
    if (indexPath.section == PAPER_SECTION) {
        switch (indexPath.row) {
            case SEPARATOR_UNDER_PRINT_INDEX:
                rowHeight = SEPARATOR_ROW_HEIGHT;
                break;
            
            case SEPARATOR_UNDER_SELECT_PRINTER_INDEX:
                rowHeight = SEPARATOR_ROW_HEIGHT;
                break;
            
            case SEPARATOR_UNDER_PAPER_TYPE_INDEX:
                rowHeight = SEPARATOR_ROW_HEIGHT;
                break;
                
            case PAPER_SHOW_INDEX:
                if (!(IS_IPAD && IS_OS_8_OR_LATER)) {
                    rowHeight = self.pageViewCell.frame.size.height;
                }
                break;
                
            case PAPER_SIZE_INDEX:
                if (!self.hppp.hidePaperSizeOption) {
                    rowHeight = tableView.rowHeight;
                }
                break;
                
            case PAPER_TYPE_INDEX:
                if ((!self.hppp.hidePaperTypeOption) && (self.currentPrintSettings.paper.paperSize == SizeLetter)) {
                    rowHeight = tableView.rowHeight;
                }
                break;
        
            case FILTER_INDEX:
                if (!([HPPP sharedInstance].hideBlackAndWhiteOption)) {
                    rowHeight = self.tableView.rowHeight;
                }
                break;
                
            case PRINT_SETTINGS_INDEX:
                rowHeight = tableView.rowHeight;
                break;
                
            case PRINTER_STATUS_INDEX:
                rowHeight = PRINTER_STATUS_ROW_HEIGHT;
                break;
                
            default:
                rowHeight = self.tableView.rowHeight;
                break;
        }
    } else {
        rowHeight = tableView.rowHeight;
    }
    
    return rowHeight;
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
    [defaults synchronize];
    
    [self paperSizeTableViewController:(HPPPPaperSizeTableViewController *)printSettingsTableViewController didSelectPaper:printSettings.paper];
    
    [self paperTypeTableViewController:(HPPPPaperTypeTableViewController *)printSettingsTableViewController didSelectPaper:printSettings.paper];
}

#pragma mark - HPPPPaperSizeTableViewControllerDelegate

- (void)paperSizeTableViewController:(HPPPPaperSizeTableViewController *)paperSizeTableViewController didSelectPaper:(HPPPPaper *)paper
{
    self.currentPrintSettings.paper = paper;
    [self updatePageSettingsUI];
    [self updatePrintSettingsUI];
    
    [self.tableView reloadData];
    
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

#pragma mark - PGPageViewControllerDelegate

- (void)pageViewController:(HPPPPageViewController *)pageViewController didTapPrintBarButtonItem:(UIBarButtonItem *)printBarButtonItem
{
    [self displaySystemPrintFromBarButtonItem:printBarButtonItem];
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
        [defaults synchronize];
        
        
        self.currentPrintSettings.printerName = selectedPrinter.displayName;
        self.currentPrintSettings.printerUrl = selectedPrinter.URL;
        self.currentPrintSettings.printerIsAvailable = YES;
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
