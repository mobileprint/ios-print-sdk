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

#import <CoreLocation/CoreLocation.h>
#import "HPPPPrintLaterManager.h"
#import "HPPP.h"
#import "HPPPPrinter.h"
#import "HPPPPrintLaterQueue.h"
#import "HPPPDefaultSettingsManager.h"
#import "HPPPPrintJobsTableViewController.h"
#import "NSBundle+HPPPLocalizable.h"

const int kSecondsInOneHour = (60 * 60);
const CLLocationDistance kDefaultPrinterRadiusInMeters = 20.0f;
NSString * const kDefaultPrinterRegionIdentifier = @"DEFAULT_PRINTER_IDENTIFIER";
NSString * const kUserNotificationsPermissionSetKey = @"kUserNotificationsPermissionSetKey";


@interface HPPPPrintLaterManager() <CLLocationManagerDelegate>

@property (strong, nonatomic) CLLocationManager *locationManager;
@property (strong, nonatomic) HPPPDefaultSettingsManager *defaultSettingsManager;

@end

@implementation HPPPPrintLaterManager

+ (HPPPPrintLaterManager *)sharedInstance
{
    static HPPPPrintLaterManager *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[HPPPPrintLaterManager alloc] init];
    });
    
    return sharedInstance;
}

- (id)init
{
    self = [super init];
    if (self) {
        self.defaultSettingsManager = [HPPPDefaultSettingsManager sharedInstance];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handlePrintJobAddedToQueueNotification:) name:kHPPPPrintJobAddedToQueueNotification object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleAllPrintJobsRemovedFromQueueNotification:) name:kHPPPAllPrintJobsRemovedFromQueueNotification object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleDefaultPrinterAddedNotification:) name:kHPPPDefaultPrinterAddedNotification object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleDefaultPrinterRemovedNotification:) name:kHPPPDefaultPrinterRemovedNotification object:nil];
    }
    
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)initLocationManager
{
    if (nil == self.locationManager) {
        self.locationManager = [[CLLocationManager alloc] init];
        [self.locationManager requestAlwaysAuthorization];
        self.locationManager.delegate = self;
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
        self.locationManager.distanceFilter = 5.0f;
        self.locationManager.activityType = CLActivityTypeOtherNavigation;
        
        if (![CLLocationManager isMonitoringAvailableForClass:[CLCircularRegion class]]) {
            [[[UIAlertView alloc] initWithTitle:HPPPLocalizedString(@"Monitoring not available", @"Monitoring of regions (location) not available")
                                        message:HPPPLocalizedString(@"Your device does not support the region monitoring, it is not possible to fire alarms base on position", nil)
                                       delegate:nil
                              cancelButtonTitle:nil
                              otherButtonTitles:nil] show];
        }
        
        if ([[HPPPPrintLaterQueue sharedInstance] retrieveNumberOfPrintLaterJobs] > 0) {
            if ([self.defaultSettingsManager isDefaultPrinterSet]) {
                NSLog(@"Print jobs in the queue and default printer set");
                [self.locationManager startUpdatingLocation];
            }
        }
    }
}

- (BOOL)currentLocationPermissionSet
{
    return !(([CLLocationManager authorizationStatus] == kCLAuthorizationStatusNotDetermined) || ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusRestricted));
}

#pragma mark - Notifications

- (void)handlePrintJobAddedToQueueNotification:(NSNotification *)notification
{
    if ([[HPPPPrintLaterQueue sharedInstance] retrieveNumberOfPrintLaterJobs] == 1) {
        // It is the first one, so add the monitoring
        if ([self.defaultSettingsManager isDefaultPrinterSet]) {
            NSLog(@"First print job added and default printer set");
            [self.locationManager startUpdatingLocation];
            [self addMonitoringForDefaultPrinter];
        }
    }
}

- (void)handleAllPrintJobsRemovedFromQueueNotification:(NSNotification *)notification
{
    if ([self.defaultSettingsManager isDefaultPrinterSet]) {
        NSLog(@"All print jobs removed and default printer set");
        [self removeMonitoringForDefaultPrinter];
        [self.locationManager stopUpdatingLocation];
    }
}

- (void)handleDefaultPrinterAddedNotification:(NSNotification *)notification
{
    if ([[HPPPPrintLaterQueue sharedInstance] retrieveNumberOfPrintLaterJobs] > 0) {
        NSLog(@"Default printer added and print jobs in the queue");
        [self.locationManager startUpdatingLocation];
        [self addMonitoringForDefaultPrinter];
    }
}

