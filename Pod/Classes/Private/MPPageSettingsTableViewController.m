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
#import "MPAnalyticsManager.h"
#import "MPPageSettingsTableViewController.h"
#import "MPPaper.h"
#import "MPPrintPageRenderer.h"
#import "MPPrintSettings.h"
#import "MPPrintItem.h"
#import "MPPaperSizeTableViewController.h"
#import "MPPaperTypeTableViewController.h"
#import "MPPrintSettingsTableViewController.h"
#import "MPWiFiReachability.h"
#import "MPPrinter.h"
#import "MPPrintLaterManager.h"
#import "MPDefaultSettingsManager.h"
#import "MPPrintSettingsDelegateManager.h"
#import "UITableView+MPHeader.h"
#import "UIColor+MPHexString.h"
#import "UIView+MPAnimation.h"
#import "UIImage+MPResize.h"
#import "UIColor+MPStyle.h"
#import "NSBundle+MPLocalizable.h"
#import "MPSupportAction.h"
#import "MPLayoutFactory.h"
#import "MPMultiPageView.h"
#import "MPPageRangeKeyboardView.h"
#import "MPPageRange.h"
#import "MPPrintManager.h"
#import "MPPrintManager+Options.h"
#import "MPPrintJobsViewController.h"
#import "MPPrintLaterQueue.h"
#import "UIImage+MPBundle.h"

#define REFRESH_PRINTER_STATUS_INTERVAL_IN_SECONDS 60

#define DEFAULT_ROW_HEIGHT 44.0f
#define DEFAULT_NUMBER_OF_COPIES 1

#define BASIC_PRINT_SUMMARY_SECTION 0
#define PREVIEW_PRINT_SUMMARY_SECTION 1
#define PRINT_FUNCTION_SECTION 2
#define PRINTER_SELECTION_SECTION 3
#define PAPER_SELECTION_SECTION 4
#define PRINT_SETTINGS_SECTION 5
#define PRINT_JOB_NAME_SECTION 6
#define PAGE_RANGE_SECTION 7
#define NUMBER_OF_COPIES_SECTION 8
#define BLACK_AND_WHITE_FILTER_SECTION 9
#define SUPPORT_SECTION 10

#define PRINTER_SELECTION_INDEX 0
#define PAPER_SIZE_ROW_INDEX 0
#define PAPER_TYPE_ROW_INDEX 1
#define PRINT_SETTINGS_ROW_INDEX 0
#define FILTER_ROW_INDEX 0
#define PAGE_RANGE_ROW_INDEX 1

#define kMPSelectPrinterPrompt MPLocalizedString(@"Select Printer", nil)
#define kPrinterDetailsNotAvailable MPLocalizedString(@"Not Available", @"Printer details not available")

@interface MPPageSettingsTableViewController ()
   <UIGestureRecognizerDelegate,
    MPMultiPageViewDelegate,
    UIAlertViewDelegate,
    MPPrintManagerDelegate,
    UITextFieldDelegate>

@property (strong, nonatomic) MPPrintManager *printManager;
@property (strong, nonatomic) MPWiFiReachability *wifiReachability;

@property (weak, nonatomic) IBOutlet UIStepper *numberOfCopiesStepper;
@property (weak, nonatomic) IBOutlet UISwitch *blackAndWhiteModeSwitch;
@property (weak, nonatomic) IBOutlet UILabel *paperSizeSelectedLabel;
@property (weak, nonatomic) IBOutlet UILabel *paperTypeSelectedLabel;
@property (weak, nonatomic) IBOutlet UILabel *paperSizeLabel;
@property (weak, nonatomic) IBOutlet UILabel *paperTypeLabel;
@property (weak, nonatomic) IBOutlet UILabel *filterLabel;
@property (weak, nonatomic) IBOutlet UILabel *pageRangeLabel;
@property (weak, nonatomic) IBOutlet UITextField *pageRangeDetailTextField;
@property (weak, nonatomic) IBOutlet UILabel *printLabel;
@property (weak, nonatomic) IBOutlet UILabel *selectPrinterLabel;
@property (weak, nonatomic) IBOutlet UILabel *selectedPrinterLabel;
@property (weak, nonatomic) IBOutlet UILabel *printSettingsLabel;
@property (weak, nonatomic) IBOutlet UILabel *printSettingsDetailLabel;
@property (weak, nonatomic) IBOutlet UILabel *jobNameLabel;
@property (weak, nonatomic) IBOutlet UITextField *jobNameTextField;
@property (weak, nonatomic) IBOutlet UILabel *numberOfCopiesLabel;
@property (weak, nonatomic) IBOutlet MPMultiPageView *multiPageView;
@property (weak, nonatomic) IBOutlet UILabel *footerHeadingLabel;
@property (weak, nonatomic) IBOutlet UILabel *footerTextLabel;

@property (weak, nonatomic) UITableViewCell *jobSummaryCell;
@property (weak, nonatomic) IBOutlet UITableViewCell *basicJobSummaryCell;
@property (weak, nonatomic) IBOutlet UITableViewCell *previewJobSummaryCell;
@property (weak, nonatomic) IBOutlet UITableViewCell *printCell;
@property (weak, nonatomic) IBOutlet UITableViewCell *selectPrinterCell;
@property (weak, nonatomic) IBOutlet UITableViewCell *paperSizeCell;
@property (weak, nonatomic) IBOutlet UITableViewCell *paperTypeCell;
@property (weak, nonatomic) IBOutlet UITableViewCell *pageRangeCell;
@property (weak, nonatomic) IBOutlet UITableViewCell *filterCell;
@property (weak, nonatomic) IBOutlet UITableViewCell *printSettingsCell;
@property (weak, nonatomic) IBOutlet UITableViewCell *jobNameCell;
@property (weak, nonatomic) IBOutlet UITableViewCell *numberOfCopiesCell;
@property (weak, nonatomic) IBOutlet UIView *footerView;

@property (strong, nonatomic) UIButton *pageSelectionMark;
@property (strong, nonatomic) UIButton *pageSelectionExtendedArea;
@property (strong, nonatomic) UIImage *selectedPageImage;
@property (strong, nonatomic) UIImage *unselectedPageImage;

@property (strong, nonatomic) MPPrintSettingsDelegateManager *delegateManager;

@property (strong, nonatomic) UIBarButtonItem *cancelBarButtonItem;

@property (strong, nonatomic) NSTimer *refreshPrinterStatusTimer;

@property (nonatomic, strong) UIActivityIndicatorView *spinner;
@property (nonatomic, strong) MP *mp;
@property (nonatomic, assign) NSInteger numberOfCopies;

@property (strong, nonatomic) NSMutableArray *itemsToPrint;
@property (strong, nonatomic) NSMutableArray *pageRanges;
@property (strong, nonatomic) NSMutableArray *blackAndWhiteSelections;
@property (strong, nonatomic) NSMutableArray *numCopySelections;

@property (assign, nonatomic) BOOL editing;
@property (weak, nonatomic) IBOutlet UIView *headerInactivityView;

@property (assign, nonatomic) NSInteger currentPrintJob;

@property (assign, nonatomic) BOOL actionInProgress;

@end

@implementation MPPageSettingsTableViewController

int const kSaveDefaultPrinterIndex = 1;

NSString * const kMPDefaultPrinterAddedNotification = @"kMPDefaultPrinterAddedNotification";
NSString * const kMPDefaultPrinterRemovedNotification = @"kMPDefaultPrinterRemovedNotification";
NSString * const kPageSettingsScreenName = @"Print Preview Screen";
NSString * const kPrintFromQueueScreenName = @"Add Job Screen";
NSString * const kSettingsOnlyScreenName = @"Print Settings Screen";

CGFloat const kMPPreviewHeightRatio = 0.61803399; // golden ratio
CGFloat const kMPDisabledAlpha = 0.5;

