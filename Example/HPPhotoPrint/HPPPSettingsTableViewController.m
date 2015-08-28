//
//  HPPPSettingsViewControllerTableViewController.m
//  HPPhotoPrint
//
//  Created by James Trask on 7/7/15.
//  Copyright (c) 2015 James. All rights reserved.
//

#import "HPPPSettingsTableViewController.h"
#import "HPPPSelectPrintItemTableViewController.h"
#import "HPPPExperimentManager.h"
#import <HPPP.h>
#import <HPPPLayoutFactory.h>
#import <HPPPPrintItemFactory.h>
#import <HPPPPrintManager.h>

@interface HPPPSettingsTableViewController () <UIPopoverPresentationControllerDelegate, HPPPPrintDelegate, HPPPPrintDataSource, HPPPSelectPrintItemTableViewControllerDelegate, HPPPAddPrintLaterDelegate, HPPPPrintManagerDelegate>

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
@property (strong, nonatomic) HPPPPrintItem *printItem;
@property (strong, nonatomic) HPPPPrintLaterJob *printLaterJob;
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
@property (weak, nonatomic) IBOutlet UITableViewCell *useDeviceIDCell;
@property (weak, nonatomic) IBOutlet UISwitch *detectWiFiSwitch;
@property (weak, nonatomic) IBOutlet UITextField *deviceIDTextField;
@property (weak, nonatomic) IBOutlet UISegmentedControl *showButtonsSegment;
@property (weak, nonatomic) IBOutlet UITableViewCell *directPrintCell;

@end

@implementation HPPPSettingsTableViewController

int const kLayoutDefaultIndex = 0;
int const kLayoutFitIndex = 1;
int const kLayoutFillIndex = 2;
int const kLayoutStretchIndex = 3;

int const kOrientationBest = 0;
int const kOrientationPortrait = 1;
int const kOrientationLandscape = 2;

int const kMetricsSegmentHPIndex = 0;
int const kMetricsSegmentPartnerIndex = 1;
int const kMetricsSegmentNoneIndex = 2;
int const kMetricsSegmentErrorIndex = 3;

int const kShowButtonsSegmentDeviceIndex = 0;
int const kShowButtonsSegmentOnIndex = 1;
int const kShowButtonsSegmentOffIndex = 2;

NSString * const kMetricsOfframpKey = @"off_ramp";
NSString * const kMetricsAppTypeKey = @"app_type";
NSString * const kMetricsAppTypeHP = @"HP";

NSString * const kAddJobClientNamePrefix = @"From Client";
NSString * const kAddJobShareNamePrefix = @"From Share";

