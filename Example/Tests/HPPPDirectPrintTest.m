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
#import "HPPPPrintItemFactory.h"
#import "HPPPPrintManager.h"
#import <HPPPLogger.h>
#import <OCMock/OCMock.h>

@interface HPPPDirectPrintTest : XCTestCase

@property (strong, nonatomic) HPPPPrintItem *printItem;
@property (strong, nonatomic) HPPPPrintManager *printManager;

@end

@implementation HPPPDirectPrintTest
{
    id _loggerMock;
}

- (void)setUp {
    [super setUp];

    UIImage *image = [UIImage imageNamed:@"Balloons.jpg"];
    self.printItem = [HPPPPrintItemFactory printItemWithAsset:image];
    
    self.printManager = [[HPPPPrintManager alloc] init];
    self.printManager.currentPrintSettings.printerName = @"dummyPrinterName";
    self.printManager.currentPrintSettings.printerUrl = [NSURL URLWithString:@"dummyPrinterUrl"];
    self.printManager.currentPrintSettings.paper = [[HPPPPaper alloc] initWithPaperSize:HPPPPaperSize5x7 paperType:HPPPPaperTypePhoto];

    _loggerMock = OCMPartialMock([HPPPLogger sharedInstance]);
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
    [_loggerMock stopMocking];
}

- (void)testNoPrinterUrl {
    NSError *error;
    self.printManager.currentPrintSettings.printerUrl = nil;
    [self.printManager print:self.printItem
                   pageRange:nil
                   numCopies:1
                       error:&error];
    
    [self verifyError:error expectedName:@"HPPPPrintManagerErrorNoPrinterUrl" expectedCode:HPPPPrintManagerErrorNoPrinterUrl];
    
    self.printManager.currentPrintSettings.printerUrl = [NSURL URLWithString:@""];
    [self.printManager print:self.printItem
                   pageRange:nil
                   numCopies:1
                       error:&error];

    [self verifyError:error expectedName:@"HPPPPrintManagerErrorNoPrinterUrl" expectedCode:HPPPPrintManagerErrorNoPrinterUrl];
}

- (void)testPrinterNotAvailable {
    NSError *error;
    self.printManager.currentPrintSettings.printerIsAvailable = FALSE;
    [self.printManager print:self.printItem
                   pageRange:nil
                   numCopies:1
                       error:&error];
  
    
    [self verifyError:error expectedName:@"HPPPPrintManagerErrorPrinterNotAvailable" expectedCode:HPPPPrintManagerErrorPrinterNotAvailable];
}

- (void)testNoPaperType {
    NSError *error;
    self.printManager.currentPrintSettings.paper = nil;
    [self.printManager print:self.printItem
                   pageRange:nil
                   numCopies:1
                       error:&error];
    
    [self verifyError:error expectedName:@"HPPPPrintManagerErrorNoPaperType" expectedCode:HPPPPrintManagerErrorNoPaperType];
}

- (void)testSuccess {
    NSError *error;
    [self.printManager print:self.printItem
                   pageRange:nil
                   numCopies:1
                       error:&error];
    
    [self verifyError:error expectedName:@"HPPPPrintManagerErrorNone" expectedCode:HPPPPrintManagerErrorNone];
}

#pragma mark - Error verification

- (void)verifyError:(NSError *)error expectedName:(NSString *)expectedName expectedCode:(NSInteger)expectedCode
{
    if (IS_OS_8_OR_LATER) {
        XCTAssert(expectedCode == error.code, @"Expected error %@ (%d), recieved %@", expectedName, expectedCode ,error);
    } else {
        [self checkiOS7Error:error];
    }
}

- (void)checkiOS7Error:(NSError *)error
{
    XCTAssert(HPPPPrintManagerErrorDirectPrintNotSupported == error.code, @"Expected HPPPPrintManagerErrorDirectPrintNotSupported for iOS 7, recieved %@", error);

    OCMVerify([_loggerMock logWarn:[OCMArg checkWithBlock:^BOOL(id obj) {
        NSString *arg = obj;
        return [arg rangeOfString:@"directPrint not completed - only available on iOS 8 and later"].location != NSNotFound;
    }]]);
    
    [_loggerMock stopMocking];
    _loggerMock = OCMPartialMock([HPPPLogger sharedInstance]);
}

@end
