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
#import "MPPrintLaterManager.h"
#import "MPPrintLaterQueue.h"
#import "MPPrintJobsViewController.h"
#import "MPPageSettingsTableViewController.h"
#import "MPWiFiReachability.h"
#import "MPPrintManager.h"
#import <CoreFoundation/CoreFoundation.h>
#import "MPLayoutFactory.h"
#import "MPBTSprocket.h"
#import "MPBTPairedAccessoriesViewController.h"
#import "MPPrintSettingsDelegateManager.h"
#import "MPBTProgressView.h"
#import "MPBTDeviceInfoTableViewController.h"

NSString * const kMPLibraryVersion = @"3.0.8";

NSString * const kLaterActionIdentifier = @"LATER_ACTION_IDENTIFIER";
NSString * const kPrintActionIdentifier = @"PRINT_ACTION_IDENTIFIER";
NSString * const kPrintCategoryIdentifier = @"PRINT_CATEGORY_IDENTIFIER";

NSString * const kMPBTPrintJobStartedNotification = @"kMPBTPrintJobStartedNotification";
NSString * const kMPBTPrintJobCompletedNotification = @"kMPBTPrintJobCompletedNotification";
NSString * const kMPBTPrintJobPrinterIdKey = @"kMPBTPrintJobPrinterIdKey";
NSString * const kMPBTPrintJobErrorKey = @"kMPBTPrintJobErrorKey";
NSString * const kMPBTPrinterNotConnectedNotification = @"kMPBTPrinterNotConnectedNotification";
NSString * const kMPBTPrinterNotConnectedSourceKey = @"kMPBTPrinterNotConnectedSourceKey";

NSString * const kMPShareCompletedNotification = @"kMPShareCompletedNotification";

NSString * const kMPTrackableScreenNotification = @"kMPTrackableScreenNotification";
NSString * const kMPTrackableScreenNameKey = @"screen-name";

NSString * const kMPPrintQueueNotification = @"kMPPrintQueueNotification";
NSString * const kMPPrintQueueActionKey = @"kMPPrintQueueActionKey";
NSString * const kMPPrintQueueJobKey = @"kMPPrintQueueJobKey";
NSString * const kMPPrintQueuePrintItemKey = @"kMPPrintQueuePrintItemKey";

NSString * const kMPPrintJobAddedToQueueNotification = @"kMPPrintJobAddedToQueueNotification";
NSString * const kMPPrintJobRemovedFromQueueNotification = @"kMPPrintJobRemovedFromQueueNotification";
NSString * const kMPAllPrintJobsRemovedFromQueueNotification = @"kMPAllPrintJobsRemovedFromQueueNotification";

NSString * const kMPPrinterAvailabilityNotification = @"kMPPrinterAvailabilityNotification";
NSString * const kMPPrinterAvailableKey = @"availability";
NSString * const kMPPrinterKey = @"printer";

NSString * const kMPWiFiConnectionEstablished = @"kMPWiFiConnectionEstablished";
NSString * const kMPWiFiConnectionLost = @"kMPWiFiConnectionLost";

NSString * const kMPBlackAndWhiteFilterId = @"black_and_white_filter";
NSString * const kMPNumberOfCopies = @"copies";
NSString * const kMPPaperSizeId = @"paper_size";
NSString * const kMPPaperTypeId = @"paper_type";
NSString * const kMPPaperWidthId = @"user_paper_width_inches";
NSString * const kMPPaperHeightId = @"user_paper_height_inches";
NSString * const kMPPrinterId = @"printer_id";
NSString * const kMPPrinterDisplayLocation = @"printer_location";
NSString * const kMPPrinterMakeAndModel = @"printer_model";
NSString * const kMPPrinterDisplayName = @"printer_name";

NSString * const kMPNumberPagesDocument = @"number_pages_document";
NSString * const kMPNumberPagesPrint = @"number_pages_print";

