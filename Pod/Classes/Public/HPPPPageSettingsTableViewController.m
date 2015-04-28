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
#import "HPPPDefaultSettingsManager.h"
#import "HPPPPageView.h"
#import "HPPPPaperSizeTableViewController.h"
#import "HPPPPaperTypeTableViewController.h"
#import "HPPPPrintSettingsTableViewController.h"
#import "HPPPWiFiReachability.h"
#import "HPPPPrinter.h"
#import "HPPPPrintLaterManager.h"
#import "UITableView+HPPPHeader.h"
#import "UIColor+HPPPHexString.h"
#import "UIView+HPPPAnimation.h"
#import "UIImage+HPPPResize.h"
#import "UIColor+HPPPStyle.h"
#import "NSBundle+HPPPLocalizable.h"

#define REFRESH_PRINTER_STATUS_INTERVAL_IN_SECONDS 60

#define DEFAULT_ROW_HEIGHT 44.0f
#define DEFAULT_NUMBER_OF_COPIES 1

#define PRINT_FUNCTION_SECTION 0
#define PRINTER_SELECTION_SECTION 1
#define PAPER_SELECTION_SECTION 2
#define PRINT_SETTINGS_SECTION 3
#define NUMBER_OF_COPIES_SECTION 4
#define FILTER_SECTION 5
#define SUPPORT_SECTION 6

#define PRINT_FUNCTION_ROW_INDEX 0
#define PRINTER_SELECTION_INDEX 0
#define PAPER_SIZE_ROW_INDEX 0
#define PAPER_TYPE_ROW_INDEX 1
#define PRINT_SETTINGS_ROW_INDEX 0
#define FILTER_ROW_INDEX 0

#define HPPP_DEFAULT_PRINT_JOB_NAME HPPPLocalizedString(@"Photo", @"Default job name of the print send to the printer")

#define kHPPPSelectPrinterPrompt HPPPLocalizedString(@"Select Printer", nil)
#define kPrinterDetailsNotAvailable HPPPLocalizedString(@"Not Available", @"Printer details not available")


@interface HPPPPageSettingsTableViewController () <UIPrintInteractionControllerDelegate, UIGestureRecognizerDelegate, HPPPPaperSizeTableViewControllerDelegate, HPPPPaperTypeTableViewControllerDelegate, HPPPPrintSettingsTableViewControllerDelegate, UIPrinterPickerControllerDelegate, UIAlertViewDelegate>

@property (weak, nonatomic) HPPPPageView *pageView;
@property (strong, nonatomic) HPPPDefaultSettingsManager *defaultSettingsManager;
@property (strong, nonatomic) HPPPPrintSettings *currentPrintSettings;
@property (strong, nonatomic) HPPPWiFiReachability *wifiReachability;
@property (weak, nonatomic) IBOutlet HPPPPageView *tableViewCellPageView;

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

@property (weak, nonatomic) IBOutlet UITableViewCell *pageViewCell;
@property (weak, nonatomic) IBOutlet UITableViewCell *printCell;
@property (weak, nonatomic) IBOutlet UITableViewCell *selectPrinterCell;
@property (weak, nonatomic) IBOutlet UITableViewCell *paperSizeCell;
@property (weak, nonatomic) IBOutlet UITableViewCell *paperTypeCell;
@property (weak, nonatomic) IBOutlet UITableViewCell *filterCell;
@property (weak, nonatomic) IBOutlet UITableViewCell *printSettingsCell;

@property (weak, nonatomic) IBOutlet UIBarButtonItem *cancelBarButtonItem;

@property (strong, nonatomic) UIRefreshControl *refreshControl;
@property (strong, nonatomic) NSTimer *refreshPrinterStatusTimer;

@property (nonatomic, strong) UIActivityIndicatorView *spinner;
@property (nonatomic, strong) HPPP *hppp;
@property (nonatomic, assign) NSInteger numberOfCopies;

@end

@implementation HPPPPageSettingsTableViewController

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
NSString * const kPageSettingsScreenName = @"Paper Settings Screen";

