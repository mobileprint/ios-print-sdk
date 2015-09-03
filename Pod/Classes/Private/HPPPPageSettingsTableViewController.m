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
#import "HPPPPrintSettingsDelegateManager.h"
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


@interface HPPPPageSettingsTableViewController ()
   <UIGestureRecognizerDelegate,
    HPPPMultiPageViewDelegate,
    UIAlertViewDelegate,
    HPPPPrintManagerDelegate>

@property (strong, nonatomic) HPPPPrintManager *printManager;
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

@property (strong, nonatomic) HPPPPrintSettingsDelegateManager *delegateManager;

@property (weak, nonatomic) IBOutlet UIBarButtonItem *cancelBarButtonItem;

@property (strong, nonatomic) UIRefreshControl *refreshControl;
@property (strong, nonatomic) NSTimer *refreshPrinterStatusTimer;

@property (nonatomic, strong) UIActivityIndicatorView *spinner;
@property (nonatomic, strong) HPPP *hppp;
@property (nonatomic, assign) NSInteger numberOfCopies;

@property (strong, nonatomic) NSMutableArray *itemsToPrint;
@property (strong, nonatomic) NSMutableArray *pageRanges;
@property (strong, nonatomic) NSMutableArray *blackAndWhiteSelections;
@property (strong, nonatomic) NSMutableArray *numCopySelections;

@property (assign, nonatomic) BOOL showCurlOnAppear;

@end

@implementation HPPPPageSettingsTableViewController