NSString * const kMPPrinterPaperWidthPoints = @"printer_paper_width_points";
NSString * const kMPPrinterPaperHeightPoints = @"printer_paper_height_points";
NSString * const kMPPrinterPaperAreaWidthPoints = @"printer_paper_area_width_points";
NSString * const kMPPrinterPaperAreaHeightPoints = @"printer_paper_area_height_points";
NSString * const kMPPrinterPaperAreaXPoints = @"printer_paper_area_x_points";
NSString * const kMPPrinterPaperAreaYPoints = @"printer_paper_area_y_points";

BOOL const kMPDefaultUniqueDeviceIdPerApp = YES;

@interface MP()
@property (weak, nonatomic) id<MPSprocketDelegate> sprocketDelegate;
@end

@implementation MP

#pragma mark - Public methods

+ (MP *)sharedInstance
{
    static MP *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[MP alloc] init];
        sharedInstance.interfaceOptions = [[MPInterfaceOptions alloc] init];
        sharedInstance.printPaperDelegate = nil;
        sharedInstance.uniqueDeviceIdPerApp = kMPDefaultUniqueDeviceIdPerApp;
        sharedInstance.minimumSprocketBatteryLevelForUpgrade = 75;
    });
    
    return sharedInstance;
}

#pragma mark - Initialization

- (id)init
{
    self = [super init];
    if (self) {
        
        if ([MPPrintLaterManager sharedInstance].userNotificationsPermissionSet) {
            [[MPPrintLaterManager sharedInstance] initLocationManager];
            [[MPPrintLaterManager sharedInstance] initUserNotifications];
        }
        
        self.handlePrintMetricsAutomatically = YES;
        self.lastOptionsUsed = [NSMutableDictionary dictionary];
        self.appearance = [[MPAppearance alloc] init];
        self.supportedPapers = [MPPaper availablePapers];
        self.defaultPaper = [[MPPaper alloc] initWithPaperSize:MPPaperSize5x7 paperType:MPPaperTypePhoto];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleShareCompletedNotification:) name:kMPShareCompletedNotification object:nil];
    }
    
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (BOOL)hideBlackAndWhiteOption
{
    BOOL retVal = YES;
    
    if (IS_OS_8_OR_LATER) {
        retVal = _hideBlackAndWhiteOption;
    }
    
    return retVal;
}

- (BOOL)pageSettingsCancelButtonLeft
{
    return _pageSettingsCancelButtonLeft;
}

#pragma mark - Metrics

- (void)handleShareCompletedNotification:(NSNotification *)notification
{
    NSString *offramp = [notification.userInfo objectForKey:kMPOfframpKey];
    
    if ([MPPrintManager printingOfframp:offramp] && self.handlePrintMetricsAutomatically) {
        // The client app must disable automatic print metric handling in order to post print metrics via the notification system
        MPLogError(@"Cannot post extended metrics notification while automatic metric handling is active");
        return;
    }
    
    if ([[notification.object class] isSubclassOfClass:[MPPrintItem class]]) {
        [[MPAnalyticsManager sharedManager] trackShareEventWithPrintItem:notification.object andOptions:notification.userInfo];
    } else {
        [[MPAnalyticsManager sharedManager] trackShareEventWithPrintLaterJob:notification.object andOptions:notification.userInfo];
    }
}

#pragma mark - Getter methods