#pragma mark - UIView

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.currentPrintJob = 0;
    
    if( nil == self.delegateManager ) {
        self.delegateManager = [[MPPrintSettingsDelegateManager alloc] init];
    }
    
    self.mp = [MP sharedInstance];
    
    self.cancelBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:MPLocalizedString(@"Cancel", @"button bar cancel button") style:UIBarButtonItemStylePlain target:self action:@selector(cancelButtonTapped:)];

    if( self.mp.pageSettingsCancelButtonLeft ) {
        self.navigationItem.leftBarButtonItem = self.cancelBarButtonItem;
    } else {
        self.navigationItem.rightBarButtonItem = self.cancelBarButtonItem;
    }    
    
    if( MPPageSettingsDisplayTypePreviewPane == self.displayType ) {
        self.navigationItem.rightBarButtonItem = nil;
        self.navigationItem.leftBarButtonItem = nil;
    }
    
    [self configureJobSummaryCell];
    
    if( nil != self.printItem ) {
        self.delegateManager.pageRange = [[MPPageRange alloc] initWithString:kPageRangeAllPages allPagesIndicator:kPageRangeAllPages maxPageNum:self.printItem.numberOfPages sortAscending:YES];
    } else {
        self.delegateManager.pageRange = nil;
    }
    self.delegateManager.pageRange.range = kPageRangeAllPages;
    self.delegateManager.numCopies = DEFAULT_NUMBER_OF_COPIES;

    if (self.navigationController) {
        self.navigationController.interactivePopGestureRecognizer.delegate = self;
    } else {
        [[MPLogger sharedInstance] logWarn:@"MPPageSettingsTableViewController is intended to be embedded in navigation controller. Navigation problems and othe unexpected behavior may occur if used without a navigation controller."];
    }
    
    self.tableView.backgroundColor = [self.mp.appearance.settings objectForKey:kMPGeneralBackgroundColor];
    self.tableView.separatorColor = [self.mp.appearance.settings objectForKey:kMPGeneralTableSeparatorColor];
    self.tableView.rowHeight = DEFAULT_ROW_HEIGHT;
    
    if (MPPageSettingsDisplayTypePageSettingsPane == self.displayType  ||  (MPPageSettingsModeSettingsOnly == self.mode && nil == self.printItem)) {
        self.tableView.tableHeaderView = [[UIView alloc] initWithFrame:CGRectZero];
    }
    
    self.multiPageView.delegate = self;
    
    self.tableView.tableFooterView.backgroundColor = [self.mp.appearance.settings objectForKey:kMPGeneralBackgroundColor];
    self.tableView.tableHeaderView.backgroundColor = [self.mp.appearance.settings objectForKey:kMPGeneralBackgroundColor];

    self.basicJobSummaryCell.backgroundColor = [self.mp.appearance.settings objectForKey:kMPJobSettingsBackgroundColor];
    self.basicJobSummaryCell.textLabel.font = [self.mp.appearance.settings objectForKey:kMPJobSettingsSecondaryFont];
    self.basicJobSummaryCell.textLabel.textColor = [self.mp.appearance.settings objectForKey:kMPJobSettingsSecondaryFontColor];

    self.previewJobSummaryCell.backgroundColor = [self.mp.appearance.settings objectForKey:kMPJobSettingsBackgroundColor];
    self.previewJobSummaryCell.textLabel.font = [self.mp.appearance.settings objectForKey:kMPJobSettingsPrimaryFont];
    self.previewJobSummaryCell.textLabel.textColor = [self.mp.appearance.settings objectForKey:kMPJobSettingsPrimaryFontColor];
    self.previewJobSummaryCell.detailTextLabel.font = [self.mp.appearance.settings objectForKey:kMPJobSettingsSecondaryFont];
    self.previewJobSummaryCell.detailTextLabel.textColor = [self.mp.appearance.settings objectForKey:kMPJobSettingsSecondaryFontColor];

    self.printCell.backgroundColor = [self.mp.appearance.settings objectForKey:kMPMainActionBackgroundColor];
    self.printLabel.font = [self.mp.appearance.settings objectForKey:kMPMainActionLinkFont];
    self.printLabel.textColor = [self.mp.appearance.settings objectForKey:kMPMainActionActiveLinkFontColor];
    self.printLabel.text = MPLocalizedString(@"Print", @"Caption of the button for printing");
    
    self.printSettingsCell.backgroundColor = [self.mp.appearance.settings objectForKey:kMPSelectionOptionsBackgroundColor];
    self.printSettingsCell.accessoryView = [[UIImageView alloc] initWithImage:[self.mp.appearance.settings objectForKey:kMPSelectionOptionsDisclosureIndicatorImage]];
    self.printSettingsLabel.font = [self.mp.appearance.settings objectForKey:kMPSelectionOptionsPrimaryFont];
    self.printSettingsLabel.textColor = [self.mp.appearance.settings objectForKey:kMPSelectionOptionsPrimaryFontColor];
    self.printSettingsLabel.text = MPLocalizedString(@"Settings", nil);
    
    self.printSettingsDetailLabel.font = [self.mp.appearance.settings objectForKey:kMPSelectionOptionsSecondaryFont];
    self.printSettingsDetailLabel.textColor = [self.mp.appearance.settings objectForKey:kMPSelectionOptionsSecondaryFontColor];
    
    self.selectPrinterCell.backgroundColor = [self.mp.appearance.settings objectForKey:kMPSelectionOptionsBackgroundColor];
    self.selectPrinterLabel.font = [self.mp.appearance.settings objectForKey:kMPSelectionOptionsPrimaryFont];
    self.selectPrinterLabel.textColor = [self.mp.appearance.settings objectForKey:kMPSelectionOptionsPrimaryFontColor];
    self.selectPrinterLabel.text = MPLocalizedString(@"Printer", nil);
    
    self.selectedPrinterLabel.font = [self.mp.appearance.settings objectForKey:kMPSelectionOptionsSecondaryFont];
    self.selectedPrinterLabel.textColor = [self.mp.appearance.settings objectForKey:kMPSelectionOptionsSecondaryFontColor];
    self.selectedPrinterLabel.text = MPLocalizedString(@"Select Printer", nil);
    
    self.paperSizeCell.backgroundColor = [self.mp.appearance.settings objectForKey:kMPSelectionOptionsBackgroundColor];
    self.paperSizeCell.accessoryView = [[UIImageView alloc] initWithImage:[self.mp.appearance.settings objectForKey:kMPSelectionOptionsDisclosureIndicatorImage]];
    self.paperSizeLabel.font = [self.mp.appearance.settings objectForKey:kMPSelectionOptionsPrimaryFont];
    self.paperSizeLabel.textColor = [self.mp.appearance.settings objectForKey:kMPSelectionOptionsPrimaryFontColor];
    self.paperSizeLabel.text = MPLocalizedString(@"Paper Size", nil);
    
    self.paperSizeSelectedLabel.font = [self.mp.appearance.settings objectForKey:kMPSelectionOptionsSecondaryFont];
    self.paperSizeSelectedLabel.textColor = [self.mp.appearance.settings objectForKey:kMPSelectionOptionsSecondaryFontColor];
    
    self.paperTypeCell.backgroundColor = [self.mp.appearance.settings objectForKey:kMPSelectionOptionsBackgroundColor];
    self.paperTypeCell.accessoryView = [[UIImageView alloc] initWithImage:[self.mp.appearance.settings objectForKey:kMPSelectionOptionsDisclosureIndicatorImage]];
    self.paperTypeLabel.font = [self.mp.appearance.settings objectForKey:kMPSelectionOptionsPrimaryFont];
    self.paperTypeLabel.textColor = [self.mp.appearance.settings objectForKey:kMPSelectionOptionsPrimaryFontColor];
    self.paperTypeLabel.text = MPLocalizedString(@"Paper Type", nil);
    
    self.paperTypeSelectedLabel.font = [self.mp.appearance.settings objectForKey:kMPSelectionOptionsSecondaryFont];
    self.paperTypeSelectedLabel.textColor = [self.mp.appearance.settings objectForKey:kMPSelectionOptionsSecondaryFontColor];
    self.paperTypeSelectedLabel.text = [MPPaper titleFromType:MPPaperTypePlain];
    
    self.jobNameCell.backgroundColor = [self.mp.appearance.settings objectForKey:kMPSelectionOptionsBackgroundColor];
    self.jobNameLabel.font = [self.mp.appearance.settings objectForKey:kMPSelectionOptionsSecondaryFont];
    self.jobNameLabel.textColor = [self.mp.appearance.settings objectForKey:kMPSelectionOptionsPrimaryFontColor];
    self.jobNameLabel.text = MPLocalizedString(@"Name", @"job name label");
    self.jobNameTextField.font = [self.mp.appearance.settings objectForKey:kMPSelectionOptionsSecondaryFont];
    self.jobNameTextField.textColor = [self.mp.appearance.settings objectForKey:kMPSelectionOptionsSecondaryFontColor];
    self.jobNameTextField.returnKeyType = UIReturnKeyDone;
    self.jobNameTextField.delegate = self;
    
    self.numberOfCopiesCell.backgroundColor = [self.mp.appearance.settings objectForKey:kMPSelectionOptionsBackgroundColor];
    self.numberOfCopiesLabel.font = [self.mp.appearance.settings objectForKey:kMPSelectionOptionsPrimaryFont];
    self.numberOfCopiesLabel.textColor = [self.mp.appearance.settings objectForKey:kMPSelectionOptionsPrimaryFontColor];
    self.numberOfCopiesLabel.text = MPLocalizedString(@"1 Copy", nil);
    
    self.pageRangeCell.backgroundColor = [self.mp.appearance.settings objectForKey:kMPSelectionOptionsBackgroundColor];
    [self setPageRangeLabelText:kPageRangeAllPages];

    self.pageRangeLabel.font = [self.mp.appearance.settings objectForKey:kMPSelectionOptionsPrimaryFont];
    self.pageRangeLabel.textColor = [self.mp.appearance.settings objectForKey:kMPSelectionOptionsPrimaryFontColor];
    self.pageRangeLabel.text = MPLocalizedString(@"Page Range", @"Used to specify that a range of pages can be displayed");
    self.pageRangeDetailTextField.font = [self.mp.appearance.settings objectForKey:kMPSelectionOptionsSecondaryFont];
    self.pageRangeDetailTextField.textColor = [self.mp.appearance.settings objectForKey:kMPSelectionOptionsSecondaryFontColor];
    self.pageRangeDetailTextField.delegate = self;
    
    self.pageSelectionExtendedArea = [UIButton buttonWithType:UIButtonTypeCustom];
    self.pageSelectionExtendedArea.backgroundColor = [UIColor clearColor];
    self.pageSelectionExtendedArea.adjustsImageWhenHighlighted = NO;
    [self.pageSelectionExtendedArea addTarget:self action:@selector(pageSelectionMarkClicked) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.pageSelectionExtendedArea];

    self.selectedPageImage = [self.mp.appearance.settings objectForKey:kMPJobSettingsSelectedPageIcon];
    self.unselectedPageImage = [self.mp.appearance.settings objectForKey:kMPJobSettingsUnselectedPageIcon];
    self.pageSelectionMark = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.pageSelectionMark setImage:self.selectedPageImage forState:UIControlStateNormal];
    self.pageSelectionMark.backgroundColor = [UIColor clearColor];
    self.pageSelectionMark.adjustsImageWhenHighlighted = NO;
    [self.pageSelectionMark addTarget:self action:@selector(pageSelectionMarkClicked) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.pageSelectionMark];
    
    self.filterCell.backgroundColor = [self.mp.appearance.settings objectForKey:kMPSelectionOptionsBackgroundColor];
    self.filterLabel.font = [self.mp.appearance.settings objectForKey:kMPSelectionOptionsPrimaryFont];
    self.filterLabel.textColor = [self.mp.appearance.settings objectForKey:kMPSelectionOptionsPrimaryFontColor];
    self.filterLabel.text = MPLocalizedString(@"Black & White mode", nil);
    self.blackAndWhiteModeSwitch.onTintColor = [self.mp.appearance.settings objectForKey:kMPMainActionActiveLinkFontColor];
    
    self.delegateManager.printSettings = [[MPPrintSettings alloc] init];
    [self.delegateManager loadLastUsed];
    self.delegateManager.printSettings.printerIsAvailable = YES;
    self.blackAndWhiteModeSwitch.on = self.delegateManager.blackAndWhite;
     
    if (self.mp.hideBlackAndWhiteOption) {
        self.filterCell.hidden = YES;
    }
    
    self.numberOfCopies = self.delegateManager.numCopies;
    self.numberOfCopiesStepper.value = self.delegateManager.numCopies;
    self.numberOfCopiesStepper.tintColor = [self.mp.appearance.settings objectForKey:kMPMainActionActiveLinkFontColor];
    
    [self reloadPaperSelectionSection];
    
    self.footerHeadingLabel.font = [self.mp.appearance.settings objectForKey:kMPGeneralBackgroundPrimaryFont];
    self.footerHeadingLabel.textColor = [self.mp.appearance.settings objectForKey:kMPGeneralBackgroundPrimaryFontColor];
    self.footerHeadingLabel.text = MPLocalizedString(@"What is Print Queue?", @"footer heading describing print queue");
    self.footerTextLabel.font = [self.mp.appearance.settings objectForKey:kMPGeneralBackgroundSecondaryFont];
    self.footerTextLabel.textColor = [self.mp.appearance.settings objectForKey:kMPGeneralBackgroundSecondaryFontColor];
    self.footerTextLabel.text = MPLocalizedString(@"Add a print to the Print Queue and receive a notification when you are near your printer.  Tap your notification or simply come back to this app to print your projects.", @"fotter text describing print queue");
    
    [self updatePrintSettingsUI];
    [[MPPrinter sharedInstance] checkLastPrinterUsedAvailability];
    [self updatePageSettingsUI];
    
    if ([self.dataSource respondsToSelector:@selector(numberOfPrintingItems)]) {
        NSInteger numberOfJobs = [self.dataSource numberOfPrintingItems];
        
        self.printLabel.text = [self stringFromNumberOfPrintingItems:numberOfJobs copies:1];
    }
    
    if (IS_OS_8_OR_LATER && MPPageSettingsDisplayTypePreviewPane != self.displayType) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleDidCheckPrinterAvailability:) name:kMPPrinterAvailabilityNotification object:nil];
        self.refreshPrinterStatusTimer = [NSTimer scheduledTimerWithTimeInterval:REFRESH_PRINTER_STATUS_INTERVAL_IN_SECONDS
                                                                          target:self
                                                                        selector:@selector(refreshPrinterStatus:)
                                                                        userInfo:nil
                                                                         repeats:YES];
    }

    if (MPPageSettingsModePrint == self.mode || MPPageSettingsModePrintFromQueue == self.mode) {
        [[MPAnalyticsManager sharedManager] trackUserFlowEventWithId:kMPMetricsEventTypePrintInitiated];
    }
    
    [self preparePrintManager];
    [self refreshData];
}

