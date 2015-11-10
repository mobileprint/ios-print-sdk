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
#import "MPPrintSettingsDelegateManager.h"
#import "MPPrintItemFactory.h"
#import "MPPageRange.h"

#define MPTestPrinterName @"Test Printer"

@interface MPPrintSettingsDelegateManagerTest : XCTestCase

@property (strong, nonatomic) MPPrintSettingsDelegateManager *delegateManager;

@end

@implementation MPPrintSettingsDelegateManagerTest

- (void)setUp {
    [super setUp];

    self.delegateManager = [[MPPrintSettingsDelegateManager alloc] init];
    self.delegateManager.printSettings = [MPPrintSettings alloc];
    self.delegateManager.printSettings.paper = [MP sharedInstance].defaultPaper;
    self.delegateManager.printSettings.printerName = MPTestPrinterName;
    self.delegateManager.printSettings.printerIsAvailable = YES;
    self.delegateManager.numCopies = 1;
    
    NSString *path = [[NSBundle mainBundle] pathForResource:@"10 Pages" ofType:@"pdf"];
    MPPrintItem *printItemPdf = [MPPrintItemFactory printItemWithAsset:[NSData dataWithContentsOfFile:path]];
    self.delegateManager.printItem = printItemPdf;

    MPPageRange *pageRange = [[MPPageRange alloc] initWithString:kPageRangeAllPages allPagesIndicator:kPageRangeAllPages maxPageNum:10 sortAscending:YES];
    self.delegateManager.pageRange = pageRange;
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testPrintLabelText {
    
    // Test the single copy case
    NSString *expectedPrintLabelText = @"Print";
    NSString *expected0PageText = @"Print";
    NSString *expected1PageText = @"Print 1 Page";
    NSString *expected8PagesText = @"Print 8 Pages";

    XCTAssert([expectedPrintLabelText isEqualToString:[self.delegateManager printLabelText]], @"All Pages Print Label Text: %@", [self.delegateManager printLabelText]);
    
    self.delegateManager.pageRange.range = @"";
    XCTAssert([expected0PageText isEqualToString:[self.delegateManager printLabelText]], @"0 Page Print Label Text: %@", [self.delegateManager printLabelText]);

    self.delegateManager.pageRange.range = @"1";
    XCTAssert([expected1PageText isEqualToString:[self.delegateManager printLabelText]], @"1 Page Print Label Text: %@", [self.delegateManager printLabelText]);

    self.delegateManager.pageRange.range = @"1-8";
    XCTAssert([expected8PagesText isEqualToString:[self.delegateManager printLabelText]], @"8 Page Print Label Text: %@", [self.delegateManager printLabelText]);
    

    // Now, test with multiple copies
    self.delegateManager.pageRange.range = kPageRangeAllPages;
    self.delegateManager.numCopies = 2;
    expectedPrintLabelText = [NSString stringWithFormat:@"Print %ld Pages", (long)(long)self.delegateManager.printItem.numberOfPages*2];
    expected0PageText = @"Print";
    expected1PageText = @"Print 2 Pages";
    expected8PagesText = @"Print 16 Pages";
    
    XCTAssert([expectedPrintLabelText isEqualToString:[self.delegateManager printLabelText]], @"2 Copies, All Pages Print Label Text: %@", [self.delegateManager printLabelText]);
    
    self.delegateManager.pageRange.range = @"";
    XCTAssert([expected0PageText isEqualToString:[self.delegateManager printLabelText]], @"2 Copies, 0 Page Print Label Text: %@", [self.delegateManager printLabelText]);
    
    self.delegateManager.pageRange.range = @"1";
    XCTAssert([expected1PageText isEqualToString:[self.delegateManager printLabelText]], @"2 Copies, 1 Page Print Label Text: %@", [self.delegateManager printLabelText]);
    
    self.delegateManager.pageRange.range = @"1-8";
    XCTAssert([expected8PagesText isEqualToString:[self.delegateManager printLabelText]], @"2 Copies, 8 Page Print Label Text: %@", [self.delegateManager printLabelText]);
}

- (void)testPageRangeText {

    // Page ranges are tested by MPPageRangeTest, but
    //  the display text for 0 pages is not tested by MPPageRangeTest
    self.delegateManager.pageRange.range = @"";
    NSString *expected0PageText = kPageRangeNoPages;
    XCTAssert([expected0PageText isEqualToString:[self.delegateManager pageRangeText]], @"0 Page Print Range Text: %@", [self.delegateManager pageRangeText]);
    
}

- (void)testPrintJobSummaryText {
    
    NSString *singleCopy = @"1 Copy";
    NSString *expectedJobSummaryText = [NSString stringWithFormat:@"%@ / %@ %@", singleCopy, self.delegateManager.printSettings.paper.sizeTitle, self.delegateManager.printSettings.paper.typeTitle];
    NSString *expected0PageText = [NSString stringWithFormat:@"0 of %ld Pages / %@ / %@ %@", (long)self.delegateManager.printItem.numberOfPages, singleCopy, self.delegateManager.printSettings.paper.sizeTitle, self.delegateManager.printSettings.paper.typeTitle];
    NSString *expected1PageText = [NSString stringWithFormat:@"1 of %ld Pages / %@ / %@ %@", (long)self.delegateManager.printItem.numberOfPages, singleCopy, self.delegateManager.printSettings.paper.sizeTitle, self.delegateManager.printSettings.paper.typeTitle];
    NSString *expected8PagesText = [NSString stringWithFormat:@"8 of %ld Pages / B&W / %@ / %@ %@", (long)self.delegateManager.printItem.numberOfPages, singleCopy, self.delegateManager.printSettings.paper.sizeTitle, self.delegateManager.printSettings.paper.typeTitle];
    
    XCTAssert([expectedJobSummaryText isEqualToString:[self.delegateManager printJobSummaryText]], @"All Pages Job Summary Text: %@", [self.delegateManager printJobSummaryText]);
    
    self.delegateManager.pageRange.range = @"";
    XCTAssert([expected0PageText isEqualToString:[self.delegateManager printJobSummaryText]], @"0 Page Job Summary Text: %@", [self.delegateManager printJobSummaryText]);

    self.delegateManager.pageRange.range = @"3";
    XCTAssert([expected1PageText isEqualToString:[self.delegateManager printJobSummaryText]], @"1 Page Job Summary Text: %@", [self.delegateManager printJobSummaryText]);

    self.delegateManager.pageRange.range = @"1-8";
    self.delegateManager.blackAndWhite = YES;
    XCTAssert([expected8PagesText isEqualToString:[self.delegateManager printJobSummaryText]], @"8 Pages, Black and White Job Summary Text: %@", [self.delegateManager printJobSummaryText]);

    // Test multiple copies
    NSString *twoCopies = @"2 Copies";
    expectedJobSummaryText = [expectedJobSummaryText stringByReplacingOccurrencesOfString:singleCopy withString:twoCopies];
    expected0PageText = [expected0PageText stringByReplacingOccurrencesOfString:singleCopy withString:twoCopies];
    expected1PageText = [expected1PageText stringByReplacingOccurrencesOfString:singleCopy withString:twoCopies];
    expected8PagesText = [expected8PagesText stringByReplacingOccurrencesOfString:singleCopy withString:twoCopies];

    self.delegateManager.blackAndWhite = NO;
    self.delegateManager.numCopies = 2;
    self.delegateManager.pageRange.range = kPageRangeAllPages;
    XCTAssert([expectedJobSummaryText isEqualToString:[self.delegateManager printJobSummaryText]], @"2 Copies, All Pages Job Summary Text: %@", [self.delegateManager printJobSummaryText]);
    
    self.delegateManager.pageRange.range = @"";
    XCTAssert([expected0PageText isEqualToString:[self.delegateManager printJobSummaryText]], @"2 Copies, 0 Page Job Summary Text: %@", [self.delegateManager printJobSummaryText]);
    
    self.delegateManager.pageRange.range = @"3";
    XCTAssert([expected1PageText isEqualToString:[self.delegateManager printJobSummaryText]], @"2 Copies, 1 Page Job Summary Text: %@", [self.delegateManager printJobSummaryText]);
    
    self.delegateManager.pageRange.range = @"1-8";
    self.delegateManager.blackAndWhite = YES;
    XCTAssert([expected8PagesText isEqualToString:[self.delegateManager printJobSummaryText]], @"2 Copies, 8 Pages, Black and White Job Summary Text: %@", [self.delegateManager printJobSummaryText]);
}

- (void)testPrintLaterJobSummaryText {
    
    NSString *singleCopy = @"1 Copy";
    NSString *expectedJobSummaryText = [NSString stringWithFormat:@"%@", singleCopy];
    NSString *expected0PageText = [NSString stringWithFormat:@"0 of %ld Pages / %@", (long)self.delegateManager.printItem.numberOfPages, singleCopy];
    NSString *expected1PageText = [NSString stringWithFormat:@"1 of %ld Pages / %@", (long)self.delegateManager.printItem.numberOfPages, singleCopy];
    NSString *expected8PagesText = [NSString stringWithFormat:@"8 of %ld Pages / B&W / %@", (long)self.delegateManager.printItem.numberOfPages, singleCopy];
    
    XCTAssert([expectedJobSummaryText isEqualToString:[self.delegateManager printLaterJobSummaryText]], @"All Pages Later Job Summary Text: %@", [self.delegateManager printJobSummaryText]);
    
    self.delegateManager.pageRange.range = @"";
    XCTAssert([expected0PageText isEqualToString:[self.delegateManager printLaterJobSummaryText]], @"0 Page Later Job Summary Text: %@", [self.delegateManager printJobSummaryText]);
    
    self.delegateManager.pageRange.range = @"3";
    XCTAssert([expected1PageText isEqualToString:[self.delegateManager printLaterJobSummaryText]], @"1 Page Later Job Summary Text: %@", [self.delegateManager printJobSummaryText]);
    
    self.delegateManager.pageRange.range = @"1-8";
    self.delegateManager.blackAndWhite = YES;
    XCTAssert([expected8PagesText isEqualToString:[self.delegateManager printLaterJobSummaryText]], @"8 Pages, Black and White Later Job Summary Text: %@", [self.delegateManager printJobSummaryText]);
    
    // Test multiple copies
    NSString *twoCopies = @"2 Copies";
    expectedJobSummaryText = [expectedJobSummaryText stringByReplacingOccurrencesOfString:singleCopy withString:twoCopies];
    expected0PageText = [expected0PageText stringByReplacingOccurrencesOfString:singleCopy withString:twoCopies];
    expected1PageText = [expected1PageText stringByReplacingOccurrencesOfString:singleCopy withString:twoCopies];
    expected8PagesText = [expected8PagesText stringByReplacingOccurrencesOfString:singleCopy withString:twoCopies];
    
    self.delegateManager.blackAndWhite = NO;
    self.delegateManager.numCopies = 2;
    self.delegateManager.pageRange.range = kPageRangeAllPages;
    XCTAssert([expectedJobSummaryText isEqualToString:[self.delegateManager printLaterJobSummaryText]], @"2 Copies, All Pages Later Job Summary Text: %@", [self.delegateManager printJobSummaryText]);
    
    self.delegateManager.pageRange.range = @"";
    XCTAssert([expected0PageText isEqualToString:[self.delegateManager printLaterJobSummaryText]], @"2 Copies, 0 Page Later Job Summary Text: %@", [self.delegateManager printJobSummaryText]);
    
    self.delegateManager.pageRange.range = @"3";
    XCTAssert([expected1PageText isEqualToString:[self.delegateManager printLaterJobSummaryText]], @"2 Copies, 1 Page Later Job Summary Text: %@", [self.delegateManager printJobSummaryText]);
    
    self.delegateManager.pageRange.range = @"1-8";
    self.delegateManager.blackAndWhite = YES;
    XCTAssert([expected8PagesText isEqualToString:[self.delegateManager printLaterJobSummaryText]], @"2 Copies, 8 Pages, Black and White Later Job Summary Text: %@", [self.delegateManager printJobSummaryText]);
}

- (void)testSelectedPrinterText {
    
    // expected case
    XCTAssert([MPTestPrinterName isEqualToString:[self.delegateManager selectedPrinterText]], @"Printer Text: %@", [self.delegateManager selectedPrinterText]);
    
    // nil printer case
    NSString *expectedPrinterText = @"Select Printer";
    self.delegateManager.printSettings.printerName = nil;
    XCTAssert([expectedPrinterText isEqualToString:[self.delegateManager selectedPrinterText]], @"Printer Text: %@", [self.delegateManager selectedPrinterText]);
}

- (void)testPrintSettingsText {
    
    NSString *printerPrompt = @"Select Printer";
    
    // Hide size, hide type, no printer
    NSString *expectedText = printerPrompt;
    [MP sharedInstance].hidePaperSizeOption = YES;
    [MP sharedInstance].hidePaperTypeOption = YES;
    self.delegateManager.printSettings.printerName = nil;
    XCTAssert([expectedText isEqualToString:[self.delegateManager printSettingsText]], @"Print Summary Text: %@", [self.delegateManager printSettingsText]);

    // Show size, hide type, no printer
    expectedText = [NSString stringWithFormat:@"%@, %@", self.delegateManager.printSettings.paper.sizeTitle, printerPrompt];
    [MP sharedInstance].hidePaperSizeOption = NO;
    [MP sharedInstance].hidePaperTypeOption = YES;
    self.delegateManager.printSettings.printerName = nil;
    XCTAssert([expectedText isEqualToString:[self.delegateManager printSettingsText]], @"Print Summary Text: %@", [self.delegateManager printSettingsText]);

    // Hide size, show type, no printer
    expectedText = [NSString stringWithFormat:@"%@, %@", self.delegateManager.printSettings.paper.typeTitle, printerPrompt];
    [MP sharedInstance].hidePaperSizeOption = YES;
    [MP sharedInstance].hidePaperTypeOption = NO;
    self.delegateManager.printSettings.printerName = nil;
    XCTAssert([expectedText isEqualToString:[self.delegateManager printSettingsText]], @"Print Summary Text: %@", [self.delegateManager printSettingsText]);

    // Show size, show type, no printer
    expectedText = [NSString stringWithFormat:@"%@, %@, %@", self.delegateManager.printSettings.paper.sizeTitle, self.delegateManager.printSettings.paper.typeTitle, printerPrompt];
    [MP sharedInstance].hidePaperSizeOption = NO;
    [MP sharedInstance].hidePaperTypeOption = NO;
    self.delegateManager.printSettings.printerName = nil;
    XCTAssert([expectedText isEqualToString:[self.delegateManager printSettingsText]], @"Print Summary Text: %@", [self.delegateManager printSettingsText]);
 
    // Hide size, hide type, yes printer
    expectedText = MPTestPrinterName;
    [MP sharedInstance].hidePaperSizeOption = YES;
    [MP sharedInstance].hidePaperTypeOption = YES;
    self.delegateManager.printSettings.printerName = MPTestPrinterName;
    XCTAssert([expectedText isEqualToString:[self.delegateManager printSettingsText]], @"Print Summary Text: %@", [self.delegateManager printSettingsText]);
    
    // Show size, hide type, yes printer
    expectedText = [NSString stringWithFormat:@"%@, %@", self.delegateManager.printSettings.paper.sizeTitle, MPTestPrinterName];
    [MP sharedInstance].hidePaperSizeOption = NO;
    [MP sharedInstance].hidePaperTypeOption = YES;
    self.delegateManager.printSettings.printerName = MPTestPrinterName;
    XCTAssert([expectedText isEqualToString:[self.delegateManager printSettingsText]], @"Print Summary Text: %@", [self.delegateManager printSettingsText]);
    
    // Hide size, show type, yes printer
    expectedText = [NSString stringWithFormat:@"%@, %@", self.delegateManager.printSettings.paper.typeTitle, MPTestPrinterName];
    [MP sharedInstance].hidePaperSizeOption = YES;
    [MP sharedInstance].hidePaperTypeOption = NO;
    self.delegateManager.printSettings.printerName = MPTestPrinterName;
    XCTAssert([expectedText isEqualToString:[self.delegateManager printSettingsText]], @"Print Summary Text: %@", [self.delegateManager printSettingsText]);
    
    // Show size, show type, yes printer
    expectedText = [NSString stringWithFormat:@"%@, %@, %@", self.delegateManager.printSettings.paper.sizeTitle, self.delegateManager.printSettings.paper.typeTitle, MPTestPrinterName];
    [MP sharedInstance].hidePaperSizeOption = NO;
    [MP sharedInstance].hidePaperTypeOption = NO;
    self.delegateManager.printSettings.printerName = MPTestPrinterName;
    XCTAssert([expectedText isEqualToString:[self.delegateManager printSettingsText]], @"Print Summary Text: %@", [self.delegateManager printSettingsText]);

}

@end