- (UIViewController *)printViewControllerWithDelegate:(id<MPPrintDelegate>)delegate
                                           dataSource:(id<MPPrintDataSource>)dataSource
                                       printLaterJobs: (NSArray *)printLaterJobs
                                            fromQueue:(BOOL)fromQueue
                                         settingsOnly:(BOOL)settingsOnly
{
    MPPrintLaterJob *firstJob = printLaterJobs[0];
    
    MPPrintItem *printItem = [firstJob.printItems objectForKey:self.defaultPaper.sizeTitle];
    printItem.extra = firstJob.extra;
    
    UIViewController *vc = [self printViewControllerWithDelegate:delegate dataSource:dataSource printItem:printItem fromQueue:fromQueue settingsOnly:settingsOnly];
    
    if ([vc isKindOfClass:[UINavigationController class]]) {
        ((MPPageSettingsTableViewController *)((UINavigationController *)vc).viewControllers[0]).printLaterJobs = printLaterJobs;
    } else if ([vc isKindOfClass:[UISplitViewController class]]){
        for (UINavigationController *navController in ((UISplitViewController *)vc).viewControllers) {
            MPPageSettingsTableViewController *pageSettings = navController.viewControllers[0];
            pageSettings.printLaterJobs = printLaterJobs;
        }
    }
    
    return vc;
}

- (UIViewController *)printViewControllerWithDelegate:(id<MPPrintDelegate>)delegate
                                           dataSource:(id<MPPrintDataSource>)dataSource
                                            printItem:(MPPrintItem *)printItem
                                            fromQueue:(BOOL)fromQueue
                                         settingsOnly:(BOOL)settingsOnly;
{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"MP" bundle:[NSBundle bundleForClass:[MP class]]];
    
    UISplitViewController *pageSettingsSplitViewController = (UISplitViewController *)[storyboard instantiateViewControllerWithIdentifier:@"MPPageSettingsSplitViewController"];
    
    if( 1 == pageSettingsSplitViewController.viewControllers.count ) {
        MPLogError(@"Only one navController created for the pageSettingsSplitViewController... correcting");
        UINavigationController *activeNavigationController = (UINavigationController *)[storyboard instantiateViewControllerWithIdentifier:@"MPActiveNavigationController"];
        UINavigationController *detailsNavigationController = (UINavigationController *)[storyboard instantiateViewControllerWithIdentifier:@"MPPreviewNavigationController"];
        NSMutableArray *viewControllers = [[NSMutableArray alloc] initWithObjects:activeNavigationController, detailsNavigationController, nil];
        pageSettingsSplitViewController.viewControllers = viewControllers;
    }
    
    UINavigationController *detailsNavigationController = pageSettingsSplitViewController.viewControllers[1];
    if( nil == (MPPageSettingsTableViewController *)detailsNavigationController.topViewController ) {
        MPLogError(@"Preview pane view controller failed to be created... correcting");
        MPPageSettingsTableViewController *previewPane = [storyboard instantiateViewControllerWithIdentifier:@"MPPageSettingsTableViewController"];
        [detailsNavigationController pushViewController:previewPane animated:NO];
    }
    detailsNavigationController.navigationBar.translucent = NO;
    MPPageSettingsTableViewController *previewPane = (MPPageSettingsTableViewController *)detailsNavigationController.topViewController;
    previewPane.dataSource = dataSource;
    previewPane.printItem = printItem;
    previewPane.displayType = MPPageSettingsDisplayTypePreviewPane;
    
    UINavigationController *masterNavigationController = pageSettingsSplitViewController.viewControllers[0];
    if( nil == (MPPageSettingsTableViewController *)masterNavigationController.topViewController ) {
        MPLogError(@"Page Settings view controller failed to be created... correcting");
        MPPageSettingsTableViewController *pageSettingsTableViewController = [storyboard instantiateViewControllerWithIdentifier:@"MPPageSettingsTableViewController"];
        [masterNavigationController pushViewController:pageSettingsTableViewController animated:NO];
    }
    masterNavigationController.navigationBar.translucent = NO;
    MPPageSettingsTableViewController *pageSettingsTableViewController = (MPPageSettingsTableViewController *)masterNavigationController.topViewController;
    pageSettingsTableViewController.displayType = MPPageSettingsDisplayTypePageSettingsPane;
    pageSettingsTableViewController.printDelegate = delegate;
    pageSettingsTableViewController.dataSource = dataSource;
    pageSettingsTableViewController.printItem = printItem;
    pageSettingsSplitViewController.preferredDisplayMode = UISplitViewControllerDisplayModeAllVisible;
    pageSettingsTableViewController.previewViewController = previewPane;
    
    if( fromQueue ) {
        pageSettingsTableViewController.mode = MPPageSettingsModePrintFromQueue;
        previewPane.mode = MPPageSettingsModePrintFromQueue;
    } else if( settingsOnly ) {
        pageSettingsTableViewController.mode = MPPageSettingsModeSettingsOnly;
        previewPane.mode = MPPageSettingsModeSettingsOnly;
    } else {
        pageSettingsTableViewController.mode = MPPageSettingsModePrint;
        previewPane.mode = MPPageSettingsModePrint;
    }
    
    return pageSettingsSplitViewController;
}