@dynamic refreshControl;

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
    
    if( nil == self.delegateManager ) {
        self.delegateManager = [[HPPPPrintSettingsDelegateManager alloc] init];
    }
    self.delegateManager.pageSettingsViewController = self;
    
    if( self.printLaterJob ) {
        self.delegateManager.pageRange = self.printLaterJob.pageRange;
        self.delegateManager.blackAndWhite = self.printLaterJob.blackAndWhite;
        self.delegateManager.numCopies = self.printLaterJob.numCopies;
    } else {
        self.delegateManager.pageRange = [[HPPPPageRange alloc] initWithString:kPageRangeAllPages allPagesIndicator:kPageRangeAllPages maxPageNum:self.printItem.numberOfPages sortAscending:YES];
        self.delegateManager.pageRange.range = kPageRangeAllPages;
        self.delegateManager.numCopies = DEFAULT_NUMBER_OF_COPIES;
    }

    if (self.navigationController) {
        self.navigationController.interactivePopGestureRecognizer.delegate = self;
    } else {
        [[HPPPLogger sharedInstance] logWarn:@"HPPPPageSettingsTableViewController is intended to be embedded in navigation controller. Navigation problems and othe unexpected behavior may occur if used without a navigation controller."];
    }
    
    self.tableView.backgroundColor = [self.hppp.appearance.settings objectForKey:kHPPPBackgroundBackgroundColor];
    self.tableView.rowHeight = DEFAULT_ROW_HEIGHT;
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    
    if ((IS_IPAD && IS_OS_8_OR_LATER) || (self.settingsOnly && nil == self.printItem)) {
        self.tableView.tableHeaderView = [[UIView alloc] initWithFrame:CGRectZero];
    }
    
    self.multiPageView.delegate = self;
    
    self.jobSummaryCell.backgroundColor = [self.hppp.appearance.settings objectForKey:kHPPPJobSettingsBackgroundColor];
    self.jobSummaryCell.textLabel.font = [self.hppp.appearance.settings objectForKey:kHPPPJobSettingsSecondaryFont];
    self.jobSummaryCell.textLabel.textColor = [self.hppp.appearance.settings objectForKey:kHPPPJobSettingsSecondaryFontColor];
    
    self.printCell.backgroundColor = [self.hppp.appearance.settings objectForKey:kHPPPMainActionBackgroundColor];
    self.printLabel.font = [self.hppp.appearance.settings objectForKey:kHPPPMainActionLinkFont];
    self.printLabel.textColor = [self.hppp.appearance.settings objectForKey:kHPPPMainActionActiveLinkFontColor];
    self.printLabel.text = HPPPLocalizedString(@"Print", @"Caption of the button for printing");
    
    self.printSettingsCell.backgroundColor = [self.hppp.appearance.settings objectForKey:kHPPPSelectionOptionsBackgroundColor];
    self.printSettingsLabel.font = [self.hppp.appearance.settings objectForKey:kHPPPSelectionOptionsPrimaryFont];
    self.printSettingsLabel.textColor = [self.hppp.appearance.settings objectForKey:kHPPPSelectionOptionsPrimaryFontColor];
    self.printSettingsLabel.text = HPPPLocalizedString(@"Settings", nil);
    
    self.printSettingsDetailLabel.font = [self.hppp.appearance.settings objectForKey:kHPPPSelectionOptionsSecondaryFont];
    self.printSettingsDetailLabel.textColor = [self.hppp.appearance.settings objectForKey:kHPPPSelectionOptionsSecondaryFontColor];
    
    self.selectPrinterCell.backgroundColor = [self.hppp.appearance.settings objectForKey:kHPPPSelectionOptionsBackgroundColor];
    self.selectPrinterLabel.font = [self.hppp.appearance.settings objectForKey:kHPPPSelectionOptionsPrimaryFont];
    self.selectPrinterLabel.textColor = [self.hppp.appearance.settings objectForKey:kHPPPSelectionOptionsPrimaryFontColor];
    self.selectPrinterLabel.text = HPPPLocalizedString(@"Printer", nil);
    
    self.selectedPrinterLabel.font = [self.hppp.appearance.settings objectForKey:kHPPPSelectionOptionsSecondaryFont];
    self.selectedPrinterLabel.textColor = [self.hppp.appearance.settings objectForKey:kHPPPSelectionOptionsSecondaryFontColor];
    self.selectedPrinterLabel.text = HPPPLocalizedString(@"Select Printer", nil);
    
    self.paperSizeCell.backgroundColor = [self.hppp.appearance.settings objectForKey:kHPPPSelectionOptionsBackgroundColor];
    self.paperSizeLabel.font = [self.hppp.appearance.settings objectForKey:kHPPPSelectionOptionsPrimaryFont];
    self.paperSizeLabel.textColor = [self.hppp.appearance.settings objectForKey:kHPPPSelectionOptionsPrimaryFontColor];
    self.paperSizeLabel.text = HPPPLocalizedString(@"Paper Size", nil);
    
    self.paperSizeSelectedLabel.font = [self.hppp.appearance.settings objectForKey:kHPPPSelectionOptionsSecondaryFont];
    self.paperSizeSelectedLabel.textColor = [self.hppp.appearance.settings objectForKey:kHPPPSelectionOptionsSecondaryFontColor];
    
    self.paperTypeCell.backgroundColor = [self.hppp.appearance.settings objectForKey:kHPPPSelectionOptionsBackgroundColor];
    self.paperTypeLabel.font = [self.hppp.appearance.settings objectForKey:kHPPPSelectionOptionsPrimaryFont];
    self.paperTypeLabel.textColor = [self.hppp.appearance.settings objectForKey:kHPPPSelectionOptionsPrimaryFontColor];
    self.paperTypeLabel.text = HPPPLocalizedString(@"Paper Type", nil);
    
    self.paperTypeSelectedLabel.font = [self.hppp.appearance.settings objectForKey:kHPPPSelectionOptionsSecondaryFont];
    self.paperTypeSelectedLabel.textColor = [self.hppp.appearance.settings objectForKey:kHPPPSelectionOptionsSecondaryFontColor];
    self.paperTypeSelectedLabel.text = HPPPLocalizedString(@"Plain Paper", nil);
    
    self.numberOfCopiesCell.backgroundColor = [self.hppp.appearance.settings objectForKey:kHPPPSelectionOptionsBackgroundColor];
    self.numberOfCopiesLabel.font = [self.hppp.appearance.settings objectForKey:kHPPPSelectionOptionsPrimaryFont];
    self.numberOfCopiesLabel.textColor = [self.hppp.appearance.settings objectForKey:kHPPPSelectionOptionsPrimaryFontColor];
    self.numberOfCopiesLabel.text = HPPPLocalizedString(@"1 Copy", nil);
    
    self.pageRangeCell.backgroundColor = [self.hppp.appearance.settings objectForKey:kHPPPSelectionOptionsBackgroundColor];
    [self setPageRangeLabelText:kPageRangeAllPages];
    if( 1 == self.printItem.numberOfPages ) {
        self.pageRangeCell.hidden = YES;
        self.pageSelectionMark.hidden = YES;
    } else {
        self.pageRangeCell.textLabel.font = [self.hppp.appearance.settings objectForKey:kHPPPSelectionOptionsPrimaryFont];
        self.pageRangeCell.textLabel.textColor = [self.hppp.appearance.settings objectForKey:kHPPPSelectionOptionsPrimaryFontColor];
        self.pageRangeCell.detailTextLabel.font = [self.hppp.appearance.settings objectForKey:kHPPPSelectionOptionsSecondaryFont];
        self.pageRangeCell.detailTextLabel.textColor = [self.hppp.appearance.settings objectForKey:kHPPPSelectionOptionsSecondaryFontColor];

        self.selectedPageImage = [self.hppp.appearance.settings objectForKey:kHPPPJobSettingsSelectedPageIcon];
        self.unselectedPageImage = [self.hppp.appearance.settings objectForKey:kHPPPJobSettingsUnselectedPageIcon];
        self.pageSelectionMark = [UIButton buttonWithType:UIButtonTypeCustom];
        [self.pageSelectionMark setImage:self.selectedPageImage forState:UIControlStateNormal];
        self.pageSelectionMark.backgroundColor = [UIColor clearColor];
        self.pageSelectionMark.adjustsImageWhenHighlighted = NO;
        [self.pageSelectionMark addTarget:self action:@selector(pageSelectionMarkClicked) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:self.pageSelectionMark];
    }
    
    self.filterCell.backgroundColor = [self.hppp.appearance.settings objectForKey:kHPPPSelectionOptionsBackgroundColor];
    self.filterLabel.font = [self.hppp.appearance.settings objectForKey:kHPPPSelectionOptionsPrimaryFont];
    self.filterLabel.textColor = [self.hppp.appearance.settings objectForKey:kHPPPSelectionOptionsPrimaryFontColor];
    self.filterLabel.text = HPPPLocalizedString(@"Black & White mode", nil);
    self.blackAndWhiteModeSwitch.onTintColor = [self.hppp.appearance.settings objectForKey:kHPPPMainActionActiveLinkFontColor];
    
    self.pageViewCell.backgroundColor = [self.hppp.appearance.settings objectForKey:kHPPPBackgroundBackgroundColor];
    
    self.delegateManager.printSettings = [[HPPPPrintSettings alloc] init];
    [self.delegateManager loadLastUsed];
    self.delegateManager.printSettings.printerIsAvailable = YES;
    self.blackAndWhiteModeSwitch.on = self.delegateManager.blackAndWhite;
     
    if (self.hppp.hideBlackAndWhiteOption) {
        self.filterCell.hidden = YES;
    }
    
    self.numberOfCopies = self.delegateManager.numCopies;
    self.numberOfCopiesStepper.value = self.delegateManager.numCopies;
    self.numberOfCopiesStepper.tintColor = [self.hppp.appearance.settings objectForKey:kHPPPMainActionActiveLinkFontColor];
    
    [self reloadPaperSelectionSection];
    
    self.smokeyView = [[UIView alloc] init];
    self.smokeyView.backgroundColor = [self.hppp.appearance.settings objectForKey:kHPPPOverlayBackgroundColor];
    self.smokeyView.alpha = 0.0f;
    self.smokeyView.hidden = YES;
    self.smokeyView.userInteractionEnabled = NO;
    
    self.smokeyCancelButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [self.smokeyCancelButton setTitle:HPPPLocalizedString(@"Cancel", nil) forState:UIControlStateNormal];
    [self.smokeyCancelButton setTintColor:[self.hppp.appearance.settings objectForKey:kHPPPOverlayPrimaryFontColor]];
    self.smokeyCancelButton.titleLabel.font = [self.hppp.appearance.settings objectForKey:kHPPPOverlayPrimaryFont];
    [self.smokeyView addSubview:self.smokeyCancelButton];
    
    [self.navigationController.view addSubview:self.smokeyView];
    
    self.pageRangeView = [[HPPPPageRangeView alloc] initWithFrame:self.view.frame];
    self.pageRangeView.delegate = self.delegateManager;
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
    [self refreshData];
}