- (void)configureSettingsForPrintLaterJob:(MPPrintLaterJob *)printLaterJob
{
    self.delegateManager.jobName = printLaterJob.name;

    if( MPPageSettingsModeAddToQueue != self.mode ) {
        self.delegateManager.pageRange = printLaterJob.pageRange;
        self.delegateManager.blackAndWhite = printLaterJob.blackAndWhite;
        self.delegateManager.numCopies = printLaterJob.numCopies;
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if (MPPageSettingsModePrintFromQueue != self.mode) {
        [self.multiPageView setBlackAndWhite:self.delegateManager.blackAndWhite];
    }
    
    [self preparePrintManager];

    if (self.printItem) {
        [self configurePrintButton];
        [self refreshData];
        if( MPPageSettingsModeAddToQueue != self.mode && MPPageSettingsModeSettingsOnly != self.mode ) {
            if (![[MPWiFiReachability sharedInstance] isWifiConnected]) {
                [[MPWiFiReachability sharedInstance] noPrintingAlert];
            }
        }
        
        if ((MPPageSettingsModePrintFromQueue == self.mode && 1 == self.printLaterJobs.count) ||
            (MPPageSettingsModePrintFromQueue != self.mode && 1 == self.printItem.numberOfPages)) {
            [self.multiPageView showPageNumberLabel:NO];
        }
    }
    
    MPPrintLaterJob *printLaterJob = self.printLaterJobs[self.currentPrintJob];
    if( printLaterJob ) {
        [self configureSettingsForPrintLaterJob:printLaterJob];
    }
    
    if( MPPageSettingsDisplayTypePreviewPane == self.displayType ) {
        self.title = MPLocalizedString(@"Preview", @"Title of the Preview pane in any print or add-to-queue screen");
    } else {
        if( MPPageSettingsModeAddToQueue == self.mode ) {
            self.title = MPLocalizedString(@"Add Print", @"Title of the Add Print to the Print Later Queue Screen");
            self.delegateManager.pageSettingsViewController = self;
        } else if( MPPageSettingsModeSettingsOnly == self.mode ) {
            self.title = MPLocalizedString(@"Print Settings", @"Title of the screen for setting default print settings");
            self.delegateManager.pageSettingsViewController = self;
        } else {
            self.title = MPLocalizedString(@"Page Settings", @"Title of the Page Settings Screen");
            self.delegateManager.pageSettingsViewController = self;
        }
    }
    
    if( MPPageSettingsModeAddToQueue == self.mode  &&  MPPageSettingsDisplayTypePreviewPane != self.displayType ) {
        self.tableView.tableFooterView = self.footerView;
    } else {
        self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    }
    
    [self setPageRangeKeyboardView];
    
    [self configureJobSummaryCell];

    [self refreshData];
    
    NSString *screenName = kPageSettingsScreenName;
    if (MPPageSettingsModeSettingsOnly == self.mode) {
        screenName = kSettingsOnlyScreenName;
    } else if (MPPageSettingsModePrintFromQueue == self.mode) {
        screenName = kPrintFromQueueScreenName;
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(connectionEstablished:)
                                                 name:kMPWiFiConnectionEstablished
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(connectionLost:)
                                                 name:kMPWiFiConnectionLost
                                               object:nil];

    [[NSNotificationCenter defaultCenter] postNotificationName:kMPTrackableScreenNotification object:nil userInfo:[NSDictionary dictionaryWithObject:screenName forKey:kMPTrackableScreenNameKey]];

    [[NSNotificationCenter defaultCenter] addObserver:self  selector:@selector(orientationChanged:)  name:UIDeviceOrientationDidChangeNotification  object:nil];

    [self setPreviewPaneFrame];

    [self.multiPageView refreshLayout];
}

-  (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kMPWiFiConnectionEstablished object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kMPWiFiConnectionLost object:nil];

    [self.refreshPrinterStatusTimer invalidate];
    self.refreshPrinterStatusTimer = nil;
    
    self.printManager.delegate = nil;
}

- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator
{
    [super viewWillTransitionToSize:size withTransitionCoordinator:coordinator];

    [self.multiPageView cancelZoom];

    self.multiPageView.rotationInProgress = YES;
    [coordinator animateAlongsideTransition:^(id<UIViewControllerTransitionCoordinatorContext> context) {
        [self refreshPreviewLayout];
    } completion:^(id<UIViewControllerTransitionCoordinatorContext> context) {
        self.multiPageView.rotationInProgress = NO;
    }];
}

- (void)orientationChanged:(NSNotification *)notification{
    if( IS_OS_8_OR_LATER ) {
        // do nothing-- we rely on the call to viewWillTransitionToSize
    } else {
        // iOS 7 never calls viewWillTransitionToSize... must handle rotations here
        [self.multiPageView cancelZoom];
        self.multiPageView.rotationInProgress = YES;
        [self refreshPreviewLayout];
        self.multiPageView.rotationInProgress = NO;
    }
}

- (void)refreshPreviewLayout
{
    [self setPreviewPaneFrame];
    [self setPageRangeKeyboardView];
    [self.multiPageView refreshLayout];
    [self.tableView reloadData];
}

- (void)setPreviewPaneFrame
{
    CGSize size = self.tableView.bounds.size;
    CGRect frame = self.tableView.tableHeaderView.frame;
    
    CGFloat height = 0.0;
    if (MPPageSettingsDisplayTypePreviewPane == self.displayType) {
        height = size.height - self.jobSummaryCell.frame.size.height - 1;
    } else if (MPPageSettingsDisplayTypeSingleView == self.displayType) {
        CGFloat printHeight = 2 * (self.tableView.rowHeight + SEPARATOR_SECTION_FOOTER_HEIGHT);
        height = fminf(size.height - printHeight, size.height * kMPPreviewHeightRatio);
    }
    
    frame.size.height = height;
    self.tableView.tableHeaderView.frame = frame;
    
    // without this seemingly useless line, the header view is not displayed in the appropriate frame
    self.tableView.tableHeaderView = self.tableView.tableHeaderView;
}