- (UIViewController *)printLaterViewControllerWithDelegate:(id<MPAddPrintLaterDelegate>)delegate printLaterJob:(MPPrintLaterJob *)printLaterJob
{
    MPPrintItem *printItem = [printLaterJob.printItems objectForKey:self.defaultPaper.sizeTitle];

    MPPageSettingsTableViewController *pageSettingsTableViewController;
    MPPageSettingsTableViewController *previewViewController;
    
    UIViewController *vc = [self printViewControllerWithDelegate:nil dataSource:nil printItem:printItem fromQueue:NO settingsOnly:NO];
    
    if( [vc isKindOfClass:[UISplitViewController class]] ) {
        UINavigationController *masterNavigationController = (UINavigationController *)((UISplitViewController *)vc).viewControllers[0];
        pageSettingsTableViewController = (MPPageSettingsTableViewController *)masterNavigationController.topViewController;
        pageSettingsTableViewController.printLaterJobs =  [[NSArray alloc] initWithObjects:printLaterJob, nil];
        pageSettingsTableViewController.printLaterDelegate = delegate;
        pageSettingsTableViewController.mode = MPPageSettingsModeAddToQueue;
        pageSettingsTableViewController.printItem = printItem;

        UINavigationController *previewNavigationController = (UINavigationController *)((UISplitViewController *)vc).viewControllers[1];
        previewViewController = (MPPageSettingsTableViewController *)previewNavigationController.topViewController;
        previewViewController.mode = MPPageSettingsModeAddToQueue;
        previewViewController.printLaterJobs =  [[NSArray alloc] initWithObjects:printLaterJob, nil];
        previewViewController.printItem = printItem;
    }
    
    return vc;
}

#pragma mark - Bluetooth

- (NSInteger)numberOfPairedSprockets
{
    return [MPBTSprocket pairedSprockets].count;
}

- (NSUInteger)printerVersionNumber
{
    return [[MPBTSprocket sharedInstance] firmwareVersion];
}

- (void)checkSprocketForFirmwareUpgrade:(id<MPSprocketDelegate>)delegate
{
    NSString *deviceName = nil;
    
    NSArray *pairedSprockets = [MPBTSprocket pairedSprockets];
    if (1 == pairedSprockets.count) {
        self.sprocketDelegate = delegate;
        EAAccessory *device = (EAAccessory *)pairedSprockets[0];
        [MPBTSprocket sharedInstance].accessory = device;
        [MPBTSprocket sharedInstance].delegate = self;
        [[MPBTSprocket sharedInstance] refreshInfo];
    }
}

- (void)didCompareWithLatestFirmwareVersion:(MPBTSprocket *)sprocket needsUpgrade:(BOOL)needsUpgrade
{
    if (needsUpgrade) {
        [self.sprocketDelegate didCompareSprocketWithLatestFirmwareVersion:sprocket.displayName batteryLevel:sprocket.batteryStatus needsUpgrade:needsUpgrade];
    }
    
    if (self == sprocket.delegate) {
        sprocket.delegate = nil;
    }
    
    self.sprocketDelegate = nil;
}

