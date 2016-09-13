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
#import "MPPageRange.h"
#import "MPPrintManager.h"
#import "MPPaper.h"
#import <sys/sysctl.h>
#import <SystemConfiguration/CaptiveNetwork.h>
#import <CommonCrypto/CommonDigest.h>

@interface MP()

// expose this private method only to the private MPAnalyticsManager class
- (NSString *)printLibraryVersion;

@end

@interface MPAnalyticsManager()

@property NSMutableArray *userSpecifiedObfuscationMetrics;

@end

@implementation MPAnalyticsManager

NSString * const kMPMetricsServer = @"print-metrics-w1.twosmiles.com/api/v1/mobile_app_metrics";
NSString * const kMPMetricsServerTestBuilds = @"print-metrics-test.twosmiles.com/api/v1/mobile_app_metrics";
//NSString * const kMPMetricsServerTestBuilds = @"localhost:4567/api/v1/mobile_app_metrics"; // use for local testing
NSString * const kMPMetricsUsername = @"hpmobileprint";
NSString * const kMPMetricsPassword = @"print1t";
NSString * const kMPOSType = @"iOS";
NSString * const kMPManufacturer = @"Apple";
NSString * const kMPNoNetwork = @"NO-WIFI";
NSString * const kMPNoPrint = @"No Print";
NSString * const kMPNoContent = @"No Content";
NSString * const kMPOfframpKey = @"off_ramp";
NSString * const kMPContentTypeKey = @"content_type";
NSString * const kMPContentWidthKey = @"content_width_pixels";
NSString * const kMPContentHeightKey = @"content_height_pixels";
NSString * const kMPMetricsDeviceBrand = @"device_brand";
NSString * const kMPMetricsDeviceID = @"device_id";
NSString * const kMPMetricsDeviceType = @"device_type";
NSString * const kMPMetricsManufacturer = @"manufacturer";
NSString * const kMPMetricsOSType = @"os_type";
NSString * const kMPMetricsOSVersion = @"os_version";
NSString * const kMPMetricsProductID = @"product_id";
NSString * const kMPMetricsProductName = @"product_name";
NSString * const kMPMetricsVersion = @"version";
NSString * const kMPMetricsPrintLibraryVersion = @"print_library_version";
NSString * const kMPMetricsWiFiSSID = @"wifi_ssid";
NSString * const kMPMetricsAppType = @"app_type";
NSString * const kMPMetricsAppTypeHP = @"HP";
NSString * const kMPMetricsAppTypePartner = @"Partner";
NSString * const kMPMetricsNotCollected = @"Not Collected";
NSString * const kMPMetricsCountryCode = @"country_code";
NSString * const kMPMetricsLanguageCode = @"language_code";
NSString * const kMPMetricsTimezoneDescription = @"timezone_description";
NSString * const kMPMetricsTimezoneOffsetSeconds = @"timezone_offset_seconds";

NSString * const kMPMetricsEventTypeID = @"event_type_id";
NSString * const kMPMetricsPrintSessionID = @"print_session_id";
NSString * const kMPMetricsEventCount = @"event_count";
NSInteger  const kMPMetricsEventInitialCountValue = 1;
NSNumber *       kMPMetricsEventInitialCount;

NSString * const kMPMetricsEventTypePrintInitiated = @"1";
NSString * const kMPMetricsEventTypePrintCompleted = @"5";

#pragma mark - Initialization

+ (MPAnalyticsManager *)sharedManager
{
    static MPAnalyticsManager *sharedManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedManager = [[self alloc] init];
        kMPMetricsEventInitialCount = [NSNumber numberWithInteger:kMPMetricsEventInitialCountValue];
        sharedManager.userSpecifiedObfuscationMetrics = [[NSMutableArray alloc] init];
    });
    
    return sharedManager;
}

