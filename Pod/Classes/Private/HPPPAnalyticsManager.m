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
#import "HPPPPageRange.h"
#import "HPPPPrintManager.h"
#import <sys/sysctl.h>
#import <SystemConfiguration/CaptiveNetwork.h>
#import <CommonCrypto/CommonDigest.h>

NSString * const kHPPPMetricsServer = @"print-metrics-w1.twosmiles.com/api/v1/mobile_app_metrics";
NSString * const kHPPPMetricsServerTestBuilds = @"print-metrics-test.twosmiles.com/api/v1/mobile_app_metrics";
//NSString * const kHPPPMetricsServerTestBuilds = @"localhost:4567/api/v1/mobile_app_metrics"; // use for local testing
NSString * const kHPPPMetricsUsername = @"hpmobileprint";
NSString * const kHPPPMetricsPassword = @"print1t";
NSString * const kHPPPOSType = @"iOS";
NSString * const kHPPPManufacturer = @"Apple";
NSString * const kHPPPNoNetwork = @"NO-WIFI";
NSString * const kHPPPNoPrint = @"No Print";
NSString * const kHPPPNoContent = @"No Content";
NSString * const kHPPPOfframpKey = @"off_ramp";
NSString * const kHPPPContentTypeKey = @"content_type";
NSString * const kHPPPContentWidthKey = @"content_width_pixels";
NSString * const kHPPPContentHeightKey = @"content_height_pixels";
NSString * const kHPPPMetricsDeviceBrand = @"device_brand";
NSString * const kHPPPMetricsDeviceID = @"device_id";
NSString * const kHPPPMetricsDeviceType = @"device_type";
NSString * const kHPPPMetricsManufacturer = @"manufacturer";
NSString * const kHPPPMetricsOSType = @"os_type";
NSString * const kHPPPMetricsOSVersion = @"os_version";
NSString * const kHPPPMetricsProductID = @"product_id";
NSString * const kHPPPMetricsProductName = @"product_name";
NSString * const kHPPPMetricsVersion = @"version";
NSString * const kHPPPMetricsPrintLibraryVersion = @"print_library_version";
NSString * const kHPPPMetricsWiFiSSID = @"wifi_ssid";
NSString * const kHPPPMetricsAppType = @"app_type";
NSString * const kHPPPMetricsAppTypeHP = @"HP";
NSString * const kHPPPMetricsAppTypePartner = @"Partner";
NSString * const kHPPPMetricsNotCollected = @"Not Collected";

@interface HPPPAnalyticsManager ()

@property (nonatomic, strong, readonly) NSString *userUniqueIdentifier;

@end

@implementation HPPPAnalyticsManager

#pragma mark - Initialization

+ (HPPPAnalyticsManager *)sharedManager
{
    static HPPPAnalyticsManager *sharedManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedManager = [[self alloc] init];
        [sharedManager setupSettings];
    });
    
    return sharedManager;
}

- (void)setupSettings
{
    _userUniqueIdentifier = [[UIDevice currentDevice].identifierForVendor UUIDString];
}

- (NSURL *)metricsServerURL
{
    NSURL *productionURL = [NSURL URLWithString:[NSString stringWithFormat:@"https://%@:%@@%@", kHPPPMetricsUsername, kHPPPMetricsPassword, kHPPPMetricsServer]];
    NSURL *testURL = [NSURL URLWithString:[NSString stringWithFormat:@"http://%@:%@@%@", kHPPPMetricsUsername, kHPPPMetricsPassword, kHPPPMetricsServerTestBuilds]];
    NSString *provisionPath = [[NSBundle mainBundle] pathForResource:@"embedded" ofType:@"mobileprovision"];
    NSURL *metricsURL = testURL;
    if (!provisionPath && !TARGET_IPHONE_SIMULATOR) {
        metricsURL = productionURL;
    }
    return metricsURL;
}

#pragma mark - Gather metrics

