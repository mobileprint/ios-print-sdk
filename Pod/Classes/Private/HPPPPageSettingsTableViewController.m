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
#import "HPPPAnalyticsManager.h"
#import "HPPPPageSettingsTableViewController.h"
#import "HPPPPaper.h"
#import "HPPPPrintPageRenderer.h"
#import "HPPPPrintSettings.h"
#import "HPPPPrintItem.h"
#import "HPPPPaperSizeTableViewController.h"
#import "HPPPPaperTypeTableViewController.h"
#import "HPPPPrintSettingsTableViewController.h"
#import "HPPPWiFiReachability.h"
#import "HPPPPrinter.h"
#import "HPPPPrintLaterManager.h"
#import "HPPPDefaultSettingsManager.h"
#import "UITableView+HPPPHeader.h"
#import "UIColor+HPPPHexString.h"
#import "UIView+HPPPAnimation.h"
#import "UIImage+HPPPResize.h"
#import "UIColor+HPPPStyle.h"
#import "NSBundle+HPPPLocalizable.h"
#import "HPPPSupportAction.h"
#import "HPPPLayoutFactory.h"
#import "HPPPMultiPageView.h"
#import "HPPPPageRangeView.h"
#import "HPPPPageRange.h"
#import "HPPPPrintManager.h"
#import "HPPPPrintManager+Options.h"
#import "HPPPPrintJobsViewController.h"

#define REFRESH_PRINTER_STATUS_INTERVAL_IN_SECONDS 60

#define DEFAULT_ROW_HEIGHT 44.0f
#define DEFAULT_NUMBER_OF_COPIES 1

#define PRINT_SUMMARY_SECTION 0
#define PRINT_FUNCTION_SECTION 1
#define PRINTER_SELECTION_SECTION 2
#define PAPER_SELECTION_SECTION 3
#define PRINT_SETTINGS_SECTION 4
#define NUMBER_OF_COPIES_SECTION 5
#define FILTER_SECTION 6
#define SUPPORT_SECTION 7

#define PRINTER_SELECTION_INDEX 0
#define PAPER_SIZE_ROW_INDEX 0
#define PAPER_TYPE_ROW_INDEX 1
#define PRINT_SETTINGS_ROW_INDEX 0
#define FILTER_ROW_INDEX 0

#define kHPPPSelectPrinterPrompt HPPPLocalizedString(@"Select Printer", nil)
#define kPrinterDetailsNotAvailable HPPPLocalizedString(@"Not Available", @"Printer details not available")

@interface HPPPPageSettingsTableViewController () <UIPrintInteractionControllerDelegate, UIGestureRecognizerDelegate, HPPPPaperSizeTableViewControllerDelegate, HPPPPaperTypeTableViewControllerDelegate, HPPPPrintSettingsTableViewControllerDelegate,
    HPPPPageRangeViewDelegate, HPPPMultiPageViewDelegate,
    UIPrinterPickerControllerDelegate, UIAlertViewDelegate, HPPPPrintManagerDelegate>

@property (strong, nonatomic) HPPPPrintManager *printManager;
@property (strong, nonatomic) HPPPPrintSettings *currentPrintSettings;
@property (strong, nonatomic) HPPPWiFiReachability *wifiReachability;

@property (weak, nonatomic) IBOutlet UIStepper *numberOfCopiesStepper;
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
@property (weak, nonatomic) IBOutlet UILabel *numberOfCopiesLabel;
@property (weak, nonatomic) IBOutlet HPPPMultiPageView *multiPageView;

@property (weak, nonatomic) IBOutlet UITableViewCell *pageViewCell;
@property (weak, nonatomic) IBOutlet UITableViewCell *jobSummaryCell;
@property (weak, nonatomic) IBOutlet UITableViewCell *printCell;
@property (weak, nonatomic) IBOutlet UITableViewCell *selectPrinterCell;
@property (weak, nonatomic) IBOutlet UITableViewCell *paperSizeCell;
@property (weak, nonatomic) IBOutlet UITableViewCell *paperTypeCell;
@property (weak, nonatomic) IBOutlet UITableViewCell *pageRangeCell;
@property (weak, nonatomic) IBOutlet UITableViewCell *filterCell;
@property (weak, nonatomic) IBOutlet UITableViewCell *printSettingsCell;
@property (weak, nonatomic) IBOutlet UITableViewCell *numberOfCopiesCell;

@property (strong, nonatomic) UIView *smokeyView;
@property (strong, nonatomic) UIButton *smokeyCancelButton;
@property (strong, nonatomic) HPPPPageRangeView *pageRangeView;
@property (assign, nonatomic) CGRect editViewFrame;
@property (strong, nonatomic) UIButton *pageSelectionMark;
@property (strong, nonatomic) UIImage *selectedPageImage;
@property (strong, nonatomic) UIImage *unselectedPageImage;
@property (strong, nonatomic) HPPPPageRange *pageRange;

@property (weak, nonatomic) IBOutlet UIBarButtonItem *cancelBarButtonItem;

@property (strong, nonatomic) UIRefreshControl *refreshControl;
@property (strong, nonatomic) NSTimer *refreshPrinterStatusTimer;

@property (nonatomic, strong) UIActivityIndicatorView *spinner;
@property (nonatomic, strong) HPPP *hppp;
@property (nonatomic, assign) NSInteger numberOfCopies;

@property (strong, nonatomic) NSMutableArray *itemsToPrint;

@property (assign, nonatomic) BOOL showCurlOnAppear;

@end

@implementation HPPPPageSettingsTableViewController

@dynamic refreshControl;

NSString * const kHPPPLastPrinterNameSetting = @"kHPPPLastPrinterNameSetting";
NSString * const kHPPPLastPrinterIDSetting = @"kHPPPLastPrinterIDSetting";
NSString * const kHPPPLastPrinterModelSetting = @"kHPPPLastPrinterModelSetting";
NSString * const kHPPPLastPrinterLocationSetting = @"kHPPPLastPrinterLocationSetting";
NSString * const kHPPPLastPaperSizeSetting = @"kHPPPLastPaperSizeSetting";
NSString * const kHPPPLastPaperTypeSetting = @"kHPPPLastPaperTypeSetting";
NSString * const kHPPPLastFilterSetting = @"kHPPPLastFilterSetting";

