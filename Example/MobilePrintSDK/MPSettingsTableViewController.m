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

#import "MPSettingsTableViewController.h"
#import "MPSelectPrintItemTableViewController.h"
#import "MPExperimentManager.h"
#import "MP+PrintLibraryVersion.h"
#import "MP.h"
#import "MPLayoutFactory.h"
#import "MPPrintItemFactory.h"
#import "MPPrintManager.h"
#import <CommonCrypto/CommonDigest.h>

@interface MPSettingsTableViewController () <UIPopoverPresentationControllerDelegate, MPPrintDelegate, MPPrintDataSource, MPSelectPrintItemTableViewControllerDelegate, MPAddPrintLaterDelegate, MPPrintManagerDelegate, MPPrintPaperDelegate>

typedef enum {
    Print,
    PrintLater,
    Share,
    DirectPrint,
    Settings
} SelectItemAction;

@property (strong, nonatomic) UIBarButtonItem *shareBarButtonItem;
@property (strong, nonatomic) UIBarButtonItem *printBarButtonItem;
@property (strong, nonatomic) UIBarButtonItem *printLaterBarButtonItem;
@property (strong, nonatomic) UIPopoverController *popover;
@property (strong, nonatomic) MPPrintItem *printItem;
@property (strong, nonatomic) MPPrintLaterJob *printLaterJob;
@property (strong, nonatomic) NSDictionary *imageFiles;
@property (strong, nonatomic) NSArray *pdfFiles;
@property (weak, nonatomic) IBOutlet UISwitch *automaticMetricsSwitch;
@property (weak, nonatomic) IBOutlet UISwitch *extendedMetricsSwitch;
@property (weak, nonatomic) IBOutlet UISwitch *appearanceTestSettingsSwitch;
@property (weak, nonatomic) IBOutlet UISegmentedControl *layoutSegmentControl;
@property (weak, nonatomic) IBOutlet UISegmentedControl *orientationSegmentControl;
@property (strong, nonatomic) IBOutletCollection(UITextField) NSArray *positionTextField;
@property (weak, nonatomic) IBOutlet UITableViewCell *showPrintQueueCell;
@property (weak, nonatomic) IBOutlet UITableViewCell *showGeoHelperCell;
@property (weak, nonatomic) IBOutlet UISegmentedControl *metricsSegmentControl;
@property (weak, nonatomic) IBOutlet UITableViewCell *automaticMetricsCell;
@property (weak, nonatomic) IBOutlet UITableViewCell *extendedMetricsCell;
@property (weak, nonatomic) IBOutlet UISwitch *printPreviewSwitch;
@property (assign, nonatomic) SelectItemAction action;
@property (weak, nonatomic) IBOutlet UISwitch *detectWiFiSwitch;
@property (weak, nonatomic) IBOutlet UISegmentedControl *showButtonsSegment;
@property (weak, nonatomic) IBOutlet UITableViewCell *directPrintCell;
@property (weak, nonatomic) IBOutlet UISegmentedControl *paperSegmentControl;
@property (weak, nonatomic) IBOutlet UISegmentedControl *verticalSegmentControl;
@property (weak, nonatomic) IBOutlet UISegmentedControl *horizontalSegmentControl;
@property (weak, nonatomic) IBOutlet UITextField *borderWidthTextField;
@property (weak, nonatomic) IBOutlet UITableViewCell *veritcalRow;
@property (weak, nonatomic) IBOutlet UITableViewCell *horizontalRow;
@property (weak, nonatomic) IBOutlet UITableViewCell *assetPositionRow;
@property (weak, nonatomic) IBOutlet UITableViewCell *borderWidthRow;
@property (weak, nonatomic) IBOutlet UILabel *SHALabel;
@property (weak, nonatomic) IBOutlet UILabel *SHAModifiedLabel;
@property (weak, nonatomic) IBOutlet UILabel *unmodifiedDeviceIdLabel;
@property (weak, nonatomic) IBOutlet UILabel *reportedDeviceIdLabel;
@property (weak, nonatomic) IBOutlet UISwitch *useUniqueIdPerAppSwitch;
@property (weak, nonatomic) IBOutlet UILabel *reportedIdTitleLabel;
@property (weak, nonatomic) IBOutlet UITableViewCell *configurePrintCell;
@property (weak, nonatomic) IBOutlet UITableViewCell *printPreviewCell;
@property (weak, nonatomic) IBOutlet UISwitch *cancelButtonPositionLeft;
@property (weak, nonatomic) IBOutlet UITextField *customLibraryVersionTextField;

@end

@implementation MPSettingsTableViewController

int const kLayoutFitIndex = 0;
int const kLayoutFillIndex = 1;
int const kLayoutStretchIndex = 2;

int const kOrientationBest = 0;
int const kOrientationPortrait = 1;
int const kOrientationLandscape = 2;

int const kVerticalTopIndex = 0;
int const kVerticalMiddleIndex = 1;
int const kVerticalBottomIndex = 2;

int const kHorizontalLeftIndex = 0;
int const kHorizontalCenterIndex = 1;
int const kHorizontalRightIndex = 2;

int const kMetricsSegmentHPIndex = 0;
int const kMetricsSegmentPartnerIndex = 1;
int const kMetricsSegmentNoneIndex = 2;
int const kMetricsSegmentErrorIndex = 3;

int const kShowButtonsSegmentDeviceIndex = 0;
int const kShowButtonsSegmentOnIndex = 1;
int const kShowButtonsSegmentOffIndex = 2;

int const kPaperSegmentUSAIndex = 0;
int const kPaperSegmentInternationalIndex = 1;
int const kPaperSegmentAllIndex = 2;

NSString * const kMetricsOfframpKey = @"off_ramp";
NSString * const kMetricsAppTypeKey = @"app_type";
NSString * const kMetricsAppTypeHP = @"HP";

NSString * const kAddJobClientNamePrefix = @"From Client";
NSString * const kAddJobShareNamePrefix = @"From Share";

NSInteger const kLengthOfSHA = 7;

