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
#import "HPPPPrinter.h"
#import "HPPPPrintLaterQueue.h"

const int kSecondsInOneHour = (60 * 60);

@interface HPPPPrintLaterManager() <CLLocationManagerDelegate>

@property (strong, nonatomic) CLLocationManager *locationManager;

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
        [self initLocationManager];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handlePrintJobAddedToQueueNotification:) name:kHPPPPrintJobAddedToQueueNotification object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleAllPrintJobsRemovedFromQueueNotification:) name:kHPPPAllPrintJobsRemovedFromQueueNotification object:nil];
        
//        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleDefaultPrinterAddedNotification:) name:kHPPPDefaultPrinterAddedNotification object:nil];
//        
//        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleDefaultPrinterRemovedNotification:) name:kHPPPDefaultPrinterRemovedNotification object:nil];
    }
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)initLocationManager
{
    self.locationManager = [[CLLocationManager alloc] init];
    [self.locationManager requestAlwaysAuthorization];
    self.locationManager.delegate = self;
    self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    self.locationManager.distanceFilter = 5.0f;
    self.locationManager.activityType = CLActivityTypeOtherNavigation;
    
    // TODO. NOTE to myself. check if we need to start the updating location to use the region monitoring, otherwise delete that line
    [self.locationManager startUpdatingLocation];
    
    if (![CLLocationManager isMonitoringAvailableForClass:[CLCircularRegion class]]) {
        [[[UIAlertView alloc] initWithTitle:@"Monitoring not available" message:@"Your device does not support the region monitoring, it is not possible to fire alarms base on position" delegate:nil cancelButtonTitle:nil otherButtonTitles:nil] show];
    }
}

#pragma mark - Notifications

- (void)handlePrintJobAddedToQueueNotification:(NSNotification *)notification
{
    if ([[HPPPPrintLaterQueue sharedInstance] retrieveNumberOfPrintLaterJobs] == 1) {
        // It is the first one, so add the monitoring
        if ([self isDefaultPrinterSet]) {
            [self addMonitoringForDefaultPrinter];
        }
    }
}

- (void)handleAllPrintJobsRemovedFromQueueNotification:(NSNotification *)notification
{
    if ([self isDefaultPrinterSet]) {
        [self removeMonitoringForDefaultPrinter];
    }
}

- (void)handleDefaultPrinterAddedNotification:(NSNotification *)notification
{
    if ([[HPPPPrintLaterQueue sharedInstance] retrieveNumberOfPrintLaterJobs] > 0) {
        [self addMonitoringForDefaultPrinter];
    }
}

- (void)handleDefaultPrinterRemovedNotification:(NSNotification *)notification
{
    if ([[HPPPPrintLaterQueue sharedInstance] retrieveNumberOfPrintLaterJobs] > 0) {
        [self removeMonitoringForDefaultPrinter];
    }
}

#pragma mark - Utils

- (BOOL)isDefaultPrinterSet
{
    return YES;
}

- (void)addMonitoringForDefaultPrinter
{
    
}

- (void)removeMonitoringForDefaultPrinter
{
    
}

- (UILocalNotification *)localNotification
{
    UILocalNotification *localNotification = [[UILocalNotification alloc] init];
    
    localNotification.timeZone = [NSTimeZone defaultTimeZone];
    
    localNotification.soundName = UILocalNotificationDefaultSoundName;
    localNotification.alertBody = @"Printer available. Projects waiting...";
    [localNotification setHasAction:NO];
    
    localNotification.category = @"PRINT_CATEGORY_IDENTIFIER";
    
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
    return YES;
}

- (void)fireNotificationLater
{
    UILocalNotification *localNotification = [self localNotification];
    localNotification.fireDate = [NSDate dateWithTimeIntervalSinceNow:(kSecondsInOneHour / 2)];
    [[UIApplication sharedApplication] scheduleLocalNotification:localNotification];
}

#pragma mark - CLLocationManagerDelegate

- (void)locationManager:(CLLocationManager *)manager
    didUpdateToLocation:(CLLocation *)newLocation
           fromLocation:(CLLocation *)oldLocation
{
    NSLog(@"Location updated: (old %f %f) (new %f %f)", oldLocation.coordinate.latitude, oldLocation.coordinate.longitude, newLocation.coordinate.latitude, newLocation.coordinate.longitude);
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
        [[[UIAlertView alloc] initWithTitle:@"Monitoring of default printer" message:@"You won't be notify when you are in the region of your default printer and you have print later jobs" delegate:nil cancelButtonTitle:nil otherButtonTitles:nil] show];
    }
    else if (status == kCLAuthorizationStatusAuthorizedAlways) {
        
    }
}

@end