#pragma mark - UIView

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = HPPPLocalizedString(@"Page Settings", @"Title of the Page Settings Screen");
    
    self.hppp = [HPPP sharedInstance];
    self.defaultSettingsManager = [HPPPDefaultSettingsManager sharedInstance];
    
    self.navigationController.interactivePopGestureRecognizer.delegate = self;
    
    self.tableView.rowHeight = DEFAULT_ROW_HEIGHT;
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    
    if (IS_IPAD && IS_OS_8_OR_LATER) {
        self.tableView.tableHeaderView = [[UIView alloc] initWithFrame:CGRectZero];
    }
    
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
    self.numberOfCopiesLabel.text = HPPPLocalizedString(@"1 copy", nil);
    
    self.filterLabel.font = self.hppp.tableViewCellLabelFont;
    self.filterLabel.textColor = self.hppp.tableViewCellLabelColor;
    self.filterLabel.text = HPPPLocalizedString(@"Black & White mode", nil);
    
    self.pageViewCell.backgroundColor = [UIColor HPPPHPGrayBackgroundColor];
    
    HPPPPaper *paper = [[HPPPPaper alloc] initWithPaperSize:Size4x6 paperType:Photo];
    self.currentPrintSettings = [HPPPPrintSettings alloc];
    self.currentPrintSettings.paper = paper;
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
    
    [self prepareUiForIosVersion];
    [self updatePrintSettingsUI];
    [[HPPPPrinter sharedInstance] checkLastPrinterUsedAvailability];
    [self updatePageSettingsUI];
    
    if ([self.dataSource respondsToSelector:@selector(pageSettingsTableViewControllerRequestNumberOfImagesToPrint)]) {
        NSInteger numberOfJobs = [self.dataSource pageSettingsTableViewControllerRequestNumberOfImagesToPrint];
        
        self.printLabel.text = [self stringFromNumberOfImages:numberOfJobs copies:1];
    }
    
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
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self configurePrintButton];
    if (![[HPPPWiFiReachability sharedInstance] isWifiConnected]) {
        [[HPPPWiFiReachability sharedInstance] noPrintingAlert];
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
        self.pageView = self.pageViewController.pageView;
        
        if ([self.dataSource respondsToSelector:@selector(pageSettingsTableViewControllerRequestNumberOfImagesToPrint)]) {
            NSInteger numberOfJobs = [self.dataSource pageSettingsTableViewControllerRequestNumberOfImagesToPrint];
            if (numberOfJobs > 1) {
                self.pageView.mutipleImages = YES;
            }
        }
        
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

- (void)dealloc
{
    [self.refreshPrinterStatusTimer invalidate];
    self.refreshPrinterStatusTimer = nil;
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)orientation duration:(NSTimeInterval)duration
{
    if (IS_SPLIT_VIEW_CONTROLLER_IMPLEMENTATION) {
        [self setPaperSize:self.pageView animated:NO completion:nil];
    }
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
    [[HPPPPrinter sharedInstance] checkLastPrinterUsedAvailability];
}

#pragma mark - Configure UI

- (void)configurePageView
{
    if (!IS_SPLIT_VIEW_CONTROLLER_IMPLEMENTATION) {
        self.pageView = self.tableViewCellPageView;
        
        if ([self.dataSource respondsToSelector:@selector(pageSettingsTableViewControllerRequestNumberOfImagesToPrint)]) {
            NSInteger numberOfJobs = [self.dataSource pageSettingsTableViewControllerRequestNumberOfImagesToPrint];
            if (numberOfJobs > 1) {
                self.pageView.mutipleImages = YES;
            }
        }
        
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
    if (self.printFromQueue && [settings isDefaultPrinterSet]) {
        self.currentPrintSettings.printerName = settings.defaultPrinterName;
        self.currentPrintSettings.printerUrl = [NSURL URLWithString:settings.defaultPrinterUrl];
        self.currentPrintSettings.printerId = nil;
    } else {
        self.currentPrintSettings.printerName = [[NSUserDefaults standardUserDefaults] objectForKey:kHPPPLastPrinterNameSetting];
        self.currentPrintSettings.printerUrl = [NSURL URLWithString:[[NSUserDefaults standardUserDefaults] objectForKey:LAST_PRINTER_USED_URL_SETTING]];
        self.currentPrintSettings.printerId = [[NSUserDefaults standardUserDefaults] objectForKey:kHPPPLastPrinterIDSetting];
    }
    
    NSString *lastModel = [[NSUserDefaults standardUserDefaults] objectForKey:kHPPPLastPrinterModelSetting];
    self.currentPrintSettings.printerModel = lastModel;
    
    NSString *lastLocation = [[NSUserDefaults standardUserDefaults] objectForKey:kHPPPLastPrinterLocationSetting];
    self.currentPrintSettings.printerLocation = lastLocation;
    
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
        HPPPLogError(@"Couldn't get shared UIPrintInteractionController!");
        return;
    }
    
    controller.showsNumberOfCopies = NO;
    
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

#pragma mark - Stepper actions

- (IBAction)numberOfCopiesStepperTapped:(UIStepper *)sender
{
    self.numberOfCopies = sender.value;
    
    self.numberOfCopiesLabel.text = (self.numberOfCopies == 1) ? HPPPLocalizedString(@"1 copy", nil) : [NSString stringWithFormat:HPPPLocalizedString(@"%ld copies", @"Number of copies"), (long)self.numberOfCopies];
    
    if ([self.dataSource respondsToSelector:@selector(pageSettingsTableViewControllerRequestNumberOfImagesToPrint)]) {
        NSInteger numberOfJobs = [self.dataSource pageSettingsTableViewControllerRequestNumberOfImagesToPrint];
        
        self.printLabel.text = [self stringFromNumberOfImages:numberOfJobs copies:self.numberOfCopies];
    } else {
        self.printLabel.text = [self stringFromNumberOfImages:1 copies:self.numberOfCopies];
    }
}

#pragma mark - Switch actions

- (IBAction)blackAndWhiteSwitchToggled:(id)sender
{
    [self applyFilter];
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:[NSNumber numberWithInteger:self.blackAndWhiteModeSwitch.on] forKey:kHPPPLastFilterSetting];
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
        if( !self.pageView.isAnimating ) {
            HPPPSupportAction *action = self.hppp.supportActions[indexPath.row];
            if (action.url) {
                [[UIApplication sharedApplication] openURL:action.url];
            } else {
                [self presentViewController:action.viewController animated:YES completion:nil];
            }
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
    if (self.currentPrintSettings.printerUrl != nil) {
        UIPrintInteractionController *controller = [self getSharedPrintInteractionController];
        
        if (!controller) {
            HPPPLogError(@"Couldn't get shared UIPrintInteractionController!");
            return;
        }
        
        controller.showsNumberOfCopies = NO;
        
        [self createPrintJob:controller];
        
        UIPrinter *printer = [UIPrinter printerWithURL:self.currentPrintSettings.printerUrl];
        
        [controller printToPrinter:printer completionHandler:^(UIPrintInteractionController *printController, BOOL completed, NSError *error) {
            
            [self printCompleted:printController isCompleted:completed printError:error];
        }];
    }
}

- (NSString *)stringFromNumberOfImages:(NSInteger)numberOfImages copies:(NSInteger)copies
{
    NSString *result = nil;
    
    if (numberOfImages == 1) {
        result = HPPPLocalizedString(@"Print", @"Caption of the button for printing");
    } else {
        NSInteger total = numberOfImages * copies;
        
        if (total == 2) {
            result = HPPPLocalizedString(@"Print both", @"Caption of the button for printing");
        } else {
            result = [NSString stringWithFormat:HPPPLocalizedString(@"Print all %lu", @"Caption of the button for printing"), (long)total];
        }
    }
    
    return result;
}

- (void)createPrintJob:(UIPrintInteractionController *)controller
{
    // Obtain a printInfo so that we can set our printing defaults.
    UIPrintInfo *printInfo = [UIPrintInfo printInfo];
    
    // The path to the image may or may not be a good name for our print job
    // but that's all we've got.
    if (nil != self.hppp.printJobName) {
        printInfo.jobName = self.hppp.printJobName;
    } else {
        printInfo.jobName = HPPP_DEFAULT_PRINT_JOB_NAME;
    }
    
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
    
    HPPPPrintPageRenderer *renderer;
    
    if ([self.dataSource respondsToSelector:@selector(pageSettingsTableViewControllerRequestNumberOfImagesToPrint)]) {
        NSInteger numberOfJobs = [self.dataSource pageSettingsTableViewControllerRequestNumberOfImagesToPrint];
        if (numberOfJobs > 1) {
            if ([self.dataSource respondsToSelector:@selector(pageSettingsTableViewControllerRequestImagesForPaper:)]) {
                NSMutableArray *images = [self.dataSource pageSettingsTableViewControllerRequestImagesForPaper:self.currentPrintSettings.paper].mutableCopy;
                
                // Check if the images needs rotation for printing
                for (NSInteger i = 0; i < images.count; i++) {
                    UIImage *image = images[i];
                    
                    if (![image HPPPIsPortraitImage] && !(self.currentPrintSettings.paper.paperSize == SizeLetter)) {
                        [images replaceObjectAtIndex:i withObject:[image HPPPRotate]];
                    }
                }
                
                renderer = [[HPPPPrintPageRenderer alloc] initWithImages:images];
            }
        }
    }
    
    if (!renderer) {
        renderer = [[HPPPPrintPageRenderer alloc] initWithImages:@[self.image]];
    }
    
    renderer.numberOfCopies = self.numberOfCopies;
    controller.printPageRenderer = renderer;
    
    // Use this printInfo for this print job.
    controller.printInfo = printInfo;
}

- (void)printCompleted:(UIPrintInteractionController *)printController isCompleted:(BOOL)completed printError:(NSError *)error
{
    [self setLastOptionsUsedWithPrintController:printController];
    
    if (error) {
        HPPPLogError(@"FAILED! due to error in domain %@ with error code %ld", error.domain, (long)error.code);
    }
    
    if (completed) {
        if (IS_OS_8_OR_LATER) {
            [self displaySaveAsDefaultPrinter];
        }
        
        if ([self.delegate respondsToSelector:@selector(pageSettingsTableViewControllerDidFinishPrintFlow:)]) {
            [self.delegate pageSettingsTableViewControllerDidFinishPrintFlow:self];
        }
        
        if ([HPPP sharedInstance].handlePrintMetricsAutomatically) {
            NSInteger numberOfJobs = 1;
            NSString *offramp = NSStringFromClass([HPPPPrintActivity class]);
            if (self.printFromQueue) {
                offramp = kHPPPQueuePrintAction;
                if ([self.dataSource respondsToSelector:@selector(pageSettingsTableViewControllerRequestNumberOfImagesToPrint)]) {
                    numberOfJobs = [self.dataSource pageSettingsTableViewControllerRequestNumberOfImagesToPrint];
                    if (numberOfJobs > 1) {
                        offramp = kHPPPQueuePrintAllAction;
                    }
                }
            }
            for (int count = 0; count < numberOfJobs; count++) {
                [[HPPPAnalyticsManager sharedManager] trackShareEventWithOptions:@{ kHPPPOfframpKey:offramp }];
            }
        }
    }
    
    if (IS_IPAD) {
        self.cancelBarButtonItem.enabled = YES;
    }
}

- (void)displaySaveAsDefaultPrinter
{
    NSString *defaultPrinterUrl = [self.defaultSettingsManager defaultPrinterUrl];
    if (defaultPrinterUrl != nil) {
        return;
    }
    
    NSString *message = [NSString stringWithFormat:HPPPLocalizedString(@"Would you like to set the following as this app's default printer?\n\n'%@'", nil), self.currentPrintSettings.printerName];
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil
                                                    message:message
                                                   delegate:self
                                          cancelButtonTitle:HPPPLocalizedString(@"No, thanks", nil)
                                          otherButtonTitles:HPPPLocalizedString(@"Yes", nil), nil];
    [alert show];
}

- (void)setLastOptionsUsedWithPrintController:(UIPrintInteractionController *)printController;
{
    NSMutableDictionary *lastOptionsUsed = [NSMutableDictionary dictionary];
    [lastOptionsUsed setValue:self.currentPrintSettings.paper.typeTitle forKey:kHPPPPaperTypeId];
    [lastOptionsUsed setValue:self.currentPrintSettings.paper.sizeTitle forKey:kHPPPPaperSizeId];
    [lastOptionsUsed setValue:[NSNumber numberWithBool:self.blackAndWhiteModeSwitch.on] forKey:kHPPPBlackAndWhiteFilterId];
    [lastOptionsUsed setValue:[NSNumber numberWithInteger:self.numberOfCopies] forKey:kHPPPNumberOfCopies];
    
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
    [defaults setObject:self.currentPrintSettings.printerId forKey:kHPPPLastPrinterIDSetting];
    [defaults synchronize];
    
}

- (void)setPrinterDetails:(UIPrinter *)printer
{
    self.currentPrintSettings.printerUrl = printer.URL;
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

#pragma mark - UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if( kSaveDefaultPrinterIndex == buttonIndex ) {
        
        self.defaultSettingsManager.defaultPrinterName = self.currentPrintSettings.printerName;
        self.defaultSettingsManager.defaultPrinterUrl = self.currentPrintSettings.printerUrl.absoluteString;
        self.defaultSettingsManager.defaultPrinterNetwork = [HPPPAnalyticsManager wifiName];
        self.defaultSettingsManager.defaultPrinterCoordinate = [[HPPPPrintLaterManager sharedInstance] retrieveCurrentLocation];
        
        [[NSNotificationCenter defaultCenter] postNotificationName:kHPPPDefaultPrinterAddedNotification object:self userInfo:nil];
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
