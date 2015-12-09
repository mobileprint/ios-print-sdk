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

#import <MapKit/MapKit.h>
#import "MPPrintLaterHelperViewController.h"
#import "MPDefaultSettingsManager.h"
#import "MPPrintLaterManager.h"
#import "MPPrinter.h"

#define DEFAULT_SPAN_X 0.01
#define DEFAULT_SPAN_Y 0.01

@interface MPPrintLaterHelperViewController () <CLLocationManagerDelegate, MKMapViewDelegate>

@property (strong, nonatomic) CLLocationManager *locationManager;
@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@property (weak, nonatomic) IBOutlet UILabel *printerNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *printerCoordinatesLabel;
@property (weak, nonatomic) IBOutlet UILabel *radiusLabel;
@property (weak, nonatomic) IBOutlet UILabel *enableLabel;
@property (weak, nonatomic) IBOutlet UILabel *currentLocationCoordinatesLabel;
@property (weak, nonatomic) IBOutlet UILabel *distanceLabel;
@property (weak, nonatomic) IBOutlet UILabel *notificationReceivedView;
@property (weak, nonatomic) IBOutlet UILabel *insideRegionLabel;

@end


@implementation MPPrintLaterHelperViewController

#pragma mark - Init

- (void)initLocationManager
{
    self.locationManager = [[CLLocationManager alloc] init];
    [self.locationManager requestAlwaysAuthorization];
    
    self.locationManager.delegate = self;
    self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    self.locationManager.distanceFilter = 5.0f;
    self.locationManager.activityType = CLActivityTypeOtherNavigation;
    
    [self.locationManager startUpdatingLocation];
}

- (void)initMapView
{
    [self centerInCoordinate:self.mapView.userLocation.location.coordinate spanX:DEFAULT_SPAN_X spanY:DEFAULT_SPAN_Y];
    self.mapView.delegate = self;
    [self.mapView showsBuildings];
    [self.mapView showsPointsOfInterest];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.insideRegionLabel.text = @"";
    
    [self initLocationManager];
    
    [self initMapView];
    
    BOOL defaultPrinterMonitored = NO;
    
    for (CLCircularRegion *region in self.locationManager.monitoredRegions) {
        if ([[MPPrintLaterManager sharedInstance] isDefaultPrinterRegion:region]) {
            MKPointAnnotation *ann = [[MKPointAnnotation alloc] init];
            ann.title = [self defaultPrinterName];
            ann.coordinate = region.center;
            [self.mapView addAnnotation:ann];
            
            MKCircle *circle = [MKCircle circleWithCenterCoordinate:region.center radius:region.radius];
            [self.mapView addOverlay:circle];
            
            defaultPrinterMonitored = YES;
        }
    }
    
    MPDefaultSettingsManager *defaultSettingsManager = [MPDefaultSettingsManager sharedInstance];
    self.printerNameLabel.text = [self defaultPrinterName];
    self.printerCoordinatesLabel.text = [NSString stringWithFormat:@"%f, %f", defaultSettingsManager.defaultPrinterCoordinate.latitude, defaultSettingsManager.defaultPrinterCoordinate.longitude];
    self.radiusLabel.text = [NSString stringWithFormat:@"%.02f meters", kDefaultPrinterRadiusInMeters];
    self.enableLabel.text = defaultPrinterMonitored ? @"YES" : @"NO";
}

-(void)dealloc
{
    [self.locationManager stopUpdatingLocation];
    self.locationManager = nil;
}

#pragma mark - Action buttons

- (IBAction)doneButtonTapped:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma marks - Utils

- (NSString *)defaultPrinterName
{
    MPDefaultSettingsManager *defaultSettingsManager = [MPDefaultSettingsManager sharedInstance];
    
    NSString *defaultPrinterName = @"Not Set";
    if (defaultSettingsManager.defaultPrinterName != nil) {
        defaultPrinterName = defaultSettingsManager.defaultPrinterName;
    }
    
    return defaultPrinterName;
}

- (void)centerInCoordinate:(CLLocationCoordinate2D)coordinate spanX:(CLLocationDegrees)spanX spanY:(CLLocationDegrees)spanY
{
    MKCoordinateRegion region;
    region.center = coordinate;
    region.span = MKCoordinateSpanMake(spanX, spanY);
    [self.mapView setRegion:region animated:YES];
}