int const kSaveDefaultPrinterIndex = 1;

NSString * const kHPPPDefaultPrinterAddedNotification = @"kHPPPDefaultPrinterAddedNotification";
NSString * const kHPPPDefaultPrinterRemovedNotification = @"kHPPPDefaultPrinterRemovedNotification";
NSString * const kPageSettingsScreenName = @"Print Preview Screen";

#pragma mark - UIView

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = HPPPLocalizedString(@"Page Settings", @"Title of the Page Settings Screen");
    
    self.hppp = [HPPP sharedInstance];
    
    if (self.navigationController) {
        self.navigationController.interactivePopGestureRecognizer.delegate = self;
    } else {
        [[HPPPLogger sharedInstance] logWarn:@"HPPPPageSettingsTableViewController is intended to be embedded in navigation controller. Navigation problems and othe unexpected behavior may occur if used without a navigation controller."];
    }
    
    self.tableView.rowHeight = DEFAULT_ROW_HEIGHT;
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    
    if ((IS_IPAD && IS_OS_8_OR_LATER) || (self.settingsOnly && nil == self.printItem)) {
        self.tableView.tableHeaderView = [[UIView alloc] initWithFrame:CGRectZero];
    }

    self.multiPageView.delegate = self;
    
    self.jobSummaryCell.textLabel.font = [self.hppp.appearance.addPrintLaterJobScreenAttributes objectForKey:kHPPPAddPrintLaterJobScreenJobSummarySubtitleFontAttribute];
    self.jobSummaryCell.textLabel.textColor = [UIColor blackColor];
    
    self.printLabel.font = self.hppp.tableViewCellPrintLabelFont;
    self.printLabel.textColor = self.hppp.tableViewCellPrintLabelColor;
    self.printLabel.text = HPPPLocalizedString(@"Print", @"Caption of the button for printing");
    
    self.printSettingsLabel.font = self.hppp.tableViewCellLabelFont;
    self.printSettingsLabel.textColor = self.hppp.tableViewCellLabelColor;
    self.printSettingsLabel.text = HPPPLocalizedString(@"Settings", nil);
    
    self.printSettingsDetailLabel.font = self.hppp.tableViewSettingsCellValueFont;
    self.printSettingsDetailLabel.textColor = self.hppp.tableViewSettingsCellValueColor;
    
    self.selectPrinterLabel.font = self.hppp.tableViewCellLabelFont;
    self.selectPrinterLabel.textColor = self.hppp.tableViewCellLabelColor;
    self.selectPrinterLabel.text = HPPPLocalizedString(@"Printer", nil);
    
    self.selectedPrinterLabel.font = self.hppp.tableViewCellValueFont;
    self.selectedPrinterLabel.textColor = self.hppp.tableViewCellValueColor;
    self.selectedPrinterLabel.text = HPPPLocalizedString(@"Select Printer", nil);
    
    self.paperSizeLabel.font = self.hppp.tableViewCellLabelFont;
    self.paperSizeLabel.textColor = self.hppp.tableViewCellLabelColor;
    self.paperSizeLabel.text = HPPPLocalizedString(@"Paper Size", nil);
    
    self.paperSizeSelectedLabel.font = self.hppp.tableViewCellValueFont;
    self.paperSizeSelectedLabel.textColor = self.hppp.tableViewCellValueColor;
    
    self.paperTypeLabel.font = self.hppp.tableViewCellLabelFont;
    self.paperTypeLabel.textColor = self.hppp.tableViewCellLabelColor;
    self.paperTypeLabel.text = HPPPLocalizedString(@"Paper Type", nil);
    
    self.paperTypeSelectedLabel.font = self.hppp.tableViewCellValueFont;
    self.paperTypeSelectedLabel.textColor = self.hppp.tableViewCellValueColor;
    self.paperTypeSelectedLabel.text = HPPPLocalizedString(@"Plain Paper", nil);
    
    self.numberOfCopiesLabel.font = self.hppp.tableViewCellLabelFont;
    self.numberOfCopiesLabel.textColor = self.hppp.tableViewCellLabelColor;
    self.numberOfCopiesLabel.text = HPPPLocalizedString(@"1 Copy", nil);
    
    [self setPageRangeLabelText:kPageRangeAllPages];
    if( 1 == self.printItem.numberOfPages ) {
        self.pageRangeCell.hidden = TRUE;
        self.pageSelectionMark.hidden = TRUE;
    } else {
        self.pageRangeCell.textLabel.font = self.hppp.tableViewCellLabelFont;
        self.pageRangeCell.textLabel.textColor = self.hppp.tableViewCellLabelColor;
        self.pageRangeCell.detailTextLabel.font = self.hppp.tableViewCellValueFont;
        self.pageRangeCell.detailTextLabel.textColor = self.hppp.tableViewCellValueColor;

        self.selectedPageImage = [self.hppp.appearance.addPrintLaterJobScreenAttributes objectForKey:kHPPPAddPrintLaterJobScreenJobPageSelectedImageAttribute];
        self.unselectedPageImage = [self.hppp.appearance.addPrintLaterJobScreenAttributes objectForKey:kHPPPAddPrintLaterJobScreenJobPageNotSelectedImageAttribute];
        self.pageSelectionMark = [UIButton buttonWithType:UIButtonTypeCustom];
        [self.pageSelectionMark setImage:self.selectedPageImage forState:UIControlStateNormal];
        self.pageSelectionMark.backgroundColor = [UIColor clearColor];
        self.pageSelectionMark.adjustsImageWhenHighlighted = NO;
        [self.pageSelectionMark addTarget:self action:@selector(pageSelectionMarkClicked) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:self.pageSelectionMark];
    }
    

    self.filterLabel.font = self.hppp.tableViewCellLabelFont;
    self.filterLabel.textColor = self.hppp.tableViewCellLabelColor;
    self.filterLabel.text = HPPPLocalizedString(@"Black & White mode", nil);
    
    self.pageViewCell.backgroundColor = [UIColor HPPPHPGrayBackgroundColor];
    
    self.currentPrintSettings = [HPPPPrintSettings alloc];
    self.currentPrintSettings.paper = [HPPP sharedInstance].defaultPaper;
    self.currentPrintSettings.printerName = kHPPPSelectPrinterPrompt;
    self.currentPrintSettings.printerIsAvailable = YES;
    
    [self loadLastUsed];
    
    if (self.hppp.hideBlackAndWhiteOption) {
        self.filterCell.hidden = YES;
    }
    
    self.numberOfCopies = DEFAULT_NUMBER_OF_COPIES;
    self.numberOfCopiesStepper.value = DEFAULT_NUMBER_OF_COPIES;
    self.numberOfCopiesStepper.tintColor = self.hppp.tableViewCellLinkLabelColor;
    
    [self reloadPaperSelectionSection];
    
    self.smokeyView = [[UIView alloc] init];
    self.smokeyView.backgroundColor = [UIColor blackColor];
    self.smokeyView.alpha = 0.0f;
    self.smokeyView.hidden = TRUE;
    self.smokeyView.userInteractionEnabled = FALSE;
    
    self.smokeyCancelButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [self.smokeyCancelButton setTitle:@"Cancel" forState:UIControlStateNormal];
    [self.smokeyCancelButton setTintColor:[UIColor whiteColor]];
    [self.smokeyView addSubview:self.smokeyCancelButton];
    
    [self.navigationController.view addSubview:self.smokeyView];
    
    self.pageRangeView = [[HPPPPageRangeView alloc] initWithFrame:self.view.frame];
    self.pageRangeView.delegate = self;
    self.pageRangeView.hidden = YES;
    self.pageRangeView.maxPageNum = self.printItem.numberOfPages;
    [self.navigationController.view addSubview:self.pageRangeView];

    [self prepareUiForIosVersion];
    [self updatePrintSettingsUI];
    [[HPPPPrinter sharedInstance] checkLastPrinterUsedAvailability];
    [self updatePageSettingsUI];
    
    if ([self.dataSource respondsToSelector:@selector(numberOfPrintingItems)]) {
        NSInteger numberOfJobs = [self.dataSource numberOfPrintingItems];
        
        self.printLabel.text = [self stringFromNumberOfPrintingItems:numberOfJobs copies:1];
    }

    self.showCurlOnAppear = YES;

    [self changePaper];
    
    if (IS_OS_8_OR_LATER) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleDidCheckPrinterAvailability:) name:kHPPPPrinterAvailabilityNotification object:nil];
        
        self.refreshControl = [[UIRefreshControl alloc] init];
        [self.refreshControl addTarget:self action:@selector(startRefreshing:) forControlEvents:UIControlEventValueChanged];
        [self.tableView addSubview:self.refreshControl];
        
        self.refreshPrinterStatusTimer = [NSTimer scheduledTimerWithTimeInterval:REFRESH_PRINTER_STATUS_INTERVAL_IN_SECONDS
                                                                          target:self
                                                                        selector:@selector(refreshPrinterStatus:)
                                                                        userInfo:nil
                                                                         repeats:YES];
    }
    
    [self preparePrintManager];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if (self.printItem) {
        [self configurePrintButton];
        [self reloadJobSummary];
        if (![[HPPPWiFiReachability sharedInstance] isWifiConnected]) {
            [[HPPPWiFiReachability sharedInstance] noPrintingAlert];
        }
    }

    if (self.settingsOnly) {
        self.printCell.hidden = YES;
        self.cancelBarButtonItem.title = @"Done";
        self.pageSelectionMark.hidden = YES;
        self.pageRangeCell.hidden = YES;
        self.numberOfCopiesCell.hidden = YES;
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(connectionEstablished:) name:kHPPPWiFiConnectionEstablished object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(connectionLost:) name:kHPPPWiFiConnectionLost object:nil];
    [[NSNotificationCenter defaultCenter] postNotificationName:kHPPPTrackableScreenNotification object:nil userInfo:[NSDictionary dictionaryWithObject:kPageSettingsScreenName forKey:kHPPPTrackableScreenNameKey]];
}