- (NSURL *)metricsServerPrintMetricsURL
{
    NSURL *productionURL = [NSURL URLWithString:[NSString stringWithFormat:@"https://%@:%@@%@", kMPMetricsUsername, kMPMetricsPassword, kMPMetricsServer]];
    NSURL *testURL = [NSURL URLWithString:[NSString stringWithFormat:@"http://%@:%@@%@", kMPMetricsUsername, kMPMetricsPassword, kMPMetricsServerTestBuilds]];
    NSString *provisionPath = [[NSBundle mainBundle] pathForResource:@"embedded" ofType:@"mobileprovision"];

    // The following is adapted from: http://stackoverflow.com/questions/26081543/how-to-tell-at-runtime-whether-an-ios-app-is-running-through-a-testflight-beta-i
    BOOL sandboxReceipt = [[[[NSBundle mainBundle] appStoreReceiptURL] lastPathComponent] isEqualToString:@"sandboxReceipt"];
    
    NSURL *metricsURL = testURL;
    if (!provisionPath && !sandboxReceipt && !TARGET_IPHONE_SIMULATOR) {
        metricsURL = productionURL;
    }
    return metricsURL;
}

- (NSURL *)metricsServerEventsURL
{
    NSString *printMetricsURL = [self metricsServerPrintMetricsURL].absoluteString;
    NSString *eventsURL = [printMetricsURL stringByReplacingOccurrencesOfString:@"v1/mobile_app_metrics" withString:@"v2/events"];
    return [NSURL URLWithString:eventsURL];
}

- (void)setPrintSessionId:(NSString *)printSessionId
{
    _printSessionId = printSessionId;
}

#pragma mark - Gather metrics

- (NSDictionary *)baseMetrics
{
    NSString *version = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
    NSString *build = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"];
    NSString *displayName = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleDisplayName"];
    if (!displayName) {
        // Adapted from https://developer.apple.com/library/mac/qa/qa1544/_index.html
        displayName = [[NSFileManager defaultManager] displayNameAtPath: [[NSBundle mainBundle] bundlePath]];
    }
    NSString *bundleID = [[NSBundle mainBundle] bundleIdentifier];
    NSString *completeVersion = [NSString stringWithFormat:@"%@ (%@)", version, build];
    NSString *osVersion = [[UIDevice currentDevice] systemVersion];
    NSString *printLibraryVersion = [MP sharedInstance].printLibraryVersion;
    NSDictionary *metrics = @{
                              kMPMetricsDeviceBrand : [self nonNullString:kMPManufacturer],
                              kMPMetricsDeviceID : [self nonNullString:[self userUniqueIdentifier]],
                              kMPMetricsDeviceType : [self nonNullString:[self platform]],
                              kMPMetricsManufacturer : [self nonNullString:kMPManufacturer],
                              kMPMetricsOSType : [self nonNullString:kMPOSType],
                              kMPMetricsOSVersion : [self nonNullString:osVersion],
                              kMPMetricsProductID : [self nonNullString:bundleID],
                              kMPMetricsProductName : [self nonNullString:displayName],
                              kMPMetricsVersion : [self nonNullString:completeVersion],
                              kMPMetricsPrintLibraryVersion :[self nonNullString:printLibraryVersion],
                              kMPMetricsWiFiSSID : [MPAnalyticsManager wifiName],
                              kMPMetricsCountryCode : [self nonNullString:[[NSLocale currentLocale] objectForKey:NSLocaleCountryCode]],
                              kMPMetricsLanguageCode : [self nonNullString:[[NSLocale currentLocale] objectForKey:NSLocaleLanguageCode]],
                              kMPMetricsTimezoneDescription : [self nonNullString:[NSTimeZone systemTimeZone].description],
                              kMPMetricsTimezoneOffsetSeconds : [NSString stringWithFormat:@"%ld", (long)[NSTimeZone systemTimeZone].secondsFromGMT]
                              };
    
    return metrics;
}

