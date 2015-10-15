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

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import "HPPP.h"
#import "HPPPAnalyticsManager.h"
#import "HPPPPrintItemFactory.h"
#import <OCMock/OCMock.h>

@interface HPPPAnalyticsManagerTest : XCTestCase


@end

static NSURLRequest *_request = nil;

@implementation HPPPAnalyticsManagerTest
{
    id _classMock;
    id _deviceMock;
    id _bundleMock;
}

NSTimeInterval const HPPPAnalyticsManagerTestCallDelay = 1.0; // seconds

#pragma mark - Setup

NSString * const kTestAnalyticsDeviceIdKey = @"device_id";

- (void)setUp {
    [super setUp];
    _classMock = OCMClassMock([NSURLConnection class]);
}

- (void)tearDown {
    [super tearDown];
}

#pragma mark - Tests

- (void)testUniqueDeviceIdDefaultValue {
    [self verifyMetricsParameters:^BOOL(id value) {
        NSDictionary *params = [self parametersFromURLRequest:value];
        NSString *expectedDeviceId = [self appUniqueDeviceId];
        return [expectedDeviceId isEqualToString:[params objectForKey:kTestAnalyticsDeviceIdKey]];
    }];
}

- (void)testUniqueDeviceIdPerApp {
    [HPPP sharedInstance].uniqueDeviceIdPerApp = YES;
    [self verifyMetricsParameters:^BOOL(id value) {
        NSDictionary *params = [self parametersFromURLRequest:value];
        NSString *expectedDeviceId = [self appUniqueDeviceId];
        return [expectedDeviceId isEqualToString:[params objectForKey:kTestAnalyticsDeviceIdKey]];
    }];
}

- (void)testUniqueDeviceIdPerVendor {
    [HPPP sharedInstance].uniqueDeviceIdPerApp = NO;
    [self verifyMetricsParameters:^BOOL(id value) {
        NSDictionary *params = [self parametersFromURLRequest:value];
        NSString *expectedDeviceId = [self vendorUniqueDeviceId];
        return [expectedDeviceId isEqualToString:[params objectForKey:kTestAnalyticsDeviceIdKey]];
    }];
}

- (void)verifyMetricsParameters:(BOOL(^)(id value))validateParameters
{
    // Double pointer on NSURLResponse param requires autorelease casting of OCMArg param:  http://stackoverflow.com/questions/15259583/ocmock-argument-match-on-double-pointer
    OCMExpect([_classMock sendSynchronousRequest:[OCMArg checkWithBlock:validateParameters] returningResponse:(NSURLResponse * __autoreleasing *)[OCMArg anyPointer] error:(NSError * __autoreleasing *)[OCMArg anyPointer]]).andDo(^(NSInvocation *invocation) {
        NSString *result = @"";
        NSData *data = [result dataUsingEncoding:NSUTF8StringEncoding];
        [invocation setReturnValue:&data];
    });
    
    HPPPPrintItem *printItem = [HPPPPrintItemFactory printItemWithAsset:[UIImage imageNamed:@"Cat.jpg"]];
    [[HPPPAnalyticsManager sharedManager] trackShareEventWithPrintItem:printItem andOptions:@{ kHPPPOfframpKey:@"foo" }];
    
    OCMVerifyAllWithDelay(_classMock, HPPPAnalyticsManagerTestCallDelay);
}

#pragma mark - Helpers

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
    return [HPPPAnalyticsManager obfuscateValue:[NSString stringWithFormat:@"%@%@", [[UIDevice currentDevice].identifierForVendor UUIDString], [[NSBundle mainBundle] bundleIdentifier]]];
}

- (NSString *)vendorUniqueDeviceId
{
    return [HPPPAnalyticsManager obfuscateValue:[[UIDevice currentDevice].identifierForVendor UUIDString]];
}

@end