-  (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kHPPPWiFiConnectionEstablished object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kHPPPWiFiConnectionLost object:nil];
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    if (IS_SPLIT_VIEW_CONTROLLER_IMPLEMENTATION) {
        self.multiPageView = self.pageViewController.multiPageView;
        self.multiPageView.delegate = self;
        [self configureMultiPageViewWithPrintItem:self.printItem];
    }
    
    [self.multiPageView refreshLayout];
}

- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator
{
    [super viewWillTransitionToSize:size withTransitionCoordinator:coordinator];
    
    [self.tableView reloadData];
}

- (void)viewDidLayoutSubviews
{
    [self.view layoutIfNeeded];
    [self.multiPageView refreshLayout];
    [self setEditFrames];
    if( self.pageRangeView ) {
        [self.pageRangeView refreshLayout:(CGRect)self.editViewFrame];
    }
}

- (void)dealloc
{
    [self.refreshPrinterStatusTimer invalidate];
    self.refreshPrinterStatusTimer = nil;
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - Pull to refresh

- (void)startRefreshing:(UIRefreshControl *)refreshControl
{
    NSString *lastPrinterUrl = [[NSUserDefaults standardUserDefaults] objectForKey:LAST_PRINTER_USED_URL_SETTING];
    
    if( nil != lastPrinterUrl ) {
        [[HPPPPrinter sharedInstance] checkLastPrinterUsedAvailability];
    } else {
        if (self.refreshControl.refreshing) {
            [self.refreshControl endRefreshing];
        }
    }
}

- (void)refreshPrinterStatus:(NSTimer *)timer
{
    HPPPLogInfo(@"Printer status timer fired");
    [[HPPPPrinter sharedInstance] checkLastPrinterUsedAvailability];
}

#pragma mark - Configure UI

- (void)changePaper
{
    if ([self.dataSource respondsToSelector:@selector(printingItemForPaper:withCompletion:)] && [self.dataSource respondsToSelector:@selector(previewImageForPaper:withCompletion:)]) {
        [self.dataSource printingItemForPaper:self.currentPrintSettings.paper withCompletion:^(HPPPPrintItem *printItem) {
            if (printItem) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    self.printItem = printItem;
                });
            } else {
                HPPPLogError(@"Missing printing item or preview image");
            }
        }];
    } else {
        [self configureMultiPageViewWithPrintItem:self.printItem];
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
    
    HPPPDefaultSettingsManager *settings = [HPPPDefaultSettingsManager sharedInstance];
    if( [settings isDefaultPrinterSet] ) {
        self.currentPrintSettings.printerName = settings.defaultPrinterName;
        self.currentPrintSettings.printerUrl = [NSURL URLWithString:settings.defaultPrinterUrl];
        self.currentPrintSettings.printerId = nil;
        self.currentPrintSettings.printerModel = settings.defaultPrinterModel;
        self.currentPrintSettings.printerLocation = settings.defaultPrinterLocation;
    } else {
        self.currentPrintSettings.printerName = [[NSUserDefaults standardUserDefaults] objectForKey:kHPPPLastPrinterNameSetting];
        self.currentPrintSettings.printerUrl = [NSURL URLWithString:[[NSUserDefaults standardUserDefaults] objectForKey:LAST_PRINTER_USED_URL_SETTING]];
        self.currentPrintSettings.printerId = [[NSUserDefaults standardUserDefaults] objectForKey:kHPPPLastPrinterIDSetting];
        self.currentPrintSettings.printerModel = [[NSUserDefaults standardUserDefaults] objectForKey:kHPPPLastPrinterModelSetting];
        self.currentPrintSettings.printerLocation = [[NSUserDefaults standardUserDefaults] objectForKey:kHPPPLastPrinterLocationSetting];
    }
    
    if (IS_OS_8_OR_LATER) {
        NSNumber *lastFilterUsed = [[NSUserDefaults standardUserDefaults] objectForKey:kHPPPLastFilterSetting];
        if (lastFilterUsed != nil) {
            self.blackAndWhiteModeSwitch.on = lastFilterUsed.boolValue;
        }
    }
}