- (NSDictionary *)printMetricsForOfframp:(NSString *)offramp
{
    if ([MPPrintManager printNowOfframp:offramp]) {
        NSMutableDictionary *lastOptions = [[MP sharedInstance].lastOptionsUsed mutableCopy];
        
        NSString *paperType = [lastOptions objectForKey:kMPPaperTypeId];
        if (paperType) {
            NSString *analyticsPaperType = [MPPaper constantPaperTypeFromTitle:paperType];
            if (analyticsPaperType) {
                [lastOptions setObject:analyticsPaperType forKey:kMPPaperTypeId];
            }
        }

        NSString *paperSize = [lastOptions objectForKey:kMPPaperSizeId];
        if (paperSize) {
            NSString *analyticsPaperSize = [MPPaper constantPaperSizeFromTitle:paperSize];
            if (analyticsPaperSize) {
                [lastOptions setObject:analyticsPaperSize forKey:kMPPaperSizeId];
            }
        }

        return lastOptions;
    } else {
        return [NSDictionary dictionaryWithObjectsAndKeys:
                kMPNoPrint, kMPBlackAndWhiteFilterId,
                kMPNoPrint, kMPNumberOfCopies,
                kMPNoPrint, kMPPaperSizeId,
                kMPNoPrint, kMPPaperTypeId,
                kMPNoPrint, kMPPaperWidthId,
                kMPNoPrint, kMPPaperHeightId,
                kMPNoPrint, kMPPrinterId,
                kMPNoPrint, kMPPrinterDisplayLocation,
                kMPNoPrint, kMPPrinterMakeAndModel,
                kMPNoPrint, kMPPrinterDisplayName,
                kMPNoPrint, kMPNumberPagesPrint,
                kMPNoPrint, kMPPrinterPaperWidthPoints,
                kMPNoPrint, kMPPrinterPaperHeightPoints,
                kMPNoPrint, kMPPrinterPaperAreaWidthPoints,
                kMPNoPrint, kMPPrinterPaperAreaHeightPoints,
                kMPNoPrint, kMPPrinterPaperAreaXPoints,
                kMPNoPrint, kMPPrinterPaperAreaYPoints,
                nil
                ];
    }
}

- (NSDictionary *)contentOptionsForPrintItem:(MPPrintItem *)printItem
{
    NSDictionary *options = @{
                              kMPContentTypeKey:kMPNoContent,
                              kMPContentWidthKey:kMPNoContent,
                              kMPContentHeightKey:kMPNoContent
                              };
    if (printItem) {
        CGSize printItemSize = [printItem sizeInUnits:Pixels];
        options = @{
                    kMPContentTypeKey:printItem.assetType,
                    kMPContentWidthKey:[NSString stringWithFormat:@"%.0f", printItemSize.width],
                    kMPContentHeightKey:[NSString stringWithFormat:@"%.0f", printItemSize.height]
                    };
    }
    
    return options;
}

- (NSString *)userUniqueIdentifier
{
    NSString *identifier = [[UIDevice currentDevice].identifierForVendor UUIDString];
    if ([MP sharedInstance].uniqueDeviceIdPerApp) {
        NSString *seed = [NSString stringWithFormat:@"%@%@", identifier, [[NSBundle mainBundle] bundleIdentifier]];
        identifier = [MPAnalyticsManager obfuscateValue:seed];
    }
    return identifier;
}

- (NSArray *)partnerExcludedMetrics
{
    return @[
             kMPMetricsDeviceBrand,
             kMPMetricsManufacturer,
             kMPPrinterDisplayName,
             kMPPrinterDisplayLocation
             ];
}

- (void)obfuscateMetric:(NSString *)keyName
{
    [self.userSpecifiedObfuscationMetrics addObject:keyName];
}

- (NSArray *)obfuscatedMetrics
{
    NSMutableArray *metrics = [[NSMutableArray alloc] initWithArray:@[
                                                                      kMPPrinterId,
                                                                      kMPMetricsWiFiSSID]];
    [metrics addObjectsFromArray:self.userSpecifiedObfuscationMetrics];
    
    return metrics;
}