- (void)viewDidLayoutSubviews
{
    [self.view layoutIfNeeded];
    [self.tableView bringSubviewToFront:self.pageSelectionExtendedArea];
    [self.tableView bringSubviewToFront:self.pageSelectionMark];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - Configure UI

- (void)changePaper
{
    static MPPaper *currentPaper = nil;
    if( currentPaper != self.delegateManager.printSettings.paper ) {
        currentPaper = self.delegateManager.printSettings.paper;
        
        if ([self.dataSource respondsToSelector:@selector(printingItemForPaper:withCompletion:)] && [self.dataSource respondsToSelector:@selector(previewImageForPaper:withCompletion:)]) {
            [self.dataSource printingItemForPaper:self.delegateManager.printSettings.paper withCompletion:^(MPPrintItem *printItem) {
                if (printItem) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        self.printItem = printItem;
                        [self refreshData];
                    });
                } else {
                    MPLogError(@"Missing printing item or preview image");
                }
            }];
        } else {
            MPPrintLaterJob *printLaterJob = self.printLaterJobs[self.currentPrintJob];
            if( nil != printLaterJob ) {
                self.printItem = [printLaterJob printItemForPaperSize:self.delegateManager.paper.sizeTitle];
            }

            [self configureMultiPageViewWithPrintItem:self.printItem];
        }
    }
}

- (BOOL)showPageRange
{
    BOOL showPageRange = NO;
    
    if (MPPageSettingsModePrintFromQueue == self.mode && self.multiPageView) {
        MPPrintLaterJob *job = self.printLaterJobs[self.multiPageView.currentPage-1];
        MPPrintItem *item = [job.printItems objectForKey:self.delegateManager.printSettings.paper.sizeTitle];
        if (item.numberOfPages > 1) {
            showPageRange = YES;
        }
    } else {
        showPageRange = self.printItem.numberOfPages > 1;
    }
    
    return showPageRange;
}

// Hide or show UI that will always be hidden or shown based on the iOS version
- (void) prepareUiForIosVersion
{
    if (!IS_OS_8_OR_LATER){
        self.selectPrinterCell.hidden = YES;
        self.printSettingsCell.hidden = YES;
        self.numberOfCopiesCell.hidden = YES;
    }
}