#pragma mark - Initialization

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self configureHPPP];
    
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
    
    [self useDeviceID];
    [self setBarButtonItems];
    [self.appearanceTestSettingsSwitch setOn:NO];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(connectionChanged:) name:kHPPPWiFiConnectionEstablished object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(connectionChanged:) name:kHPPPWiFiConnectionLost object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handlePrintQueueNotification:) name:kHPPPPrintQueueNotification object:nil];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)configureHPPP
{
    [HPPP sharedInstance].printJobName = @"Print POD Example";
    
    [HPPP sharedInstance].defaultPaper = [[HPPPPaper alloc] initWithPaperSize:Size5x7 paperType:Photo];
    
    [HPPP sharedInstance].handlePrintMetricsAutomatically = NO;
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    UINavigationController *navigationController = (UINavigationController *)[storyboard instantiateViewControllerWithIdentifier:@"PrintInstructions"];
    
    HPPPSupportAction *action1 = [[HPPPSupportAction alloc] initWithIcon:[UIImage imageNamed:@"print-instructions"] title:@"Print Instructions" url:[NSURL URLWithString:@"http://hp.com"]];
    HPPPSupportAction *action2 = [[HPPPSupportAction alloc] initWithIcon:[UIImage imageNamed:@"print-instructions"] title:@"Print Instructions VC" viewController:navigationController];
    
    [HPPP sharedInstance].supportActions =  @[action1, action2];
    
    [HPPP sharedInstance].paperSizes = @[
                                         [HPPPPaper titleFromSize:Size4x5],
                                         [HPPPPaper titleFromSize:Size4x6],
                                         [HPPPPaper titleFromSize:Size5x7],
                                         [HPPPPaper titleFromSize:SizeLetter]
                                         ];
    
    [HPPP sharedInstance].interfaceOptions.multiPageMaximumGutter = 0;
    [HPPP sharedInstance].interfaceOptions.multiPageBleed = 40;
    [HPPP sharedInstance].interfaceOptions.multiPageBackgroundPageScale = 0.61803399;
    [HPPP sharedInstance].interfaceOptions.multiPageDoubleTapEnabled = YES;
    [HPPP sharedInstance].interfaceOptions.multiPageZoomOnSingleTap = NO;
    [HPPP sharedInstance].interfaceOptions.multiPageZoomOnDoubleTap = YES;
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
    [[HPPPExperimentManager sharedInstance] updateVariationsWithDeviceID:self.deviceIDTextField.text];

    NSMutableArray *icons = [NSMutableArray arrayWithArray:@[ self.shareBarButtonItem]];
    
    if (
        kShowButtonsSegmentOnIndex == self.showButtonsSegment.selectedSegmentIndex ||
        (kShowButtonsSegmentDeviceIndex == self.showButtonsSegment.selectedSegmentIndex && [HPPPExperimentManager sharedInstance].showPrintIcon)) {
        
        if (self.detectWiFiSwitch.on) {
            if ([[HPPP sharedInstance] isWifiConnected]) {
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

- (void)useDeviceID
{
    self.deviceIDTextField.text = [[UIDevice currentDevice].identifierForVendor UUIDString];
}

- (IBAction)showButtonsSegmentChanged:(id)sender {
    [self setBarButtonItems];
}

- (IBAction)detectWiFiSwitchChanged:(id)sender {
    [self setBarButtonItems];
}

- (IBAction)deviceIDTextChanged:(id)sender {
    [self setBarButtonItems];
    [self setDeviceIDCellState];
}

- (void)connectionChanged:(NSNotification *)notification
{
    [self setBarButtonItems];
}

- (void)setDeviceIDCellState
{
    if ([self.deviceIDTextField.text isEqualToString:[[UIDevice currentDevice].identifierForVendor UUIDString]]) {
        self.useDeviceIDCell.alpha = 0.5;
        self.useDeviceIDCell.userInteractionEnabled = NO;
    } else {
        self.useDeviceIDCell.alpha = 1.0;
        self.useDeviceIDCell.userInteractionEnabled = YES;
    }
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
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    UINavigationController *navigationController = (UINavigationController *)[storyboard instantiateViewControllerWithIdentifier:@"SelectPrintItemNavigationController"];
    [self prepareForPrint:navigationController title:@"Print Item" action:action];
    [self presentViewController:navigationController animated:YES completion:nil];
}

- (void)prepareForPrint:(UINavigationController *)navigationController title:(NSString *)title action:(SelectItemAction)action
{
    self.action = action;
    HPPPSelectPrintItemTableViewController *vc = (HPPPSelectPrintItemTableViewController *)navigationController.topViewController;
    vc.delegate = self;
    vc.navigationItem.title = title;
}

- (void)preparePrintLaterJobWithName:(NSString *)name
{
    NSString *printLaterJobNextAvailableId = [[HPPP sharedInstance] nextPrintJobId];
    self.printLaterJob = [[HPPPPrintLaterJob alloc] init];
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
}

#pragma mark - Sharing

- (void)shareTapped:(id)sender
{
    self.action = Share;
    [self doActivityWithPrintItem:[HPPPPrintItemFactory printItemWithAsset:[self randomImage]]];
}

- (void)shareItem
{
    NSString *bundlePath = [NSString stringWithFormat:@"%@/HPPhotoPrint.bundle", [NSBundle mainBundle].bundlePath];
    NSLog(@"Bundle %@", bundlePath);
    
    HPPPPrintActivity *printActivity = [[HPPPPrintActivity alloc] init];
    printActivity.dataSource = self;
    
    NSArray *applicationActivities = nil;
    if (IS_OS_8_OR_LATER) {
        [self preparePrintLaterJobWithName:kAddJobShareNamePrefix];
        HPPPPrintLaterActivity *printLaterActivity = [[HPPPPrintLaterActivity alloc] init];
        printLaterActivity.printLaterJob = self.printLaterJob;
        applicationActivities = @[printActivity, printLaterActivity];
    } else {
        applicationActivities = @[printActivity];
    }
    
    NSArray *activitiesItems = @[self.printItem, self.printItem.printAsset];
    
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
        BOOL printActivity = [activityType isEqualToString:[[HPPPPrintActivity alloc] init].activityType];
        BOOL printLaterActivity = [activityType isEqualToString:[[HPPPPrintLaterActivity alloc] init].activityType];
        if (completed) {
            HPPPPrintItem *printItem = self.printItem;
            NSString *offramp = activityType;
            if (printActivity) {
                offramp = [self.printItem.extra objectForKey:kMetricsOfframpKey];
            } else if (printLaterActivity) {
                offramp = [self.printLaterJob.extra objectForKey:kMetricsOfframpKey];
                printItem = self.printLaterJob.defaultPrintItem;
                printItem.extra = self.printLaterJob.extra;
                [[HPPP sharedInstance] presentPrintQueueFromController:self animated:YES completion:nil];
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

#pragma mark - HPPPPrintDelegate

- (void)didFinishPrintFlow:(UIViewController *)printViewController;
{
    [printViewController dismissViewControllerAnimated:YES completion:nil];
    [self processMetricsForPrintItem:self.printItem];
}

- (void)didCancelPrintFlow:(UIViewController *)printViewController;
{
    [printViewController dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - HPPPPrintDataSource

- (void)printingItemForPaper:(HPPPPaper *)paper withCompletion:(void (^)(HPPPPrintItem *))completion
{
    if (completion) {
        self.printItem.layout = [self layoutForPaper:paper];
        completion(self.printItem);
    }
}

- (void)previewImageForPaper:(HPPPPaper *)paper withCompletion:(void (^)(UIImage *))completion
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

- (NSArray *)printingItemsForPaper:(HPPPPaper *)paper
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
    [self setDeviceIDCellState];
    if (!IS_OS_8_OR_LATER && (cell == self.showPrintQueueCell || cell == self.showGeoHelperCell || cell == self.directPrintCell)) {
        cell.alpha = 0.5;
        cell.userInteractionEnabled = NO;
    }
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
    } else if (selectedCell == self.useDeviceIDCell) {
        [self useDeviceID];
        [self setBarButtonItems];
        [self setDeviceIDCellState];
        selectedCell.selected = NO;
    }
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
    [HPPP sharedInstance].handlePrintMetricsAutomatically = self.automaticMetricsSwitch.on;
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
    
    [HPPP sharedInstance].handlePrintMetricsAutomatically = self.automaticMetricsSwitch.on;
}

- (NSDictionary *)photoSourceMetrics
{
    return [NSDictionary dictionaryWithObjectsAndKeys:
            @"facebook", @"photo_source",
            @"1234567890", @"user_id",
            @"Samply McSampleson", @"user_name", nil];
}

- (void)processMetricsForPrintItem:(HPPPPrintItem *)printItem
{
    if (self.extendedMetricsSwitch.on) {
        NSMutableDictionary *metrics = [NSMutableDictionary dictionaryWithDictionary:@{ kMetricsAppTypeKey:kMetricsAppTypeHP }];
        [metrics addEntriesFromDictionary:printItem.extra];
        [metrics addEntriesFromDictionary:[self photoSourceMetrics]];
        [[NSNotificationCenter defaultCenter] postNotificationName:kHPPPShareCompletedNotification object:self.printItem userInfo:metrics];
    }
}

- (void)handlePrintQueueNotification:(NSNotification *)notification
{
    if (self.extendedMetricsSwitch.on) {
        NSString *action = [notification.object objectForKey:kHPPPPrintQueueActionKey];
        HPPPPrintLaterJob *job = [notification.object objectForKey:kHPPPPrintQueueJobKey];
        HPPPPrintItem *printItem = [notification.object objectForKey:kHPPPPrintQueuePrintItemKey];
        NSMutableDictionary *metrics = [NSMutableDictionary dictionaryWithDictionary:@{ kMetricsOfframpKey:action, kMetricsAppTypeKey:kMetricsAppTypeHP }];
        [metrics addEntriesFromDictionary:job.extra];
        [[NSNotificationCenter defaultCenter] postNotificationName:kHPPPShareCompletedNotification object:printItem userInfo:metrics];
    }
}

#pragma mark - Print Queue

- (void)showPrintQueue
{
    [[HPPP sharedInstance] presentPrintQueueFromController:self animated:YES completion:nil];
}

- (void)populatePrintQueue
{
    [[HPPP sharedInstance] clearQueue];
    
    int jobCount = 5;
    
    for (int idx = 0; idx < jobCount; idx++) {
        
        NSString *jobID = [[HPPP sharedInstance] nextPrintJobId];
        
        HPPPPrintLaterJob *job = [[HPPPPrintLaterJob alloc] init];
        job.id = jobID;
        job.name = [NSString stringWithFormat:@"Print Job #%d", idx + 1];
        job.date = [NSDate date];
        job.printItems = [self printItemsForAsset:[self randomImage]];
        
        [[HPPP sharedInstance] addJobToQueue:job];
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
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"HPPP" bundle:[NSBundle mainBundle]];
    UINavigationController *nc = (UINavigationController *)[storyboard instantiateViewControllerWithIdentifier:@"HPPPPrintLaterHelperNavigationController"];
    [self presentViewController:nc animated:YES completion:nil];
}

#pragma mark - HPPPSelectPrintItemTableViewControllerDelegate

- (void)didSelectPrintItem:(HPPPPrintItem *)printItem
{
    [self doActivityWithPrintItem:printItem];
}

#pragma mark - Activity

- (void)doActivityWithPrintItem:(HPPPPrintItem *)printItem
{
    self.printItem = printItem;
    if (Share == self.action) {
        [self shareItem];
    } else if (DirectPrint == self.action) {
        
        HPPPPrintManager *printManager = [[HPPPPrintManager alloc] init];
        printManager.delegate = self;
        
        if( printManager.currentPrintSettings.paper ) {
            printItem.layout = [self layoutForPaper:printManager.currentPrintSettings.paper];
        }
        
        NSError *error;
        [printManager print:printItem
                  pageRange:nil
                  numCopies:1
                      error:&error];
        
        if (HPPPPrintManagerErrorNone != error.code) {
            NSString *reason;
            switch (error.code) {
                case HPPPPrintManagerErrorNoPaperType:
                    reason = @"No paper type selected";
                    break;
                case HPPPPrintManagerErrorNoPrinterUrl:
                    reason = @"No printer URL";
                    break;
                case HPPPPrintManagerErrorPrinterNotAvailable:
                    reason = @"Printer not available";
                    break;
                case HPPPPrintManagerErrorDirectPrintNotSupported:
                    reason = @"Direct print is not supported";
                    break;
                case HPPPPrintManagerErrorUnknown:
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
        UIViewController *vc = [[HPPP sharedInstance] printLaterViewControllerWithDelegate:self printLaterJob:self.printLaterJob];
        [self presentViewController:vc animated:YES completion:nil];
    }
    else {
        BOOL settingsInProgress = (Settings == self.action);
        UIViewController *vc = [[HPPP sharedInstance] printViewControllerWithDelegate:self dataSource:self printItem:printItem fromQueue:NO settingsOnly:settingsInProgress];
        [self presentViewController:vc animated:YES completion:nil];
    }
}

#pragma mark - Layout

- (HPPPLayout *)layoutForPaper:(HPPPPaper *)paper
{
    HPPPLayout *layout = [HPPPLayoutFactory layoutWithType:[HPPPLayoutFit layoutType]];
    if (DefaultPrintRenderer != self.printItem.renderer) {
        BOOL defaultLetter = (kLayoutDefaultIndex == self.layoutSegmentControl.selectedSegmentIndex && SizeLetter == paper.paperSize);
        
        HPPPLayoutOrientation orientation = HPPPLayoutOrientationBestFit;
        if (defaultLetter || kOrientationPortrait == self.orientationSegmentControl.selectedSegmentIndex) {
            orientation = HPPPLayoutOrientationPortrait;
        } else if (kOrientationLandscape == self.orientationSegmentControl.selectedSegmentIndex) {
            orientation = HPPPLayoutOrientationLandscape;
        }
        
        CGRect position = [HPPPLayout completeFillRectangle];
        if (defaultLetter) {
            position = [self defaultLetterPosition];
        } else {
            CGFloat x = [((UITextField *)self.positionTextField[0]).text floatValue];
            CGFloat y = [((UITextField *)self.positionTextField[1]).text floatValue];
            CGFloat width = [((UITextField *)self.positionTextField[2]).text floatValue];
            CGFloat height = [((UITextField *)self.positionTextField[3]).text floatValue];
            if (width > 0 && height > 0) {
                position = CGRectMake(x, y, width, height);
            }
        }
        
        BOOL allowRotation = !defaultLetter;
        
        NSString * type = [HPPPLayoutFit layoutType];
        if (defaultLetter || kLayoutFitIndex == self.layoutSegmentControl.selectedSegmentIndex || DefaultPrintRenderer == self.printItem.renderer) {
            type = [HPPPLayoutFit layoutType];
        } else if (kLayoutFillIndex == self.layoutSegmentControl.selectedSegmentIndex) {
            type = [HPPPLayoutFill layoutType];
        } else if (kLayoutStretchIndex == self.layoutSegmentControl.selectedSegmentIndex) {
            type = [HPPPLayoutStretch layoutType];
        }
        
        layout = [HPPPLayoutFactory layoutWithType:type orientation:orientation assetPosition:position allowContentRotation:allowRotation];
    }
    
    return layout;
}

- (CGRect)defaultLetterPosition
{
    HPPPPaper *letterPaper = [[HPPPPaper alloc] initWithPaperSize:SizeLetter paperType:Plain];
    HPPPPaper *defaultPaper = [HPPP sharedInstance].defaultPaper;
    CGFloat maxDimension = fmaxf(defaultPaper.width, defaultPaper.height);
    CGFloat width = maxDimension / letterPaper.width * 100.0f;
    CGFloat height = maxDimension / letterPaper.height * 100.0f;
    CGFloat x = (100.0f - width) / 2.0f;
    CGFloat y = (100.0f - height) / 2.0f;
    return CGRectMake(x, y, width, height);
}

- (NSDictionary *)printItemsForAsset:(id)asset
{
    NSArray *sizes = @[ @"4 x 5", @"4 x 6", @"5 x 7", @"8.5 x 11" ];
    NSMutableDictionary *printItems = [NSMutableDictionary dictionary];
    for (NSString *size in sizes) {
        HPPPPrintItem *printItem = [HPPPPrintItemFactory printItemWithAsset:asset];
        HPPPPaper *paper = [[HPPPPaper alloc] initWithPaperSizeTitle:size paperTypeTitle:@"Plain Paper"];
        printItem.layout = [self layoutForPaper:paper];
        [printItems addEntriesFromDictionary:@{ paper.sizeTitle: printItem }];
    }
    return printItems;
}

#pragma mark - HPPPAddPrintLaterDelegate

- (void)didFinishAddPrintLaterFlow:(UIViewController *)addPrintLaterJobTableViewController
{
    NSDictionary *values = @{
                             kHPPPPrintQueueActionKey:[self.printLaterJob.extra objectForKey:kMetricsOfframpKey],
                             kHPPPPrintQueueJobKey:self.printLaterJob,
                             kHPPPPrintQueuePrintItemKey:[self.printLaterJob.printItems objectForKey:[HPPP sharedInstance].defaultPaper.sizeTitle] };
    [[NSNotificationCenter defaultCenter] postNotificationName:kHPPPPrintQueueNotification object:values];
    [self dismissViewControllerAnimated:YES completion:^{
        [[HPPP sharedInstance] presentPrintQueueFromController:self animated:YES completion:nil];
    }];
}

- (void)didCancelAddPrintLaterFlow:(UIViewController *)addPrintLaterJobTableViewController
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - HPPPPrintManagerDelegate

- (void)didFinishPrintJob:(UIPrintInteractionController *)printController completed:(BOOL)completed error:(NSError *)error
{
    if (!completed) {
        HPPPLogInfo(@"Print was NOT completed");
    }
    
    if (error) {
        HPPPLogWarn(@"Print error:  %@", error);
    }
    
    if (completed && !error) {
        [self processMetricsForPrintItem:self.printItem];
    }
}

#pragma mark - Pod Appearance Testing
- (IBAction)appearanceSettingsChanged:(id)sender {
    static NSDictionary *defaultSettings = nil;

    HPPP *hppp = [HPPP sharedInstance];
    
    if( self.appearanceTestSettingsSwitch.on ) {
        defaultSettings = hppp.appearance.settings;
        hppp.appearance.settings = [self testSettings];
    } else {
        [HPPP sharedInstance].appearance.settings = defaultSettings;
    }
}

- (NSDictionary *)testSettings
{
    NSString *regularFont = @"Baskerville-Bold";
    NSString *lightFont   = @"Baskerville-Italic";
    
    return @{// General
             kHPPPGeneralDefaultDateFormat: @"MMMM d, h:mma",
             
             // Background
             kHPPPBackgroundBackgroundColor:   [UIColor colorWithRed:0x00/255.0F green:0x00/255.0F blue:0xFF/255.0F alpha:1.0F],
             kHPPPBackgroundPrimaryFont:       [UIFont fontWithName:regularFont size:14],
             kHPPPBackgroundPrimaryFontColor:  [UIColor colorWithRed:0xFF/255.0F green:0x00/255.0F blue:0x00/255.0F alpha:1.0F],
             kHPPPBackgroundSecondaryFont:     [UIFont fontWithName:lightFont size:12],
             kHPPPBackgroundSecondaryFontColor:[UIColor colorWithRed:0x00/255.0F green:0xFF/255.0F blue:0x00/255.0F alpha:1.0F],
             
             // Selection Options
             kHPPPSelectionOptionsBackgroundColor:   [UIColor colorWithRed:0xFF/255.0F green:0xA5/255.0F blue:0x00/255.0F alpha:1.0F],
             kHPPPSelectionOptionsStrokeColor:       [UIColor colorWithRed:0x33/255.0F green:0x33/255.0F blue:0x33/255.0F alpha:1.0F],
             kHPPPSelectionOptionsPrimaryFont:       [UIFont fontWithName:regularFont size:16],
             kHPPPSelectionOptionsPrimaryFontColor:  [UIColor colorWithRed:0xFF/255.0F green:0x00/255.0F blue:0x00/255.0F alpha:1.0F],
             kHPPPSelectionOptionsSecondaryFont:     [UIFont fontWithName:regularFont size:16],
             kHPPPSelectionOptionsSecondaryFontColor:[UIColor colorWithRed:0x00/255.0F green:0xFF/255.0F blue:0x00/255.0F alpha:1.0F],
             kHPPPSelectionOptionsLinkFont:          [UIFont fontWithName:regularFont size:16],
             kHPPPSelectionOptionsLinkFontColor:     [UIColor colorWithRed:0x00/255.0F green:0x00/255.0F blue:0xFF/255.0F alpha:1.0F],
             
             // Job Settings
             kHPPPJobSettingsBackgroundColor:    [UIColor colorWithRed:0x00/255.0F green:0xFF/255.0F blue:0x00/255.0F alpha:1.0F],
             kHPPPJobSettingsStrokeColor:        [UIColor colorWithRed:0x33/255.0F green:0x33/255.0F blue:0x33/255.0F alpha:1.0F],
             kHPPPJobSettingsPrimaryFont:        [UIFont fontWithName:regularFont size:16],
             kHPPPJobSettingsPrimaryFontColor:   [UIColor colorWithRed:0xFF/255.0F green:0x00/255.0F blue:0x00/255.0F alpha:1.0F],
             kHPPPJobSettingsSecondaryFont:      [UIFont fontWithName:regularFont size:12],
             kHPPPJobSettingsSecondaryFontColor: [UIColor colorWithRed:0x00/255.0F green:0x00/255.0F blue:0xFF/255.0F alpha:1.0F],
             kHPPPJobSettingsSelectedPageIcon:   [UIImage imageNamed:@"HPPPSelected.png"],
             kHPPPJobSettingsUnselectedPageIcon: [UIImage imageNamed:@"HPPPUnselected.png"],
             
             // Main Action
             kHPPPMainActionBackgroundColor:       [UIColor colorWithRed:0x8A/255.0F green:0x2B/255.0F blue:0xE2/255.0F alpha:1.0F],
             kHPPPMainActionStrokeColor:           [UIColor colorWithRed:0x33/255.0F green:0x33/255.0F blue:0x33/255.0F alpha:1.0F],
             kHPPPMainActionLinkFont:              [UIFont fontWithName:regularFont size:18],
             kHPPPMainActionActiveLinkFontColor:   [UIColor colorWithRed:0xFF/255.0F green:0x00/255.0F blue:0x00/255.0F alpha:1.0F],
             kHPPPMainActionInactiveLinkFontColor: [UIColor colorWithRed:0x00/255.0F green:0x00/255.0F blue:0x00/255.0F alpha:1.0F],
             
             // Queue Project Count
             kHPPPQueuePrimaryFont:     [UIFont fontWithName:regularFont size:16],
             kHPPPQueuePrimaryFontColor:[UIColor colorWithRed:0x00 green:0x00 blue:0x00 alpha:1.0F],
             
             // Form Field
             kHPPPFormFieldBackgroundColor:  [UIColor colorWithRed:0xFF/255.0F green:0xD7/255.0F blue:0x00/255.0F alpha:1.0F],
             kHPPPFormFieldStrokeColor:      [UIColor colorWithRed:0x33/255.0F green:0x33/255.0F blue:0x33/255.0F alpha:1.0F],
             kHPPPFormFieldPrimaryFont:      [UIFont fontWithName:regularFont size:16],
             kHPPPFormFieldPrimaryFontColor: [UIColor colorWithRed:0xFF/255.0F green:0x00/255.0F blue:0x00/255.0F alpha:1.0F],
             
             // Multipage Graphics
             kHPPPMultipageGraphicsStrokeColor: [UIColor colorWithRed:0xFF green:0xFF blue:0xFF alpha:1.0F],
             
             // Overlay
             kHPPPOverlayBackgroundColor:    [UIColor colorWithRed:0x8D/255.0F green:0xEE/255.0F blue:0xEE/255.0F alpha:1.0F],
             kHPPPOverlayBackgroundOpacity:  [NSNumber numberWithFloat:.60F],
             kHPPPOverlayPrimaryFont:        [UIFont fontWithName:regularFont size:16],
             kHPPPOverlayPrimaryFontColor:   [UIColor colorWithRed:0xFF/255.0F green:0x00/255.0F blue:0x00/255.0F alpha:1.0F],
             kHPPPOverlaySecondaryFont:      [UIFont fontWithName:regularFont size:14],
             kHPPPOverlaySecondaryFontColor: [UIColor colorWithRed:0x00/255.0F green:0xFF/255.0F blue:0x00/255.0F alpha:1.0F],
             kHPPPOverlayLinkFont:           [UIFont fontWithName:regularFont size:18],
             kHPPPOverlayLinkFontColor:      [UIColor colorWithRed:0x00/255.0F green:0x00/255.0F blue:0xFF/255.0F alpha:1.0F]
             };
}

@end
