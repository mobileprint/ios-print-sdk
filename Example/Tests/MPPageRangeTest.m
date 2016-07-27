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
#import "MPPageRange.h"

@interface MPPageRangeTest : XCTestCase

@end

@implementation MPPageRangeTest

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testInit {
    MPPageRange *pageRange;
    NSString *allPages = @"All";
    
    NSString *badString1 = @"5,2,a,1";
    NSString *badStringResult1 = @"5,2,1";
    
    NSString *badString2 = @"~-5,3,4***,,,---6-8";
    NSString *badStringResult2 = @"5,3,4,6-8";
    
    NSString *goodString1 = @"6-10,1,2,3";
    NSString *goodStringResult1 = @"6-10,1-3";
    NSString *goodStringSortedResult1 = @"1-3,6-10";
    
    NSString *goodString2 = @"1";
    NSString *goodStringResult2 = @"1";
    
    NSString *outOfBounds = @"1,2,100,5,6";
    NSString *outOfBoundsResult = @"1,2,10,5,6";

    NSString *outOfBounds2 = @"00000,0,0,1,2,100,5,6,00000,0";
    NSString *outOfBoundsResult2 = @"1,2,10,5,6";
    
    NSString *extremeOutOfBounds = @"00000000000001,100000000000,1234123412341341341234123413241324124,0-3,3-0";
    NSString *extremeOutOfBoundsResult = @"1,10,10,1-3,3-1";

    // Init with empty string
    pageRange = [[MPPageRange alloc] initWithString:@"" allPagesIndicator:allPages maxPageNum:10 sortAscending:FALSE];
    XCTAssert([pageRange.range isEqualToString:@""], @"InitWithString:@\"\" produced range: \"%@\"", pageRange.range);
              

    // Init with single page
    pageRange = [[MPPageRange alloc] initWithString:goodString2 allPagesIndicator:allPages maxPageNum:10 sortAscending:FALSE];
    XCTAssert([pageRange.range isEqualToString:goodStringResult2], @"InitWithString:%@ produced range: \"%@\"", goodString2, pageRange.range);

    
    // Init with all-pages indicator
    pageRange = [[MPPageRange alloc] initWithString:allPages allPagesIndicator:allPages maxPageNum:10 sortAscending:FALSE];
    XCTAssert([pageRange.range isEqualToString:allPages], @"InitWithString:%@ produced range: \"%@\"", allPages, pageRange.range);

    
    // Init with illegal characters
    pageRange = [[MPPageRange alloc] initWithString:badString1 allPagesIndicator:allPages maxPageNum:10 sortAscending:FALSE];
    XCTAssert([pageRange.range isEqualToString:badStringResult1], @"InitWithString:%@ produced range: \"%@\"", badString1, pageRange.range);


    pageRange = [[MPPageRange alloc] initWithString:badString2 allPagesIndicator:allPages maxPageNum:10 sortAscending:FALSE];
    XCTAssert([pageRange.range isEqualToString:badStringResult2], @"InitWithString:%@ produced range: \"%@\"", badString2, pageRange.range);


    // Init with good string
    pageRange = [[MPPageRange alloc] initWithString:goodString1 allPagesIndicator:allPages maxPageNum:10 sortAscending:FALSE];
    XCTAssert([pageRange.range isEqualToString:goodStringResult1], @"InitWithString:%@ produced range: \"%@\"", goodString1, pageRange.range);


    // Verify sorting
    pageRange = [[MPPageRange alloc] initWithString:goodString1 allPagesIndicator:allPages maxPageNum:10 sortAscending:TRUE];
    XCTAssert([pageRange.range isEqualToString:goodStringSortedResult1], @"InitWithString:%@ produced range: \"%@\"", goodString1, pageRange.range);

    // Verify out-of-bounds page number
    pageRange = [[MPPageRange alloc] initWithString:outOfBounds allPagesIndicator:allPages maxPageNum:10 sortAscending:FALSE];
    XCTAssert([pageRange.range isEqualToString:outOfBoundsResult], @"InitWithString:%@ produced range: \"%@\"", outOfBounds, pageRange.range);

    // Verify out-of-bounds page number (leading 0's)
    pageRange = [[MPPageRange alloc] initWithString:outOfBounds2 allPagesIndicator:allPages maxPageNum:10 sortAscending:FALSE];
    XCTAssert([pageRange.range isEqualToString:outOfBoundsResult2], @"InitWithString:%@ produced range: \"%@\"", outOfBounds2, pageRange.range);
    
    // Verify extreme out-of-bounds page number
    pageRange = [[MPPageRange alloc] initWithString:extremeOutOfBounds allPagesIndicator:allPages maxPageNum:10 sortAscending:FALSE];
    XCTAssert([pageRange.range isEqualToString:extremeOutOfBoundsResult], @"InitWithString:%@ produced range: \"%@\"", extremeOutOfBounds, pageRange.range);
}