// Hide or show UI based on current print settings
- (void)updatePageSettingsUI
{
    // This block of beginUpdates-endUpdates is required to refresh the tableView while it is currently being displayed on screen
    [self.tableView beginUpdates];
    
    self.printCell.hidden = NO;
    self.selectPrinterCell.hidden = NO;
    self.printSettingsCell.hidden = YES;
    self.jobNameCell.hidden = YES;
    self.numberOfCopiesCell.hidden = NO;
    self.paperSizeCell.hidden = self.mp.hidePaperSizeOption;
    self.paperTypeCell.hidden = self.mp.hidePaperTypeOption || [[self.delegateManager.printSettings.paper supportedTypes] count] == 1;
    self.pageRangeCell.hidden = ![self showPageRange];
    self.pageSelectionMark.hidden = ![self showPageRange];
    self.pageSelectionExtendedArea.hidden = self.pageSelectionMark.hidden;
    
    if (MPPageSettingsModeAddToQueue == self.mode) {
        self.jobNameCell.hidden = NO;
        self.selectPrinterCell.hidden = YES;
        self.paperSizeCell.hidden = YES;
        self.paperTypeCell.hidden = YES;
    } else if (MPPageSettingsModeSettingsOnly == self.mode) {
        self.cancelBarButtonItem.title = @"Done";
        self.printCell.hidden = YES;
        self.jobSummaryCell.hidden = YES;
        self.numberOfCopiesCell.hidden = YES;
        self.pageRangeCell.hidden = YES;
        self.pageSelectionMark.hidden = YES;
    } else if (MPPageSettingsModePrintFromQueue == self.mode) {
        self.numberOfCopiesCell.hidden = YES;
        self.pageRangeCell.hidden = YES;
        self.pageSelectionMark.hidden = YES;
        self.filterCell.hidden = YES;
    } else {
        if (IS_OS_8_OR_LATER){
            if (nil != self.delegateManager.printSettings.printerName){
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
        }
    }

    if (MPPageSettingsDisplayTypePreviewPane == self.displayType) {
        self.jobNameCell.hidden = YES;
        self.printCell.hidden = YES;
        self.selectPrinterCell.hidden = YES;
        self.printSettingsCell.hidden = YES;
        self.paperSizeCell.hidden = YES;
        self.paperTypeCell.hidden = YES;
        self.numberOfCopiesCell.hidden = YES;
        self.pageRangeCell.hidden = YES;
        self.filterCell.hidden = YES;
    } else if( MPPageSettingsDisplayTypePageSettingsPane == self.displayType ) {
        self.basicJobSummaryCell.hidden = YES;
        self.previewJobSummaryCell.hidden = YES;
    }
    
    [self prepareUiForIosVersion];

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
    MP *mp = [MP sharedInstance];
    if( [self.delegateManager noPagesSelected] ) {
        self.printCell.userInteractionEnabled = NO;
        self.printLabel.textColor = [mp.appearance.settings objectForKey:kMPMainActionInactiveLinkFontColor];
    } else {
        self.printCell.userInteractionEnabled = YES;
        self.printLabel.textColor = [mp.appearance.settings objectForKey:kMPMainActionActiveLinkFontColor];
    }
    
    if( MPPageSettingsModeAddToQueue == self.mode ) {
        self.printLabel.text = self.delegateManager.printLaterLabelText;
    } else if( MPPageSettingsModePrintFromQueue == self.mode ) {
        if (self.printLaterJobs.count > 1) {
            self.printLabel.text = self.delegateManager.printMultipleJobsFromQueueLabelText;
        } else {
            self.printLabel.text = self.delegateManager.printSingleJobFromQueueLabelText;
        }
    } else {
        self.printLabel.text = self.delegateManager.printLabelText;
    }
}

- (void)showPrinterSelection:(UITableView *)tableView withCompletion:(void (^)(BOOL userDidSelect))completion
{
    if ([[MPWiFiReachability sharedInstance] isWifiConnected]) {
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
        [[MPWiFiReachability sharedInstance] noPrinterSelectAlert];
    }
}

- (void)reloadPrintSettingsSection
{
    NSRange range = NSMakeRange(PRINT_SETTINGS_SECTION, 1);
    NSIndexSet *sectionToReload = [NSIndexSet indexSetWithIndexesInRange:range];
    [self.tableView reloadSections:sectionToReload withRowAnimation:UITableViewRowAnimationNone];
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

- (MPPrintItem *)printItem
{
    return self.delegateManager.printItem;
}

- (void)setPrintItem:(MPPrintItem *)printItem
{
    if( nil == self.delegateManager ) {
        self.delegateManager = [[MPPrintSettingsDelegateManager alloc] init];
    }

    self.delegateManager.printItem = printItem;
    [self configureMultiPageViewWithPrintItem:printItem];
}

- (void)configureMultiPageViewWithPrintItem:(MPPrintItem *)printItem
{
    if (self.delegateManager.printSettings.paper) {
        NSInteger numPages = printItem.numberOfPages;
        
        if (MPPageSettingsModePrintFromQueue == self.mode) {
            numPages = self.printLaterJobs.count;
        }
        [self.multiPageView configurePages:numPages paper:self.delegateManager.printSettings.paper layout:printItem.layout];
        
        if (MPPageSettingsModePrintFromQueue == self.mode) {
            NSInteger jobNum = 1;
            for (MPPrintLaterJob* job in self.printLaterJobs) {
                if (job.blackAndWhite) {
                    [self.multiPageView setPageNum:jobNum blackAndWhite:YES];
                }
                
                jobNum++;
            }
        } else {
            self.multiPageView.blackAndWhite = self.delegateManager.blackAndWhite;
        }
    }
}

- (MPMultiPageView *)multiPageView
{
    if (self.previewViewController) {
        _multiPageView = self.previewViewController.multiPageView;
        _multiPageView.delegate = self;
        
        _headerInactivityView = self.previewViewController.headerInactivityView;
    }
    
    return _multiPageView;
}

-(void)respondToMultiPageViewAction
{
    if( self.printItem.numberOfPages > 1  &&  MPPageSettingsModePrintFromQueue != self.mode) {
        BOOL includePage = self.pageSelectionMark.imageView.image == self.unselectedPageImage;
        
        [self.delegateManager includePageInPageRange:includePage pageNumber:self.multiPageView.currentPage];
        
        [self updateSelectedPageIcon:includePage];
    }
}

- (void)setPageRangeLabelText:(NSString *)pageRange
{
    if( pageRange.length ) {
        self.pageRangeDetailTextField.text = pageRange;
    } else {
        self.pageRangeDetailTextField.text = kPageRangeAllPages;
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
    
    if( self.previewViewController ) {
        [self.previewViewController.pageSelectionMark setImage:image forState:UIControlStateNormal];
    }
}

- (void)setPageRange:(MPPageRange *)pageRange
{
	self.delegateManager.pageRange = pageRange;
}

- (MPPageRange *)pageRange
{
    if (nil == self.delegateManager.pageRange) {
        self.delegateManager.pageRange = [[MPPageRange alloc] initWithString:kPageRangeAllPages allPagesIndicator:kPageRangeAllPages maxPageNum:self.printItem.numberOfPages sortAscending:YES];
        self.delegateManager.pageRange.range = kPageRangeAllPages;
    }
    
    if( 1 < self.printItem.numberOfPages ) {
        [self.delegateManager.pageRange setRange:self.pageRangeDetailTextField.text];
    }
    
    return self.delegateManager.pageRange;
}

- (NSString *)stringFromNumberOfPrintingItems:(NSInteger)numberOfPrintingItems copies:(NSInteger)copies
{
    NSString *result = nil;
    
    if (numberOfPrintingItems == 1) {
        result = MPLocalizedString(@"Print", @"Caption of the button for printing");
    } else {
        NSInteger total = numberOfPrintingItems * copies;
        
        if (total == 2) {
            result = MPLocalizedString(@"Print both", @"Caption of the button for printing");
        } else {
            result = [NSString stringWithFormat:MPLocalizedString(@"Print all %lu", @"Caption of the button for printing"), (long)total];
        }
    }
    
    return result;
}

- (void) refreshData
{
    self.printManager.currentPrintSettings = self.delegateManager.printSettings;
    
    [self setPageRangeLabelText:self.delegateManager.pageRangeText];
    BOOL pageSelected = NO;
    NSArray *pageNums = [self.delegateManager.pageRange getPages];
    for( NSNumber *pageNum in pageNums ) {
        if( [pageNum integerValue] == self.multiPageView.currentPage) {
            pageSelected = YES;
            break;
        }
    }
    [self updateSelectedPageIcon:pageSelected];
    
    self.jobNameTextField.text = self.delegateManager.jobName;
    
    self.numberOfCopiesLabel.text = self.delegateManager.numCopiesLabelText;
    self.pageRangeDetailTextField.text = self.delegateManager.pageRangeText;
    
    if( !self.previewJobSummaryCell.hidden ) {
        self.previewJobSummaryCell.textLabel.text = self.delegateManager.jobName;
        if( MPPageSettingsModeAddToQueue == self.mode ) {
            self.previewJobSummaryCell.detailTextLabel.text = self.delegateManager.printLaterJobSummaryText;
        } else {
            self.previewJobSummaryCell.detailTextLabel.text = self.delegateManager.printJobSummaryText;
        }
    } else {
        if( MPPageSettingsModeAddToQueue == self.mode ) {
            self.basicJobSummaryCell.textLabel.text = self.delegateManager.printLaterJobSummaryText;
        } else {
            self.basicJobSummaryCell.textLabel.text = self.delegateManager.printJobSummaryText;
        }
    }
    
    [self changePaper];
    [self reloadPaperSelectionSection];
    
    [self updatePageSettingsUI];
    [self updatePrintSettingsUI];
    [self updatePrintButtonUI];
    
    [self.tableView reloadData];
    
    if( self.previewViewController ) {
        [self.previewViewController refreshData];
    }
}

- (void)refreshPrinterStatus:(NSTimer *)timer
{
    if( nil != timer ) {
        MPLogInfo(@"Printer status timer fired");
    } else {
        MPLogInfo(@"Checking printer status... non-timer event");
    }
    
    [[MPPrinter sharedInstance] checkLastPrinterUsedAvailability];
}

- (void)positionPreviewJobSummaryCell
{
    CGRect headerFrame = self.tableView.tableHeaderView.frame;
    headerFrame.size.height = self.view.frame.size.height - self.jobSummaryCell.frame.size.height - 1;
    self.tableView.tableHeaderView.frame = headerFrame;
    self.tableView.tableHeaderView = self.tableView.tableHeaderView;
}

- (void)configureJobSummaryCell
{
    if( MPPageSettingsModeAddToQueue == self.mode || MPPageSettingsModePrintFromQueue == self.mode ) {
        self.jobSummaryCell = self.previewJobSummaryCell;
        self.basicJobSummaryCell.hidden = YES;
        self.previewJobSummaryCell.hidden = NO;
    } else {
        self.jobSummaryCell = self.basicJobSummaryCell;
        self.previewJobSummaryCell.hidden = YES;
        self.basicJobSummaryCell.hidden = NO;
    }
    
    CGRect frame = self.jobSummaryCell.frame;
    if( MPPageSettingsDisplayTypePreviewPane == self.displayType ) {
        if( CGFLOAT_MIN < self.previewJobSummaryCell.frame.size.height ) {
            frame.size.height = self.previewJobSummaryCell.frame.size.height;
            self.jobSummaryCell.frame = frame;
        }
        [self positionPreviewJobSummaryCell];
    } else {
        frame.size.height = self.basicJobSummaryCell.frame.size.height;
    }
}

- (BOOL)isPrintSummarySection:(NSInteger)section
{
    return (BASIC_PRINT_SUMMARY_SECTION == section || PREVIEW_PRINT_SUMMARY_SECTION == section);
}

-(BOOL)isSectionVisible:(NSInteger)section {
    BOOL isCellVisible = NO;
    
    NSArray *indexes = [self.tableView indexPathsForVisibleRows];
    for (NSIndexPath *index in indexes) {
        if (section == index.section) {
            isCellVisible = YES;
        }
    }
    
    return isCellVisible;
}

- (void)positionPageSelectionMark
{
    NSInteger imageSize = 30;
    NSInteger extendedSize = 75;
    NSInteger yOffset = 12.5;
    
    CGRect pageFrame = [self.multiPageView currentPageFrame];
    CGFloat xOrigin = self.view.frame.size.width - 55;
    if( !CGRectEqualToRect(pageFrame, CGRectZero) ) {
        xOrigin = pageFrame.origin.x + pageFrame.size.width - imageSize/2;
    }
    
    // the page selection image
    CGRect frame = self.jobSummaryCell.frame;
    frame.origin.x = xOrigin;
    frame.origin.y = self.jobSummaryCell.frame.origin.y - yOffset;
    frame.size.width = imageSize;
    frame.size.height = imageSize;
    
    self.pageSelectionMark.frame = [self.jobSummaryCell.superview convertRect:frame toView:self.view];
    
    // the active area
    CGFloat extendedOffset = (extendedSize - imageSize)/2;
    frame.origin.x -= extendedOffset;
    frame.origin.y -= extendedOffset;
    frame.size.width = extendedSize;
    frame.size.height = extendedSize;

    self.pageSelectionExtendedArea.frame = frame;
}

#pragma mark - UITextField delegate

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    if( self.jobNameTextField == textField ) {
        NSString *text = [textField.text stringByTrimmingCharactersInSet:
                          [NSCharacterSet whitespaceCharacterSet]];
        if( 0 < [text length] ) {
            self.delegateManager.jobName = text;
        } else {
            textField.text = self.delegateManager.jobName;
        }
    } else if( self.pageRangeDetailTextField == textField ) {
        [((MPPageRangeKeyboardView *)self.pageRangeDetailTextField.inputView) commitEditing];
    }
    
    [self stopEditing];
    
    [self refreshData];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if( self.jobNameTextField == textField ) {
        [self.jobNameTextField resignFirstResponder];
    } else if( self.pageRangeDetailTextField == textField ) {
        [self.pageRangeDetailTextField resignFirstResponder];
    }
    
    [self stopEditing];
    
    return NO;
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    self.editing = YES;
    
    if( textField == self.pageRangeDetailTextField ) {
        [((MPPageRangeKeyboardView *)self.pageRangeDetailTextField.inputView) prepareForDisplay];
        self.jobNameTextField.userInteractionEnabled = NO;
    } else {
        self.pageRangeDetailTextField.userInteractionEnabled = NO;
    }
    
    return YES;
}

#pragma  mark - Job Name and Page Range editing

-(void)stopEditing
{
    self.editing = NO;
}

- (void)setPageRangeKeyboardView
{
    MPPageRangeKeyboardView *pageRangeKeyboardView = [[MPPageRangeKeyboardView alloc] initWithFrame:self.view.frame textField:self.pageRangeDetailTextField maxPageNum:[self.printItem numberOfPages]];
    pageRangeKeyboardView.delegate = self.delegateManager;
    self.pageRangeDetailTextField.inputView = pageRangeKeyboardView;
    [self.pageRangeDetailTextField resignFirstResponder];
}

- (void)cancelAllEditing
{
    [self cancelJobNameEditing];
    [((MPPageRangeKeyboardView *)self.pageRangeDetailTextField.inputView) cancelEditing];
    self.pageRangeDetailTextField.text = self.delegateManager.pageRangeText;
    [self stopEditing];
}

- (void)cancelJobNameEditing
{
    self.jobNameTextField.text = self.delegateManager.jobName;
    [self.jobNameTextField resignFirstResponder];
    [self stopEditing];
}

-(void)handleTap:(UITapGestureRecognizer *)sender{

    [self cancelAllEditing];
}

- (void)setEditing:(BOOL)editing
{
    static UITapGestureRecognizer *tableViewTaps;
    static UITapGestureRecognizer *headerInactivityViewTaps;
    _editing = editing;
    
    if( _editing ) {
        tableViewTaps = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap:)];
        headerInactivityViewTaps = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap:)];
        [self.tableView addGestureRecognizer:tableViewTaps];
        [self.headerInactivityView addGestureRecognizer:headerInactivityViewTaps];
        self.headerInactivityView.alpha = 0.1F;
        self.headerInactivityView.userInteractionEnabled = YES;
        
        self.numberOfCopiesStepper.userInteractionEnabled = NO;
        self.blackAndWhiteModeSwitch.userInteractionEnabled = NO;
        self.pageSelectionMark.userInteractionEnabled = NO;
        self.pageSelectionExtendedArea.userInteractionEnabled = NO;
    } else {
        [self.tableView removeGestureRecognizer:tableViewTaps];
        [self.headerInactivityView removeGestureRecognizer:headerInactivityViewTaps];
        self.headerInactivityView.alpha = 0.0F;
        self.headerInactivityView.userInteractionEnabled = NO;
        
        self.numberOfCopiesStepper.userInteractionEnabled = YES;
        self.blackAndWhiteModeSwitch.userInteractionEnabled = YES;
        self.pageSelectionMark.userInteractionEnabled = YES;
        self.pageSelectionExtendedArea.userInteractionEnabled = YES;
        
        self.jobNameTextField.userInteractionEnabled = YES;
        self.pageRangeDetailTextField.userInteractionEnabled = YES;
    }
}

