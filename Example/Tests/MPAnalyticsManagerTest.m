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

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import "MP.h"
#import "MPAnalyticsManager.h"
#import "MPPrintItemFactory.h"
#import <OCMock/OCMock.h>

@interface MPAnalyticsManagerTest : XCTestCase

@end

@interface  MPAnalyticsManager (private)

- (void)setPrintSessionId:(NSString *)printSessionId;

@end

static NSURLRequest *_request = nil;

@implementation MPAnalyticsManagerTest
{
    id _classMock;
    id _deviceMock;
    id _bundleMock;
    id _loggerMock;
}

extern NSString * const kMPMetricsEventTypeID;
extern NSString * const kMPMetricsEventCount;
extern NSInteger const kMPMetricsEventInitialCount;

NSTimeInterval const kMPAnalyticsManagerTestCallDelay = 1.0; // seconds

#pragma mark - Setup

NSString * const kTestAnalyticsDeviceIdKey = @"device_id";

- (void)setUp {
    [super setUp];
    _classMock = OCMClassMock([NSURLConnection class]);
    _loggerMock = OCMPartialMock([MPLogger sharedInstance]);
}

- (void)tearDown {
    [super tearDown];
    [_loggerMock stopMocking];
}

#pragma mark - Tests

- (void)testUniqueDeviceIdDefaultValue {
    [self verifyCall:^{
        [self sendSampleMetrics];
    } usingBlock:^BOOL(id value) {
        NSDictionary *params = [self parametersFromURLRequest:value];
        NSString *expectedDeviceId = [self appUniqueDeviceId];
        NSString *actualDeviceId = [params objectForKey:kTestAnalyticsDeviceIdKey];
        return [actualDeviceId isEqualToString:expectedDeviceId] && [self verifyMetricsURL:value];
    }];
}

- (void)testUniqueDeviceIdPerApp {
    [MP sharedInstance].uniqueDeviceIdPerApp = YES;
    [self verifyCall:^{
        [self sendSampleMetrics];
    } usingBlock:^BOOL(id value) {
        NSDictionary *params = [self parametersFromURLRequest:value];
        NSString *expectedDeviceId = [self appUniqueDeviceId];
        NSString *actualDeviceId = [params objectForKey:kTestAnalyticsDeviceIdKey];
        return [actualDeviceId isEqualToString:expectedDeviceId] && [self verifyMetricsURL:value];
    }];
}

- (void)testUniqueDeviceIdPerVendor {
    [MP sharedInstance].uniqueDeviceIdPerApp = NO;
    [self verifyCall:^{
        [self sendSampleMetrics];
    } usingBlock:^BOOL(id value) {
        NSDictionary *params = [self parametersFromURLRequest:value];
        NSString *expectedDeviceId = [self vendorUniqueDeviceId];
        NSString *actualDeviceId = [params objectForKey:kTestAnalyticsDeviceIdKey];
        return [actualDeviceId isEqualToString:expectedDeviceId] && [self verifyMetricsURL:value];
    }];
}

- (void)testEventPrintInitate {
    
    [MPAnalyticsManager sharedManager].printSessionId = nil;
    __block NSString *expectedSessionId = nil;
    
    [self verifyCall:^{
        [[MPAnalyticsManager sharedManager] trackUserFlowEventWithId:kMPMetricsEventTypePrintInitiated];
    } usingBlock:^BOOL(id value) {
        if (![self verifyEventURL:value]) {
            return NO;
        }
        NSDictionary *params = [self parametersFromURLRequest:value];
        NSString *expectedEventId = kMPMetricsEventTypePrintInitiated;
        NSString *actualEventId = [params objectForKey:kMPMetricsEventTypeID];
        if (![actualEventId isEqualToString:expectedEventId]) {
            return NO;
        }
        expectedSessionId = [params objectForKey:kMPMetricsEventCount];
        NSString *actualSessionId = [params objectForKey:kMPMetricsPrintSessionID];
        if (![actualSessionId isEqualToString:expectedSessionId]) {
            return NO;
        }
        return YES;
    }];
    
    NSString *finalSessionId = [MPAnalyticsManager sharedManager].printSessionId;
    XCTAssert(
              [finalSessionId isEqualToString:expectedSessionId],
              @"Expected print session ID to be '%@' but got '%@'",
              expectedSessionId,
              finalSessionId);
}

- (void)testEventPrintCompleted {
    
    NSString *testSessionId = @"Test Session";
    [MPAnalyticsManager sharedManager].printSessionId = testSessionId;
    
    [self verifyCall:^{
        [[MPAnalyticsManager sharedManager] trackUserFlowEventWithId:kMPMetricsEventTypePrintCompleted];
    } usingBlock:^BOOL(id value) {
        if (![self verifyEventURL:value]) {
            return NO;
        }
        NSDictionary *params = [self parametersFromURLRequest:value];
        NSString *expectedEventId = kMPMetricsEventTypePrintCompleted;
        NSString *actualEventId = [params objectForKey:kMPMetricsEventTypeID];
        if (![actualEventId isEqualToString:expectedEventId]) {
            return NO;
        }
        NSString *expectedSessionId = testSessionId;
        NSString *actualSessionId = [params objectForKey:kMPMetricsPrintSessionID];
        if (![actualSessionId isEqualToString:expectedSessionId]) {
            return NO;
        }
        return YES;
    }];
    
    NSString *finalSessionId = [MPAnalyticsManager sharedManager].printSessionId;
    XCTAssert(
              nil == finalSessionId,
              @"Expected print session ID to be nil but got '%@'",
              finalSessionId);
}