- (void)testGetPages {
    MPPageRange *pageRange;
    NSString *range = @"10,9,8,7,6,1,2,3,4,5";
    NSArray *unsortedResults = @[ [NSNumber numberWithInteger:10],
                                   [NSNumber numberWithInteger:9],
                                   [NSNumber numberWithInteger:8],
                                   [NSNumber numberWithInteger:7],
                                   [NSNumber numberWithInteger:6],
                                   [NSNumber numberWithInteger:1],
                                   [NSNumber numberWithInteger:2],
                                   [NSNumber numberWithInteger:3],
                                   [NSNumber numberWithInteger:4],
                                   [NSNumber numberWithInteger:5] ];
    
    NSArray *sortedResults = @[ [NSNumber numberWithInteger:1],
                                 [NSNumber numberWithInteger:2],
                                 [NSNumber numberWithInteger:3],
                                 [NSNumber numberWithInteger:4],
                                 [NSNumber numberWithInteger:5],
                                 [NSNumber numberWithInteger:6],
                                 [NSNumber numberWithInteger:7],
                                 [NSNumber numberWithInteger:8],
                                 [NSNumber numberWithInteger:9],
                                 [NSNumber numberWithInteger:10] ];
    NSInteger maxPage = 10;
    
    pageRange = [[MPPageRange alloc] initWithString:range allPagesIndicator:@"" maxPageNum:maxPage sortAscending:FALSE];

    // Unsorted test
    NSArray *pages = [pageRange getPages];
    for( int i=0; i<unsortedResults.count; i++) {
        if( [pages[i] integerValue] != [unsortedResults[i] integerValue] ) {
            XCTAssert(FALSE, @"Unsorted pages are in the wrong order: %@", pages);
        }
    }
    
    // Sorted test
    pageRange.sortAscending = TRUE;
    pages = [pageRange getPages];
    for( int i=0; i<sortedResults.count; i++) {
        if( [pages[i] integerValue] != [sortedResults[i] integerValue] ) {
            XCTAssert(FALSE, @"Sorted pages are in the wrong order: %@", pages);
        }
    }
}

- (void)testGetUniquePages {
    MPPageRange *pageRange;
    NSString *kRange = @"10,10,10,7,6,1,1,4,5";
    
    NSArray *kSortedResults = @[ [NSNumber numberWithInteger:1],
                                 [NSNumber numberWithInteger:4],
                                 [NSNumber numberWithInteger:5],
                                 [NSNumber numberWithInteger:6],
                                 [NSNumber numberWithInteger:7],
                                 [NSNumber numberWithInteger:10] ];
    NSInteger kMaxPage = 10;
    
    pageRange = [[MPPageRange alloc] initWithString:kRange allPagesIndicator:@"" maxPageNum:kMaxPage sortAscending:FALSE];
    
    // Unsorted test (results are always sorted... even if the range is not)
    NSArray *pages = [pageRange getUniquePages];
    for( int i=0; i<kSortedResults.count; i++) {
        if( [pages[i] integerValue] != [kSortedResults[i] integerValue] ) {
            XCTAssert(FALSE, @"Unsorted pages are in the wrong order: %@", pages);
        }
    }
    
    // Sorted test
    pageRange.sortAscending = TRUE;
    pages = [pageRange getUniquePages];
    for( int i=0; i<kSortedResults.count; i++) {
        if( [pages[i] integerValue] != [kSortedResults[i] integerValue] ) {
            XCTAssert(FALSE, @"Sorted pages are in the wrong order: %@", pages);
        }
    }
}