#pragma mark - Printer availability

- (void)printerNotAvailable
{
    // This block of beginUpdates-endUpdates is required to refresh the tableView while it is currently being displayed on screen
    [self.tableView beginUpdates];
    UIImage *warningSign = [UIImage imageResource:@"MPDoNoEnter" ofType:@"png"];
    [self.printSettingsCell.imageView setImage:warningSign];
    [self.selectPrinterCell.imageView setImage:warningSign];

    self.delegateManager.printSettings.printerIsAvailable = NO;
    [self.tableView endUpdates];
}

- (void)printerIsAvailable
{
    // This block of beginUpdates-endUpdates is required to refresh the tableView while it is currently being displayed on screen
    [self.tableView beginUpdates];
    [self.printSettingsCell.imageView setImage:nil];
    [self.selectPrinterCell.imageView setImage:nil];
    self.delegateManager.printSettings.printerIsAvailable = YES;
    [self.tableView endUpdates];
}

-(void) setPreviewViewController:(MPPageSettingsTableViewController *)vc
{
    _previewViewController = vc;
    _previewViewController.delegateManager = self.delegateManager;
}

#pragma mark - Button actions

- (IBAction)cancelButtonTapped:(id)sender
{
    if( self.editing ) {
        [self cancelAllEditing];
    } else {
        if ([self.printDelegate respondsToSelector:@selector(didCancelPrintFlow:)]) {
            if (MPPageSettingsModeSettingsOnly == self.mode) {
                [self saveSettings];
            }
            [self.printDelegate didCancelPrintFlow:self];
        } else if ([self.printLaterDelegate respondsToSelector:@selector(didCancelAddPrintLaterFlow:)]) {
            if (MPPageSettingsModeSettingsOnly == self.mode) {
                [self saveSettings];
            }
            [self.printLaterDelegate didCancelAddPrintLaterFlow:self];
        } else {
            MPLogWarn(@"No MPPrintDelegate or MPAddPrintLaterDelegate has been set to respond to the end of the print flow.  Implement one of these delegates to dismiss the Page Settings view controller.");
        }
    }
}

