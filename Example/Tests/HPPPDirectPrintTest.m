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
#import "HPPPPrintItemFactory.h"
#import "HPPPPrintManager.h"

@interface HPPPDirectPrintTest : XCTestCase

@property (strong, nonatomic) HPPPPrintItem *printItem;
@property (strong, nonatomic) HPPPPrintManager *printManager;

@end

@implementation HPPPDirectPrintTest

- (void)setUp {
    [super setUp];

    UIImage *image = [UIImage imageNamed:@"Balloons.jpg"];
    self.printItem = [HPPPPrintItemFactory printItemWithAsset:image];
    
    self.printManager = [[HPPPPrintManager alloc] init];
    self.printManager.currentPrintSettings.printerName = @"dummyPrinterName";
    self.printManager.currentPrintSettings.printerUrl = [NSURL URLWithString:@"dummyPrinterUrl"];
    self.printManager.currentPrintSettings.paper = [[HPPPPaper alloc] initWithPaperSizeTitle:@"5 x 7" paperTypeTitle:@"Photo Paper"];
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testNoPrinterUrl {
    // test printer not available
    self.printManager.currentPrintSettings.printerUrl = nil;
    HPPPPrintManagerError error = [self.printManager directPrint:self.printItem
                                                           color:TRUE
                                                       pageRange:nil
                                                       numCopies:1];
    
    XCTAssert(HPPPPrintManagerErrorNoPrinterUrl == error, @"Expected HPPPPrintManagerErrorNoPrinterUrl for nil value, recieved %d", error);
    
    self.printManager.currentPrintSettings.printerUrl = [NSURL URLWithString:@""];
    error = [self.printManager directPrint:self.printItem
                                     color:TRUE
                                 pageRange:nil
                                 numCopies:1];
    
    XCTAssert(HPPPPrintManagerErrorNoPrinterUrl == error, @"Expected HPPPPrintManagerErrorNoPrinterUrl for empty string, recieved %d", error);
}

- (void)testPrinterNotAvailable {
    // test printer not available
    self.printManager.currentPrintSettings.printerIsAvailable = FALSE;
    HPPPPrintManagerError error = [self.printManager directPrint:self.printItem
                                                           color:TRUE
                                                       pageRange:nil
                                                       numCopies:1];
    
    XCTAssert(HPPPPrintManagerErrorPrinterNotAvailable == error, @"Expected HPPPPrintManagerErrorPrinterNotAvailable, recieved %d", error);
    
}

- (void)testNoPaperType {
    // test printer not available
    self.printManager.currentPrintSettings.paper = nil;
    HPPPPrintManagerError error = [self.printManager directPrint:self.printItem
                                                      color:TRUE
                                                  pageRange:nil
                                                  numCopies:1];
    
    XCTAssert(HPPPPrintManagerErrorNoPaperType == error, @"Expected HPPPPrintManagerErrorNoPaperType, recieved %d", error);

}

- (void)testSuccess {
    // test printer not available
    HPPPPrintManagerError error = [self.printManager directPrint:self.printItem
                                                           color:TRUE
                                                       pageRange:nil
                                                       numCopies:1];
    
    XCTAssert(HPPPPrintManagerErrorNone == error, @"Expected HPPPPrintManagerErrorNone, recieved %d", error);
    
}


@end
