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

#import "HPPPDefaultSettingsManager.h"

NSString * const kDefaultPrinterNameKey = @"kDefaultPrinterNameKey";
NSString * const kDefaultPrinterURLKey = @"kDefaultPrinterURLKey";
NSString * const kDefaultPrinterNetworkKey = @"kDefaultPrinterNetworkKey";
NSString * const kDefaultPrinterLatitudeCoordinateKey = @"kDefaultPrinterLatitudeCoordinateKey";
NSString * const kDefaultPrinterLongitudeCoordinateKey = @"kDefaultPrinterLongitudeCoordinateKey";
NSString * const kDefaultPrinterModelKey = @"kDefaultPrinterModelKey";
NSString * const kDefaultPrinterLocationKey = @"kDefaultPrinterLocationKey";

@implementation HPPPDefaultSettingsManager

#pragma mark - Public methods

+ (HPPPDefaultSettingsManager *)sharedInstance
{
    static HPPPDefaultSettingsManager *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[HPPPDefaultSettingsManager alloc] init];
    });
    
    return sharedInstance;
}

#pragma mark - Getter and setter methods

- (NSString *)defaultPrinterName
{
    return [[NSUserDefaults standardUserDefaults] objectForKey:kDefaultPrinterNameKey];
}

-(void)setDefaultPrinterName:(NSString *)defaultPrinterName
{
    NSUserDefaults * defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:defaultPrinterName forKey:kDefaultPrinterNameKey];
    [defaults synchronize];
}

- (NSString *)defaultPrinterUrl
{
    return [[NSUserDefaults standardUserDefaults] objectForKey:kDefaultPrinterURLKey];
}

-(void)setDefaultPrinterUrl:(NSString *)defaultPrinterUrl
{
    NSUserDefaults * defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:defaultPrinterUrl forKey:kDefaultPrinterURLKey];
    [defaults synchronize];
}

- (NSString *)defaultPrinterNetwork
{
    return [[NSUserDefaults standardUserDefaults] objectForKey:kDefaultPrinterNetworkKey];
}

-(void)setDefaultPrinterNetwork:(NSString *)defaultPrinterNetwork
{
    NSUserDefaults * defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:defaultPrinterNetwork forKey:kDefaultPrinterNetworkKey];
    [defaults synchronize];
}

- (CLLocationCoordinate2D)defaultPrinterCoordinate
{
    CLLocationCoordinate2D coordinate;
    coordinate.latitude = [[NSUserDefaults standardUserDefaults] floatForKey:kDefaultPrinterLatitudeCoordinateKey];
    coordinate.longitude = [[NSUserDefaults standardUserDefaults] floatForKey:kDefaultPrinterLongitudeCoordinateKey];
    return coordinate;
}

-(void)setDefaultPrinterCoordinate:(CLLocationCoordinate2D)defaultPrinterCoordinate
{
#if TARGET_IPHONE_SIMULATOR
    // This allows us to test geo-fencing even on the simulator
    //   Go to the simulator's "Debug" menu
    //   Select "Location"
    //   Select "Custom location..."
    //   Enter something other than lat = 10, long = 10 to exit the region
    //   Enter lat = 10, long = 10 to re-enter the region
    if( 0 == defaultPrinterCoordinate.latitude && 0 == defaultPrinterCoordinate.longitude ) {
        defaultPrinterCoordinate.latitude  = 10;
        defaultPrinterCoordinate.longitude = 10;
    }
#endif
    
    NSUserDefaults * defaults = [NSUserDefaults standardUserDefaults];
    [defaults setFloat:defaultPrinterCoordinate.latitude forKey:kDefaultPrinterLatitudeCoordinateKey];
    [defaults setFloat:defaultPrinterCoordinate.longitude forKey:kDefaultPrinterLongitudeCoordinateKey];
    [defaults synchronize];
    
    HPPPLogInfo(@"DEFAULT PRINTER COORDINATES:\nlat:%f\nlon:%f", defaultPrinterCoordinate.latitude, defaultPrinterCoordinate.longitude);
}

- (NSString *)defaultPrinterModel
{
    return [[NSUserDefaults standardUserDefaults] objectForKey:kDefaultPrinterModelKey];
}

-(void)setDefaultPrinterModel:(NSString *)defaultPrinterModel
{
    NSUserDefaults * defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:defaultPrinterModel forKey:kDefaultPrinterModelKey];
    [defaults synchronize];
}

- (NSString *)defaultPrinterLocation
{
    return [[NSUserDefaults standardUserDefaults] objectForKey:kDefaultPrinterLocationKey];
}

-(void)setDefaultPrinterLocation:(NSString *)defaultPrinterLocation
{
    NSUserDefaults * defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:defaultPrinterLocation forKey:kDefaultPrinterLocationKey];
    [defaults synchronize];
}

- (BOOL)isDefaultPrinterSet
{
    NSString *defaultPrinterName = [self defaultPrinterName];
    
    return (nil != defaultPrinterName);
}

@end
