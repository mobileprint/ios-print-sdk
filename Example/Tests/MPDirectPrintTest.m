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
#import "MPPrintItemFactory.h"
#import "MPPrintManager.h"
#import "MPLogger.h"
#import <OCMock/OCMock.h>

@interface MPDirectPrintTest : XCTestCase

@property (strong, nonatomic) MPPrintItem *printItem;
@property (strong, nonatomic) MPPrintManager *printManager;

@end

@implementation MPDirectPrintTest
{
    id _loggerMock;
}

- (void)setUp {
    [super setUp];

    UIImage *image = [UIImage imageNamed:@"Balloons.jpg"];
    self.printItem = [MPPrintItemFactory printItemWithAsset:image];
    
    self.printManager = [[MPPrintManager alloc] init];
    self.printManager.currentPrintSettings.printerName = @"dummyPrinterName";
    self.printManager.currentPrintSettings.printerUrl = [NSURL URLWithString:@"dummyPrinterUrl"];
    self.printManager.currentPrintSettings.paper = [[MPPaper alloc] initWithPaperSize:MPPaperSize5x7 paperType:MPPaperTypePhoto];

    _loggerMock = OCMPartialMock([MPLogger sharedInstance]);
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
    
    [self verifyError:error expectedName:@"MPPrintManagerErrorNoPrinterUrl" expectedCode:MPPrintManagerErrorNoPrinterUrl];
    
    self.printManager.currentPrintSettings.printerUrl = [NSURL URLWithString:@""];
    [self.printManager print:self.printItem
                   pageRange:nil
                   numCopies:1
                       error:&error];

    [self verifyError:error expectedName:@"MPPrintManagerErrorNoPrinterUrl" expectedCode:MPPrintManagerErrorNoPrinterUrl];
}

- (void)testPrinterNotAvailable {
    NSError *error;
    self.printManager.currentPrintSettings.printerIsAvailable = FALSE;
    [self.printManager print:self.printItem
                   pageRange:nil
                   numCopies:1
                       error:&error];
  
    
    [self verifyError:error expectedName:@"MPPrintManagerErrorPrinterNotAvailable" expectedCode:MPPrintManagerErrorPrinterNotAvailable];
}

- (void)testNoPaperType {
    NSError *error;
    self.printManager.currentPrintSettings.paper = nil;
    [self.printManager print:self.printItem
                   pageRange:nil
                   numCopies:1
                       error:&error];
    
    [self verifyError:error expectedName:@"MPPrintManagerErrorNoPaperType" expectedCode:MPPrintManagerErrorNoPaperType];
}

- (void)testSuccess {
    NSError *error;
    [self.printManager print:self.printItem
                   pageRange:nil
                   numCopies:1
                       error:&error];
    
    [self verifyError:error expectedName:@"MPPrintManagerErrorNone" expectedCode:MPPrintManagerErrorNone];
}

#pragma mark - Error verification

- (void)verifyError:(NSError *)error expectedName:(NSString *)expectedName expectedCode:(NSInteger)expectedCode
{
    if (IS_OS_8_OR_LATER) {
        XCTAssert(expectedCode == error.code, @"Expected error %@ (%ld), recieved %@", expectedName, (long)expectedCode ,error);
    } else {
        [self checkiOS7Error:error];
    }
}

- (void)checkiOS7Error:(NSError *)error
{
    XCTAssert(MPPrintManagerErrorDirectPrintNotSupported == error.code, @"Expected MPPrintManagerErrorDirectPrintNotSupported for iOS 7, recieved %@", error);

    OCMVerify([_loggerMock logWarn:[OCMArg checkWithBlock:^BOOL(id obj) {
        NSString *arg = obj;
        return [arg rangeOfString:@"directPrint not completed - only available on iOS 8 and later"].location != NSNotFound;
    }]]);
    
    [_loggerMock stopMocking];
    _loggerMock = OCMPartialMock([MPLogger sharedInstance]);
}

@end