#pragma mark - Initialization

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    [self configureMP];
    
    self.shareBarButtonItem = [[UIBarButtonItem alloc]
                               initWithBarButtonSystemItem:UIBarButtonSystemItemAction
                               target:self
                               action:@selector(shareTapped:)];
    
    
    self.printBarButtonItem = [[UIBarButtonItem alloc]
                               initWithImage:[UIImage imageNamed:@"printIcon"]
                               style:UIBarButtonItemStylePlain
                               target:self
                               action:@selector(printTapped:)];
    
    self.printLaterBarButtonItem = [[UIBarButtonItem alloc]
                                    initWithImage:[UIImage imageNamed:@"printLaterIcon"]
                                    style:UIBarButtonItemStylePlain
                                    target:self
                                    action:@selector(printLaterTapped:)];
    
    self.printBarButtonItem.accessibilityIdentifier = @"printBarButtonItem";
    self.printLaterBarButtonItem.accessibilityIdentifier = @"printLaterBarButtonItem";
    
    [self setBarButtonItems];
    [self.appearanceTestSettingsSwitch setOn:NO];
    [self.cancelButtonPositionLeft setOn:NO];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(connectionChanged:) name:kMPWiFiConnectionEstablished object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(connectionChanged:) name:kMPWiFiConnectionLost object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handlePrintQueueNotification:) name:kMPPrintQueueNotification object:nil];
    
    [self setDeviceInfo];
}
- (IBAction)cancelButtonSwitchChange:(id)sender {
    [MP sharedInstance].pageSettingsCancelButtonLeft = self.cancelButtonPositionLeft.isOn;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)configureMP
{
    [MP sharedInstance].printJobName = @"Print POD Example";
    
    [MP sharedInstance].handlePrintMetricsAutomatically = NO;
    
    [MP sharedInstance].defaultPaper = [[MPPaper alloc] initWithPaperSize:MPPaperSize5x7 paperType:MPPaperTypePhoto];
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]];
    UINavigationController *navigationController = (UINavigationController *)[storyboard instantiateViewControllerWithIdentifier:@"PrintInstructions"];
    
    MPSupportAction *action1 = [[MPSupportAction alloc] initWithIcon:[UIImage imageNamed:@"print-instructions"] title:@"Print Instructions" url:[NSURL URLWithString:@"http://hp.com"]];
    MPSupportAction *action2 = [[MPSupportAction alloc] initWithIcon:[UIImage imageNamed:@"print-instructions"] title:@"Print Instructions VC" viewController:navigationController];
    
    [MP sharedInstance].supportActions =  @[action1, action2];
    
    [MP sharedInstance].interfaceOptions.multiPageMaximumGutter = 0;
    [MP sharedInstance].interfaceOptions.multiPageBleed = 40;
    [MP sharedInstance].interfaceOptions.multiPageBackgroundPageScale = 0.61803399;
    [MP sharedInstance].interfaceOptions.multiPageDoubleTapEnabled = YES;
    [MP sharedInstance].interfaceOptions.multiPageZoomOnSingleTap = NO;
    [MP sharedInstance].interfaceOptions.multiPageZoomOnDoubleTap = YES;
    
    [self configurePaper];
    [MP sharedInstance].printPaperDelegate = self;
}

#pragma mark - Papers

- (void)configurePaper
{
    [self configurePhotoStripPaper];
    [self setSupportedPaper];
}

- (NSArray *)paperList
{
    NSArray *papers = [MPPaper availablePapers];
    [MP sharedInstance].defaultPaper = [[MPPaper alloc] initWithPaperSize:MPPaperSize4x6 paperType:MPPaperTypePhoto];
    if (kPaperSegmentUSAIndex == self.paperSegmentControl.selectedSegmentIndex) {
        [MP sharedInstance].defaultPaper = [MPPaper standardUSADefaultPaper];
        NSMutableArray *standardPapers = [NSMutableArray arrayWithArray:[MPPaper standardUSAPapers]];
        MPPaper *paper3Up = [[MPPaper alloc] initWithPaperSize:MPPaperSize5x7 paperType:k3UpPaperTypeId];
        papers = [standardPapers arrayByAddingObject:paper3Up];
    } else if (kPaperSegmentInternationalIndex == self.paperSegmentControl.selectedSegmentIndex) {
        [MP sharedInstance].defaultPaper = [MPPaper standardInternationalDefaultPaper];
        papers = [MPPaper standardInternationalPapers];
    }
    return papers;
}

- (void)setSupportedPaper
{
    [MP sharedInstance].supportedPapers = [self paperList];
}

- (NSArray *)papersWithSizes:(NSArray *)sizes
{
    NSMutableArray *papers = [NSMutableArray array];
    for (MPPaper *paper in [MPPaper availablePapers]) {
        if ([sizes containsObject:[NSNumber numberWithUnsignedInteger:paper.paperSize]]) {
            [papers addObject:paper];
        }
    }
    return papers;
}

- (IBAction)paperSegmentChanged:(id)sender {
    [self setSupportedPaper];
}

#pragma mark - Navigation

- (BOOL)shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender
{
    BOOL perform = YES;
    if ([identifier isEqualToString:@"Print Settings"] && !self.printPreviewSwitch.on) {
        perform = NO;
        self.action = Settings;
        [self doActivityWithPrintItem:nil];
    }
    return perform;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"Select Print Item"] ||
        [segue.identifier isEqualToString:@"Select Share Item"] ||
        [segue.identifier isEqualToString:@"Select Direct Print Item"] ||
        [segue.identifier isEqualToString:@"Print Settings"]) {
        NSString *title = @"Print Item";
        SelectItemAction action = Print;
        if ([segue.identifier isEqualToString:@"Select Share Item"]) {
            title = @"Share Item";
            action = Share;
        } else if ([segue.identifier isEqualToString:@"Select Direct Print Item"]) {
            title = @"Direct Print Item";
            action = DirectPrint;
        } else if ([segue.identifier isEqualToString:@"Print Settings"]) {
            title = @"Preview Item";
            action = Settings;
        }
        
        UINavigationController *navController = (UINavigationController *)segue.destinationViewController;
        [self prepareForPrint:navController title:title action:action];
    }
}

#pragma mark - Bar button items

- (void)setBarButtonItems
{
    [[MPExperimentManager sharedInstance] updateVariationsWithDeviceID:[self userUniqueIdentifier]];
    
    NSMutableArray *icons = [NSMutableArray arrayWithArray:@[ self.shareBarButtonItem]];
    
    if (
        kShowButtonsSegmentOnIndex == self.showButtonsSegment.selectedSegmentIndex ||
        (kShowButtonsSegmentDeviceIndex == self.showButtonsSegment.selectedSegmentIndex && [MPExperimentManager sharedInstance].showPrintIcon)) {
        
        if (self.detectWiFiSwitch.on) {
            if ([[MP sharedInstance] isWifiConnected]) {
                [icons addObjectsFromArray:@[ self.printBarButtonItem ]];
            } else if (IS_OS_8_OR_LATER) {
                [icons addObjectsFromArray:@[ self.printLaterBarButtonItem ]];
            }
        } else {
            [icons addObjectsFromArray:@[ self.printBarButtonItem]];
            if (IS_OS_8_OR_LATER) {
                [icons addObjectsFromArray:@[ self.printLaterBarButtonItem]];
            }
        }
    }
    
    self.navigationItem.rightBarButtonItems = icons;
}

