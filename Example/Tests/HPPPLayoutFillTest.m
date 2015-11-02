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
#import <HPPPLayoutFactory.h>
#import <HPPPLogger.h>
#import <OCMock/OCMock.h>

@interface HPPPLayoutFillTest : XCTestCase

@end

@implementation HPPPLayoutFillTest
{
    id _loggerMock;
}

#pragma mark - Setup tests

- (void)setUp
{
    [super setUp];
    _loggerMock = OCMPartialMock([HPPPLogger sharedInstance]);
}

- (void)tearDown
{
    [super tearDown];
    [_loggerMock stopMocking];
}

#pragma mark - Test asset position

- (void)testInitWithNonDefaultAssetPosition
{
    HPPPLayout *fillLayout = [HPPPLayoutFactory layoutWithType:[HPPPLayoutFill layoutType] orientation:HPPPLayoutOrientationBestFit assetPosition:CGRectMake(5, 5, 90, 90)];
    
    XCTAssert(
              CGRectEqualToRect(fillLayout.assetPosition, [HPPPLayout completeFillRectangle]),
              @"Expected asset position to be rejected and replaced with default asset position (e.g. [HPPPLayout completeFillRectangle])");
    
    OCMVerify([_loggerMock logError:[OCMArg checkWithBlock:^BOOL(id obj) {
        NSString *arg = obj;
        return [arg containsString:@"The HPPPLayoutFill layout type only supports the complete fill asset position"];
    }]]);
}

- (void)testInitWithDefaultAssetPosition
{
    [[_loggerMock reject] logError:[OCMArg checkWithBlock:^BOOL(id obj) {
        NSString *arg = obj;
        return [arg containsString:@"The HPPPLayoutFill layout type only supports the complete fill asset position"];
    }]];
    
    HPPPLayout *fillLayout = [HPPPLayoutFactory layoutWithType:[HPPPLayoutFill layoutType] orientation:HPPPLayoutOrientationBestFit assetPosition:[HPPPLayout completeFillRectangle]];
    
    XCTAssert(
              CGRectEqualToRect(fillLayout.assetPosition, [HPPPLayout completeFillRectangle]),
              @"Expected asset position to be initialized with default asset position");
}

#pragma mark - Test border inches

- (void)testInitBorderInches
{
    HPPPLayout *fillLayout = [HPPPLayoutFactory layoutWithType:[HPPPLayoutFill layoutType] orientation:HPPPLayoutOrientationBestFit assetPosition:[HPPPLayout completeFillRectangle]];
    
    XCTAssert(
              0 == fillLayout.borderInches,
              @"Expected border inches to be initialized to zero instead of %.1f",
              fillLayout.borderInches);
}

- (void)testSetNonZeroBorderInches
{
    HPPPLayout *fillLayout = [HPPPLayoutFactory layoutWithType:[HPPPLayoutFill layoutType] orientation:HPPPLayoutOrientationBestFit assetPosition:[HPPPLayout completeFillRectangle]];
    fillLayout.borderInches = 1.0;
    
    XCTAssert(
              0 == fillLayout.borderInches,
              @"Expected non-zero border inches to be rejected");
    
    OCMVerify([_loggerMock logError:[OCMArg checkWithBlock:^BOOL(id obj) {
        NSString *arg = obj;
        return [arg containsString:@"The HPPPLayoutFill layout type does not support non-zero border"];
    }]]);
}

- (void)testSetZeroBorderInches
{
    [[_loggerMock reject] logError:[OCMArg checkWithBlock:^BOOL(id obj) {
        NSString *arg = obj;
        return [arg containsString:@"The HPPPLayoutFill layout type does not support non-zero border"];
    }]];
    
    HPPPLayout *fillLayout = [HPPPLayoutFactory layoutWithType:[HPPPLayoutFill layoutType] orientation:HPPPLayoutOrientationBestFit assetPosition:[HPPPLayout completeFillRectangle]];
    fillLayout.borderInches = 0.0;
    
    XCTAssert(
              0 == fillLayout.borderInches,
              @"Expected border inches to remain at 0");
}

@end