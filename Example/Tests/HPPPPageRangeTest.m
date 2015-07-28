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
#import <HPPPPageRange.h>

@interface HPPPPageRangeTest : XCTestCase

@end

@implementation HPPPPageRangeTest

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testInit {
    HPPPPageRange *pageRange;
    NSString *kAllPages = @"All";
    
    NSString *kBadString1 = @"5,2,a,1";
    NSString *kBadStringResult1 = @"5,2,1";
    
    NSString *kBadString2 = @"~-5,3,4***,,,---6-8";
    NSString *kBadStringResult2 = @"5,3,4,6-8";
    
    NSString *kGoodString1 = @"6-10,1,2,3";
    NSString *kGoodStringResult1 = @"6-10,1-3";
    NSString *kGoodStringSortedResult1 = @"1-3,6-10";
    
    NSString *kGoodString2 = @"1";
    NSString *kGoodStringResult2 = @"1";
    
    NSString *kOutOfBounds = @"1,2,100,5,6";
    NSString *kOutOfBoundsResult = @"1,2,10,5,6";

    // Init with empty string
    pageRange = [[HPPPPageRange alloc] initWithString:@"" allPagesIndicator:kAllPages maxPageNum:10 sortAscending:FALSE];
    XCTAssert([pageRange.range isEqualToString:kAllPages], @"InitWithString:@\"\" produced range: \"%@\"", pageRange.range);
              

    // Init with single page
    pageRange = [[HPPPPageRange alloc] initWithString:kGoodString2 allPagesIndicator:kAllPages maxPageNum:10 sortAscending:FALSE];
    XCTAssert([pageRange.range isEqualToString:kGoodStringResult2], @"InitWithString:%@ produced range: \"%@\"", kGoodString2, pageRange.range);

    
    // Init with all-pages indicator
    pageRange = [[HPPPPageRange alloc] initWithString:kAllPages allPagesIndicator:kAllPages maxPageNum:10 sortAscending:FALSE];
    XCTAssert([pageRange.range isEqualToString:kAllPages], @"InitWithString:%@ produced range: \"%@\"", kAllPages, pageRange.range);

    
    // Init with illegal characters
    pageRange = [[HPPPPageRange alloc] initWithString:kBadString1 allPagesIndicator:kAllPages maxPageNum:10 sortAscending:FALSE];
    XCTAssert([pageRange.range isEqualToString:kBadStringResult1], @"InitWithString:%@ produced range: \"%@\"", kBadString1, pageRange.range);


    pageRange = [[HPPPPageRange alloc] initWithString:kBadString2 allPagesIndicator:kAllPages maxPageNum:10 sortAscending:FALSE];
    XCTAssert([pageRange.range isEqualToString:kBadStringResult2], @"InitWithString:%@ produced range: \"%@\"", kBadString2, pageRange.range);


    // Init with good string
    pageRange = [[HPPPPageRange alloc] initWithString:kGoodString1 allPagesIndicator:kAllPages maxPageNum:10 sortAscending:FALSE];
    XCTAssert([pageRange.range isEqualToString:kGoodStringResult1], @"InitWithString:%@ produced range: \"%@\"", kGoodString1, pageRange.range);


    // Verify sorting
    pageRange = [[HPPPPageRange alloc] initWithString:kGoodString1 allPagesIndicator:kAllPages maxPageNum:10 sortAscending:TRUE];
    XCTAssert([pageRange.range isEqualToString:kGoodStringSortedResult1], @"InitWithString:%@ produced range: \"%@\"", kGoodString1, pageRange.range);

    // Verify out-of-bounds page number
    pageRange = [[HPPPPageRange alloc] initWithString:kOutOfBounds allPagesIndicator:kAllPages maxPageNum:10 sortAscending:FALSE];
    XCTAssert([pageRange.range isEqualToString:kOutOfBoundsResult], @"InitWithString:%@ produced range: \"%@\"", kOutOfBounds, pageRange.range);
}