- (void)handleDefaultPrinterRemovedNotification:(NSNotification *)notification
{
    if ([[HPPPPrintLaterQueue sharedInstance] retrieveNumberOfPrintLaterJobs] > 0) {
        NSLog(@"Default printer removed and print jobs in the queue");
        [self removeMonitoringForDefaultPrinter];
        [self.locationManager stopUpdatingLocation];
    }
}

#pragma mark - Utils

- (void)addMonitoringForDefaultPrinter
{
    NSLog(@"Adding monitoring for default printer");
    CLCircularRegion *region = [[CLCircularRegion alloc] initWithCenter:self.defaultSettingsManager.defaultPrinterCoordinate radius:kDefaultPrinterRadiusInMeters identifier:kDefaultPrinterRegionIdentifier];
    
    [self.locationManager startMonitoringForRegion:region];
}

- (void)removeMonitoringForDefaultPrinter
{
    NSLog(@"Removing monitoring for default printer");
    for (CLRegion *region in self.locationManager.monitoredRegions) {
        if ([self isDefaultPrinterRegion:region]) {
            [self.locationManager stopMonitoringForRegion:region];
        }
    }
}

- (UILocalNotification *)localNotification
{
    UILocalNotification *localNotification = [[UILocalNotification alloc] init];
    
    localNotification.timeZone = [NSTimeZone defaultTimeZone];
    
    localNotification.soundName = UILocalNotificationDefaultSoundName;
    localNotification.alertBody = HPPPLocalizedString(@"Printer available. Projects waiting...", @"The printer is available and there are print later jobs in the print queue");
    [localNotification setHasAction:NO];
    
    localNotification.category = kPrintCategoryIdentifier;
    
    return localNotification;
}

// Method call when the region is entered and there are jobs in the print queue
- (void)fireNotificationIfPrinterIsAvailable
{
    [[HPPPPrinter sharedInstance] checkDefaultPrinterAvailabilityWithCompletion:^(BOOL available) {
        if (available) {
            UILocalNotification *localNotification = [self localNotification];
            [[UIApplication sharedApplication] presentLocalNotificationNow:localNotification];
        }
    }];
}

- (BOOL)isDefaultPrinterRegion:(CLRegion *)region
{
    return ([region.identifier isEqualToString:kDefaultPrinterRegionIdentifier]);
}

- (void)fireNotificationLater
{
    UILocalNotification *localNotification = [self localNotification];
    localNotification.fireDate = [NSDate dateWithTimeIntervalSinceNow:(kSecondsInOneHour / 2)];
    [[UIApplication sharedApplication] scheduleLocalNotification:localNotification];
}

- (CLLocationCoordinate2D)retrieveCurrentLocation
{
    CLLocation *location = [self.locationManager location];
    return [location coordinate];
}

#pragma mark - CLLocationManagerDelegate

- (void)locationManager:(CLLocationManager *)manager
    didUpdateToLocation:(CLLocation *)newLocation
           fromLocation:(CLLocation *)oldLocation
{
    static BOOL contactingPrinter = NO;
    
    NSLog(@"Location updated: (old %f %f) (new %f %f)", oldLocation.coordinate.latitude, oldLocation.coordinate.longitude, newLocation.coordinate.latitude, newLocation.coordinate.longitude);
    
    if (!contactingPrinter) {
        // There are many reason why we want to do this...
        // First the user may have rejected the permission to use current location and later, after the default printer was set, he allowed it in the settings.
        // Second at the moment of adding the default printer the GPS signal was lost or not yet retrieved (could be 0,0).
        // TBD if we want to do this regardless the latitude = 0 and longitude = 0, the home printer can change its location...
        CLLocationCoordinate2D coordinate = [HPPPDefaultSettingsManager sharedInstance].defaultPrinterCoordinate;
        
        if ((coordinate.latitude == 0.0f) && (coordinate.longitude == 0.0f)) {
            
            contactingPrinter = YES;
            
            [[HPPPPrinter sharedInstance] checkDefaultPrinterAvailabilityWithCompletion:^(BOOL available) {
                if (available) {
                    [HPPPDefaultSettingsManager sharedInstance].defaultPrinterCoordinate = newLocation.coordinate;
                    if ([[HPPPPrintLaterQueue sharedInstance] retrieveNumberOfPrintLaterJobs] > 0) {
                        [self removeMonitoringForDefaultPrinter];
                        [self addMonitoringForDefaultPrinter];
                    }
                }
                
                contactingPrinter = NO;
            }];
        }
    }
}

- (void)locationManager:(CLLocationManager *)manager didEnterRegion:(CLRegion *)region
{
    NSLog(@"Region entered: %@", region.identifier);
    
    if ([self isDefaultPrinterRegion:region]) {
        [self fireNotificationIfPrinterIsAvailable];
    }
}