-(void) refreshData
{
    [self setPageRangeLabelText:self.delegateManager.pageRangeText];
    BOOL pageSelected = NO;
    NSArray *pageNums = [self.delegateManager.pageRange getPages];
    for( NSNumber *pageNum in pageNums ) {
        if( [pageNum integerValue] == self.multiPageView.currentPage) {
            pageSelected = YES;
            break;
        }
    }
    [self dismissEditView];

    self.numberOfCopiesLabel.text = self.delegateManager.numCopiesLabelText;
    self.pageRangeCell.detailTextLabel.text = self.delegateManager.pageRangeText;
    self.jobSummaryCell.textLabel.text = self.delegateManager.printJobSummaryText;
    
    [self changePaper];
    [self reloadPaperSelectionSection];
    [self updatePageSettingsUI];
    [self updatePrintSettingsUI];
    [self updatePrintButtonUI];
    
    if ([self.dataSource respondsToSelector:@selector(numberOfPrintingItems)]) {
        NSInteger numberOfJobs = [self.dataSource numberOfPrintingItems];
        if (numberOfJobs > 1) {
            self.numberOfCopiesCell.hidden = TRUE;
            self.filterCell.hidden = TRUE;
            self.pageRangeCell.hidden = TRUE;
            self.printLabel.text = HPPPLocalizedString(@"Print All", @"Print all pages in a document");
        }
    }

    [self.tableView reloadData];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if (self.printItem) {
        [self configurePrintButton];
        [self refreshData];
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
        [self.dataSource printingItemForPaper:self.delegateManager.printSettings.paper withCompletion:^(HPPPPrintItem *printItem) {
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
        if (self.delegateManager.printSettings.printerName == nil || self.settingsOnly){
            self.selectPrinterCell.hidden = NO;
            self.paperSizeCell.hidden = NO;
            self.printSettingsCell.hidden = YES;
            self.paperTypeCell.hidden = (self.delegateManager.printSettings.paper.paperSize == SizeLetter) ? NO : YES;
        } else {
            self.selectPrinterCell.hidden = YES;
            self.paperSizeCell.hidden = YES;
            self.paperTypeCell.hidden = YES;
            self.printSettingsCell.hidden = NO;
        }
        if (self.delegateManager.printSettings.printerIsAvailable){
            [self printerIsAvailable];
        } else {
            [self printerNotAvailable];
        }
    } else {
        self.paperTypeCell.hidden = (self.delegateManager.printSettings.paper.paperSize == SizeLetter) ? NO : YES;
    }
    [self.tableView endUpdates];
}

// Update the Paper Size, Paper Type, and Select Printer cells
- (void)updatePrintSettingsUI
{
    self.paperSizeSelectedLabel.text = self.delegateManager.printSettings.paper.sizeTitle;
    self.paperTypeSelectedLabel.text = self.delegateManager.printSettings.paper.typeTitle;
    self.selectedPrinterLabel.text = self.delegateManager.selectedPrinterText;
    
    self.printSettingsDetailLabel.text = self.delegateManager.printSettingsText;
}

- (void)updatePrintButtonUI
{
    HPPP *hppp = [HPPP sharedInstance];
    if( [self.delegateManager noPagesSelected] ) {
        self.printCell.userInteractionEnabled = NO;
        self.printLabel.textColor = [hppp.appearance.settings objectForKey:kHPPPMainActionInactiveLinkFontColor];
    } else {
        self.printCell.userInteractionEnabled = YES;
        self.printLabel.textColor = [hppp.appearance.settings objectForKey:kHPPPMainActionActiveLinkFontColor];
    }
    
    self.printLabel.text = self.delegateManager.printLabelText;
}

- (UIPrintInteractionController *)getSharedPrintInteractionController
{
    UIPrintInteractionController *controller = [UIPrintInteractionController sharedPrintController];
    
    if (nil != controller) {
        controller.delegate = self.delegateManager;
    }
    
    return controller;
}

- (void)showPrinterSelection:(UITableView *)tableView withCompletion:(void (^)(BOOL userDidSelect))completion
{
    if ([[HPPPWiFiReachability sharedInstance] isWifiConnected]) {
        UIPrinterPickerController *printerPicker = [UIPrinterPickerController printerPickerControllerWithInitiallySelectedPrinter:nil];
        printerPicker.delegate = self.delegateManager;
        
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

- (HPPPPrintItem *)printItem
{
    return self.delegateManager.printItem;
}

- (void)setPrintItem:(HPPPPrintItem *)printItem
{
    if( nil == self.delegateManager ) {
        self.delegateManager = [[HPPPPrintSettingsDelegateManager alloc] init];
    }

    self.delegateManager.printItem = printItem;
    [self configureMultiPageViewWithPrintItem:printItem];
}

- (void)configureMultiPageViewWithPrintItem:(HPPPPrintItem *)printItem
{
    if (self.delegateManager.printSettings.paper) {
        self.multiPageView.blackAndWhite = self.delegateManager.blackAndWhite;
        [self.multiPageView setInterfaceOptions:[HPPP sharedInstance].interfaceOptions];
        NSArray *images = [printItem previewImagesForPaper:self.delegateManager.printSettings.paper];
        [self.multiPageView setPages:images paper:self.delegateManager.printSettings.paper layout:printItem.layout];
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
        self.smokeyView.hidden = NO;
        self.smokeyView.alpha = [[[HPPP sharedInstance].appearance.settings objectForKey:kHPPPOverlayBackgroundOpacity] floatValue];
    } else {
        self.smokeyView.alpha = 0.0f;
    }
}

- (void)dismissEditView
{
    CGRect desiredFrame = self.pageRangeView.frame;
    desiredFrame.origin.y = self.pageRangeView.frame.origin.y + self.pageRangeView.frame.size.height;
    
    [UIView animateWithDuration:HPPP_ANIMATION_DURATION animations:^{
        [self displaySmokeyView:NO];
        self.pageRangeView.frame = desiredFrame;
        [self setNavigationBarEditing:NO];
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
    if( self.printItem.numberOfPages > 1 ) {
        BOOL includePage = self.pageSelectionMark.imageView.image == self.unselectedPageImage;
        
        [self.delegateManager includePageInPageRange:includePage pageNumber:self.multiPageView.currentPage];
        
        [self updateSelectedPageIcon:includePage];
    }
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

- (void)setPageRange:(HPPPPageRange *)pageRange
{
	self.delegateManager.pageRange = pageRange;
}

- (HPPPPageRange *)pageRange
{
    if (nil == self.delegateManager.pageRange) {
        self.delegateManager.pageRange = [[HPPPPageRange alloc] initWithString:kPageRangeAllPages allPagesIndicator:kPageRangeAllPages maxPageNum:self.printItem.numberOfPages sortAscending:YES];
        self.delegateManager.pageRange.range = kPageRangeAllPages;
    }
    
    if( 1 < self.printItem.numberOfPages ) {
        [self.delegateManager.pageRange setRange:self.pageRangeCell.detailTextLabel.text];
    }
    
    return self.delegateManager.pageRange;
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
    self.delegateManager.printSettings.printerIsAvailable = NO;
    [self.tableView endUpdates];
}

- (void)printerIsAvailable
{
    // This block of beginUpdates-endUpdates is required to refresh the tableView while it is currently being displayed on screen
    [self.tableView beginUpdates];
    [self.printSettingsCell.imageView setImage:nil];
    self.delegateManager.printSettings.printerIsAvailable = YES;
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
    
    self.printManager.currentPrintSettings = self.delegateManager.printSettings;
    [self.printManager prepareController:controller printItem:self.printItem color:!self.blackAndWhiteModeSwitch.on pageRange:self.pageRange numCopies:self.numberOfCopies];
    
    __weak __typeof(self) weakSelf = self;
    UIPrintInteractionCompletionHandler completionHandler = ^(UIPrintInteractionController *printController, BOOL completed, NSError *error) {
        
        if (!completed) {
            HPPPLogInfo(@"Print was NOT completed");
        }
        
        if (error) {
            HPPPLogWarn(@"Print error:  %@", error);
        }

        if (completed && !error) {
            [weakSelf.printManager saveLastOptionsForPrinter:printController.printInfo.printerID];
            [weakSelf.printManager processMetricsForPrintItem:weakSelf.printItem andPageRange:weakSelf.pageRange];
        }

        [weakSelf printCompleted:printController isCompleted:completed printError:error];

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

#pragma mark - Stepper actions

- (IBAction)numberOfCopiesStepperTapped:(UIStepper *)sender
{
    self.delegateManager.numCopies = sender.value;
}

#pragma mark - Switch actions

- (IBAction)blackAndWhiteSwitchToggled:(id)sender
{
    self.delegateManager.blackAndWhite = self.blackAndWhiteModeSwitch.on;
    self.multiPageView.blackAndWhite = self.delegateManager.blackAndWhite;
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
        if (self.delegateManager.printSettings.paper.paperSize == SizeLetter) {
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
        
        cell.backgroundColor = [self.hppp.appearance.settings objectForKey:kHPPPSelectionOptionsBackgroundColor];
        cell.textLabel.font = [self.hppp.appearance.settings objectForKey:kHPPPSelectionOptionsPrimaryFont];
        cell.textLabel.textColor = [self.hppp.appearance.settings objectForKey:kHPPPSelectionOptionsPrimaryFontColor];
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
        if ((!self.hppp.hidePaperTypeOption) && (self.delegateManager.printSettings.printerUrl == nil)) {
            height = SEPARATOR_SECTION_FOOTER_HEIGHT;
        }
    } else if (!IS_OS_8_OR_LATER && (section == PAPER_SELECTION_SECTION)) {
        height = SEPARATOR_SECTION_FOOTER_HEIGHT;
    } else if (IS_OS_8_OR_LATER && (section == PRINT_SETTINGS_SECTION)) {
        if (self.delegateManager.printSettings.printerUrl != nil) {
            if (self.delegateManager.printSettings.printerIsAvailable) {
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
        
        [UIView animateWithDuration:HPPP_ANIMATION_DURATION animations:^{
            [self displaySmokeyView:YES];
            [self setNavigationBarEditing:YES];
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
            if ((self.delegateManager.printSettings.printerUrl != nil) && !self.delegateManager.printSettings.printerIsAvailable) {
                footer = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, tableView.frame.size.width, PRINTER_WARNING_SECTION_FOOTER_HEIGHT)];
                
                UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(20.0f, 0.0f, tableView.frame.size.width - 20.0f, PRINTER_WARNING_SECTION_FOOTER_HEIGHT)];
                label.font = [self.hppp.appearance.settings objectForKey:kHPPPBackgroundPrimaryFont];
                label.textColor = [self.hppp.appearance.settings objectForKey:kHPPPBackgroundPrimaryFontColor];
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
            if ((!self.hppp.hidePaperTypeOption) && (self.delegateManager.printSettings.paper.paperSize == SizeLetter)) {
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
        if (self.delegateManager.printSettings.printerUrl == nil ||
            !self.delegateManager.printSettings.printerIsAvailable ) {
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
    self.itemsToPrint = [[NSMutableArray alloc] init];
    self.pageRanges = [[NSMutableArray alloc] init];
    self.blackAndWhiteSelections = [[NSMutableArray alloc] init];
    self.numCopySelections = [[NSMutableArray alloc] init];
    
    [self collectHPPPPrintLaterJobs];
    if( 0 == self.itemsToPrint.count ) {
        [self collectParallelArrayPrintJobs];
    }
    
    HPPPPrintItem *firstItem = [self.itemsToPrint firstObject];
    HPPPPageRange *pageRange = [self.pageRanges firstObject];
    NSNumber *blackAndWhite = [self.blackAndWhiteSelections firstObject];
    NSNumber *numCopies = [self.numCopySelections firstObject];
    
    if( firstItem ) {
        [self.itemsToPrint removeObjectAtIndex:0];
        [self.blackAndWhiteSelections removeObjectAtIndex:0];
        [self.pageRanges removeObjectAtIndex:0];
        [self.numCopySelections removeObjectAtIndex:0];
    }

    [self print:firstItem blackAndWhite:[blackAndWhite boolValue] pageRange:pageRange numberOfCopies:[numCopies integerValue]];
}

- (void)collectHPPPPrintLaterJobs
{
    NSMutableArray *printLaterJobs = nil;
    
    if ([self.dataSource respondsToSelector:@selector(numberOfPrintingItems)]) {
        NSInteger numberOfJobs = [self.dataSource numberOfPrintingItems];
        if (numberOfJobs > 1) {
            if ([self.dataSource respondsToSelector:@selector(printLaterJobs)]) {
                printLaterJobs = [self.dataSource printLaterJobs].mutableCopy;
            }
        }
    }
    
    for (HPPPPrintLaterJob *job in printLaterJobs) {
        [self.itemsToPrint addObject:[job printItemForPaperSize:self.delegateManager.printSettings.paper.sizeTitle]];
        [self.pageRanges addObject:job.pageRange];
        [self.blackAndWhiteSelections addObject:[NSNumber numberWithBool:job.blackAndWhite]];
        [self.numCopySelections addObject:[NSNumber numberWithInteger:job.numCopies]];
    }
}

- (void)collectParallelArrayPrintJobs
{
    [self.itemsToPrint addObjectsFromArray:[self collectPrintingItems]];
    [self.pageRanges addObjectsFromArray:[self collectPageRanges]];
    [self.blackAndWhiteSelections addObjectsFromArray:[self collectBlackAndWhiteSelections]];
    [self.numCopySelections addObjectsFromArray:[self collectNumCopiesSelections]];
    
    HPPPPrintItem *firstItem = [self.itemsToPrint firstObject];
    
    if( self.pageRanges.count != self.itemsToPrint.count ) {
        HPPPLogWarn(@"%lu HPPPPrintItems and %lu HPPPPageRanges.  Using default values for all HPPPPageRanges.", (unsigned long)self.itemsToPrint.count, (unsigned long)self.pageRanges.count);
        self.pageRanges = [[NSMutableArray alloc] initWithCapacity:self.itemsToPrint.count];
        for (int i=0; i<self.itemsToPrint.count; i++) {
            [self.pageRanges insertObject:[[HPPPPageRange alloc] initWithString:@"All" allPagesIndicator:@"All" maxPageNum:firstItem.numberOfPages sortAscending:TRUE] atIndex:i];
        }
    }
    
    if( self.blackAndWhiteSelections.count != self.itemsToPrint.count ) {
        HPPPLogWarn(@"%lu HPPPPrintItems and %lu BOOLs for black and white.  Using default values for all black and white indicators.", (unsigned long)self.itemsToPrint.count, (unsigned long)self.blackAndWhiteSelections.count);
        self.blackAndWhiteSelections = [[NSMutableArray alloc] initWithCapacity:self.itemsToPrint.count];
        for (int i=0; i<self.itemsToPrint.count; i++) {
            [self.blackAndWhiteSelections insertObject:[NSNumber numberWithBool:NO] atIndex:i];
        }
    }
    
    if( self.numCopySelections.count != self.itemsToPrint.count ) {
        HPPPLogWarn(@"%lu HPPPPrintItems and %lu NSNumbers for number of copies.  Using default values for all number of copies.", (unsigned long)self.itemsToPrint.count, (unsigned long)self.numCopySelections.count);
        self.numCopySelections = [[NSMutableArray alloc] initWithCapacity:self.itemsToPrint.count];
        for (int i=0; i<self.itemsToPrint.count; i++) {
            [self.numCopySelections insertObject:[NSNumber numberWithInteger:DEFAULT_NUMBER_OF_COPIES] atIndex:i];
        }
    }
}

- (NSMutableArray *)collectPrintingItems
{
    NSMutableArray *items = nil;
    
    if ([self.dataSource respondsToSelector:@selector(numberOfPrintingItems)]) {
        NSInteger numberOfJobs = [self.dataSource numberOfPrintingItems];
        if (numberOfJobs > 1) {
            if ([self.dataSource respondsToSelector:@selector(printingItemsForPaper:)]) {
                items = [self.dataSource printingItemsForPaper:self.delegateManager.printSettings.paper].mutableCopy;
            }
        }
    }
    
    if (nil == items) {
        items = [NSMutableArray arrayWithObjects:self.printItem, nil];
    }
    
    return items;
}

- (NSMutableArray *)collectPageRanges
{
    NSMutableArray *pageRanges = nil;
    
    if ([self.dataSource respondsToSelector:@selector(numberOfPrintingItems)]) {
        NSInteger numberOfJobs = [self.dataSource numberOfPrintingItems];
        if (numberOfJobs > 1) {
            if ([self.dataSource respondsToSelector:@selector(pageRangeSelections)]) {
                pageRanges = [self.dataSource pageRangeSelections].mutableCopy;
            }
        }
    }
    
    if (nil == pageRanges) {
        pageRanges = [NSMutableArray arrayWithObjects:self.pageRange, nil];
    }
    
    return pageRanges;
}

- (NSMutableArray *)collectBlackAndWhiteSelections
{
    NSMutableArray *bws = nil;
    
    if ([self.dataSource respondsToSelector:@selector(numberOfPrintingItems)]) {
        NSInteger numberOfJobs = [self.dataSource numberOfPrintingItems];
        if (numberOfJobs > 1) {
            if ([self.dataSource respondsToSelector:@selector(blackAndWhiteSelections)]) {
                bws = [self.dataSource blackAndWhiteSelections].mutableCopy;
            }
        }
    }
    
    if (nil == bws) {
        bws = [NSMutableArray arrayWithObjects:[NSNumber numberWithBool:self.blackAndWhiteModeSwitch.on], nil];
    }
    
    return bws;
}

- (NSMutableArray *)collectNumCopiesSelections
{
    NSMutableArray *numCopies = nil;
    
    if ([self.dataSource respondsToSelector:@selector(numberOfPrintingItems)]) {
        NSInteger numberOfJobs = [self.dataSource numberOfPrintingItems];
        if (numberOfJobs > 1) {
            if ([self.dataSource respondsToSelector:@selector(numberOfCopiesSelections)]) {
                numCopies = [self.dataSource numberOfCopiesSelections].mutableCopy;
            }
        }
    }
    
    if (nil == numCopies) {
        numCopies = [NSMutableArray arrayWithObjects:[NSNumber numberWithInteger:self.numberOfCopiesStepper.value], nil];
    }
    
    return numCopies;
}


- (void)print:(HPPPPrintItem *)printItem blackAndWhite:(BOOL)blackAndWhite pageRange:(HPPPPageRange *)pageRange numberOfCopies:(NSInteger)numCopies
{
    self.delegateManager.blackAndWhite = blackAndWhite;
    self.printManager.currentPrintSettings = self.delegateManager.printSettings;
    self.printManager.currentPrintSettings.color = !blackAndWhite;
    
    NSError *error;
    [self.printManager print:printItem
                   pageRange:pageRange
                   numCopies:numCopies
                       error:&error];
    
    if( HPPPPrintManagerErrorNone != error.code ) {
        HPPPLogError(@"Failed to print with error %@", error);
    }
}

- (void)print:(HPPPPrintItem *)printItem
{
    self.delegateManager.blackAndWhite = self.blackAndWhiteModeSwitch.on;
    self.printManager.currentPrintSettings = self.delegateManager.printSettings;

    [self print:printItem blackAndWhite:self.blackAndWhiteModeSwitch.on pageRange:self.pageRange numberOfCopies:self.numberOfCopiesStepper.value];
}

- (void)printCompleted:(UIPrintInteractionController *)printController isCompleted:(BOOL)completed printError:(NSError *)error
{
    [self.delegateManager savePrinterId:printController.printInfo.printerID];
    
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

- (void)setDefaultPrinter
{
    [HPPPDefaultSettingsManager sharedInstance].defaultPrinterName = self.delegateManager.printSettings.printerName;
    [HPPPDefaultSettingsManager sharedInstance].defaultPrinterUrl = self.delegateManager.printSettings.printerUrl.absoluteString;
    [HPPPDefaultSettingsManager sharedInstance].defaultPrinterNetwork = [HPPPAnalyticsManager wifiName];
    [HPPPDefaultSettingsManager sharedInstance].defaultPrinterCoordinate = [[HPPPPrintLaterManager sharedInstance] retrieveCurrentLocation];
    [HPPPDefaultSettingsManager sharedInstance].defaultPrinterModel = self.delegateManager.printSettings.printerModel;
    [HPPPDefaultSettingsManager sharedInstance].defaultPrinterLocation = self.delegateManager.printSettings.printerLocation;
    [[NSNotificationCenter defaultCenter] postNotificationName:kHPPPDefaultPrinterAddedNotification object:self userInfo:nil];
}

- (void)saveSettings
{
    [self setDefaultPrinter];
    
    NSString *printerID = [HPPPDefaultSettingsManager sharedInstance].defaultPrinterUrl;
    [self.delegateManager savePrinterId:printerID];
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
        BOOL pageSelected = NO;
        
        NSArray *pageNums = [self.pageRange getPages];
        
        for( NSNumber *pageNum in pageNums ) {
            if( [pageNum integerValue] == newPageNumber ) {
                pageSelected = YES;
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

#pragma mark - UIGestureRecognizerDelegate

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer
{
    return NO;
}

#pragma mark - HPPPPrintManagerDelegate

- (void)didFinishPrintJob:(UIPrintInteractionController *)printController completed:(BOOL)completed error:(NSError *)error
{
    if (error) {
        HPPPLogError(@"Print error: %@", error);
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        HPPPPrintItem *nextItem = [self.itemsToPrint firstObject];
        NSNumber *blackAndWhite = [self.blackAndWhiteSelections firstObject];
        HPPPPageRange *pageRange = [self.pageRanges firstObject];
        NSNumber *numCopies = [self.numCopySelections firstObject];
        
        if (nextItem) {
            [self.itemsToPrint removeObjectAtIndex:0];
            [self.blackAndWhiteSelections removeObjectAtIndex:0];
            [self.pageRanges removeObjectAtIndex:0];
            [self.numCopySelections removeObjectAtIndex:0];
            
            [self print:nextItem blackAndWhite:[blackAndWhite boolValue] pageRange:pageRange numberOfCopies:[numCopies integerValue]];
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
        vc.printSettings = self.delegateManager.printSettings;
        vc.useDefaultPrinter = self.printFromQueue;
        vc.delegate = self.delegateManager;
    } else if ([segue.identifier isEqualToString:@"PaperSizeSegue"]) {
        
        HPPPPaperSizeTableViewController *vc = (HPPPPaperSizeTableViewController *)segue.destinationViewController;
        vc.currentPaper = self.delegateManager.printSettings.paper;
        vc.delegate = self.delegateManager;
    } else if ([segue.identifier isEqualToString:@"PaperTypeSegue"]) {
        
        HPPPPaperTypeTableViewController *vc = (HPPPPaperTypeTableViewController *)segue.destinationViewController;
        vc.currentPaper = self.delegateManager.printSettings.paper;
        vc.delegate = self.delegateManager;
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
        self.printLabel.textColor = [self.hppp.appearance.settings objectForKey:kHPPPMainActionActiveLinkFontColor];
    } else {
        self.printCell.userInteractionEnabled = NO;
        self.printLabel.textColor = [self.hppp.appearance.settings objectForKey:kHPPPMainActionInactiveLinkFontColor];
    }
}

@end