// The following is adapted from http://stackoverflow.com/questions/2018550/how-do-i-create-an-md5-hash-of-a-string-in-cocoa
+ (NSString *)obfuscateValue:(NSString *)value
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
    NSString *appType = [metrics objectForKey:kMPMetricsAppType];
    
    if (nil == appType && ![MP sharedInstance].handlePrintMetricsAutomatically) {
        appType = kMPMetricsAppTypeHP;
        [metrics setObject:appType forKey:kMPMetricsAppType];
    }
    
    if (![appType isEqualToString:kMPMetricsAppTypeHP]) {
        [metrics setObject:kMPMetricsAppTypePartner forKey:kMPMetricsAppType];
        for (NSString *key in [self partnerExcludedMetrics]) {
            [metrics setObject:kMPMetricsNotCollected forKey:key];
        }
    }
    
    for (NSString *key in [self obfuscatedMetrics]) {
        NSString *value = [metrics objectForKey:key];
        if (value) {
            if ([key isEqualToString:kMPMetricsWiFiSSID]  &&  [value isEqualToString:kMPNoNetwork]) {
                // do nothing for unpopulated wifi
            } else if ([key isEqualToString:kMPPrinterId]  &&  [[metrics objectForKey:kMPMetricsProductName] containsString:@"sprocket"]) {
                // do nothing for the sprocket printer ids
            } else {
                NSString *obfsucatedValue = [MPAnalyticsManager obfuscateValue:value];
                [metrics setObject:obfsucatedValue forKey:key];
            }
        }
    }
}

#pragma mark - Send metrics

- (void)trackShareEventWithPrintLaterJob:(NSDictionary *)objects andOptions:(NSDictionary *)options
{
    MPPrintLaterJob *printLaterJob = [objects objectForKey:kMPPrintQueueJobKey];
    MPPrintItem *printItem = [objects objectForKey:kMPPrintQueuePrintItemKey];
    
    NSMutableDictionary *metrics = [self getMetricsForPrintItem:printItem andOptions:options];
    [metrics setObject:[NSNumber numberWithInteger:printLaterJob.numCopies] forKey:kMPNumberOfCopies];

    [self sendMetrics:metrics toURL:[self metricsServerPrintMetricsURL]];
}

- (void)trackShareEventWithPrintItem:(MPPrintItem *)printItem andOptions:(NSDictionary *)options
{
    NSMutableDictionary *metrics = [self getMetricsForPrintItem:printItem andOptions:options];
    
    [self sendMetrics:metrics toURL:[self metricsServerPrintMetricsURL]];
}

- (void)trackUserFlowEventWithId:(NSString *)eventId
{
    NSString *eventCount = [self eventCountForId:eventId];
    NSMutableDictionary *metrics = [NSMutableDictionary dictionaryWithDictionary:[self baseMetrics]];
    [metrics addEntriesFromDictionary:@{
                                        kMPMetricsEventTypeID:eventId,
                                        kMPMetricsEventCount:eventCount,
                                        kMPMetricsPrintSessionID:[self nonNullString:self.printSessionId]
                                        }];

    if (!self.printSessionId) {
        MPLogWarn(@"Unexpected missing print session ID for event:\n\n%@", metrics);
    }

    [self sendMetrics:metrics toURL:[self metricsServerEventsURL]];
    
    if (kMPMetricsEventTypePrintCompleted == eventId) {
        _printSessionId = nil;
    }
}

- (void)sendMetrics:(NSMutableDictionary *)metrics toURL:(NSURL *)url
{
    [self sanitizeMetrics:metrics];

    NSData *bodyData = [self postBodyWithValues:metrics];
    NSString *bodyLength = [NSString stringWithFormat:@"%ld", (long)[bodyData length]];
    NSMutableURLRequest *urlRequest = [NSMutableURLRequest requestWithURL:url];
    [urlRequest setHTTPMethod:@"POST"];
    [urlRequest setHTTPBody:bodyData];
    [urlRequest addValue:bodyLength forHTTPHeaderField: @"Content-Length"];
    [urlRequest setValue:@"application/x-www-form-urlencoded; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        [self sendMetricsData:urlRequest];
    });
}