- (void)locationManager:(CLLocationManager *)manager didExitRegion:(CLRegion *)region
{
    NSLog(@"Region exited: %@", region.identifier);
}

- (void)locationManager:(CLLocationManager *)manager monitoringDidFailForRegion:(CLRegion *)region withError:(NSError *)error
{
    NSLog(@"Region Fail: %@", region.identifier);
}

- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status
{
    NSLog(@"Status %d", status);
    
    if (status == kCLAuthorizationStatusDenied) {
        NSLog(@"Current location permission denied");
        [[HPPPPrintLaterManager sharedInstance] initUserNotifications];
    } else if ((status == kCLAuthorizationStatusAuthorizedAlways) || (status == kCLAuthorizationStatusAuthorizedWhenInUse)) {
        NSLog(@"Current location permission granted");
        [[HPPPPrintLaterManager sharedInstance] initUserNotifications];
    }
}

#pragma mark - Notifications methods

- (void)showPrintJobsTableViewController
{
    UIViewController *viewController = [self keyWindowTopMostController];
    
    if (![viewController isKindOfClass:[HPPPPrintJobsTableViewController class]]) {
        [HPPPPrintJobsTableViewController presentAnimated:YES usingController:viewController andCompletion:nil];
    }
}

- (void)handleNotification:(UILocalNotification *)notification action:(NSString *)action
{
    if ([notification.category isEqualToString:kPrintCategoryIdentifier]) {
        if ([action isEqualToString:kLaterActionIdentifier]) {
            [self fireNotificationLater];
            NSLog(@"Notification will fire again in %d seconds", (kSecondsInOneHour / 2));
        } else if ([action isEqualToString:kPrintActionIdentifier]) {
            [self showPrintJobsTableViewController];
        }
    }
}

- (void)handleNotification:(UILocalNotification *)notification
{
    if ([notification.category isEqualToString:kPrintCategoryIdentifier]) {
        [self showPrintJobsTableViewController];
    }
}

- (UIViewController *)keyWindowTopMostController
{
    UIViewController *topController = [UIApplication sharedApplication].keyWindow.rootViewController;
    
    while (topController.presentedViewController) {
        topController = topController.presentedViewController;
    }
    
    if ([topController isKindOfClass:[UINavigationController class]]) {
        topController = ((UINavigationController *)topController).topViewController;
    }
    
    return topController;
}

#pragma mark - User Notifications methods

- (UIUserNotificationCategory *)printLaterUserNotificationCategory
{
    if (nil == _printLaterUserNotificationCategory) {
        UIMutableUserNotificationAction *laterAction = [[UIMutableUserNotificationAction alloc] init];
        laterAction.identifier = kLaterActionIdentifier;
        laterAction.activationMode = UIUserNotificationActivationModeBackground;
        laterAction.title = HPPPLocalizedString(@"Later", @"Option of the push notification to send another push notification later");
        laterAction.destructive = NO;
        
        UIMutableUserNotificationAction *printAction = [[UIMutableUserNotificationAction alloc] init];
        printAction.identifier = kPrintActionIdentifier;
        printAction.activationMode = UIUserNotificationActivationModeForeground;
        printAction.title = HPPPLocalizedString(@"Print", @"Option of the push notification to print the print later job");
        printAction.destructive = NO;
        
        UIMutableUserNotificationCategory *category = [[UIMutableUserNotificationCategory alloc] init];
        category.identifier = kPrintCategoryIdentifier;
        [category setActions:@[laterAction, printAction] forContext:UIUserNotificationActionContextDefault];
        [category setActions:@[laterAction, printAction] forContext:UIUserNotificationActionContextMinimal];
        
        _printLaterUserNotificationCategory = category.copy;
    }
    
    return _printLaterUserNotificationCategory;
}

- (void)initUserNotifications
{
    if (nil == _printLaterUserNotificationCategory) {
        UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:UIUserNotificationTypeSound|UIUserNotificationTypeBadge|UIUserNotificationTypeAlert categories:[NSSet setWithObjects:self.printLaterUserNotificationCategory, nil]];
        [[UIApplication sharedApplication] registerUserNotificationSettings:settings];
        
        self.userNotificationsPermissionSet = YES;
    }
}

- (BOOL)userNotificationsPermissionSet
{
    return [[NSUserDefaults standardUserDefaults] boolForKey:kUserNotificationsPermissionSetKey];
}

- (void)setUserNotificationsPermissionSet:(BOOL)userNotificationsPermissionSet
{
    NSUserDefaults * defaults = [NSUserDefaults standardUserDefaults];
    [defaults setBool:userNotificationsPermissionSet forKey:kUserNotificationsPermissionSetKey];
    [defaults synchronize];
}


@end
