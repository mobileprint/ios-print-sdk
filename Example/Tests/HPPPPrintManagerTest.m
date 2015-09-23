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
#import <HPPPPrintManager.h>
#import <HPPPPrintManager+Options.h>

@interface HPPPPrintManagerTest : XCTestCase

@end

@implementation HPPPPrintManagerTest
{
    HPPPPaper *_expectedPaper;
    BOOL _expectedColor;
    HPPPPrintManager *_printManager;
}

- (void)setUp
{
    [super setUp];
    
    _expectedPaper = [[HPPPPaper alloc] initWithPaperSize:HPPPPaperSizeLetter paperType:HPPPPaperTypePlain];
    _expectedColor = NO;
    
    NSUserDefaults * defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:[NSNumber numberWithUnsignedInteger:_expectedPaper.paperSize] forKey:@"kHPPPLastPaperSizeSetting"];
    [defaults setObject:[NSNumber numberWithUnsignedInteger:_expectedPaper.paperType] forKey:@"kHPPPLastPaperTypeSetting"];
    [defaults setObject:[NSNumber numberWithBool:!_expectedColor] forKey:@"kHPPPLastBlackAndWhiteFilterSetting"];
    [defaults synchronize];
    
    _printManager = [[HPPPPrintManager alloc] init];
}

- (void)tearDown
{
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
    [NSUserDefaults resetStandardUserDefaults];
}

- (void)testInit
{
    // TODO: still needs ot check all the base print settings, will do it... later
    
    XCTAssert(_printManager.currentPrintSettings.printerIsAvailable , @"Expected printer available");
    XCTAssert(_printManager.options == HPPPPrintManagerOriginDirect , @"Expected options to equal HPPPPrintManagerOriginDirect");
    XCTAssert(_printManager.currentPrintSettings.paper.paperSize == _expectedPaper.paperSize , @"Expected paper size (%lul) does not match actual paper size (%lul)", _expectedPaper.paperSize, _printManager.currentPrintSettings.paper.paperSize);
    XCTAssert(_printManager.currentPrintSettings.paper.paperType == _expectedPaper.paperType , @"Expected paper type (%lul) does not match actual paper type (%lul)", _expectedPaper.paperType, _printManager.currentPrintSettings.paper.paperType);
    XCTAssert(_printManager.currentPrintSettings.color == _expectedColor , @"Expected color (%ul) does not match actual color (%ul)", _expectedColor, _printManager.currentPrintSettings.color);
}

- (void)testsaveLastOptionsForPrinter
{
    [_printManager saveLastOptionsForPrinter:@"fake printer"];
    
    // TODO: still need to test all saved options plus "no printer" case
    
    NSNumber *width = [[HPPP sharedInstance].lastOptionsUsed objectForKey:kHPPPPaperWidthId];
    NSNumber *height = [[HPPP sharedInstance].lastOptionsUsed objectForKey:kHPPPPaperHeightId];
    XCTAssert([width floatValue] == _expectedPaper.width, @"Expected last paper width (%.3f) to equal expected paper width (%.3f)", [width floatValue], _expectedPaper.width);
    XCTAssert([height floatValue] == _expectedPaper.height, @"Expected last paper height (%.3f) to equal expected paper height (%.3f)", [height floatValue], _expectedPaper.height);
}

@end