- (HPPPPaper *)lastPaperUsed
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    NSNumber *lastSizeUsed = [defaults objectForKey:kHPPPLastPaperSizeSetting];
    NSNumber *lastTypeUsed = [defaults objectForKey:kHPPPLastPaperTypeSetting];
    
    PaperSize paperSize = (PaperSize)self.hppp.defaultPaper.paperSize;
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
        if (self.currentPrintSettings.printerName == nil || self.settingsOnly){
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
    self.selectedPrinterLabel.text = self.currentPrintSettings.printerName == nil ? kHPPPSelectPrinterPrompt : self.currentPrintSettings.printerName;
    
    NSString *displayedPrinterName = [self.selectedPrinterLabel.text isEqualToString:kHPPPSelectPrinterPrompt] ? @"" : [NSString stringWithFormat:@", %@", self.selectedPrinterLabel.text];
    
    self.printSettingsDetailLabel.text = [NSString stringWithFormat:@"%@, %@ %@", self.paperSizeSelectedLabel.text, self.paperTypeSelectedLabel.text, displayedPrinterName];
}

- (UIPrintInteractionController *)getSharedPrintInteractionController
{
    UIPrintInteractionController *controller = [UIPrintInteractionController sharedPrintController];
    
    if (nil != controller) {
        controller.delegate = self;
    }
    
    return controller;
}