- (void)reflashBluetoothDevice:(UIViewController *)viewController
{
    NSArray *pairedDevices = [MPBTSprocket pairedSprockets];
    if (1 <= pairedDevices.count) {
        EAAccessory *device = (EAAccessory *)[pairedDevices objectAtIndex:0];
        [MPBTSprocket sharedInstance].accessory = device;

        MPBTProgressView *progressView = [[MPBTProgressView alloc] initWithFrame:viewController.view.frame];
        progressView.viewController = viewController;
        [progressView reflashDevice];
    }
}

- (void)obfuscateMetric:(NSString *)keyName
{
    [[MPAnalyticsManager sharedManager] obfuscateMetric:keyName];
}

- (void)presentBluetoothDevicesFromController:(UIViewController *)controller animated:(BOOL)animated completion:(void(^)(void))completion
{
    NSArray *pairedSprockets = [MPBTSprocket pairedSprockets];

    if (1 == pairedSprockets.count) {
        EAAccessory *device = (EAAccessory *)[pairedSprockets objectAtIndex:0];
        [MPBTDeviceInfoTableViewController presentAnimated:animated device:device usingController:controller  andCompletion:completion];
    } else {
        [MPBTPairedAccessoriesViewController presentAnimatedForDeviceInfo:animated usingController:controller andCompletion:completion];
    }
}

- (void)headlessBluetoothPrintFromController:(UIViewController *)controller image:(UIImage *)image animated:(BOOL)animated printCompletion:(void(^)(void))completion
{
    NSArray *pairedSprockets = [MPBTSprocket pairedSprockets];
    
    if (0 == pairedSprockets.count) {
        [MPBTPairedAccessoriesViewController presentNoPrinterConnectedAlert:controller];
    } else if (1 == pairedSprockets.count) {
        EAAccessory *device = (EAAccessory *)[pairedSprockets objectAtIndex:0];
        [MPBTSprocket sharedInstance].accessory = device;
        
        MPBTProgressView *progressView = [[MPBTProgressView alloc] initWithFrame:controller.view.frame];
        progressView.viewController = controller;
        [progressView printToDevice:image];
        if (completion) {
            completion();
        }
        
    } else {
        [MPBTPairedAccessoriesViewController presentAnimatedForPrint:animated image:image usingController:controller andPrintCompletion:completion];
    }
}

#pragma mark - Setter methods

- (UIUserNotificationCategory *)printLaterUserNotificationCategory
{
    return [[MPPrintLaterManager sharedInstance] printLaterUserNotificationCategory];
}

- (void)handleNotification:(UILocalNotification *)notification
{
    [[MPPrintLaterManager sharedInstance] handleNotification:notification];
}

- (void)handleNotification:(UILocalNotification *)notification action:(NSString *)action
{
    [[MPPrintLaterManager sharedInstance] handleNotification:notification action:action];
}

- (void)presentPrintQueueFromController:(UIViewController *)controller animated:(BOOL)animated completion:(void(^)(void))completion
{
    [MPPrintJobsViewController presentAnimated:animated usingController:controller andCompletion:completion];
}

- (NSInteger)numberOfJobsInQueue
{
    return [[MPPrintLaterQueue sharedInstance] retrieveNumberOfPrintLaterJobs];
}

- (NSString *)nextPrintJobId
{
    return [[MPPrintLaterQueue sharedInstance] retrievePrintLaterJobNextAvailableId];
}

- (void)clearQueue
{
    [[MPPrintLaterQueue sharedInstance] deleteAllPrintLaterJobs];
}

- (void)addJobToQueue:(MPPrintLaterJob *)job
{
    [[MPPrintLaterQueue sharedInstance] addPrintLaterJob:job fromController:nil];
}

- (BOOL)isWifiConnected
{
    return [[MPWiFiReachability sharedInstance] isWifiConnected];
}

#pragma mark - Print library version 

// This private method exists so it can be swizzled for testing. See MP+PrintLibraryVersion.h/m
- (NSString *)printLibraryVersion
{
    return kMPLibraryVersion;
}

@end
