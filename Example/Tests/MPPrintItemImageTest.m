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
#import "MPPrintItemFactory.h"
#import <OCMock/OCMock.h>

@interface MPPrintItemImageTest : XCTestCase

@end

@implementation MPPrintItemImageTest

#pragma mark - Setup tests

- (void)setUp
{
    [super setUp];
}

- (void)tearDown
{
    [super tearDown];
}

#pragma mark - Test activity items

- (void)testActivityItemsSingleImage
{
    UIImage *image = [UIImage imageNamed:@"Cat.jpg"];
    MPPrintItem *printItem = [MPPrintItemFactory printItemWithAsset:image];
    
    XCTAssert(
              3 == printItem.activityItems.count,
              @"Expected three activity items, got %lu instead",
              (unsigned long)printItem.activityItems.count);
    
    XCTAssert(printItem == printItem.activityItems[0],
              @"Expected the print item itself to be the first activity item");
    
    XCTAssert(printItem.printAsset == printItem.activityItems[1],
              @"Expected the printable asset to be the second activity item");
    
    XCTAssert(image == printItem.activityItems[2],
              @"Expected image itself to be the third activity item");
}

- (void)testActivityItemsMultipleImages
{
    UIImage *image1 = [UIImage imageNamed:@"Cat.jpg"];
    UIImage *image2 = [UIImage imageNamed:@"Dog.jpg"];
    
    MPPrintItem *printItem = [MPPrintItemFactory printItemWithAsset:@[image1, image2]];
    
    XCTAssert(
              2 == printItem.activityItems.count,
              @"Expected two activity items, got %lu instead",
              (unsigned long)printItem.activityItems.count);
    
    XCTAssert(printItem == printItem.activityItems[0],
              @"Expected the print item itself to be the first activity item");
    
    XCTAssert(printItem.printAsset == printItem.activityItems[1],
              @"Expected the printable asset to be the second activity item");
}

@end