- (void)showPrinterSelection:(UITableView *)tableView withCompletion:(void (^)(BOOL userDidSelect))completion
{
    if ([[HPPPWiFiReachability sharedInstance] isWifiConnected]) {
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
    } else {
        [[HPPPWiFiReachability sharedInstance] noPrinterSelectAlert];
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

- (void)setPrintItem:(HPPPPrintItem *)printItem
{
    _printItem = printItem;
    [self configureMultiPageViewWithPrintItem:printItem];
}

- (void)configureMultiPageViewWithPrintItem:(HPPPPrintItem *)printItem
{
    if (self.currentPrintSettings.paper) {
        self.multiPageView.blackAndWhite = self.blackAndWhiteModeSwitch.on;
        [self.multiPageView setInterfaceOptions:[HPPP sharedInstance].interfaceOptions];
        NSArray *images = [printItem previewImagesForPaper:self.currentPrintSettings.paper];
        [self.multiPageView setPages:images paper:self.currentPrintSettings.paper layout:printItem.layout];
    }
}

- (void)setEditFrames
{
    self.editViewFrame = [self.navigationController.view convertRect:self.view.frame fromView:[self.view superview]];
    self.smokeyView.frame = [[UIScreen mainScreen] bounds];
    
    // We can't make use of hidden methods, so this position is hard-coded... at a decent risk of truncation and bad position
    //  Hidden method: self.smokeyCancelButton.frame = [self.navigationController.view convertRect:((UIView*)[self.cancelButtonItem performSelector:@selector(view)]).frame fromView:self.navigationController.navigationBar];
    if( IS_PORTRAIT ) {
        int cancelButtonWidth = 54;
        int cancelButtonRightMargin = IS_IPAD ? 20 : 8;
        int cancelButtonXOrigin = self.smokeyView.frame.size.width - (cancelButtonWidth + cancelButtonRightMargin);
        self.smokeyCancelButton.frame = CGRectMake(cancelButtonXOrigin, 27, cancelButtonWidth, 30);
    } else {
        int cancelButtonWidth = 54;
        int cancelButtonRightMargin = 20;
        int cancelButtonXOrigin = self.smokeyView.frame.size.width - (cancelButtonWidth + cancelButtonRightMargin);
        self.smokeyCancelButton.frame = CGRectMake(cancelButtonXOrigin, 7, cancelButtonWidth, 30);
    }
}

-(void)displaySmokeyView:(BOOL)display
{
    self.tableView.scrollEnabled = !display;
    
    if( display ) {
        self.smokeyView.hidden = FALSE;
        self.smokeyView.alpha = 0.6f;
    } else {
        self.smokeyView.alpha = 0.0f;
    }
}

- (void)dismissEditView
{
    CGRect desiredFrame = self.pageRangeView.frame;
    desiredFrame.origin.y = self.pageRangeView.frame.origin.y + self.pageRangeView.frame.size.height;
    
    [UIView animateWithDuration:0.6f animations:^{
        [self displaySmokeyView:NO];
        self.pageRangeView.frame = desiredFrame;
        [self setNavigationBarEditing:FALSE];
    } completion:^(BOOL finished) {
        self.pageRangeView.hidden = YES;
        self.smokeyView.hidden = YES;
    }];
}

- (void)setNavigationBarEditing:(BOOL)editing
{
    UIColor *buttonColor = nil;
    
    if (editing) {
        buttonColor = [UIColor clearColor];
    }
    
    self.cancelBarButtonItem.tintColor = buttonColor;
}

-(void)respondToMultiPageViewAction
{
    if( self.pageSelectionMark.imageView.image == self.selectedPageImage ) {
        [self includeCurrentPageInPageRange:FALSE];
    } else {
        [self includeCurrentPageInPageRange:TRUE];
    }
}

-(void)includeCurrentPageInPageRange:(BOOL)includePage
{
    HPPPPageRange *pageRange = self.pageRange;
    
    if( includePage ) {
        [pageRange addPage:[NSNumber numberWithInteger:self.multiPageView.currentPage]];
    } else {
        [pageRange removePage:[NSNumber numberWithInteger:self.multiPageView.currentPage]];
    }
    
    if( [pageRange getPages].count > 0 ) {
        self.pageRangeCell.detailTextLabel.text = pageRange.range;
    } else {
        self.pageRangeCell.detailTextLabel.text = kPageRangeNoPages;
    }

    [self updateSelectedPageIcon:includePage];
    [self reloadJobSummary];
}

- (void)setPageRangeLabelText:(NSString *)pageRange
{
    if( pageRange.length ) {
        self.pageRangeCell.detailTextLabel.text = pageRange;
    } else {
        self.pageRangeCell.detailTextLabel.text = kPageRangeAllPages;
    }
}

-(void)updateSelectedPageIcon:(BOOL)selectPage
{
    UIImage *image;
    
    if( selectPage ) {
        image = self.selectedPageImage;
    } else {
        image = self.unselectedPageImage;
    }
    
    [self.pageSelectionMark setImage:image forState:UIControlStateNormal];
}

-(void)reloadJobSummary
{
    NSArray *allPages = [[NSArray alloc] init];
    NSArray *uniquePages = [[NSArray alloc] init];
    NSInteger numPagesToBePrinted = 0;
    if( ![kPageRangeNoPages isEqualToString:self.pageRangeCell.detailTextLabel.text] ) {
        allPages = [self.pageRange getPages];
        uniquePages = [self.pageRange getUniquePages];
        numPagesToBePrinted = allPages.count * self.numberOfCopiesStepper.value;
    }
    
    BOOL printingOneCopyOfAllPages = (1 == self.numberOfCopiesStepper.value && [kPageRangeAllPages isEqualToString:self.pageRangeCell.detailTextLabel.text]);

    NSString *text = @"";
    if( 1 < self.printItem.numberOfPages && !self.settingsOnly ) {
        text = [NSString stringWithFormat:@"%ld of %ld Pages Selected", (long)uniquePages.count, (long)self.printItem.numberOfPages];
    }
    
    if( text.length > 0 ) {
        text = [text stringByAppendingString:@"/"];
    }
    
    text = [text stringByAppendingString:self.paperSizeSelectedLabel.text];
    
    self.jobSummaryCell.textLabel.text = text;
    
    if( 0 == allPages.count  ||  printingOneCopyOfAllPages ) {
        self.printLabel.text = @"Print";
    } else if( 1 == numPagesToBePrinted ) {
        self.printLabel.text = @"Print 1 Page";
    } else {
        self.printLabel.text = [NSString stringWithFormat:@"Print %ld Pages", (long)numPagesToBePrinted];
    }
    
    HPPP *hppp = [HPPP sharedInstance];
    if( 0 == allPages.count ) {
        self.printCell.userInteractionEnabled = FALSE;
        self.printLabel.textColor = [hppp.appearance.addPrintLaterJobScreenAttributes objectForKey:kHPPPAddPrintLaterJobScreenAddToPrintQInactiveColorAttribute];
    } else {
        self.printCell.userInteractionEnabled = TRUE;
        self.printLabel.textColor = [hppp.appearance.addPrintLaterJobScreenAttributes objectForKey:kHPPPAddPrintLaterJobScreenAddToPrintQActiveColorAttribute];;
    }
    
    [self.tableView reloadData];
}

- (HPPPPageRange *)pageRange
{
    if (nil == _pageRange) {
        _pageRange = [[HPPPPageRange alloc] initWithString:kPageRangeAllPages allPagesIndicator:kPageRangeAllPages maxPageNum:self.printItem.numberOfPages sortAscending:TRUE];
    }
    
    if( 1 < self.printItem.numberOfPages ) {
        [_pageRange setRange:self.pageRangeCell.detailTextLabel.text];
    }
    
    return _pageRange;
}

- (NSString *)stringFromNumberOfPrintingItems:(NSInteger)numberOfPrintingItems copies:(NSInteger)copies
{
    NSString *result = nil;
    
    if (numberOfPrintingItems == 1) {
        result = HPPPLocalizedString(@"Print", @"Caption of the button for printing");
    } else {
        NSInteger total = numberOfPrintingItems * copies;
        
        if (total == 2) {
            result = HPPPLocalizedString(@"Print both", @"Caption of the button for printing");
        } else {
            result = [NSString stringWithFormat:HPPPLocalizedString(@"Print all %lu", @"Caption of the button for printing"), (long)total];
        }
    }
    
    return result;
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

#pragma mark - Button actions

- (IBAction)closeButtonTapped:(id)sender
{
    if (!self.pageRangeView.hidden) {
        [self.pageRangeView cancelEditing];
        [self dismissEditView];
    }
    else if ([self.delegate respondsToSelector:@selector(didCancelPrintFlow:)]) {
        if (self.settingsOnly) {
            [self saveSettings];
        }
        [self.delegate didCancelPrintFlow:self];
    } else {
        HPPPLogWarn(@"No HPPPPrintDelegate has been set to respond to the end of the print flow.  Implement this delegate to dismiss the Page Settings view controller.");
    }
}

- (void)displaySystemPrintFromView:(UIView *)view
{
    // Obtain the shared UIPrintInteractionController
    UIPrintInteractionController *controller = [self getSharedPrintInteractionController];
    
    if (!controller) {
        HPPPLogError(@"Couldn't get shared UIPrintInteractionController!");
        return;
    }
    
    controller.showsNumberOfCopies = NO;
    
    self.printManager.currentPrintSettings = self.currentPrintSettings;
    [self.printManager prepareController:controller printItem:self.printItem color:!self.blackAndWhiteModeSwitch.on pageRange:self.pageRange numCopies:self.numberOfCopies];
    
    UIPrintInteractionCompletionHandler completionHandler = ^(UIPrintInteractionController *printController, BOOL completed, NSError *error) {
        
        if (!completed) {
            HPPPLogInfo(@"Print was NOT completed");
        }
        
        if (error) {
            HPPPLogWarn(@"Print error:  %@", error);
        }

        if (completed && !error) {
            [self.printManager saveLastOptionsForPrinter:printController.printInfo.printerID];
            [self.printManager processMetricsForPrintItem:self.printItem];
        }

        [self printCompleted:printController isCompleted:completed printError:error];

    };
    
    if (IS_IPAD) {
        self.cancelBarButtonItem.enabled = NO;
        [controller presentFromRect:view.frame inView:self.view animated:YES completionHandler:completionHandler];
    } else {
        [controller presentAnimated:YES completionHandler:completionHandler];
    }
    
}

- (void)pageSelectionMarkClicked
{
    [self respondToMultiPageViewAction];
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

#pragma mark - Stepper actions

- (IBAction)numberOfCopiesStepperTapped:(UIStepper *)sender
{
    self.numberOfCopies = sender.value;
    
    self.numberOfCopiesLabel.text = (self.numberOfCopies == 1) ? HPPPLocalizedString(@"1 Copy", nil) : [NSString stringWithFormat:HPPPLocalizedString(@"%ld Copies", @"Number of copies"), (long)self.numberOfCopies];
    
    if ([self.dataSource respondsToSelector:@selector(numberOfPrintingItems)]) {
        NSInteger numberOfJobs = [self.dataSource numberOfPrintingItems];
        
        self.printLabel.text = [self stringFromNumberOfPrintingItems:numberOfJobs copies:self.numberOfCopies];
    } else {
        self.printLabel.text = [self stringFromNumberOfPrintingItems:1 copies:self.numberOfCopies];
    }
    
    [self reloadJobSummary];
}

#pragma mark - Switch actions

- (IBAction)blackAndWhiteSwitchToggled:(id)sender
{
    self.multiPageView.blackAndWhite = self.blackAndWhiteModeSwitch.on;
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:[NSNumber numberWithInteger:self.blackAndWhiteModeSwitch.on] forKey:kHPPPLastFilterSetting];
    [defaults synchronize];
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if (self.hppp.supportActions.count != 0 && !self.settingsOnly)
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
    } else if (PRINT_SUMMARY_SECTION == section && self.settingsOnly && nil == self.printItem) {
        return 0;
    }
    else {
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

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if( cell == self.jobSummaryCell ) {
        CGRect frame = self.jobSummaryCell.frame;
        frame.origin.x = self.view.frame.size.width - 55;
        frame.origin.y = self.jobSummaryCell.frame.origin.y - 12.5;
        frame.size.width = 32;
        frame.size.height = 32;
        
        self.pageSelectionMark.frame = [self.jobSummaryCell.superview convertRect:frame toView:self.view];
    }
}

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
    
    if (section == PRINT_FUNCTION_SECTION  ||  section == PRINT_SUMMARY_SECTION) {
        height = SEPARATOR_SECTION_FOOTER_HEIGHT;
    } else if (IS_OS_8_OR_LATER && ((section == PRINTER_SELECTION_SECTION) || (section == PAPER_SELECTION_SECTION))) {
        if ((!self.hppp.hidePaperTypeOption) && (self.currentPrintSettings.printerUrl == nil)) {
            height = SEPARATOR_SECTION_FOOTER_HEIGHT;
        }
    } else if (!IS_OS_8_OR_LATER && (section == PAPER_SELECTION_SECTION)) {
        height = SEPARATOR_SECTION_FOOTER_HEIGHT;
    } else if (IS_OS_8_OR_LATER && (section == PRINT_SETTINGS_SECTION)) {
        if (self.currentPrintSettings.printerUrl != nil) {
            if (self.currentPrintSettings.printerIsAvailable) {
                height = SEPARATOR_SECTION_FOOTER_HEIGHT;
            } else {
                height = PRINTER_WARNING_SECTION_FOOTER_HEIGHT;
            }
        }
    } else if (IS_OS_8_OR_LATER && (section == NUMBER_OF_COPIES_SECTION)) {
        height = SEPARATOR_SECTION_FOOTER_HEIGHT;
    } else if (section == SUPPORT_SECTION) {
        height = SEPARATOR_SECTION_FOOTER_HEIGHT;
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
    } else if (cell == self.pageRangeCell){
        [self setEditFrames];
        self.pageRangeView.frame = self.editViewFrame;
        
        [UIView animateWithDuration:0.6f animations:^{
            [self displaySmokeyView:TRUE];
            [self setNavigationBarEditing:TRUE];
            self.pageRangeView.hidden = NO;
        } completion:^(BOOL finished) {
            [self.pageRangeView beginEditing];
        }];
    
        [self.pageRangeView prepareForDisplay:self.pageRange.range];
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
                label.font = self.hppp.tableViewFooterWarningLabelFont;
                label.textColor = self.hppp.tableViewFooterWarningLabelColor;
                if (self.printFromQueue) {
                    label.text = HPPPLocalizedString(@"Default printer not currently available", nil);
                } else {
                    label.text = HPPPLocalizedString(@"Recent printer not currently available", nil);
                }
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
            !self.currentPrintSettings.printerIsAvailable ) {
            [self showPrinterSelection:tableView withCompletion:^(BOOL userDidSelect){
                if (userDidSelect) {
                    [self startPrinting];
                }
            }];
        } else {
            [self startPrinting];
        }
    } else {
        [self displaySystemPrintFromView:self.printCell];
    }
}

- (void)startPrinting
{
    self.itemsToPrint = [self collectPrintingItems];
    id firstItem = [self.itemsToPrint firstObject];
    [self.itemsToPrint removeObject:firstItem];

    [self print:firstItem];
}

- (NSMutableArray *)collectPrintingItems
{
    NSMutableArray *items = nil;
    
    if ([self.dataSource respondsToSelector:@selector(numberOfPrintingItems)]) {
        NSInteger numberOfJobs = [self.dataSource numberOfPrintingItems];
        if (numberOfJobs > 1) {
            if ([self.dataSource respondsToSelector:@selector(printingItemsForPaper:)]) {
                items = [self.dataSource printingItemsForPaper:self.currentPrintSettings.paper].mutableCopy;
            }
        }
    }
    
    if (nil == items) {
        items = [NSMutableArray arrayWithObjects:self.printItem, nil];
    }
    
    return items;
}

- (void)print:(HPPPPrintItem *)printItem
{
    self.currentPrintSettings.color = !self.blackAndWhiteModeSwitch.on;
    self.printManager.currentPrintSettings = self.currentPrintSettings;

    NSError *error;
    [self.printManager print:printItem
                         pageRange:self.pageRange
                         numCopies:self.numberOfCopiesStepper.value
                             error:&error];
    
    if( HPPPPrintManagerErrorNone != error.code ) {
        HPPPLogError(@"Failed to print with error %@", error);
    }
}

- (void)printCompleted:(UIPrintInteractionController *)printController isCompleted:(BOOL)completed printError:(NSError *)error
{
    [self savePrinterID:printController.printInfo.printerID];
    
    if (error) {
        HPPPLogError(@"FAILED! due to error in domain %@ with error code %ld", error.domain, (long)error.code);
    }
    
    if (completed) {
        
        [self setDefaultPrinter];
    
        if ([self.delegate respondsToSelector:@selector(didFinishPrintFlow:)]) {
            [self.delegate didFinishPrintFlow:self];
        }
        else {
            HPPPLogWarn(@"No HPPPPrintDelegate has been set to respond to the end of the print flow.  Implement this delegate to dismiss the Page Settings view controller.");
        }
    }
    
    if (IS_IPAD) {
        self.cancelBarButtonItem.enabled = YES;
    }
}

- (void)savePrinterID:(NSString *)printerID
{
    self.currentPrintSettings.printerId = printerID;
    NSUserDefaults * defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:self.currentPrintSettings.printerId forKey:kHPPPLastPrinterIDSetting];
    [defaults synchronize];
}