- (NSString *)eventCountForId:(NSString *)eventId
{
    NSString *key = [NSString stringWithFormat:@"%@_%@", kMPMetricsEventTypeID, eventId];
    NSNumber *newValue = kMPMetricsEventInitialCount;
    @synchronized(self) {
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        NSNumber *currentValue = [defaults objectForKey:key];
        if (currentValue) {
            newValue = [NSNumber numberWithInteger:[currentValue integerValue] + 1];
        }
        [defaults setObject:newValue forKey:key];
        [defaults synchronize];
        if (kMPMetricsEventTypePrintInitiated == eventId) {
            _printSessionId = [newValue stringValue];
        }
    }
    
    return [newValue stringValue];
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
                MPLogError(@"MobilePrintSDK METRICS:  Response code = %ld", (long)statusCode);
                return;
            }
        }
        NSError *error;
        NSDictionary *returnDictionary = [NSJSONSerialization JSONObjectWithData:responseData options:0 error:&error];
        if (returnDictionary) {
            MPLogInfo(@"MobilePrintSDK METRICS:  Result = %@", returnDictionary);
        } else {
            // the format of our embellishment metrics produces an error, but the data is logged as expected on the server
            MPLogError(@"MobilePrintSDK METRICS:  Parse Error = %@", error);
            NSString *returnString = [[NSString alloc] initWithBytes:[responseData bytes] length:[responseData length] encoding:NSUTF8StringEncoding];
            MPLogInfo(@"MobilePrintSDK METRICS:  Return string = %@", returnString);
        }
    } else {
        MPLogError(@"MobilePrintSDK METRICS:  Connection error = %@", connectionError);
    }
}

#pragma mark - Helpers

- (NSString *)convertCustomAnalyticsToJson:(NSMutableDictionary *)customAnalytics
{
    NSString *json = @"{}";
    
    if (nil != customAnalytics) {
        if ([customAnalytics isKindOfClass:[NSDictionary class]]) {
            NSError *error;
            NSData *jsonData = [NSJSONSerialization dataWithJSONObject:customAnalytics
                                                               options:(NSJSONWritingOptions)0
                                                                 error:&error];
            
            if (!jsonData) {
                MPLogError(@"Error converting extras to JSON: %@", error.localizedDescription);
            } else {
                json = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
            }
        } else {
            MPLogError(@"Custom Analytics data must be a dictionary, not %@", [customAnalytics class]);
        }
    }

    return json;
}

- (NSMutableDictionary *)getMetricsForPrintItem:(MPPrintItem *)printItem andOptions:(NSDictionary *)options
{
    NSMutableDictionary *metrics = [NSMutableDictionary dictionaryWithDictionary:[self baseMetrics]];
    [metrics addEntriesFromDictionary:@{ kMPNumberPagesDocument:[NSNumber numberWithInteger:printItem.numberOfPages] }];
    [metrics addEntriesFromDictionary:[self printMetricsForOfframp:[options objectForKey:kMPOfframpKey]]];
    [metrics addEntriesFromDictionary:[self contentOptionsForPrintItem:printItem]];
    
    NSString *customAnalyticsJson = [self convertCustomAnalyticsToJson:[options objectForKey:kMPCustomAnalyticsKey]];
    NSMutableDictionary *mutableOptions = [options mutableCopy];
    [mutableOptions setObject:customAnalyticsJson forKey:kMPCustomAnalyticsKey];
    [metrics addEntriesFromDictionary:mutableOptions];

    return metrics;
}

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
    NSString *wifiName = kMPNoNetwork;
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