- (NSDictionary *)baseMetrics
{
    NSString *version = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
    NSString *build = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"];
    NSString *completeVersion = [NSString stringWithFormat:@"%@ (%@)", version, build];
    NSString *osVersion = [[UIDevice currentDevice] systemVersion];
    NSString *displayName = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleDisplayName"];
    NSString *bundleID = [[NSBundle mainBundle] bundleIdentifier];
    NSString *printPodVersion = [self podVersion];
    NSDictionary *metrics = @{
                              kHPPPMetricsDeviceBrand : [self nonNullString:kHPPPManufacturer],
                              kHPPPMetricsDeviceID : [self nonNullString:self.userUniqueIdentifier],
                              kHPPPMetricsDeviceType : [self nonNullString:[self platform]],
                              kHPPPMetricsManufacturer : [self nonNullString:kHPPPManufacturer],
                              kHPPPMetricsOSType : [self nonNullString:kHPPPOSType],
                              kHPPPMetricsOSVersion : [self nonNullString:osVersion],
                              kHPPPMetricsProductID : [self nonNullString:bundleID],
                              kHPPPMetricsProductName : [self nonNullString:displayName],
                              kHPPPMetricsVersion : [self nonNullString:completeVersion],
                              kHPPPMetricsPrintLibraryVersion :[self nonNullString:printPodVersion],
                              kHPPPMetricsWiFiSSID : [HPPPAnalyticsManager wifiName]
                              };
    
    return metrics;
}

- (NSDictionary *)printMetricsForOfframp:(NSString *)offramp
{
    if ([HPPPPrintManager printNowOfframp:offramp]) {
        return [HPPP sharedInstance].lastOptionsUsed;
    } else {
        return [NSDictionary dictionaryWithObjectsAndKeys:
                kHPPPNoPrint, kHPPPBlackAndWhiteFilterId,
                kHPPPNoPrint, kHPPPNumberOfCopies,
                kHPPPNoPrint, kHPPPPaperSizeId,
                kHPPPNoPrint, kHPPPPaperTypeId,
                kHPPPNoPrint, kHPPPPrinterId,
                kHPPPNoPrint, kHPPPPrinterDisplayLocation,
                kHPPPNoPrint, kHPPPPrinterMakeAndModel,
                kHPPPNoPrint, kHPPPPrinterDisplayName,
                kHPPPNoPrint, kHPPPNumberPagesPrint,
                nil
                ];
    }
}

- (NSDictionary *)contentOptionsForPrintItem:(HPPPPrintItem *)printItem
{
    NSDictionary *options = @{
                              kHPPPContentTypeKey:kHPPPNoContent,
                              kHPPPContentWidthKey:kHPPPNoContent,
                              kHPPPContentHeightKey:kHPPPNoContent
                              };
    if (printItem) {
        CGSize printItemSize = [printItem sizeInUnits:Pixels];
        options = @{
                    kHPPPContentTypeKey:printItem.assetType,
                    kHPPPContentWidthKey:[NSString stringWithFormat:@"%.0f", printItemSize.width],
                    kHPPPContentHeightKey:[NSString stringWithFormat:@"%.0f", printItemSize.height]
                    };
    }
    
    return options;
}

- (NSString *)podVersion
{
    NSString *version = @"";
#ifdef COCOAPODS_VERSION_MAJOR_HPPhotoPrint
    version = [NSString stringWithFormat:@"%d.%d.%d", COCOAPODS_VERSION_MAJOR_HPPhotoPrint, COCOAPODS_VERSION_MINOR_HPPhotoPrint, COCOAPODS_VERSION_PATCH_HPPhotoPrint];
#endif
    return version;
}

- (NSArray *)partnerExcludedMetrics
{
    return @[
             kHPPPMetricsDeviceBrand,
             kHPPPMetricsManufacturer,
             kHPPPPrinterDisplayName,
             kHPPPPrinterDisplayLocation
             ];
}