- (void)setPrinterDetails:(UIPrinter *)printer
{
    self.currentPrintSettings.printerUrl = printer.URL;
    self.currentPrintSettings.printerId = printer.URL.absoluteString;
    self.currentPrintSettings.printerName = printer.displayName;
    self.currentPrintSettings.printerLocation = printer.displayLocation;
    self.currentPrintSettings.printerModel = printer.makeAndModel;
}

- (void)savePrinterInfo
{
    NSUserDefaults * defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:self.currentPrintSettings.printerUrl.absoluteString forKey:LAST_PRINTER_USED_URL_SETTING];
    [defaults setObject:self.currentPrintSettings.printerName forKey:kHPPPLastPrinterNameSetting];
    [defaults setObject:self.currentPrintSettings.printerId forKey:kHPPPLastPrinterIDSetting];
    [defaults setObject:self.currentPrintSettings.printerModel forKey:kHPPPLastPrinterModelSetting];
    [defaults setObject:self.currentPrintSettings.printerLocation forKey:kHPPPLastPrinterLocationSetting];
    [defaults synchronize];
}

- (void)setDefaultPrinter
{
    [HPPPDefaultSettingsManager sharedInstance].defaultPrinterName = self.currentPrintSettings.printerName;
    [HPPPDefaultSettingsManager sharedInstance].defaultPrinterUrl = self.currentPrintSettings.printerUrl.absoluteString;
    [HPPPDefaultSettingsManager sharedInstance].defaultPrinterNetwork = [HPPPAnalyticsManager wifiName];
    [HPPPDefaultSettingsManager sharedInstance].defaultPrinterCoordinate = [[HPPPPrintLaterManager sharedInstance] retrieveCurrentLocation];
    [HPPPDefaultSettingsManager sharedInstance].defaultPrinterModel = self.currentPrintSettings.printerModel;
    [HPPPDefaultSettingsManager sharedInstance].defaultPrinterLocation = self.currentPrintSettings.printerLocation;
    [[NSNotificationCenter defaultCenter] postNotificationName:kHPPPDefaultPrinterAddedNotification object:self userInfo:nil];
}