- (void)displaySystemPrintFromView:(UIView *)view
{
    UIPrintInteractionController *controller = [UIPrintInteractionController sharedPrintController];
    controller.delegate = self.printManager;
    controller.showsNumberOfCopies = NO;
    controller.showsPageRange = NO;

    self.printManager.currentPrintSettings = self.delegateManager.printSettings;
    [self.printManager prepareController:controller printItem:self.printItem color:!self.blackAndWhiteModeSwitch.on pageRange:self.pageRange numCopies:self.numberOfCopies];
    
    __weak __typeof(self) weakSelf = self;
    UIPrintInteractionCompletionHandler completionHandler = ^(UIPrintInteractionController *printController, BOOL completed, NSError *error) {
        
        if (!completed) {
            MPLogInfo(@"Print was NOT completed");
        }
        
        if (error) {
            MPLogWarn(@"Print error:  %@", error);
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
    if (MPPageSettingsModePrintFromQueue == self.mode) {
        MPPrintLaterJob *job = self.printLaterJobs[self.multiPageView.currentPage-1];
        job.blackAndWhite = self.delegateManager.blackAndWhite;
        [self.multiPageView setPageNum:self.multiPageView.currentPage blackAndWhite:job.blackAndWhite];
    } else {
        self.multiPageView.blackAndWhite = self.delegateManager.blackAndWhite;
    }
    
    [self refreshData];
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if (MPPageSettingsDisplayTypePreviewPane != self.displayType  &&
        self.mp.supportActions.count         != 0                 &&
        MPPageSettingsModeSettingsOnly       != self.mode)
        return [super numberOfSectionsInTableView:tableView];
    else
        return ([super numberOfSectionsInTableView:tableView] - 1);
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
   
    if (section == SUPPORT_SECTION) {
        return self.mp.supportActions.count;
    } else if (section == PAPER_SELECTION_SECTION) {
        if ([[self.delegateManager.printSettings.paper supportedTypes] count] > 1) {
            return 2;
        } else {
            return 1;
        }
    } else if ([self isPrintSummarySection:section]           &&
               MPPageSettingsModeSettingsOnly == self.mode  &&
               nil == self.printItem) {
        return 0;

    } else if (NUMBER_OF_COPIES_SECTION == section && !IS_OS_8_OR_LATER) {
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
        
        cell.backgroundColor = [self.mp.appearance.settings objectForKey:kMPSelectionOptionsBackgroundColor];
        cell.textLabel.font = [self.mp.appearance.settings objectForKey:kMPSelectionOptionsPrimaryFont];
        cell.textLabel.textColor = [self.mp.appearance.settings objectForKey:kMPSelectionOptionsPrimaryFontColor];
        MPSupportAction *action = self.mp.supportActions[indexPath.row];
        cell.imageView.image = action.icon;
        cell.textLabel.text = action.title;
    }

    cell.userInteractionEnabled = !self.actionInProgress;
    
    return cell;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    cell.alpha = cell.userInteractionEnabled ? 1.0 : kMPDisabledAlpha;

    if (self.previewViewController) {
        self.pageSelectionMark.hidden = YES;
    } else if (![self isSectionVisible:PREVIEW_PRINT_SUMMARY_SECTION]  &&  ![self isSectionVisible:BASIC_PRINT_SUMMARY_SECTION]) {
        self.pageSelectionMark.hidden = YES;
    } else if (cell == self.jobSummaryCell) {
        
        BOOL showMark = NO;
        
        [self positionPageSelectionMark];
        
        if (nil == self.printLaterJobs) {
            if (self.printItem.numberOfPages > 1) {
                showMark = YES;
            }
        } else {
            if (MPPageSettingsModeAddToQueue == self.mode) {
                if (self.printItem.numberOfPages > 1) {
                    showMark = YES;
                }
            }
        }
        
        self.pageSelectionMark.hidden = !showMark;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    CGFloat height = ZERO_HEIGHT;
    
    if (section == SUPPORT_SECTION) {
        if (self.mp.supportActions.count != 0) {
            height = HEADER_HEIGHT;
        }
    }
    
    return height;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    CGFloat height = ZERO_HEIGHT;
 
    if ( MPPageSettingsDisplayTypePreviewPane == self.displayType ||
        0 == [self tableView:tableView numberOfRowsInSection:section]) {
        height = ZERO_HEIGHT;
    } else {
        if( MPPageSettingsModeSettingsOnly == self.mode ) {
            if( (section == PREVIEW_PRINT_SUMMARY_SECTION && self.printItem) ||
               section == PRINTER_SELECTION_SECTION ) {
                
                height = SEPARATOR_SECTION_FOOTER_HEIGHT;
            }
            
            if ( section == PAPER_SELECTION_SECTION  &&
                (!self.paperSizeCell.hidden || !self.paperTypeCell.hidden)) {
                height = SEPARATOR_SECTION_FOOTER_HEIGHT;
            }
        } else if( MPPageSettingsModeAddToQueue == self.mode ) {
            if( section == PREVIEW_PRINT_SUMMARY_SECTION ||
                section == PRINT_FUNCTION_SECTION        ||
                section == PRINT_JOB_NAME_SECTION        ||
                section == NUMBER_OF_COPIES_SECTION      ||
                (section == PAGE_RANGE_SECTION  &&  [self showPageRange])) {
                
                height = SEPARATOR_SECTION_FOOTER_HEIGHT;
            }
        } else if( MPPageSettingsModePrintFromQueue == self.mode ) {
            if( section == PREVIEW_PRINT_SUMMARY_SECTION ||
                section == PRINT_FUNCTION_SECTION        ||
                section == PRINT_JOB_NAME_SECTION        ||
                section == PRINTER_SELECTION_SECTION) {
                
                height = SEPARATOR_SECTION_FOOTER_HEIGHT;
                
                if (section == PRINTER_SELECTION_SECTION  &&  !self.selectPrinterCell.hidden) {
                    if (self.delegateManager.printSettings.printerUrl != nil) {
                        if (!self.delegateManager.printSettings.printerIsAvailable) {
                            height = PRINTER_WARNING_SECTION_FOOTER_HEIGHT;
                        }
                    }
                }
            }
        } else {
            if (section == PRINT_FUNCTION_SECTION || section == PREVIEW_PRINT_SUMMARY_SECTION) {
                height = SEPARATOR_SECTION_FOOTER_HEIGHT;
            } else if (IS_OS_8_OR_LATER && ((section == PRINTER_SELECTION_SECTION) || (section == PAPER_SELECTION_SECTION))) {
                if ( !self.mp.hidePaperTypeOption && (self.delegateManager.printSettings.printerUrl == nil) ) {
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
            } else if (section == PAGE_RANGE_SECTION  &&  [self showPageRange]) {
                height = SEPARATOR_SECTION_FOOTER_HEIGHT;
            }
            else if (IS_OS_8_OR_LATER && (section == NUMBER_OF_COPIES_SECTION)) {
                height = SEPARATOR_SECTION_FOOTER_HEIGHT;
            } else if (section == SUPPORT_SECTION) {
                height = SEPARATOR_SECTION_FOOTER_HEIGHT;
            } else if (MPPageSettingsModeAddToQueue == self.mode && (section == PRINT_JOB_NAME_SECTION)) {
                height = SEPARATOR_SECTION_FOOTER_HEIGHT;
            }
        }
    }
    
    if( MPPageSettingsDisplayTypePageSettingsPane == self.displayType && [self isPrintSummarySection:section] ) {
        height = ZERO_HEIGHT;
    }

    return height;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    cell.selected = NO;
    
    if (indexPath.section == SUPPORT_SECTION) {
        MPSupportAction *action = self.mp.supportActions[indexPath.row];
        if (action.url) {
            [[UIApplication sharedApplication] openURL:action.url];
        } else {
            [self presentViewController:action.viewController animated:YES completion:nil];
        }
    } else if (cell == self.selectPrinterCell) {
        [self showPrinterSelection:tableView withCompletion:nil];
    } else if (cell == self.printCell){
        if( MPPageSettingsModeAddToQueue == self.mode ) {
            [self addJobToPrintQueue];
        } else {
            [self oneTouchPrint:tableView];
        }
    } else if (cell == self.pageRangeCell){
        [self.pageRangeDetailTextField becomeFirstResponder];
    }  else if (cell == self.jobNameCell) {
        [self.jobNameTextField becomeFirstResponder];
    }
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *header = nil;
    
    if (section == SUPPORT_SECTION) {
        if (self.mp.supportActions.count != 0) {
            header = [tableView MPHeaderViewForSupportSection];
        }
    }
    
    return header;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    UIView *footer = nil;
    
    if (IS_OS_8_OR_LATER  &&  MPPageSettingsDisplayTypePreviewPane != self.displayType) {
        if ( (!self.selectPrinterCell.hidden  &&  section == PRINTER_SELECTION_SECTION) ||
             (!self.printSettingsCell.hidden  &&  section == PRINT_SETTINGS_SECTION) ) {
            if ((self.delegateManager.printSettings.printerUrl != nil) && !self.delegateManager.printSettings.printerIsAvailable) {
                footer = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, tableView.frame.size.width, PRINTER_WARNING_SECTION_FOOTER_HEIGHT)];
                
                UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(20.0f, 0.0f, tableView.frame.size.width - 20.0f, PRINTER_WARNING_SECTION_FOOTER_HEIGHT)];
                label.font = [self.mp.appearance.settings objectForKey:kMPGeneralBackgroundPrimaryFont];
                label.textColor = [self.mp.appearance.settings objectForKey:kMPGeneralBackgroundPrimaryFontColor];
                if( MPPageSettingsModeSettingsOnly != self.mode && MPPageSettingsModeAddToQueue != self.mode ) {
                    if (MPPageSettingsModePrintFromQueue == self.mode) {
                        label.text = MPLocalizedString(@"Default printer not currently available", nil);
                    } else {
                        label.text = MPLocalizedString(@"Recent printer not currently available", nil);
                    }
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
    CGFloat rowHeight = tableView.rowHeight;
    
    if( MPPageSettingsDisplayTypePreviewPane == self.displayType && cell == self.jobSummaryCell ) {
        rowHeight = 2 * tableView.rowHeight;
    }
    
    return cell.hidden ? 0.0 : rowHeight;
}

#pragma mark - Print Queue

- (void) addJobToPrintQueue
{
    self.actionInProgress = YES;
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        MPPrintLaterJob *printLaterJob = self.printLaterJobs[self.currentPrintJob];
        printLaterJob.pageRange = self.delegateManager.pageRange;
        printLaterJob.name = self.delegateManager.jobName;
        printLaterJob.numCopies = self.delegateManager.numCopies;
        printLaterJob.blackAndWhite = self.delegateManager.blackAndWhite;
        
        NSString *titleForInitialPaperSize = [MPPaper titleFromSize:[MP sharedInstance].defaultPaper.paperSize];
        MPPrintItem *printItem = [printLaterJob.printItems objectForKey:titleForInitialPaperSize];
        
        if (printItem == nil) {
            MPLogError(@"At least the printing item for the initial paper size (%@) must be provided", titleForInitialPaperSize);
        } else {
            BOOL result = [[MPPrintLaterQueue sharedInstance] addPrintLaterJob:printLaterJob fromController:self];
            
            self.actionInProgress = NO;
            
            if (result) {
                if ([self.printLaterDelegate respondsToSelector:@selector(didFinishAddPrintLaterFlow:)]) {
                    [self.printLaterDelegate didFinishAddPrintLaterFlow:self];
                }
            } else {
                if ([self.printLaterDelegate respondsToSelector:@selector(didCancelAddPrintLaterFlow:)]) {
                    [self.printLaterDelegate didCancelAddPrintLaterFlow:self];
                }
            }
        }
    });
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
        self.printItem.layout.paper = self.printManager.currentPrintSettings.paper;
        [self displaySystemPrintFromView:self.printCell];
    }
}

- (void)startPrinting
{
    self.itemsToPrint = [[NSMutableArray alloc] init];
    self.pageRanges = [[NSMutableArray alloc] init];
    self.blackAndWhiteSelections = [[NSMutableArray alloc] init];
    self.numCopySelections = [[NSMutableArray alloc] init];
    
    [self collectMPPrintLaterJobs];
    if( 0 == self.itemsToPrint.count ) {
        [self collectParallelArrayPrintJobs];
    }
    
    MPPrintItem *firstItem = [self.itemsToPrint firstObject];
    MPPageRange *pageRange = [self.pageRanges firstObject];
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

- (void)collectMPPrintLaterJobs
{
    NSMutableArray *printLaterJobs = nil;
    
    if ([self.dataSource respondsToSelector:@selector(numberOfPrintingItems)]) {
        if ([self.dataSource respondsToSelector:@selector(printLaterJobs)]) {
            printLaterJobs = [self.dataSource printLaterJobs].mutableCopy;
        }
    }
    
    for (MPPrintLaterJob *job in printLaterJobs) {
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
    
    MPPrintItem *firstItem = [self.itemsToPrint firstObject];
    
    if( self.pageRanges.count != self.itemsToPrint.count ) {
        MPLogWarn(@"%lu MPPrintItems and %lu MPPageRanges.  Using default values for all MPPageRanges.", (unsigned long)self.itemsToPrint.count, (unsigned long)self.pageRanges.count);
        self.pageRanges = [[NSMutableArray alloc] initWithCapacity:self.itemsToPrint.count];
        for (int i=0; i<self.itemsToPrint.count; i++) {
            [self.pageRanges insertObject:[[MPPageRange alloc] initWithString:MPLocalizedString(@"All", nil) allPagesIndicator:MPLocalizedString(@"All", nil) maxPageNum:firstItem.numberOfPages sortAscending:TRUE] atIndex:i];
        }
    }
    
    if( self.blackAndWhiteSelections.count != self.itemsToPrint.count ) {
        MPLogWarn(@"%lu MPPrintItems and %lu BOOLs for black and white.  Using default values for all black and white indicators.", (unsigned long)self.itemsToPrint.count, (unsigned long)self.blackAndWhiteSelections.count);
        self.blackAndWhiteSelections = [[NSMutableArray alloc] initWithCapacity:self.itemsToPrint.count];
        for (int i=0; i<self.itemsToPrint.count; i++) {
            [self.blackAndWhiteSelections insertObject:[NSNumber numberWithBool:NO] atIndex:i];
        }
    }
    
    if( self.numCopySelections.count != self.itemsToPrint.count ) {
        MPLogWarn(@"%lu MPPrintItems and %lu NSNumbers for number of copies.  Using default values for all number of copies.", (unsigned long)self.itemsToPrint.count, (unsigned long)self.numCopySelections.count);
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
        if ([self.dataSource respondsToSelector:@selector(printingItemsForPaper:)]) {
            items = [self.dataSource printingItemsForPaper:self.delegateManager.printSettings.paper].mutableCopy;
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
        if ([self.dataSource respondsToSelector:@selector(pageRangeSelections)]) {
            pageRanges = [self.dataSource pageRangeSelections].mutableCopy;
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
        if ([self.dataSource respondsToSelector:@selector(blackAndWhiteSelections)]) {
            bws = [self.dataSource blackAndWhiteSelections].mutableCopy;
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
        if ([self.dataSource respondsToSelector:@selector(numberOfCopiesSelections)]) {
            numCopies = [self.dataSource numberOfCopiesSelections].mutableCopy;
        }
    }
    
    if (nil == numCopies) {
        numCopies = [NSMutableArray arrayWithObjects:[NSNumber numberWithInteger:self.numberOfCopiesStepper.value], nil];
    }
    
    return numCopies;
}


- (void)print:(MPPrintItem *)printItem blackAndWhite:(BOOL)blackAndWhite pageRange:(MPPageRange *)pageRange numberOfCopies:(NSInteger)numCopies
{
    self.delegateManager.blackAndWhite = blackAndWhite;
    self.printManager.currentPrintSettings = self.delegateManager.printSettings;
    self.printManager.currentPrintSettings.color = !blackAndWhite;
    
    NSError *error;
    [self.printManager print:printItem
                   pageRange:pageRange
                   numCopies:numCopies
                       error:&error];
    
    if( MPPrintManagerErrorNone != error.code ) {
        MPLogError(@"Failed to print with error %@", error);
    }
}

- (void)print:(MPPrintItem *)printItem
{
    self.delegateManager.blackAndWhite = self.blackAndWhiteModeSwitch.on;
    self.printManager.currentPrintSettings = self.delegateManager.printSettings;

    [self print:printItem blackAndWhite:self.blackAndWhiteModeSwitch.on pageRange:self.pageRange numberOfCopies:self.numberOfCopiesStepper.value];
}

- (void)printCompleted:(UIPrintInteractionController *)printController isCompleted:(BOOL)completed printError:(NSError *)error
{
    [self.delegateManager savePrinterId:printController.printInfo.printerID];
    
    if (error) {
        MPLogError(@"FAILED! due to error in domain %@ with error code %ld", error.domain, (long)error.code);
    }
    
    if (completed) {
        
        [[MPAnalyticsManager sharedManager] trackUserFlowEventWithId:kMPMetricsEventTypePrintCompleted];
        
        [self setDefaultPrinter];
    
        if ([self.printDelegate respondsToSelector:@selector(didFinishPrintFlow:)]) {
            [self.printDelegate didFinishPrintFlow:self];
        }
        else {
            MPLogWarn(@"No MPPrintDelegate has been set to respond to the end of the print flow.  Implement this delegate to dismiss the Page Settings view controller.");
        }
    }
    
    if (IS_IPAD) {
        self.cancelBarButtonItem.enabled = YES;
    }
}

- (void)setDefaultPrinter
{
    [MPDefaultSettingsManager sharedInstance].defaultPrinterName = self.delegateManager.printSettings.printerName;
    [MPDefaultSettingsManager sharedInstance].defaultPrinterUrl = self.delegateManager.printSettings.printerUrl.absoluteString;
    [MPDefaultSettingsManager sharedInstance].defaultPrinterNetwork = [MPAnalyticsManager wifiName];
    [MPDefaultSettingsManager sharedInstance].defaultPrinterCoordinate = [[MPPrintLaterManager sharedInstance] retrieveCurrentLocation];
    [MPDefaultSettingsManager sharedInstance].defaultPrinterModel = self.delegateManager.printSettings.printerModel;
    [MPDefaultSettingsManager sharedInstance].defaultPrinterLocation = self.delegateManager.printSettings.printerLocation;
    [[NSNotificationCenter defaultCenter] postNotificationName:kMPDefaultPrinterAddedNotification object:self userInfo:nil];
}

- (void)saveSettings
{
    [self setDefaultPrinter];
    
    NSString *printerID = [MPDefaultSettingsManager sharedInstance].defaultPrinterUrl;
    [self.delegateManager savePrinterId:printerID];
    [self.printManager saveLastOptionsForPrinter:printerID];
}

- (void)preparePrintManager
{
    if (nil == self.printManager) {
        self.printManager = [[MPPrintManager alloc] init];
    }
    self.printManager.delegate = self;

    [self.printManager setOptionsForPrintDelegate:self.printDelegate dataSource:self.dataSource];
}

#pragma mark - MPMultipageViewDelegate

- (UIImage *)multiPageView:(MPMultiPageView *)multiPageView getImageForPage:(NSUInteger)pageNumber
{
    UIImage *image = nil;
    
    if (MPPageSettingsModePrintFromQueue == self.mode) {
        if (pageNumber > 0  &&  pageNumber <= [self.printLaterJobs count]) {
            MPPrintLaterJob *printLaterJob = self.printLaterJobs[pageNumber-1];
            MPPrintItem *printItem = [printLaterJob.printItems objectForKey:self.delegateManager.printSettings.paper.sizeTitle];
            
            image = [printItem previewImageForPage:1 paper:self.delegateManager.printSettings.paper];
        }
    } else if( pageNumber <= self.printItem.numberOfPages ) {
        image = [self.printItem previewImageForPage:pageNumber paper:self.delegateManager.printSettings.paper];
    }
    return image;
}

- (BOOL)multiPageView:(MPMultiPageView *)multiPageView useMultiPageIndicatorForPage:(NSUInteger)pageNumber
{
    BOOL useIndicator = NO;
    
    if (MPPageSettingsModePrintFromQueue == self.mode) {
        if (pageNumber > 0  &&  pageNumber <= self.printLaterJobs.count) {
            MPPrintLaterJob *printLaterJob = self.printLaterJobs[pageNumber-1];
            MPPrintItem *printItem = [printLaterJob.printItems objectForKey:self.delegateManager.printSettings.paper.sizeTitle];
            if (printItem.numberOfPages > 1) {
                useIndicator = YES;
            }
        }
    }
    
    return useIndicator;
}

- (void)multiPageView:(MPMultiPageView *)multiPageView didChangeFromPage:(NSUInteger)oldPageNumber ToPage:(NSUInteger)newPageNumber
{
    if (MPPageSettingsModeSettingsOnly != self.mode) {
        BOOL pageSelected = NO;
        
        NSArray *pageNums = [self.pageRange getPages];
        
        for( NSNumber *pageNum in pageNums ) {
            if( [pageNum integerValue] == newPageNumber ) {
                pageSelected = YES;
                break;
            }
        }
        
        [self updateSelectedPageIcon:pageSelected];
        
        if (MPPageSettingsModePrintFromQueue == self.mode  &&  self.printLaterJobs.count >= newPageNumber) {
            [self configureSettingsForPrintLaterJob:self.printLaterJobs[newPageNumber-1]];
            self.blackAndWhiteModeSwitch.on = self.delegateManager.blackAndWhite;
        }

        if (self.previewViewController) {
            [self.previewViewController positionPageSelectionMark];
        } else {
            [self positionPageSelectionMark];
        }
    }
}

- (void)multiPageView:(MPMultiPageView *)multiPageView didSingleTapPage:(NSUInteger)pageNumber
{
    if (MPPageSettingsModeSettingsOnly != self.mode && !self.actionInProgress) {
        [self respondToMultiPageViewAction];
    }
}

- (CGFloat)multiPageView:(MPMultiPageView *)multiPageView shrinkPageVertically:(NSInteger)pageNum
{
    CGFloat verticalShrink = 0.0;
    
    // we shrink the space vertically if the page selection mark will be present
    if (self.printItem.numberOfPages > 1) {
        verticalShrink = 10;
    }
    
    return verticalShrink;
}

#pragma mark - UIGestureRecognizerDelegate

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer
{
    return NO;
}

#pragma mark - MPPrintManagerDelegate

- (void)didFinishPrintJob:(UIPrintInteractionController *)printController completed:(BOOL)completed error:(NSError *)error
{
    if (error) {
        MPLogError(@"Print error: %@", error);
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        MPPrintItem *nextItem = [self.itemsToPrint firstObject];
        NSNumber *blackAndWhite = [self.blackAndWhiteSelections firstObject];
        MPPageRange *pageRange = [self.pageRanges firstObject];
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
        
        MPPrintSettingsTableViewController *vc = (MPPrintSettingsTableViewController *)segue.destinationViewController;
        vc.printSettings = self.delegateManager.printSettings;
        vc.useDefaultPrinter = (MPPageSettingsModePrintFromQueue == self.mode);
        vc.delegate = self.delegateManager;
    } else if ([segue.identifier isEqualToString:@"PaperSizeSegue"]) {
        
        MPPaperSizeTableViewController *vc = (MPPaperSizeTableViewController *)segue.destinationViewController;
        vc.currentPaper = self.delegateManager.printSettings.paper;
        vc.delegate = self.delegateManager;
    } else if ([segue.identifier isEqualToString:@"PaperTypeSegue"]) {
        
        MPPaperTypeTableViewController *vc = (MPPaperTypeTableViewController *)segue.destinationViewController;
        vc.currentPaper = self.delegateManager.printSettings.paper;
        vc.delegate = self.delegateManager;
    }
}

#pragma mark - Notifications

- (void)handleDidCheckPrinterAvailability:(NSNotification *)notification
{
    MPLogInfo(@"handleDidCheckPrinterAvailability: %@", notification);
    
    BOOL available = [[notification.userInfo objectForKey:kMPPrinterAvailableKey] boolValue];
    
    if ( available ) {
        [self printerIsAvailable];
    } else {
        [self printerNotAvailable];
    }
    
    [self reloadPrinterSelectionSection];
    [self reloadPrintSettingsSection];
}

#pragma mark - Wi-Fi handling

- (void)connectionEstablished:(NSNotification *)notification
{
    [self configurePrintButton];
    [self refreshPrinterStatus:nil];
}

- (void)connectionLost:(NSNotification *)notification
{
    [self configurePrintButton];
    [[MPWiFiReachability sharedInstance] noPrintingAlert];
    [self refreshPrinterStatus:nil];
}

- (void)configurePrintButton
{
    if ([[MPWiFiReachability sharedInstance] isWifiConnected]) {
        self.printCell.userInteractionEnabled = YES;
        self.printLabel.textColor = [self.mp.appearance.settings objectForKey:kMPMainActionActiveLinkFontColor];
    } else {
        self.printCell.userInteractionEnabled = NO;
        self.printLabel.textColor = [self.mp.appearance.settings objectForKey:kMPMainActionInactiveLinkFontColor];
    }
}

#pragma mark - Action in Progress

- (void)setActionInProgress:(BOOL)actionInProgress
{
    _actionInProgress = actionInProgress;
    dispatch_async(dispatch_get_main_queue(), ^{
        self.pageSelectionMark.userInteractionEnabled = !actionInProgress;
        self.pageSelectionExtendedArea.userInteractionEnabled = !actionInProgress;
        self.pageSelectionMark.alpha = actionInProgress ? kMPDisabledAlpha : 1.0;
        [self.tableView reloadData];
    });
}

@end