- (IBAction)showButtonsSegmentChanged:(id)sender {
    [self setBarButtonItems];
}

- (IBAction)detectWiFiSwitchChanged:(id)sender {
    [self setBarButtonItems];
}

- (void)connectionChanged:(NSNotification *)notification
{
    [self setBarButtonItems];
}

#pragma mark - Print

- (void)printTapped:(id)sender
{
    [self printAction:Print];
}

- (void)printLaterTapped:(id)sender
{
    [self printAction:PrintLater];
}

- (void) printAction:(SelectItemAction)action
{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]];
    UINavigationController *navigationController = (UINavigationController *)[storyboard instantiateViewControllerWithIdentifier:@"SelectPrintItemNavigationController"];
    [self prepareForPrint:navigationController title:@"Print Item" action:action];
    [self presentViewController:navigationController animated:YES completion:nil];
}

- (void)prepareForPrint:(UINavigationController *)navigationController title:(NSString *)title action:(SelectItemAction)action
{
    self.action = action;
    MPSelectPrintItemTableViewController *vc = (MPSelectPrintItemTableViewController *)navigationController.topViewController;
    vc.delegate = self;
    vc.navigationItem.title = title;
}

- (void)preparePrintLaterJobWithName:(NSString *)name
{
    NSString *printLaterJobNextAvailableId = [[MP sharedInstance] nextPrintJobId];
    self.printLaterJob = [[MPPrintLaterJob alloc] init];
    self.printLaterJob.id = printLaterJobNextAvailableId;
    self.printLaterJob.name = [NSString stringWithFormat:@"%@ (basic)", name];
    self.printLaterJob.date = [NSDate date];
    self.printLaterJob.printItems = [self printItemsForAsset:self.printItem.printAsset];
    if (self.extendedMetricsSwitch.on) {
        self.printLaterJob.name = [NSString stringWithFormat:@"%@ (extended)", name];
        NSMutableDictionary *metrics = [NSMutableDictionary dictionaryWithDictionary:@{ kMetricsAppTypeKey:kMetricsAppTypeHP }];
        [metrics addEntriesFromDictionary:[self photoSourceMetrics]];
        self.printLaterJob.extra = metrics;
    }
    
    NSMutableDictionary *customAnalytics = [self.printLaterJob.customAnalytics mutableCopy];
    [customAnalytics setObject:name forKey:@"PrintLaterJobName"];
    [self.printLaterJob setCustomAnalytics:customAnalytics];
}

#pragma mark - Sharing

- (void)shareTapped:(id)sender
{
    self.action = Share;
    [self doActivityWithPrintItem:[MPPrintItemFactory printItemWithAsset:[self randomImage]]];
}

