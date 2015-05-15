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

#import <MapKit/MapKit.h>
#import "HPPPPrintLaterHelperViewController.h"

#define DEFAULT_SPAN_X 0.00725
#define DEFAULT_SPAN_Y 0.00725

@interface HPPPPrintLaterHelperViewController () <CLLocationManagerDelegate, MKMapViewDelegate>

@property (strong, nonatomic) CLLocationManager *locationManager;
@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@property (weak, nonatomic) IBOutlet UIButton *currentLocationButton;

@end


@implementation HPPPPrintLaterHelperViewController


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
    
    self.currentLocationButton.layer.borderWidth = 1.0f;
    self.currentLocationButton.layer.cornerRadius = self.currentLocationButton.frame.size.width / 2;
    self.currentLocationButton.layer.borderColor = [UIColor blackColor].CGColor;
    self.currentLocationButton.hidden = YES;
    
    [self initLocationManager];
    
    [self initMapView];
    
    for (CLRegion *region in self.locationManager.monitoredRegions) {
        MKPointAnnotation *ann = [[MKPointAnnotation alloc] init];
        ann.title = @"Printer";
        ann.subtitle = @"Default Printer";
        ann.coordinate = region.center;
        [self.mapView addAnnotation:ann];
        
        MKCircle *circle = [MKCircle circleWithCenterCoordinate:region.center radius:region.radius];
        [self.mapView addOverlay:circle];
    }
}

- (IBAction)doneButtonTapped:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma marks - Utils

- (void)centerInCoordinate:(CLLocationCoordinate2D)coordinate
{
    [self.mapView setCenterCoordinate:coordinate animated:YES];
}

- (void)centerInCoordinate:(CLLocationCoordinate2D)coordinate spanX:(CLLocationDegrees)spanX spanY:(CLLocationDegrees)spanY
{
    MKCoordinateRegion region;
    region.center = coordinate;
    region.span = MKCoordinateSpanMake(spanX, spanY);
    [self.mapView setRegion:region animated:YES];
}

- (MKOverlayView *)mapView:(MKMapView *)map viewForOverlay:(id <MKOverlay>)overlay
{
    MKCircleView *circleView = [[MKCircleView alloc] initWithOverlay:overlay];
    circleView.lineWidth = 1;
    
    circleView.strokeColor = [UIColor redColor];
    circleView.fillColor = [[UIColor redColor] colorWithAlphaComponent:0.3];
    
    return circleView;
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
    if (status == kCLAuthorizationStatusAuthorizedAlways) {
        self.mapView.showsUserLocation = YES;
        self.mapView.userTrackingMode = MKUserTrackingModeFollow;
    }
}

@end