#pragma mark - MKMapViewDelegate

- (MKOverlayRenderer *)mapView:(MKMapView *)mapView rendererForOverlay:(id<MKOverlay>)overlay
{
    MKCircle *circle = [MKCircle circleWithCenterCoordinate:[overlay coordinate] radius:kDefaultPrinterRadiusInMeters];
    MKCircleRenderer *circleRenderer = [[MKCircleRenderer alloc] initWithCircle:circle];
    circleRenderer.lineWidth = 1;
    circleRenderer.strokeColor = [UIColor redColor];
    circleRenderer.fillColor = [[UIColor redColor] colorWithAlphaComponent:0.3];
    return circleRenderer;
}

#pragma mark - CLLocationManagerDelegate

- (void)locationManager:(CLLocationManager *)manager
    didUpdateToLocation:(CLLocation *)newLocation
           fromLocation:(CLLocation *)oldLocation
{
    self.currentLocationCoordinatesLabel.text = [NSString stringWithFormat:@"%f, %f", newLocation.coordinate.latitude, newLocation.coordinate.longitude];
    
    CLLocationCoordinate2D defaultPrinterCoordinates = [MPDefaultSettingsManager sharedInstance].defaultPrinterCoordinate;
    
    CLLocation *defaultPrinterLocation = [[CLLocation alloc] initWithLatitude:defaultPrinterCoordinates.latitude longitude:defaultPrinterCoordinates.longitude];
    
    CLLocationDistance distance = [newLocation distanceFromLocation:defaultPrinterLocation];
    
    self.distanceLabel.text = [NSString stringWithFormat:@"%.02f meters away", distance];
    
    for (CLRegion *region in self.locationManager.monitoredRegions) {
        [self.locationManager requestStateForRegion:region];
    }
}

- (void)locationManager:(CLLocationManager *)manager didEnterRegion:(CLRegion *)region
{
    if ([[MPPrintLaterManager sharedInstance] isDefaultPrinterRegion:region]) {
        
        self.notificationReceivedView.text = @"Notification received";
        
        [[[UIAlertView alloc] initWithTitle:@"Push notification"
                                    message:@"Entering printer region. Notification received."
                                   delegate:nil
                          cancelButtonTitle:@"OK"
                          otherButtonTitles:nil] show];
                
        [UIView animateWithDuration:1.0f animations:^{
            self.notificationReceivedView.alpha = 1.0f;
        } completion:^(BOOL finished) {
            [UIView animateWithDuration:1.0f delay:4.0f options:UIViewAnimationOptionCurveEaseIn animations:^{
                self.notificationReceivedView.alpha = 0.0f;
            } completion:nil];
        }];
    }
}

- (void)locationManager:(CLLocationManager *)manager didExitRegion:(CLRegion *)region
{
    if ([[MPPrintLaterManager sharedInstance] isDefaultPrinterRegion:region]) {
        [[[UIAlertView alloc] initWithTitle:@"Push notification"
                                    message:@"Exiting printer region."
                                   delegate:nil
                          cancelButtonTitle:@"OK"
                          otherButtonTitles:nil] show];
    }
}

- (void)locationManager:(CLLocationManager *)manager didDetermineState:(CLRegionState)state forRegion:(CLRegion *)region
{
    if (state != CLRegionStateInside) {
        self.insideRegionLabel.text = @"Ouside region";
    } else {
        self.insideRegionLabel.text = @"Inside region";
    }
}

- (void)locationManager:(CLLocationManager *)manager monitoringDidFailForRegion:(CLRegion *)region withError:(NSError *)error
{
    if ([[MPPrintLaterManager sharedInstance] isDefaultPrinterRegion:region]) {
        [[[UIAlertView alloc] initWithTitle:@"Push notification"
                                    message:@"Fail to monitor printer region."
                                   delegate:nil
                          cancelButtonTitle:@"OK"
                          otherButtonTitles:nil] show];
    }
}

- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status
{
    if (status == kCLAuthorizationStatusAuthorizedAlways) {
        self.mapView.showsUserLocation = YES;
        self.mapView.userTrackingMode = MKUserTrackingModeFollow;
    }
}

@end