- (NSArray *)obfuscatedMetrics
{
    return @[
             kHPPPPrinterId,
             kHPPPMetricsWiFiSSID];
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

- (void)sanitizeMetrics:(NSMutableDictionary *)metrics
{
    NSString *appType = [metrics objectForKey:kHPPPMetricsAppType];
    if (nil == appType || ![appType isEqualToString:kHPPPMetricsAppTypeHP ]) {
        [metrics setObject:kHPPPMetricsAppTypePartner forKey:kHPPPMetricsAppType];
        for (NSString *key in [self partnerExcludedMetrics]) {
            [metrics setObject:kHPPPMetricsNotCollected forKey:key];
        }
    }
    for (NSString *key in [self obfuscatedMetrics]) {
        NSString *value = [metrics objectForKey:key];
        if (value) {
            NSString *obfsucatedValue = [self obfuscateValue:value];
            [metrics setObject:obfsucatedValue forKey:key];
        }
    }
}

#pragma mark - Send metrics

- (void)trackShareEventWithPrintItem:(HPPPPrintItem *)printItem andOptions:(NSDictionary *)options
{
    NSMutableDictionary *metrics = [NSMutableDictionary dictionaryWithDictionary:[self baseMetrics]];
    [metrics addEntriesFromDictionary:@{ kHPPPNumberPagesDocument:[NSNumber numberWithInteger:printItem.numberOfPages] }];
    [metrics addEntriesFromDictionary:[self printMetricsForOfframp:[options objectForKey:kHPPPOfframpKey]]];
    [metrics addEntriesFromDictionary:[self contentOptionsForPrintItem:printItem]];
    [metrics addEntriesFromDictionary:options];

    [self sanitizeMetrics:metrics];
    
    NSData *bodyData = [self postBodyWithValues:metrics];
    NSString *bodyLength = [NSString stringWithFormat:@"%ld", (long)[bodyData length]];
    NSMutableURLRequest *urlRequest = [NSMutableURLRequest requestWithURL:[self metricsServerURL]];
    [urlRequest setHTTPMethod:@"POST"];
    [urlRequest setHTTPBody:bodyData];
    [urlRequest addValue:bodyLength forHTTPHeaderField: @"Content-Length"];
    [urlRequest setValue:@"application/x-www-form-urlencoded; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        [self sendMetricsData:urlRequest];
    });
}

- (NSData *)postBodyWithValues:(NSDictionary *)values
{
    NSMutableArray *content = [NSMutableArray array];
    for (NSString * key in values) {
        [content addObject:[NSString stringWithFormat:@"%@=%@", key, values[key]]];
    }
    NSString *body = [content componentsJoinedByString:@"&"];
    return [body dataUsingEncoding:NSUTF8StringEncoding];
}

- (void)sendMetricsData:(NSURLRequest *)request
{
    NSURLResponse *response = nil;
    NSError *connectionError = nil;
    NSData *responseData = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&connectionError];
    
    if (connectionError == nil) {
        if ([response isKindOfClass:[NSHTTPURLResponse class]]) {
            NSInteger statusCode = [(NSHTTPURLResponse *)response statusCode];
            if (statusCode != 200) {
                HPPPLogError(@"HPPhotoPrint METRICS:  Response code = %ld", (long)statusCode);
                return;
            }
        }
        NSError *error;
        NSDictionary *returnDictionary = [NSJSONSerialization JSONObjectWithData:responseData options:0 error:&error];
        if (returnDictionary) {
            HPPPLogInfo(@"HPPhotoPrint METRICS:  Result = %@", returnDictionary);
        } else {
            HPPPLogError(@"HPPhotoPrint METRICS:  Parse Error = %@", error);
            NSString *returnString = [[NSString alloc] initWithBytes:[responseData bytes] length:[responseData length] encoding:NSUTF8StringEncoding];
            HPPPLogInfo(@"HPPhotoPrint METRICS:  Return string = %@", returnString);
        }
    } else {
        HPPPLogError(@"HPPhotoPrint METRICS:  Connection error = %@", connectionError);
    }
}

#pragma mark - Helpers

- (NSString *)nonNullString:(NSString *)value
{
    return nil == value ? @"" : value;
}

// The following functions are adapted from http://stackoverflow.com/questions/448162/determine-device-iphone-ipod-touch-with-iphone-sdk

- (NSString *) platform
{
    size_t size;
    sysctlbyname("hw.machine", NULL, &size, NULL, 0);
    char *machine = malloc(size);
    sysctlbyname("hw.machine", machine, &size, NULL, 0);
    NSString *platform = [NSString stringWithUTF8String:machine];
    free(machine);
    return platform;
}

// The following code is adapted from http://stackoverflow.com/questions/4712535/how-do-i-use-captivenetwork-to-get-the-current-wifi-hotspot-name

+ (NSString *)wifiName {
    NSString *wifiName = kHPPPNoNetwork;
    NSArray *ifs = (__bridge_transfer id)CNCopySupportedInterfaces();
    for (NSString *ifnam in ifs) {
        NSDictionary *info = (__bridge_transfer id)CNCopyCurrentNetworkInfo((__bridge CFStringRef)ifnam);
        if (info[@"SSID"]) {
            wifiName = info[@"SSID"];
        }
    }
    return wifiName;
}

@end