- (void)testAddPage {
    MPPageRange *pageRange;
    NSString *range = @"10,8,7,6,1,2,3,4,5";
    NSArray *unsortedResults = @[ [NSNumber numberWithInteger:10],
                                   [NSNumber numberWithInteger:8],
                                   [NSNumber numberWithInteger:7],
                                   [NSNumber numberWithInteger:6],
                                   [NSNumber numberWithInteger:1],
                                   [NSNumber numberWithInteger:2],
                                   [NSNumber numberWithInteger:3],
                                   [NSNumber numberWithInteger:4],
                                   [NSNumber numberWithInteger:5],
                                   [NSNumber numberWithInteger:9] ];
    
    NSArray *sortedResults = @[ [NSNumber numberWithInteger:1],
                                 [NSNumber numberWithInteger:2],
                                 [NSNumber numberWithInteger:3],
                                 [NSNumber numberWithInteger:4],
                                 [NSNumber numberWithInteger:5],
                                 [NSNumber numberWithInteger:6],
                                 [NSNumber numberWithInteger:7],
                                 [NSNumber numberWithInteger:8],
                                 [NSNumber numberWithInteger:9],
                                 [NSNumber numberWithInteger:10] ];
    NSInteger maxPage = 10;
    
    // Unsorted test
    pageRange = [[MPPageRange alloc] initWithString:range allPagesIndicator:@"" maxPageNum:maxPage sortAscending:FALSE];
    
    [pageRange addPage:[NSNumber numberWithInteger:9]];
    
    NSArray *pages = [pageRange getPages];
    for( int i=0; i<unsortedResults.count; i++) {
        if( [pages[i] integerValue] != [unsortedResults[i] integerValue] ) {
            XCTAssert(FALSE, @"Unsorted page added in wrong position: %@", pages);
        }
    }
    
    // Sorted test
    pageRange = [[MPPageRange alloc] initWithString:range allPagesIndicator:@"" maxPageNum:maxPage sortAscending:TRUE];
    
    [pageRange addPage:[NSNumber numberWithInteger:9]];
    
    pages = [pageRange getPages];
    for( int i=0; i<sortedResults.count; i++) {
        if( [pages[i] integerValue] != [sortedResults[i] integerValue] ) {
            XCTAssert(FALSE, @"Sorted page added in wrong position: %@", pages);
        }
    }
}

- (void)testRemovePage {
    MPPageRange *pageRange;
    NSString *range = @"6,6,6,10,9,8,7,6,1,2,3,4,5";
    NSString *unsortedResult = @"10-7,1-5";
    NSString *sortedResult = @"1-5,7-10";
    NSInteger maxPage = 10;
    
    // Unsorted test
    pageRange = [[MPPageRange alloc] initWithString:range allPagesIndicator:@"" maxPageNum:maxPage sortAscending:FALSE];
    
    [pageRange removePage:[NSNumber numberWithInteger:6]];
    
    XCTAssert([unsortedResult isEqualToString:pageRange.range], @"Unsorted page removed incorrectly: %@", pageRange.range);
    
    // Sorted test
    pageRange = [[MPPageRange alloc] initWithString:range allPagesIndicator:@"" maxPageNum:maxPage sortAscending:TRUE];
    
    [pageRange removePage:[NSNumber numberWithInteger:6]];
    
    XCTAssert([sortedResult isEqualToString:pageRange.range], @"Sorted page removed incorrectly: %@", pageRange.range);

}

@end