- (void)saveSettings
{
    [self setDefaultPrinter];
    NSString *printerID = [HPPPDefaultSettingsManager sharedInstance].defaultPrinterUrl;
    [self savePrinterID:printerID];
    [self.printManager saveLastOptionsForPrinter:printerID];
}

- (void)preparePrintManager
{
    self.printManager = [[HPPPPrintManager alloc] init];
    self.printManager.delegate = self;

    HPPPPrintManagerOptions options = HPPPPrintManagerOriginCustom;
    if ([self.delegate class] == [HPPPPrintActivity class]) {
        options = HPPPPrintManagerOriginShare;
    } else if ([self.delegate class] == [HPPPPrintJobsViewController class]) {
        options = HPPPPrintManagerOriginQueue;
    }

    if ([self.dataSource respondsToSelector:@selector(numberOfPrintingItems)]) {
        if ([self.dataSource numberOfPrintingItems] > 1) {
            options += HPPPPrintManagerMultiJob;
        }
    }
    
    self.printManager.options = options;
}

#pragma mark - HPPPMultipageViewDelegate

- (void)multiPageView:(HPPPMultiPageView *)multiPageView didChangeFromPage:(NSUInteger)oldPageNumber ToPage:(NSUInteger)newPageNumber
{
    if (!self.settingsOnly) {
        BOOL pageSelected = FALSE;
        
        NSArray *pageNums = [self.pageRange getPages];
        
        for( NSNumber *pageNum in pageNums ) {
            if( [pageNum integerValue] == newPageNumber ) {
                pageSelected = TRUE;
                break;
            }
        }
        
        [self updateSelectedPageIcon:pageSelected];
    }
}