- (void)shareItem
{
    NSString *bundlePath = [NSString stringWithFormat:@"%@/MobilePrintSDK.bundle", [NSBundle mainBundle].bundlePath];
    NSLog(@"Bundle %@", bundlePath);
    
    MPPrintActivity *printActivity = [[MPPrintActivity alloc] init];
    printActivity.dataSource = self;
    
    NSArray *applicationActivities = nil;
    if (IS_OS_8_OR_LATER) {
        [self preparePrintLaterJobWithName:kAddJobShareNamePrefix];
        MPPrintLaterActivity *printLaterActivity = [[MPPrintLaterActivity alloc] init];
        printLaterActivity.printLaterJob = self.printLaterJob;
        applicationActivities = @[printActivity, printLaterActivity];
    } else {
        applicationActivities = @[printActivity];
    }
    
    NSArray *activitiesItems = self.printItem.activityItems;
    
    UIActivityViewController *activityViewController = [[UIActivityViewController alloc] initWithActivityItems:activitiesItems applicationActivities:applicationActivities];
    
    [activityViewController setValue:@"My HP Greeting Card" forKey:@"subject"];
    
    activityViewController.excludedActivityTypes = @[UIActivityTypeCopyToPasteboard,
                                                     UIActivityTypePostToWeibo,
                                                     UIActivityTypePostToTencentWeibo,
                                                     UIActivityTypeAddToReadingList,
                                                     UIActivityTypePrint,
                                                     UIActivityTypeAssignToContact,
                                                     UIActivityTypePostToVimeo];
    
    activityViewController.completionHandler = ^(NSString *activityType, BOOL completed) {
        NSLog(@"completed dialog - activity: %@ - finished flag: %d", activityType, completed);
        BOOL printActivity = [activityType isEqualToString:[[MPPrintActivity alloc] init].activityType];
        BOOL printLaterActivity = [activityType isEqualToString:[[MPPrintLaterActivity alloc] init].activityType];
        if (completed) {
            MPPrintItem *printItem = self.printItem;
            NSString *offramp = activityType;
            if (printActivity) {
                offramp = [self.printItem.extra objectForKey:kMetricsOfframpKey];
            } else if (printLaterActivity) {
                offramp = [self.printLaterJob.extra objectForKey:kMetricsOfframpKey];
                printItem = self.printLaterJob.defaultPrintItem;
                printItem.extra = self.printLaterJob.extra;
                [[MP sharedInstance] presentPrintQueueFromController:self animated:YES completion:nil];
            }
            if (self.extendedMetricsSwitch.on) {
                NSMutableDictionary *metrics = [NSMutableDictionary dictionaryWithDictionary:@{ kMetricsOfframpKey:offramp }];
                [metrics addEntriesFromDictionary:printItem.extra];
                printItem.extra = metrics;
                [self processMetricsForPrintItem:printItem];
            }
        }
    };
    
    if (IS_IPAD && !IS_OS_8_OR_LATER) {
        self.popover = [[UIPopoverController alloc] initWithContentViewController:activityViewController];
        [self.popover presentPopoverFromBarButtonItem:self.shareBarButtonItem permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
    } else {
        if (IS_OS_8_OR_LATER) {
            activityViewController.popoverPresentationController.barButtonItem = self.shareBarButtonItem;
            activityViewController.popoverPresentationController.delegate = self;
        }
        
        [self presentViewController:activityViewController animated:YES completion:nil];
    }
}

#pragma mark - MPPrintDelegate

- (void)didFinishPrintFlow:(UIViewController *)printViewController;
{
    [printViewController dismissViewControllerAnimated:YES completion:nil];
    [self processMetricsForPrintItem:self.printItem];
}

- (void)didCancelPrintFlow:(UIViewController *)printViewController;
{
    [printViewController dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - MPPrintDataSource

- (void)printingItemForPaper:(MPPaper *)paper withCompletion:(void (^)(MPPrintItem *))completion
{
    if (completion) {
        self.printItem.layout = [self layoutForPaper:paper];
        completion(self.printItem);
    }
}

- (void)previewImageForPaper:(MPPaper *)paper withCompletion:(void (^)(UIImage *))completion
{
    if (completion) {
        UIImage *image = [self.printItem previewImageForPaper:paper];
        if (image) {
            completion(image);
        } else {
            NSLog(@"Unable to determine preview image for printing item %@", self.printItem);
        }
    }
}

- (NSInteger)numberOfPrintingItems
{
    return 1;
}

- (NSArray *)printingItemsForPaper:(MPPaper *)paper
{
    self.printItem.layout = [self layoutForPaper:paper];
    return @[ self.printItem ];
}

#pragma mark - UIPopoverPresentationControllerDelegate

// NOTE: The implementation of this delegate with the default value is a workaround to compensate an error in the new popover presentation controller of the SDK 8. This fix correct the case where if the user keep tapping repeatedly the share button in an iPad iOS 8, the app goes back to the first screen.
- (BOOL)popoverPresentationControllerShouldDismissPopover:(UIPopoverPresentationController *)popoverPresentationController
{
    return YES;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (!IS_OS_8_OR_LATER && [self iOS7NotSupportedCell:cell]) {
        cell.alpha = 0.5;
        cell.userInteractionEnabled = NO;
    }
}

- (BOOL)iOS7NotSupportedCell:(UITableViewCell *)cell
{
    return (
            cell == self.showPrintQueueCell ||
            cell == self.showGeoHelperCell ||
            cell == self.directPrintCell ||
            cell == self.configurePrintCell ||
            cell == self.printPreviewCell
            );
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *selectedCell = [tableView cellForRowAtIndexPath:indexPath];
    if (selectedCell == self.showPrintQueueCell) {
        [self showPrintQueue];
    } else if (selectedCell == self.showGeoHelperCell) {
        [self showGeoHelper];
    } else if (selectedCell == self.automaticMetricsCell) {
        [self toggleMetricsSwitch:self.automaticMetricsSwitch];
    } else if (selectedCell == self.extendedMetricsCell) {
        [self toggleMetricsSwitch:self.extendedMetricsSwitch];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [super tableView:tableView cellForRowAtIndexPath:indexPath];
    return cell.hidden ? 0.0 : tableView.rowHeight;
}

#pragma mark - Metrics

- (IBAction)metricsSegmentChanged:(id)sender {
    [self setSwitchesFromSegment];
}

- (IBAction)automaticMetricsChanged:(id)sender {
    [self setSegmentFromSwitches];
}

- (IBAction)extendedMetricsChanged:(id)sender {
    [self setSegmentFromSwitches];
}

- (void)toggleMetricsSwitch:(UISwitch *)metricsSwitch
{
    [metricsSwitch setOn:!metricsSwitch.on animated:true];
    [self setSegmentFromSwitches];
}

- (void)setSwitchesFromSegment
{
    BOOL automated = NO;
    BOOL extended = NO;
    
    if (kMetricsSegmentHPIndex == self.metricsSegmentControl.selectedSegmentIndex) {
        extended = YES;
    } else if (kMetricsSegmentPartnerIndex == self.metricsSegmentControl.selectedSegmentIndex) {
        automated = YES;
    } else if (kMetricsSegmentErrorIndex == self.metricsSegmentControl.selectedSegmentIndex) {
        automated = YES;
        extended = YES;
    }
    
    [self.automaticMetricsSwitch setOn:automated animated:YES];
    [self.extendedMetricsSwitch setOn:extended animated:YES];
    [MP sharedInstance].handlePrintMetricsAutomatically = self.automaticMetricsSwitch.on;
}

- (void)setSegmentFromSwitches
{
    if (!self.automaticMetricsSwitch.on && self.extendedMetricsSwitch.on) {
        self.metricsSegmentControl.selectedSegmentIndex = kMetricsSegmentHPIndex;
    } else if (self.automaticMetricsSwitch.on && !self.extendedMetricsSwitch.on) {
        self.metricsSegmentControl.selectedSegmentIndex = kMetricsSegmentPartnerIndex;
    } else if (!self.automaticMetricsSwitch.on && !self.extendedMetricsSwitch.on) {
        self.metricsSegmentControl.selectedSegmentIndex = kMetricsSegmentNoneIndex;
    } else if (self.automaticMetricsSwitch.on && self.extendedMetricsSwitch.on){
        self.metricsSegmentControl.selectedSegmentIndex = kMetricsSegmentErrorIndex;
    }
    
    [MP sharedInstance].handlePrintMetricsAutomatically = self.automaticMetricsSwitch.on;
}

- (NSDictionary *)photoSourceMetrics
{
    return [NSDictionary dictionaryWithObjectsAndKeys:
            @"facebook", @"photo_source",
            @"1234567890", @"user_id",
            @"Samply McSampleson", @"user_name", nil];
}

- (void)processMetricsForPrintItem:(MPPrintItem *)printItem
{
    if (self.extendedMetricsSwitch.on) {
        NSMutableDictionary *metrics = [NSMutableDictionary dictionaryWithDictionary:@{ kMetricsAppTypeKey:kMetricsAppTypeHP }];
        [metrics addEntriesFromDictionary:printItem.extra];
        [metrics addEntriesFromDictionary:[self photoSourceMetrics]];
        [[NSNotificationCenter defaultCenter] postNotificationName:kMPShareCompletedNotification object:self.printItem userInfo:metrics];
    }
}

- (void)handlePrintQueueNotification:(NSNotification *)notification
{
    if (self.extendedMetricsSwitch.on) {
        NSString *action = [notification.object objectForKey:kMPPrintQueueActionKey];
        MPPrintLaterJob *job = [notification.object objectForKey:kMPPrintQueueJobKey];
        MPPrintItem *printItem = [notification.object objectForKey:kMPPrintQueuePrintItemKey];
        NSMutableDictionary *metrics = [NSMutableDictionary dictionaryWithDictionary:@{ kMetricsOfframpKey:action, kMetricsAppTypeKey:kMetricsAppTypeHP }];
        [metrics addEntriesFromDictionary:job.extra];
        
        NSMutableDictionary *objects = [[NSMutableDictionary alloc] init];
        [objects setObject:job forKey:kMPPrintQueueJobKey];
        [objects setObject:printItem forKey:kMPPrintQueuePrintItemKey];
        
        [[NSNotificationCenter defaultCenter] postNotificationName:kMPShareCompletedNotification object:objects userInfo:metrics];
    }
}

#pragma mark - Print Queue

- (void)showPrintQueue
{
    [[MP sharedInstance] presentPrintQueueFromController:self animated:YES completion:nil];
}

- (void)populatePrintQueue
{
    [[MP sharedInstance] clearQueue];
    
    int jobCount = 5;
    
    for (int idx = 0; idx < jobCount; idx++) {
        
        NSString *jobID = [[MP sharedInstance] nextPrintJobId];
        
        MPPrintLaterJob *job = [[MPPrintLaterJob alloc] init];
        job.id = jobID;
        job.name = [NSString stringWithFormat:@"Print Job #%d", idx + 1];
        job.date = [NSDate date];
        job.printItems = [self printItemsForAsset:[self randomImage]];
        
        [[MP sharedInstance] addJobToQueue:job];
    }
}

- (UIImage *)randomImage
{
    NSArray *sampleImages = @[
                              @"Balloons",
                              @"Cat",
                              @"Dog",
                              @"Earth",
                              @"Flowers",
                              @"Focus on Quality",
                              @"Galaxy",
                              @"Garden Path",
                              @"Quality Seal",
                              @"Soccer Ball"
                              ];
    int picNumber = arc4random_uniform((unsigned int)sampleImages.count);
    NSString *picName = [NSString stringWithFormat:@"%@.jpg", [sampleImages objectAtIndex:picNumber]];
    UIImage *image = [UIImage imageNamed:picName];
    return image;
}

#pragma mark - Geo Helper

- (void)showGeoHelper
{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"MP" bundle:[NSBundle bundleForClass:[MP class]]];
    UINavigationController *nc = (UINavigationController *)[storyboard instantiateViewControllerWithIdentifier:@"MPPrintLaterHelperNavigationController"];
    [self presentViewController:nc animated:YES completion:nil];
}

#pragma mark - MPSelectPrintItemTableViewControllerDelegate

- (void)didSelectPrintItem:(MPPrintItem *)printItem
{
    [self doActivityWithPrintItem:printItem];
}

#pragma mark - Activity

- (void)doActivityWithPrintItem:(MPPrintItem *)printItem
{
    [self setCustomLibraryVersion];
    
    self.printItem = printItem;
    if (Share == self.action) {
        [self shareItem];
    } else if (DirectPrint == self.action) {
        
        MPPrintManager *printManager = [[MPPrintManager alloc] init];
        printManager.delegate = self;
        
        if( printManager.currentPrintSettings.paper ) {
            printItem.layout = [self layoutForPaper:printManager.currentPrintSettings.paper];
        }
        
        NSError *error;
        [printManager print:printItem
                  pageRange:nil
                  numCopies:1
                      error:&error];
        
        if (MPPrintManagerErrorNone != error.code) {
            NSString *reason;
            switch (error.code) {
                case MPPrintManagerErrorNoPaperType:
                    reason = @"No paper type selected";
                    break;
                case MPPrintManagerErrorNoPrinterUrl:
                    reason = @"No printer URL";
                    break;
                case MPPrintManagerErrorPrinterNotAvailable:
                    reason = @"Printer not available";
                    break;
                case MPPrintManagerErrorDirectPrintNotSupported:
                    reason = @"Direct print is not supported";
                    break;
                case MPPrintManagerErrorUnknown:
                    reason = @"Unknown error";
                    break;
                default:
                    break;
            }
            [[[UIAlertView alloc] initWithTitle:@"Direct Print Failed"
                                        message:[NSString stringWithFormat:@"Reason: %@",reason]
                                       delegate:nil
                              cancelButtonTitle:@"OK"
                              otherButtonTitles:nil] show];
        }
    } else if (PrintLater == self.action) {
        [self preparePrintLaterJobWithName:kAddJobClientNamePrefix];
        UIViewController *vc = [[MP sharedInstance] printLaterViewControllerWithDelegate:self printLaterJob:self.printLaterJob];
        [self presentViewController:vc animated:YES completion:nil];
    }
    else {
        BOOL settingsInProgress = (Settings == self.action);
        UIViewController *vc = [[MP sharedInstance] printViewControllerWithDelegate:self dataSource:self printItem:printItem fromQueue:NO settingsOnly:settingsInProgress];
        [self presentViewController:vc animated:YES completion:nil];
    }
}

#pragma mark - Layout

- (IBAction)layoutValueChanged:(id)sender {
    
    BOOL hideAlignmentRows = kLayoutFitIndex != self.layoutSegmentControl.selectedSegmentIndex;
    self.veritcalRow.hidden = hideAlignmentRows;
    self.horizontalRow.hidden = hideAlignmentRows;
    
    BOOL hidePositionAdjustmentRows = kLayoutFillIndex == self.layoutSegmentControl.selectedSegmentIndex;
    self.assetPositionRow.hidden = hidePositionAdjustmentRows;
    self.borderWidthRow.hidden = hidePositionAdjustmentRows;
    
    [self.tableView reloadData];
}

- (MPLayout *)layoutForPaper:(MPPaper *)paper
{
    NSString *layoutType = [MPLayoutFit layoutType];
    if (kLayoutFillIndex == self.layoutSegmentControl.selectedSegmentIndex) {
        layoutType = [MPLayoutFill layoutType];
    } else if (kLayoutStretchIndex == self.layoutSegmentControl.selectedSegmentIndex) {
        layoutType = [MPLayoutStretch layoutType];
    }
    
    MPLayoutOrientation orientation = MPLayoutOrientationBestFit;
    if (kOrientationLandscape == self.orientationSegmentControl.selectedSegmentIndex) {
        orientation = MPLayoutOrientationLandscape;
    } else if (kOrientationPortrait == self.orientationSegmentControl.selectedSegmentIndex) {
        orientation = MPLayoutOrientationPortrait;
    }
    
    CGRect assetPosition = [MPLayout completeFillRectangle];
    CGFloat x = [((UITextField *)self.positionTextField[0]).text floatValue];
    CGFloat y = [((UITextField *)self.positionTextField[1]).text floatValue];
    CGFloat width = [((UITextField *)self.positionTextField[2]).text floatValue];
    CGFloat height = [((UITextField *)self.positionTextField[3]).text floatValue];
    if (width > 0 && height > 0) {
        assetPosition = CGRectMake(x, y, width, height);
    }
    
    CGFloat borderWidth = [self.borderWidthTextField.text floatValue];
    
    MPLayout *layout = [MPLayoutFactory layoutWithType:layoutType orientation:orientation assetPosition:assetPosition];
    layout.borderInches = borderWidth;
    
    if ([layoutType isEqualToString:[MPLayoutFit layoutType]]) {
        
        MPLayoutHorizontalPosition horizontalPosition = MPLayoutHorizontalPositionMiddle;
        if (kHorizontalLeftIndex == self.horizontalSegmentControl.selectedSegmentIndex) {
            horizontalPosition = MPLayoutHorizontalPositionLeft;
        } else if (kHorizontalRightIndex == self.horizontalSegmentControl.selectedSegmentIndex) {
            horizontalPosition = MPLayoutHorizontalPositionRight;
        }
        
        MPLayoutVerticalPosition verticalPosition = MPLayoutVerticalPositionMiddle;
        if (kVerticalTopIndex == self.verticalSegmentControl.selectedSegmentIndex) {
            verticalPosition = MPLayoutVerticalPositionTop;
        } else if (kVerticalBottomIndex == self.verticalSegmentControl.selectedSegmentIndex) {
            verticalPosition = MPLayoutVerticalPositionBottom;
        }
        
        MPLayoutFit *fitLayout = (MPLayoutFit *)layout;
        fitLayout.horizontalPosition = horizontalPosition;
        fitLayout.verticalPosition = verticalPosition;
    }
    
    return layout;
}

- (MPLayout *)centeredlayoutForPaper:(MPPaper *)paper andImageSize:(CGSize)imageSize
{
    CGFloat horizontalScale = paper.width / imageSize.width;
    CGFloat verticalScale = paper.height / imageSize.height;
    CGFloat scale = fminf(1.0, fminf(horizontalScale, verticalScale));
    CGSize scaledImageSize = CGSizeApplyAffineTransform(imageSize, CGAffineTransformMakeScale(scale, scale));
    CGPoint scaledImageOrigin = CGPointMake(paper.width / 2 - scaledImageSize.width / 2.0, paper.height / 2.0 - scaledImageSize.height / 2.0);
    
    CGRect assetPosition = CGRectMake(
                                      scaledImageOrigin.x / paper.width * 100.0,
                                      scaledImageOrigin.y / paper.height * 100.0,
                                      scaledImageSize.width / paper.width * 100.0,
                                      scaledImageSize.height / paper.height * 100.0);
    
    MPLayoutOrientation orientation = imageSize.width > imageSize.height ? MPLayoutOrientationLandscape : MPLayoutOrientationPortrait;
    return [MPLayoutFactory layoutWithType:[MPLayoutStretch layoutType] orientation:orientation assetPosition:assetPosition];
}

- (CGRect)defaultPositionForSize:(NSUInteger)paperSize
{
    MPPaper *letterPaper = [[MPPaper alloc] initWithPaperSize:paperSize paperType:MPPaperTypePlain];
    MPPaper *defaultPaper = [MP sharedInstance].defaultPaper;
    CGFloat maxDimension = fmaxf(defaultPaper.width, defaultPaper.height);
    CGFloat width = maxDimension / letterPaper.width * 100.0f;
    CGFloat height = maxDimension / letterPaper.height * 100.0f;
    CGFloat x = (100.0f - width) / 2.0f;
    CGFloat y = (100.0f - height) / 2.0f;
    return CGRectMake(x, y, width, height);
}

- (NSDictionary *)printItemsForAsset:(id)asset
{
    NSMutableDictionary *printItems = [NSMutableDictionary dictionary];
    for (MPPaper *supportedPaper in [MPPaper availablePapers]) {
        if (nil == [printItems objectForKey:supportedPaper.sizeTitle]) {
            MPPrintItem *printItem = [MPPrintItemFactory printItemWithAsset:asset];
            printItem.layout = [self layoutForPaper:supportedPaper];
            [printItems addEntriesFromDictionary:@{ supportedPaper.sizeTitle:printItem }];
        }
    }
    return printItems;
}

#pragma mark - MPAddPrintLaterDelegate

- (void)didFinishAddPrintLaterFlow:(UIViewController *)addPrintLaterJobTableViewController
{
    NSDictionary *values = @{
                             kMPPrintQueueActionKey:[self.printLaterJob.extra objectForKey:kMetricsOfframpKey],
                             kMPPrintQueueJobKey:self.printLaterJob,
                             kMPPrintQueuePrintItemKey:[self.printLaterJob.printItems objectForKey:[MP sharedInstance].defaultPaper.sizeTitle] };
    [[NSNotificationCenter defaultCenter] postNotificationName:kMPPrintQueueNotification object:values];
    [self dismissViewControllerAnimated:YES completion:^{
        [[MP sharedInstance] presentPrintQueueFromController:self animated:YES completion:nil];
    }];
}

- (void)didCancelAddPrintLaterFlow:(UIViewController *)addPrintLaterJobTableViewController
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - MPPrintManagerDelegate

- (void)didFinishPrintJob:(UIPrintInteractionController *)printController completed:(BOOL)completed error:(NSError *)error
{
    if (!completed) {
        MPLogInfo(@"Print was NOT completed");
    }
    
    if (error) {
        MPLogWarn(@"Print error:  %@", error);
    }
    
    if (completed && !error) {
        [self processMetricsForPrintItem:self.printItem];
    }
}

#pragma mark - Pod Appearance Testing
- (IBAction)appearanceSettingsChanged:(id)sender {
    static NSDictionary *defaultSettings = nil;
    
    MP *mp = [MP sharedInstance];
    
    if( self.appearanceTestSettingsSwitch.on ) {
        defaultSettings = mp.appearance.settings;
        mp.appearance.settings = [self testSettings];
    } else {
        [MP sharedInstance].appearance.settings = defaultSettings;
    }
}

- (NSDictionary *)testSettings
{
    NSString *regularFont = @"Baskerville-Bold";
    NSString *lightFont   = @"Baskerville-Italic";
    
    return @{// General
             kMPGeneralBackgroundColor:             [UIColor colorWithRed:0x00/255.0F green:0x00/255.0F blue:0xFF/255.0F alpha:1.0F],
             kMPGeneralBackgroundPrimaryFont:       [UIFont fontWithName:regularFont size:14],
             kMPGeneralBackgroundPrimaryFontColor:  [UIColor colorWithRed:0xFF/255.0F green:0x00/255.0F blue:0x00/255.0F alpha:1.0F],
             kMPGeneralBackgroundSecondaryFont:     [UIFont fontWithName:lightFont size:12],
             kMPGeneralBackgroundSecondaryFontColor:[UIColor colorWithRed:0x00/255.0F green:0xFF/255.0F blue:0x00/255.0F alpha:1.0F],
             kMPGeneralTableSeparatorColor:         [UIColor colorWithRed:0xFF/255.0F green:0.00/255.0F blue:0x00/255.0F alpha:1.0F],
             
             // Selection Options
             kMPSelectionOptionsBackgroundColor:         [UIColor colorWithRed:0xFF/255.0F green:0xA5/255.0F blue:0x00/255.0F alpha:1.0F],
             kMPSelectionOptionsPrimaryFont:             [UIFont fontWithName:regularFont size:16],
             kMPSelectionOptionsPrimaryFontColor:        [UIColor colorWithRed:0xFF/255.0F green:0x00/255.0F blue:0x00/255.0F alpha:1.0F],
             kMPSelectionOptionsSecondaryFont:           [UIFont fontWithName:regularFont size:16],
             kMPSelectionOptionsSecondaryFontColor:      [UIColor colorWithRed:0x00/255.0F green:0xFF/255.0F blue:0x00/255.0F alpha:1.0F],
             kMPSelectionOptionsLinkFont:                [UIFont fontWithName:regularFont size:16],
             kMPSelectionOptionsLinkFontColor:           [UIColor colorWithRed:0x00/255.0F green:0x00/255.0F blue:0xFF/255.0F alpha:1.0F],
             kMPSelectionOptionsDisclosureIndicatorImage:[UIImage imageNamed:@"MPCheck"],
             kMPSelectionOptionsCheckmarkImage:          [UIImage imageNamed:@"MPArrow"],
             
             // Job Settings
             kMPJobSettingsBackgroundColor:    [UIColor colorWithRed:0x00/255.0F green:0xFF/255.0F blue:0x00/255.0F alpha:1.0F],
             kMPJobSettingsPrimaryFont:        [UIFont fontWithName:regularFont size:16],
             kMPJobSettingsPrimaryFontColor:   [UIColor colorWithRed:0xFF/255.0F green:0x00/255.0F blue:0x00/255.0F alpha:1.0F],
             kMPJobSettingsSecondaryFont:      [UIFont fontWithName:regularFont size:12],
             kMPJobSettingsSecondaryFontColor: [UIColor colorWithRed:0x00/255.0F green:0x00/255.0F blue:0xFF/255.0F alpha:1.0F],
             kMPJobSettingsSelectedPageIcon:   [UIImage imageNamed:@"MPUnselected.png"],
             kMPJobSettingsUnselectedPageIcon: [UIImage imageNamed:@"MPSelected.png"],
             kMPJobSettingsSelectedJobIcon:    [UIImage imageNamed:@"MPInactiveCircle"],
             kMPJobSettingsUnselectedJobIcon:  [UIImage imageNamed:@"MPActiveCircle"],
             kMPJobSettingsMagnifyingGlassIcon:[UIImage imageNamed:@"MPMagnify"],
             
             // Main Action
             kMPMainActionBackgroundColor:       [UIColor colorWithRed:0x8A/255.0F green:0x2B/255.0F blue:0xE2/255.0F alpha:1.0F],
             kMPMainActionLinkFont:              [UIFont fontWithName:regularFont size:18],
             kMPMainActionActiveLinkFontColor:   [UIColor colorWithRed:0xFF/255.0F green:0x00/255.0F blue:0x00/255.0F alpha:1.0F],
             kMPMainActionInactiveLinkFontColor: [UIColor colorWithRed:0x00/255.0F green:0x00/255.0F blue:0x00/255.0F alpha:1.0F],
             
             // Queue Project Count
             kMPQueuePrimaryFont:     [UIFont fontWithName:regularFont size:16],
             kMPQueuePrimaryFontColor:[UIColor colorWithRed:0x00 green:0x00 blue:0x00 alpha:1.0F],
             
             // Form Field
             kMPFormFieldBackgroundColor:  [UIColor colorWithRed:0xFF/255.0F green:0xD7/255.0F blue:0x00/255.0F alpha:1.0F],
             kMPFormFieldPrimaryFont:      [UIFont fontWithName:regularFont size:16],
             kMPFormFieldPrimaryFontColor: [UIColor colorWithRed:0xFF/255.0F green:0x00/255.0F blue:0x00/255.0F alpha:1.0F],
             
             // Overlay
             kMPOverlayBackgroundColor:    [UIColor colorWithRed:0x8D/255.0F green:0xEE/255.0F blue:0xEE/255.0F alpha:1.0F],
             kMPOverlayBackgroundOpacity:  [NSNumber numberWithFloat:.60F],
             kMPOverlayPrimaryFont:        [UIFont fontWithName:regularFont size:16],
             kMPOverlayPrimaryFontColor:   [UIColor colorWithRed:0xFF/255.0F green:0x00/255.0F blue:0x00/255.0F alpha:1.0F],
             kMPOverlaySecondaryFont:      [UIFont fontWithName:regularFont size:14],
             kMPOverlaySecondaryFontColor: [UIColor colorWithRed:0x00/255.0F green:0xFF/255.0F blue:0x00/255.0F alpha:1.0F],
             kMPOverlayLinkFont:           [UIFont fontWithName:regularFont size:18],
             kMPOverlayLinkFontColor:      [UIColor colorWithRed:0x00/255.0F green:0x00/255.0F blue:0xFF/255.0F alpha:1.0F],
             
             // Activity
             kMPActivityPrintIcon:      [UIImage imageNamed:@"MPPrint"],
             kMPActivityPrintQueueIcon: [UIImage imageNamed:@"MPPrintLater"],
             };
}

#pragma mark - MPPrintPaperDelegate

- (BOOL)labelPrinter:(MPPrintSettings *)printSettings
{
    BOOL retValue = FALSE;
    if( nil != printSettings.printerModel ) {
        retValue = ([printSettings.printerModel rangeOfString:@"Label"].location != NSNotFound);
    }
    
    return retValue;
}

- (BOOL)hidePaperSizeForPrintSettings:(MPPrintSettings *)printSettings
{
    return [self labelPrinter:printSettings];
}

- (BOOL)hidePaperTypeForPrintSettings:(MPPrintSettings *)printSettings
{
    return [self labelPrinter:printSettings];
}

- (MPPaper *)defaultPaperForPrintSettings:(MPPrintSettings *)printSettings
{
    MPPaper *defaultPaper = [[self paperList] firstObject];
    if ([self labelPrinter:printSettings]) {
        NSUInteger paperSize = [self aspectRatio4up] ? k4UpPaperSizeId : k3UpPaperSizeId;
        defaultPaper = [[MPPaper alloc] initWithPaperSize:paperSize paperType:kLabelPaperTypeId];
    }
    
    return defaultPaper;
    
}

- (NSArray *)supportedPapersForPrintSettings:(MPPrintSettings *)printSettings
{
    NSArray *papers = [self paperList];
    
    if ([self labelPrinter:printSettings]) {
        NSUInteger paperSize = [self aspectRatio4up] ? k4UpPaperSizeId : k3UpPaperSizeId;
        papers = @[ [[MPPaper alloc] initWithPaperSize:paperSize paperType:kLabelPaperTypeId] ];
    }

    return papers;
}

- (UIPrintPaper *)printInteractionController:(UIPrintInteractionController *)printInteractionController choosePaper:(NSArray *)paperList forPrintSettings:(MPPrintSettings *)printSettings
{
    MPLogInfo(@"CHOOSE PAPER");
    return nil;
}

- (NSNumber *)printInteractionController:(UIPrintInteractionController *)printInteractionController cutLengthForPaper:(UIPrintPaper *)paper forPrintSettings:(MPPrintSettings *)printSettings
{
    MPLogInfo(@"CUT LENGTH");
    return nil; //[NSNumber numberWithFloat:printSettings.paper.height * 72.0];
}

#pragma mark - Photo strip paper

NSUInteger const k3UpPaperSizeId = 100;
NSString * const k3UpPaperSizeTitle = @"2 x 6";
CGFloat const k3UpPaperSizeWidth = 2.0; // inches
CGFloat const k3UpPaperSizeHeight = 6.0; // inches

NSUInteger const k4UpPaperSizeId = 101;
NSString * const k4UpPaperSizeTitle = @"1.5 x 8";
CGFloat const k4UpPaperSizeWidth = 1.5; // inches
CGFloat const k4UpPaperSizeHeight = 8.0; // inches

NSUInteger const k3UpPaperTypeId = 100;
NSString * const k3UpPaperTypeTitle = @"3-Up Perforated";
BOOL const k3UpPaperTypePhoto = YES;

NSUInteger const kLabelPaperTypeId = 101;
NSString * const kLabelPaperTypeTitle = @"Label";
BOOL const kLabelPaperTypePhoto = NO;

- (void)configurePhotoStripPaper
{
    [MPPaper registerSize:@{
                              kMPPaperSizeIdKey:[NSNumber numberWithUnsignedInteger:k3UpPaperSizeId],
                              kMPPaperSizeTitleKey:k3UpPaperSizeTitle,
                              kMPPaperSizeWidthKey:[NSNumber numberWithFloat:k3UpPaperSizeWidth],
                              kMPPaperSizeHeightKey:[NSNumber numberWithFloat:k3UpPaperSizeHeight]
                              }];
    
    [MPPaper registerSize:@{
                              kMPPaperSizeIdKey:[NSNumber numberWithUnsignedInteger:k4UpPaperSizeId],
                              kMPPaperSizeTitleKey:k4UpPaperSizeTitle,
                              kMPPaperSizeWidthKey:[NSNumber numberWithFloat:k4UpPaperSizeWidth],
                              kMPPaperSizeHeightKey:[NSNumber numberWithFloat:k4UpPaperSizeHeight]
                              }];
    
    [MPPaper registerType:@{
                              kMPPaperTypeIdKey:[NSNumber numberWithUnsignedInteger:k3UpPaperTypeId],
                              kMPPaperTypeTitleKey:k3UpPaperTypeTitle,
                              kMPPaperTypePhotoKey:[NSNumber numberWithBool:k3UpPaperTypePhoto]
                              }];
    
    [MPPaper registerType:@{
                              kMPPaperTypeIdKey:[NSNumber numberWithUnsignedInteger:kLabelPaperTypeId],
                              kMPPaperTypeTitleKey:kLabelPaperTypeTitle,
                              kMPPaperTypePhotoKey:[NSNumber numberWithBool:kLabelPaperTypePhoto]
                              }];
    
    [MPPaper associatePaperSize:MPPaperSize5x7 withType:k3UpPaperTypeId];
    [MPPaper associatePaperSize:k3UpPaperSizeId withType:kLabelPaperTypeId];
    [MPPaper associatePaperSize:k4UpPaperSizeId withType:kLabelPaperTypeId];
}

- (BOOL)aspectRatio3up
{
    BOOL is3up = NO;
    if (self.printItem) {
        CGSize printItemSize = [self.printItem sizeInUnits:Inches];
        is3up = fabs((printItemSize.width / printItemSize.height) - (k3UpPaperSizeWidth / k3UpPaperSizeHeight)) < 0.001;
    }
    return is3up;
}

- (BOOL)aspectRatio4up
{
    BOOL is4up = NO;
    if (self.printItem) {
        CGSize printItemSize = [self.printItem sizeInUnits:Inches];
        is4up = fabs((printItemSize.width / printItemSize.height) - (k4UpPaperSizeWidth / k4UpPaperSizeHeight)) < 0.001;
    }
    return is4up;
}

#pragma mark - Information

- (void)setDeviceInfo
{
    self.SHALabel.text = [self SHA];
    self.SHAModifiedLabel.text = [self SHAModified] ? @"Yes" : @"No";
    self.unmodifiedDeviceIdLabel.text = [[UIDevice currentDevice].identifierForVendor UUIDString];
    self.reportedDeviceIdLabel.text = [self userUniqueIdentifier];
    self.useUniqueIdPerAppSwitch.on = [MP sharedInstance].uniqueDeviceIdPerApp;
    NSString *scope = [MP sharedInstance].uniqueDeviceIdPerApp ? @"app" : @"vendor";
    self.reportedIdTitleLabel.text = [NSString stringWithFormat:@"Reported ID (per %@)", scope];
}

- (NSString *)SHA
{
    NSString *version = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"];
    NSString *SHA = version;
    if ([self SHAModified]) {
        SHA = [version substringToIndex:kLengthOfSHA - 1];
    }
    return SHA;
}

- (BOOL)SHAModified
{
    NSString *version = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"];
    return [version rangeOfString:@" *"].location != NSNotFound;
}

- (IBAction)useUniqueIdPerAppChanged:(id)sender {
    [MP sharedInstance].uniqueDeviceIdPerApp = self.useUniqueIdPerAppSwitch.on;
    [self setDeviceInfo];
    [self setBarButtonItems];
}

#pragma mark - Private MPAnalyticsManager

- (NSString *)userUniqueIdentifier
{
    NSString *identifier = [[UIDevice currentDevice].identifierForVendor UUIDString];
    if ([MP sharedInstance].uniqueDeviceIdPerApp) {
        NSString *seed = [NSString stringWithFormat:@"%@%@", identifier, [[NSBundle mainBundle] bundleIdentifier]];
        identifier = [self obfuscateValue:seed];
    }
    return identifier;
}

// The following is adapted from http://stackoverflow.com/questions/2018550/how-do-i-create-an-md5-hash-of-a-string-in-cocoa
- (NSString *)obfuscateValue:(NSString *)value
{
    const char *cstr = [value UTF8String];
    unsigned char result[16];
    CC_MD5(cstr, (CC_LONG)strlen(cstr), result);
    return [NSString stringWithFormat:
            @"%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X",
            result[0], result[1], result[2], result[3],
            result[4], result[5], result[6], result[7],
            result[8], result[9], result[10], result[11],
            result[12], result[13], result[14], result[15]
            ];
}

#pragma mark - Custom library version

- (void)setCustomLibraryVersion
{
    NSString *version = [self.customLibraryVersionTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    [MP sharedInstance].customPrintLibraryVersion = [version length] > 0 ? version : nil;
}

@end
