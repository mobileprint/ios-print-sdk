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
#import <HPPPPrintItemFactory.h>
#import <HPPPLayoutFactory.h>
#import <HPPPLayoutFit.h>
#import <HPPPLogger.h>
#import <OCMock/OCMock.h>

@interface HPPPPrintItemPDFTest : XCTestCase

@end

@implementation HPPPPrintItemPDFTest
{
    id _loggerMock;
    HPPPPrintItem *_printItem;
}

#pragma mark - Setup tests

- (void)setUp
{
    [super setUp];
    _loggerMock = OCMPartialMock([HPPPLogger sharedInstance]);
    _printItem = [HPPPPrintItemFactory printItemWithAsset:[self testPDF]];
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
              [_printItem.layout class] == [HPPPLayoutFit class],
              @"Expected layout to be type of HPPPLayoutFit (instead = '%@')",
              NSStringFromClass([_printItem.layout class]));
    
    HPPPLayoutFit *fitLayout = (HPPPLayoutFit *)_printItem.layout;

    XCTAssert(
              HPPPLayoutOrientationBestFit == fitLayout.orientation,
              @"Expected layout orientation to be HPPPLayoutOrientationBestFit (instead = %d)",
             fitLayout.orientation);
    
    XCTAssert(
              CGRectEqualToRect(fitLayout.assetPosition, [HPPPLayout completeFillRectangle]),
              @"Expected layout asset position to be the default asset position (e.g. [HPPPLayout completeFillRectangle])");
 
    XCTAssert(
              HPPPLayoutHorizontalPositionMiddle == fitLayout.horizontalPosition,
              @"Expected layout horizontal position to be HPPPLayoutHorizontalPositionMiddle (instead = %d)",
              fitLayout.horizontalPosition);
    
    XCTAssert(
              HPPPLayoutVerticalPositionMiddle == fitLayout.verticalPosition,
              @"Expected layout horizontal position to be HPPPLayoutVerticalPositionMiddle (instead = %d)",
              fitLayout.verticalPosition);
}

- (void)testSetLayout
{
    HPPPLayout *originalLayout = _printItem.layout;
    _printItem.layout = [HPPPLayoutFactory layoutWithType:[HPPPLayoutFit layoutType]];
    
    XCTAssert(
              _printItem.layout == originalLayout,
              @"Expected new layout to be rejected");
    
    OCMVerify([_loggerMock logError:[OCMArg checkWithBlock:^BOOL(id obj) {
        NSString *arg = obj;
        return [arg containsString:@"Cannot set layout of PDF print item"];
    }]]);
}

- (NSData *)testPDF
{
    NSString *path = [[NSBundle mainBundle] pathForResource:@"1 Page" ofType:@"pdf"];
    return [NSData dataWithContentsOfFile:path];
}

@end