- (void)multiPageView:(HPPPMultiPageView *)multiPageView didSingleTapPage:(NSUInteger)pageNumber
{
    if (!self.settingsOnly) {
        [self respondToMultiPageViewAction];
    }
}

#pragma mark - HPPPPrintSettingsTableViewControllerDelegate

- (void)printSettingsTableViewController:(HPPPPrintSettingsTableViewController *)printSettingsTableViewController didChangePrintSettings:(HPPPPrintSettings *)printSettings
{
    self.currentPrintSettings.printerName = printSettings.printerName;
    self.currentPrintSettings.printerUrl = printSettings.printerUrl;
    self.currentPrintSettings.printerModel = printSettings.printerModel;
    self.currentPrintSettings.printerLocation = printSettings.printerLocation;
    self.currentPrintSettings.printerIsAvailable = printSettings.printerIsAvailable;
    
    [self savePrinterInfo];
    
    [self paperSizeTableViewController:(HPPPPaperSizeTableViewController *)printSettingsTableViewController didSelectPaper:printSettings.paper];
    
    [self paperTypeTableViewController:(HPPPPaperTypeTableViewController *)printSettingsTableViewController didSelectPaper:printSettings.paper];
    
    [self reloadPrinterSelectionSection];
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
    [defaults setObject:[NSNumber numberWithInteger:self.currentPrintSettings.paper.paperSize] forKey:kHPPPLastPaperSizeSetting];
    [defaults synchronize];
    
    [self changePaper];
}

#pragma mark - HPPPPaperTypeTableViewControllerDelegate

- (void)paperTypeTableViewController:(HPPPPaperTypeTableViewController *)paperTypeTableViewController didSelectPaper:(HPPPPaper *)paper
{
    self.currentPrintSettings.paper = paper;
    [self updatePrintSettingsUI];
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:[NSNumber numberWithInteger:self.currentPrintSettings.paper.paperType] forKey:kHPPPLastPaperTypeSetting];
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
        HPPPLogInfo(@"Selected Printer: %@", selectedPrinter.URL);
        self.currentPrintSettings.printerIsAvailable = YES;
        [self setPrinterDetails:selectedPrinter];
        [self savePrinterInfo];
        [self updatePageSettingsUI];
        [self updatePrintSettingsUI];
    }
}

#pragma mark - Edit View Delegates

- (void)didSelectPageRange:(HPPPPageRangeView *)view pageRange:(HPPPPageRange *)pageRange
{
    [self setPageRangeLabelText:pageRange.range];
    [self reloadJobSummary];
    
    // Update the page selected icon accordingly
    BOOL pageSelected = FALSE;
    NSArray *pageNums = [pageRange getPages];
    for( NSNumber *pageNum in pageNums ) {
        if( [pageNum integerValue] == self.multiPageView.currentPage) {
            pageSelected = TRUE;
            break;
        }
    }
    [self updateSelectedPageIcon:pageSelected];
    
    [self dismissEditView];
}

#pragma mark - HPPPPrintManagerDelegate

- (void)didFinishPrintJob:(UIPrintInteractionController *)printController completed:(BOOL)completed error:(NSError *)error
{
    if (error) {
        HPPPLogError(@"Print error: %@", error);
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        id nextItem = [self.itemsToPrint firstObject];
        if (nextItem) {
            [self.itemsToPrint removeObject:nextItem];
            [self print:nextItem];
        } else {
            [self printCompleted:printController isCompleted:completed printError:error];
        }
    });
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"PrintSettingsSegue"]) {
        
        HPPPPrintSettingsTableViewController *vc = (HPPPPrintSettingsTableViewController *)segue.destinationViewController;
        vc.printSettings = self.currentPrintSettings;
        vc.useDefaultPrinter = self.printFromQueue;
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

#pragma mark - Notifications

- (void)handleDidCheckPrinterAvailability:(NSNotification *)notification
{
    HPPPLogInfo(@"handleDidCheckPrinterAvailability: %@", notification);
    
    BOOL available = [[notification.userInfo objectForKey:kHPPPPrinterAvailableKey] boolValue];
    
    if ( available ) {
        [self printerIsAvailable];
    } else {
        [self printerNotAvailable];
    }
    
    [self reloadPrinterSelectionSection];
    
    if (IS_OS_8_OR_LATER) {
        if (self.refreshControl.refreshing) {
            [self.refreshControl endRefreshing];
        }
    }
}

#pragma mark - Wi-Fi handling

- (void)connectionEstablished:(NSNotification *)notification
{
    [self configurePrintButton];
}

- (void)connectionLost:(NSNotification *)notification
{
    [self configurePrintButton];
    [[HPPPWiFiReachability sharedInstance] noPrintingAlert];
}

- (void)configurePrintButton
{
    if ([[HPPPWiFiReachability sharedInstance] isWifiConnected]) {
        self.printCell.userInteractionEnabled = YES;
        self.printLabel.textColor = [HPPP sharedInstance].tableViewCellPrintLabelColor;
    } else {
        self.printCell.userInteractionEnabled = NO;
        self.printLabel.textColor = [UIColor grayColor];
    }
}

@end