- (void)testGetPages {
    HPPPPageRange *pageRange;
    NSString *kRange = @"10,9,8,7,6,1,2,3,4,5";
    NSArray *kUnsortedResults = @[ [NSNumber numberWithInteger:10],
                                   [NSNumber numberWithInteger:9],
                                   [NSNumber numberWithInteger:8],
                                   [NSNumber numberWithInteger:7],
                                   [NSNumber numberWithInteger:6],
                                   [NSNumber numberWithInteger:1],
                                   [NSNumber numberWithInteger:2],
                                   [NSNumber numberWithInteger:3],
                                   [NSNumber numberWithInteger:4],
                                   [NSNumber numberWithInteger:5] ];
    
    NSArray *kSortedResults = @[ [NSNumber numberWithInteger:1],
                                 [NSNumber numberWithInteger:2],
                                 [NSNumber numberWithInteger:3],
                                 [NSNumber numberWithInteger:4],
                                 [NSNumber numberWithInteger:5],
                                 [NSNumber numberWithInteger:6],
                                 [NSNumber numberWithInteger:7],
                                 [NSNumber numberWithInteger:8],
                                 [NSNumber numberWithInteger:9],
                                 [NSNumber numberWithInteger:10] ];
    NSInteger kMaxPage = 10;
    
    pageRange = [[HPPPPageRange alloc] initWithString:kRange allPagesIndicator:@"" maxPageNum:kMaxPage sortAscending:FALSE];

    // Unsorted test
    NSArray *pages = [pageRange getPages];
    for( int i=0; i<kUnsortedResults.count; i++) {
        if( [pages[i] integerValue] != [kUnsortedResults[i] integerValue] ) {
            XCTAssert(FALSE, @"Unsorted pages are in the wrong order: %@", pages);
        }
    }
    
    // Sorted test
    pageRange.sortAscending = TRUE;
    pages = [pageRange getPages];
    for( int i=0; i<kSortedResults.count; i++) {
        if( [pages[i] integerValue] != [kSortedResults[i] integerValue] ) {
            XCTAssert(FALSE, @"Sorted pages are in the wrong order: %@", pages);
        }
    }
}

- (void)testAddPage {
    HPPPPageRange *pageRange;
    NSString *kRange = @"10,8,7,6,1,2,3,4,5";
    NSArray *kUnsortedResults = @[ [NSNumber numberWithInteger:10],
                                   [NSNumber numberWithInteger:8],
                                   [NSNumber numberWithInteger:7],
                                   [NSNumber numberWithInteger:6],
                                   [NSNumber numberWithInteger:1],
                                   [NSNumber numberWithInteger:2],
                                   [NSNumber numberWithInteger:3],
                                   [NSNumber numberWithInteger:4],
                                   [NSNumber numberWithInteger:5],
                                   [NSNumber numberWithInteger:9] ];
    
    NSArray *kSortedResults = @[ [NSNumber numberWithInteger:1],
                                 [NSNumber numberWithInteger:2],
                                 [NSNumber numberWithInteger:3],
                                 [NSNumber numberWithInteger:4],
                                 [NSNumber numberWithInteger:5],
                                 [NSNumber numberWithInteger:6],
                                 [NSNumber numberWithInteger:7],
                                 [NSNumber numberWithInteger:8],
                                 [NSNumber numberWithInteger:9],
                                 [NSNumber numberWithInteger:10] ];
    NSInteger kMaxPage = 10;
    
    // Unsorted test
    pageRange = [[HPPPPageRange alloc] initWithString:kRange allPagesIndicator:@"" maxPageNum:kMaxPage sortAscending:FALSE];
    
    [pageRange addPage:[NSNumber numberWithInteger:9]];
    
    NSArray *pages = [pageRange getPages];
    for( int i=0; i<kUnsortedResults.count; i++) {
        if( [pages[i] integerValue] != [kUnsortedResults[i] integerValue] ) {
            XCTAssert(FALSE, @"Unsorted page added in wrong position: %@", pages);
        }
    }
    
    // Sorted test
    pageRange = [[HPPPPageRange alloc] initWithString:kRange allPagesIndicator:@"" maxPageNum:kMaxPage sortAscending:TRUE];
    
    [pageRange addPage:[NSNumber numberWithInteger:9]];
    
    pages = [pageRange getPages];
    for( int i=0; i<kSortedResults.count; i++) {
        if( [pages[i] integerValue] != [kSortedResults[i] integerValue] ) {
            XCTAssert(FALSE, @"Sorted page added in wrong position: %@", pages);
        }
    }
}

- (void)testRemovePage {
    HPPPPageRange *pageRange;
    NSString *kRange = @"6,6,6,10,9,8,7,6,1,2,3,4,5";
    NSString *kUnsortedResult = @"10-7,1-5";
    NSString *kSortedResult = @"1-5,7-10";
    NSInteger kMaxPage = 10;
    
    // Unsorted test
    pageRange = [[HPPPPageRange alloc] initWithString:kRange allPagesIndicator:@"" maxPageNum:kMaxPage sortAscending:FALSE];
    
    [pageRange removePage:[NSNumber numberWithInteger:6]];
    
    XCTAssert([kUnsortedResult isEqualToString:pageRange.range], @"Unsorted page removed incorrectly: %@", pageRange.range);
    
    // Sorted test
    pageRange = [[HPPPPageRange alloc] initWithString:kRange allPagesIndicator:@"" maxPageNum:kMaxPage sortAscending:TRUE];
    
    [pageRange removePage:[NSNumber numberWithInteger:6]];
    
    XCTAssert([kSortedResult isEqualToString:pageRange.range], @"Sorted page removed incorrectly: %@", pageRange.range);

}


@end
