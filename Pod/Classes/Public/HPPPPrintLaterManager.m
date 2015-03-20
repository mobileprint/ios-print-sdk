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
        //
    }
    return self;
}

- (void)initLocationManager
{
    self.locationManager = [[CLLocationManager alloc] init];
    [self.locationManager requestAlwaysAuthorization];
    self.locationManager.delegate = self;
    self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    self.locationManager.distanceFilter = kCLDistanceFilterNone;
    self.locationManager.activityType = CLActivityTypeOtherNavigation;
    
    [self.locationManager startUpdatingLocation];
    
    if (![CLLocationManager isMonitoringAvailableForClass:[CLCircularRegion class]]) {
        [[[UIAlertView alloc] initWithTitle:@"Monitoring not available" message:@"Your device does not support the region monitoring, it is not possible to fire alarms base on position" delegate:nil cancelButtonTitle:nil otherButtonTitles:nil] show];
    } else {
        for (CLRegion *region in self.locationManager.monitoredRegions) {
            [self.locationManager stopMonitoringForRegion:region];
        }
    }
}

#pragma mark - Utils

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
    
    if ([[HPPPPrintLaterQueue sharedInstance] retrieveNumberOfPrintLaterJobs] > 0) {
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
    if (status == kCLAuthorizationStatusDenied) {
        //location denied, handle accordingly
    }
    else if (status == kCLAuthorizationStatusAuthorizedAlways) {
        
    }
}

@end