- (void)testPrintCompletedWithNoSession
{
    [MPAnalyticsManager sharedManager].printSessionId = nil;

    [self verifyCall:^{
        [[MPAnalyticsManager sharedManager] trackUserFlowEventWithId:kMPMetricsEventTypePrintCompleted];
    } usingBlock:^BOOL(id value) {
        NSDictionary *params = [self parametersFromURLRequest:value];
        NSString *expectedSessionId = @"";
        NSString *actualSessionId = [params objectForKey:kMPMetricsPrintSessionID];
        if (![actualSessionId isEqualToString:expectedSessionId]) {
            return NO;
        }
        return YES;
    }];

    OCMVerify([_loggerMock logWarn:[OCMArg checkWithBlock:^BOOL(id obj) {
        NSString *arg = obj;
        return [arg rangeOfString:@"Unexpected missing print session ID for event"].location != NSNotFound;
    }]]);
}

- (void)testRunningCountPrintInitiated
{
    NSInteger startingCount = arc4random_uniform(10000);
    [self verifyRunningCount:startingCount forEvent:kMPMetricsEventTypePrintInitiated];
}

- (void)testRunningCountPrintCompleted
{
    NSInteger startingCount = arc4random_uniform(10000);
    [self verifyRunningCount:startingCount forEvent:kMPMetricsEventTypePrintCompleted];
}

- (void)testInitialEventCountPrintInitiated
{
    [self verifyInitialCountForEvent:kMPMetricsEventTypePrintInitiated];
}

- (void)testInitialEventCountPrintCompleted
{
    [self verifyInitialCountForEvent:kMPMetricsEventTypePrintCompleted];
}

#pragma mark - Helpers

- (void)verifyCall:(void(^)(void))callBlock usingBlock:(BOOL(^)(id value))verifyBlock
{
    // Double pointer on NSURLResponse param requires autorelease casting of OCMArg param:  http://stackoverflow.com/questions/15259583/ocmock-argument-match-on-double-pointer
    OCMExpect([_classMock sendSynchronousRequest:[OCMArg checkWithBlock:verifyBlock] returningResponse:(NSURLResponse * __autoreleasing *)[OCMArg anyPointer] error:(NSError * __autoreleasing *)[OCMArg anyPointer]]).andDo(^(NSInvocation *invocation) {
        NSString *result = @"";
        NSData *data = [result dataUsingEncoding:NSUTF8StringEncoding];
        [invocation setReturnValue:&data];
    });
    
    callBlock();
    
    OCMVerifyAllWithDelay(_classMock, kMPAnalyticsManagerTestCallDelay);
}

- (void)verifyInitialCountForEvent:(NSString *)eventId
{
    NSString *key = [NSString stringWithFormat:@"%@_%@", kMPMetricsEventTypeID, eventId];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:key];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    [self verifyCount:kMPMetricsEventInitialCount forEvent:eventId];
}

- (void)verifyRunningCount:(NSInteger)count forEvent:(NSString *)eventId
{
    NSString *key = [NSString stringWithFormat:@"%@_%@", kMPMetricsEventTypeID, eventId];
    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInteger:count] forKey:key];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    [self verifyCount:count + 1 forEvent:eventId];
}

- (void)verifyCount:(NSInteger)count forEvent:(NSString *)eventId
{
    NSString *key = [NSString stringWithFormat:@"%@_%@", kMPMetricsEventTypeID, eventId];
    NSNumber *expectedCount = [NSNumber numberWithInteger:count];

    [self verifyCall:^{
        [[MPAnalyticsManager sharedManager] trackUserFlowEventWithId:eventId];
    } usingBlock:^BOOL(id value) {
        NSDictionary *params = [self parametersFromURLRequest:value];
        NSString *actualValue = [params objectForKey:kMPMetricsEventCount];
        NSNumber *actualCount = [NSNumber numberWithInteger:[actualValue integerValue]];
        if (![actualCount isEqualToNumber:expectedCount]) {
            return NO;
        }
        return YES;
    }];
    
    NSNumber *actualCount = [[NSUserDefaults standardUserDefaults] objectForKey:key];
    XCTAssert(
              [actualCount isEqualToNumber:expectedCount],
              @"Expected event count '%@' but got '%@'",
              expectedCount,
              actualCount);

}

- (void)sendSampleMetrics
{
    MPPrintItem *printItem = [MPPrintItemFactory printItemWithAsset:[UIImage imageNamed:@"Cat.jpg"]];
    [[MPAnalyticsManager sharedManager] trackShareEventWithPrintItem:printItem andOptions:@{ kMPOfframpKey:@"foo" }];
}

- (BOOL)verifyMetricsURL:(NSURLRequest *)request
{
    return [request.URL.absoluteString containsString:@"v1/mobile_app_metrics"];
}

- (BOOL)verifyEventURL:(NSURLRequest *)request
{
    return [request.URL.absoluteString containsString:@"v2/events"];
}

- (NSDictionary *)parametersFromURLRequest:(NSURLRequest *)request
{
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    NSString *body = [[NSString alloc] initWithData:request.HTTPBody encoding:NSUTF8StringEncoding];
    for (NSString *pair in [body componentsSeparatedByString:@"&"]) {
        NSArray *parts = [pair componentsSeparatedByString:@"="];
        if (parts.count > 1) {
            NSString *key = parts[0];
            NSString *value = parts[1];
            [params addEntriesFromDictionary:@{ key:value }];
        }
    }
    return params;
}

- (NSString *)appUniqueDeviceId
{
    return [MPAnalyticsManager obfuscateValue:[NSString stringWithFormat:@"%@%@", [[UIDevice currentDevice].identifierForVendor UUIDString], [[NSBundle mainBundle] bundleIdentifier]]];
}

- (NSString *)vendorUniqueDeviceId
{
    return [[UIDevice currentDevice].identifierForVendor UUIDString];
}

@end
