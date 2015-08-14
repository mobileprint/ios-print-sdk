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
#import "HPPPPrintSettingsDelegateManager.h"
#import "HPPPPageRange.h"

@interface HPPPPrintSettingsDelegateManagerTest : XCTestCase

@property (strong, nonatomic) HPPPPrintSettingsDelegateManager *delegateManager;

@end

@implementation HPPPPrintSettingsDelegateManagerTest

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
    HPPPPageRange *pageRange = [[HPPPPageRange alloc] initWithString:@"ALL" allPagesIndicator:@"All" maxPageNum:10 sortAscending:YES];

    self.delegateManager = [[HPPPPrintSettingsDelegateManager alloc] init];
    self.delegateManager.pageRange = pageRange;
    self.delegateManager.currentPrintSettings = [HPPPPrintSettings alloc];
    self.delegateManager.currentPrintSettings.paper = [HPPP sharedInstance].defaultPaper;
    self.delegateManager.currentPrintSettings.printerName = @"default printer";
    self.delegateManager.currentPrintSettings.printerIsAvailable = YES;
    self.delegateManager.numCopies = 1;

}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testExample {
    // This is an example of a functional test case.
    XCTAssert(YES, @"Pass");
}

- (void)testPerformanceExample {
    // This is an example of a performance test case.
    [self measureBlock:^{
        // Put the code you want to measure the time of here.
    }];
}

@end
