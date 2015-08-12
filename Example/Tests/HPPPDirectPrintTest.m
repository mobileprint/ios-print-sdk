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
    NSError *error;
    self.printManager.currentPrintSettings.printerUrl = nil;
    [self.printManager directPrint:self.printItem
                             color:TRUE
                         pageRange:nil
                         numCopies:1
                             error:&error];
    
    XCTAssert(HPPPPrintManagerErrorNoPrinterUrl == error.code, @"Expected HPPPPrintManagerErrorNoPrinterUrl for nil value, recieved %@", error);
    
    self.printManager.currentPrintSettings.printerUrl = [NSURL URLWithString:@""];
    [self.printManager directPrint:self.printItem
                                     color:TRUE
                                 pageRange:nil
                                 numCopies:1
                                     error:&error];
    
    XCTAssert(HPPPPrintManagerErrorNoPrinterUrl == error.code, @"Expected HPPPPrintManagerErrorNoPrinterUrl for empty string, recieved %@", error);
}

- (void)testPrinterNotAvailable {
    NSError *error;
    self.printManager.currentPrintSettings.printerIsAvailable = FALSE;
    [self.printManager directPrint:self.printItem
                             color:TRUE
                         pageRange:nil
                         numCopies:1
                             error:&error];
    
    XCTAssert(HPPPPrintManagerErrorPrinterNotAvailable == error.code, @"Expected HPPPPrintManagerErrorPrinterNotAvailable, recieved %@", error);
    
}

- (void)testNoPaperType {
    NSError *error;
    self.printManager.currentPrintSettings.paper = nil;
    [self.printManager directPrint:self.printItem
                             color:TRUE
                         pageRange:nil
                         numCopies:1
                             error:&error];
    
    XCTAssert(HPPPPrintManagerErrorNoPaperType == error.code, @"Expected HPPPPrintManagerErrorNoPaperType, recieved %@", error);

}

- (void)testSuccess {
    NSError *error;
    [self.printManager directPrint:self.printItem
                             color:TRUE
                         pageRange:nil
                         numCopies:1
                             error:&error];
    
    XCTAssert(HPPPPrintManagerErrorNone == error.code, @"Expected HPPPPrintManagerErrorNone, recieved %@", error);
    
}


@end
