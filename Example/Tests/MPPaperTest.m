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
#import "MPPaper.h"
#import "MPPrintItem.h"
#import <OCMock/OCMock.h>

@interface MPPaperTest : XCTestCase

@end

@implementation MPPaperTest

NSUInteger const kTestPaperSizeId = 1000;
NSString * const kTestPaperSizeTitle = @"Test Size";
NSString * const kTestPaperSizeConstantName = @"Test constant name";
float const kTestPaperSizeWidth = 1.0;
float const kTestPaperSizeHeight = 2.0;
float const kTestPaperSizePrinterWidth = 3.0;
float const kTestPaperSizePrinterHeight = 4.0;

NSUInteger const kTestPaperTypeId = MPPaperTypePlain;

#pragma mark - Setup tests

- (void)setUp
{
    [super setUp];
}

- (void)tearDown
{
    [super tearDown];
    [MPPaper resetPaperList];
}

#pragma mark - Test 'printerPaperSize'

- (void)testprinterPaperSize
{
    NSDictionary *info = [self defaultSizeInfo];
    [self registerPaperSize:info];
    MPPaper *paper = [[MPPaper alloc] initWithPaperSize:kTestPaperSizeId paperType:kTestPaperTypeId];
    [self verifyPrinterPaper:paper withSettings:info];
}

- (void)testprinterPaperSizeOverrideWidth
{
    float printerWidth = kTestPaperSizePrinterWidth;
    NSMutableDictionary *info = [NSMutableDictionary dictionaryWithDictionary:[self defaultSizeInfo]];
    [info addEntriesFromDictionary:@{ kMPPaperSizePrinterWidthKey:[NSNumber numberWithFloat:printerWidth] }];
    [self registerPaperSize:info];
    MPPaper *paper = [[MPPaper alloc] initWithPaperSize:kTestPaperSizeId paperType:kTestPaperTypeId];
    [self verifyPrinterPaper:paper withSettings:info];
}

- (void)testprinterPaperSizeOverrideHeight
{
    float printerHeight = kTestPaperSizePrinterHeight;
    NSMutableDictionary *info = [NSMutableDictionary dictionaryWithDictionary:[self defaultSizeInfo]];
    [info addEntriesFromDictionary:@{ kMPPaperSizePrinterHeightKey:[NSNumber numberWithFloat:printerHeight] }];
    [self registerPaperSize:info];
    MPPaper *paper = [[MPPaper alloc] initWithPaperSize:kTestPaperSizeId paperType:kTestPaperTypeId];
    [self verifyPrinterPaper:paper withSettings:info];
}

- (void)testprinterPaperConstantSizeName
{
    NSDictionary *info = [self defaultSizeInfo];
    [self registerPaperSize:info];
    
    BOOL stringsMatch = [kTestPaperSizeConstantName isEqualToString:[MPPaper constantPaperSizeFromTitle:kTestPaperSizeTitle]];
    XCTAssert(stringsMatch, @"The constant paper size name is incorrect");
}

#pragma mark - Paper helpers

- (void)registerPaperSize:(NSDictionary *)info
{
    [MPPaper registerSize:info];
    [MPPaper associatePaperSize:kTestPaperSizeId withType:kTestPaperTypeId];
}

- (NSDictionary *)defaultSizeInfo
{
    return @{
             kMPPaperSizeIdKey:[NSNumber numberWithUnsignedInteger:kTestPaperSizeId],
             kMPPaperSizeTitleKey:kTestPaperSizeTitle,
             kMPPaperSizeConstantNameKey:kTestPaperSizeConstantName,
             kMPPaperSizeWidthKey:[NSNumber numberWithFloat:kTestPaperSizeWidth],
             kMPPaperSizeHeightKey:[NSNumber numberWithFloat:kTestPaperSizeHeight]
             };
}

#pragma mark - Printer paper helpers

- (void)verifyPrinterPaper:(MPPaper *)paper withSettings:(NSDictionary *)settings
{
    CGSize printerPaper = [paper printerPaperSize];
    
    NSNumber *printerWidth = [settings objectForKey:kMPPaperSizePrinterWidthKey];
    NSNumber *printerHeight = [settings objectForKey:kMPPaperSizePrinterHeightKey];
    float expectedWidth = printerWidth ? [printerWidth floatValue] : [[settings objectForKey:kMPPaperSizeWidthKey] floatValue];
    float expectedHeight = printerHeight ? [printerHeight floatValue] : [[settings objectForKey:kMPPaperSizeHeightKey] floatValue];
    
    XCTAssert(
              printerPaper.width == expectedWidth * kMPPointsPerInch,
              @"Expected print paper width (%.1f) to equal paper width in points (%.1f)",
              printerPaper.width,
              expectedWidth * kMPPointsPerInch);
    
    XCTAssert(
              printerPaper.height == expectedHeight * kMPPointsPerInch,
              @"Expected print paper height (%.1f) to equal paper height in points (%.1f)",
              printerPaper.height,
              expectedHeight * kMPPointsPerInch);
}

@end
