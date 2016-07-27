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
#import "MPPrintItemFactory.h"
#import "MPLayoutFactory.h"
#import "MPLayoutFit.h"
#import "MPLogger.h"
#import <OCMock/OCMock.h>

@interface MPPrintItemPDFTest : XCTestCase

@end

@implementation MPPrintItemPDFTest
{
    id _loggerMock;
    MPPrintItem *_printItem;
}

#pragma mark - Setup tests

- (void)setUp
{
    [super setUp];
    _loggerMock = OCMPartialMock([MPLogger sharedInstance]);
    _printItem = [MPPrintItemFactory printItemWithAsset:[self testPDF]];
}

- (void)tearDown
{
    [super tearDown];
    [_loggerMock stopMocking];
}

#pragma mark - Test layout

- (void)testInitializeLayout
{
    XCTAssert(
              [_printItem.layout class] == [MPLayoutFit class],
              @"Expected layout to be type of MPLayoutFit (instead = '%@')",
              NSStringFromClass([_printItem.layout class]));
    
    MPLayoutFit *fitLayout = (MPLayoutFit *)_printItem.layout;

    XCTAssert(
              MPLayoutOrientationBestFit == fitLayout.orientation,
              @"Expected layout orientation to be MPLayoutOrientationBestFit (instead = %d)",
             fitLayout.orientation);
    
    XCTAssert(
              CGRectEqualToRect(fitLayout.assetPosition, [MPLayout completeFillRectangle]),
              @"Expected layout asset position to be the default asset position (e.g. [MPLayout completeFillRectangle])");
 
    XCTAssert(
              MPLayoutHorizontalPositionMiddle == fitLayout.horizontalPosition,
              @"Expected layout horizontal position to be MPLayoutHorizontalPositionMiddle (instead = %d)",
              fitLayout.horizontalPosition);
    
    XCTAssert(
              MPLayoutVerticalPositionMiddle == fitLayout.verticalPosition,
              @"Expected layout horizontal position to be MPLayoutVerticalPositionMiddle (instead = %d)",
              fitLayout.verticalPosition);
}

- (void)testSetLayout
{
    MPLayout *originalLayout = _printItem.layout;
    _printItem.layout = [MPLayoutFactory layoutWithType:[MPLayoutFit layoutType]];
    
    XCTAssert(
              _printItem.layout == originalLayout,
              @"Expected new layout to be rejected");
    
    OCMVerify([_loggerMock logError:[OCMArg checkWithBlock:^BOOL(id obj) {
        NSString *arg = obj;
        return [arg rangeOfString:@"Cannot set layout of PDF print item"].location != NSNotFound;
    }]]);
}

- (void)testActivityItems
{
    XCTAssert(
              2 == _printItem.activityItems.count,
              @"Expected two activity items, got %lu instead",
              (unsigned long)_printItem.activityItems.count);
    
    XCTAssert(_printItem == _printItem.activityItems[0],
              @"Expected the print item itself to be the first activity item");
    
    XCTAssert(_printItem.printAsset == _printItem.activityItems[1],
              @"Expected the printable asset to be the second activity item");
    
}

- (NSData *)testPDF
{
    NSString *path = [[NSBundle mainBundle] pathForResource:@"1 Page" ofType:@"pdf"];
    return [NSData dataWithContentsOfFile:path];
}

@end
