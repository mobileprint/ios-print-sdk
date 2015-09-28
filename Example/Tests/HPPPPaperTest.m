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
#import <HPPP.h>
#import <HPPPPaper.h>
#import <HPPPPrintItem.h>
#import <OCMock/OCMock.h>

@interface HPPPPaperTest : XCTestCase

@end

@implementation HPPPPaperTest

NSUInteger const kTestPaperSizeId = 1000;
NSString * const kTestPaperSizeTitle = @"Test Size";
float const kTestPaperSizeWidth = 1.0;
float const kTestPaperSizeHeight = 2.0;
float const kTestPaperSizePrinterWidth = 3.0;
float const kTestPaperSizePrinterHeight = 4.0;

NSUInteger const kTestPaperTypeId = HPPPPaperTypePlain;

#pragma mark - Setup tests

- (void)setUp
{
    [super setUp];
}

- (void)tearDown
{
    [super tearDown];
    [HPPPPaper resetPaperList];
}

#pragma mark - Test 'printerPaperSize'

- (void)testprinterPaperSize
{
    NSDictionary *info = [self defaultSizeInfo];
    [self registerPaperSize:info];
    HPPPPaper *paper = [[HPPPPaper alloc] initWithPaperSize:kTestPaperSizeId paperType:kTestPaperTypeId];
    [self verifyPrinterPaper:paper withSettings:info];
}

- (void)testprinterPaperSizeOverrideWidth
{
    float printerWidth = kTestPaperSizePrinterWidth;
    NSMutableDictionary *info = [NSMutableDictionary dictionaryWithDictionary:[self defaultSizeInfo]];
    [info addEntriesFromDictionary:@{ kHPPPPaperSizePrinterWidthKey:[NSNumber numberWithFloat:printerWidth] }];
    [self registerPaperSize:info];
    HPPPPaper *paper = [[HPPPPaper alloc] initWithPaperSize:kTestPaperSizeId paperType:kTestPaperTypeId];
    [self verifyPrinterPaper:paper withSettings:info];
}

- (void)testprinterPaperSizeOverrideHeight
{
    float printerHeight = kTestPaperSizePrinterHeight;
    NSMutableDictionary *info = [NSMutableDictionary dictionaryWithDictionary:[self defaultSizeInfo]];
    [info addEntriesFromDictionary:@{ kHPPPPaperSizePrinterHeightKey:[NSNumber numberWithFloat:printerHeight] }];
    [self registerPaperSize:info];
    HPPPPaper *paper = [[HPPPPaper alloc] initWithPaperSize:kTestPaperSizeId paperType:kTestPaperTypeId];
    [self verifyPrinterPaper:paper withSettings:info];
}

#pragma mark - Paper helpers

- (void)registerPaperSize:(NSDictionary *)info
{
    [HPPPPaper registerSize:info];
    [HPPPPaper associatePaperSize:kTestPaperSizeId withType:kTestPaperTypeId];
}

- (NSDictionary *)defaultSizeInfo
{
    return @{
             kHPPPPaperSizeIdKey:[NSNumber numberWithUnsignedInteger:kTestPaperSizeId],
             kHPPPPaperSizeTitleKey:kTestPaperSizeTitle,
             kHPPPPaperSizeWidthKey:[NSNumber numberWithFloat:kTestPaperSizeWidth],
             kHPPPPaperSizeHeightKey:[NSNumber numberWithFloat:kTestPaperSizeHeight]
             };
}

#pragma mark - Printer paper helpers

- (void)verifyPrinterPaper:(HPPPPaper *)paper withSettings:(NSDictionary *)settings
{
    CGSize printerPaper = [paper printerPaperSize];
    
    NSNumber *printerWidth = [settings objectForKey:kHPPPPaperSizePrinterWidthKey];
    NSNumber *printerHeight = [settings objectForKey:kHPPPPaperSizePrinterHeightKey];
    float expectedWidth = printerWidth ? [printerWidth floatValue] : [[settings objectForKey:kHPPPPaperSizeWidthKey] floatValue];
    float expectedHeight = printerHeight ? [printerHeight floatValue] : [[settings objectForKey:kHPPPPaperSizeHeightKey] floatValue];
    
    XCTAssert(
              printerPaper.width == expectedWidth * kHPPPPointsPerInch,
              @"Expected print paper width (%.1f) to equal paper width in points (%.1f)",
              printerPaper.width,
              expectedWidth * kHPPPPointsPerInch);
    
    XCTAssert(
              printerPaper.height == expectedHeight * kHPPPPointsPerInch,
              @"Expected print paper height (%.1f) to equal paper height in points (%.1f)",
              printerPaper.height,
              expectedHeight * kHPPPPointsPerInch);
}

@end
