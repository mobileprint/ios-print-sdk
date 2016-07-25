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
#import "MPPrintLaterQueue.h"
#import "MPPrintLaterJob.h"
#import "MPLogger.h"
#import "MPAnalyticsManager.h"
#import "MPPrintItemFactory.h"
#import <OCMock/OCMock.h>
#import "MPPrintItem.h"
#import "MPLayoutFit.h"
#import "MPLayoutFill.h"
#import "MPPrintItemImage.h"
#import "MPPrintItemPDF.h"

@interface MPPrintLaterQueue()

@property (nonatomic, strong) NSString *printLaterJobsDirectoryPath;
- (MPPrintLaterJob *)attemptDecodeJobWithId:(NSString *)jobId;

@end

@interface MPPrintLaterQueueTest : XCTestCase

@end

@implementation MPPrintLaterQueueTest
{
    id _loggerMock;
    id _archiverMock;
    id _unarchiverMock;
    id _analyticsMock;
}

#pragma mark - Setup tests

- (void)setUp
{
    [super setUp];
    _loggerMock = OCMPartialMock([MPLogger sharedInstance]);
    _archiverMock = OCMClassMock([NSKeyedArchiver class]);
    _unarchiverMock = OCMClassMock([NSKeyedUnarchiver class]);
    _analyticsMock = OCMPartialMock([MPAnalyticsManager sharedManager]);
    OCMStub([_analyticsMock trackShareEventWithPrintItem:[OCMArg any] andOptions:[OCMArg any]]);
    [[MPPrintLaterQueue sharedInstance] deleteAllPrintLaterJobs];
}

- (void)tearDown
{
    [super tearDown];
    [_loggerMock stopMocking];
    [_archiverMock stopMocking];
    [_unarchiverMock stopMocking];
    [_analyticsMock stopMocking];
}

#pragma mark - Tests

- (void)testAddJob
{
    MPPrintLaterJob *job = [self printLaterJob];
    NSString *filename = [[MPPrintLaterQueue sharedInstance].printLaterJobsDirectoryPath stringByAppendingPathComponent:job.id];
    
    BOOL result = [[MPPrintLaterQueue sharedInstance] addPrintLaterJob:job fromController:nil];
    
    XCTAssert(result, @"Expected job to be added successfully");
    OCMVerify([_archiverMock archiveRootObject:job toFile:filename]);
}

- (void)testRetrieveCachedJob
{
    [[_unarchiverMock reject] unarchiveObjectWithFile:[OCMArg any]];
    
    MPPrintLaterJob *originalJob = [self printLaterJob];
    [[MPPrintLaterQueue sharedInstance] addPrintLaterJob:originalJob fromController:nil];
    
    MPPrintLaterJob *retrievedJob = [[MPPrintLaterQueue sharedInstance] retrievePrintLaterJobWithID:originalJob.id];
    
    XCTAssert(
              [retrievedJob.id isEqualToString:originalJob.id],
              @"Expected retrieved job ID ('%@') to equal original job ID ('%@')",
              retrievedJob.id,
              originalJob.id);
}

- (void)testRetrieveFreshJob
{
    MPPrintLaterQueue *originalQueue = [MPPrintLaterQueue sharedInstance];
    
    MPPrintLaterJob *originalJob = [self printLaterJob];
    [originalQueue addPrintLaterJob:originalJob fromController:nil];
    
    MPPrintLaterQueue *newQueue = [[MPPrintLaterQueue alloc] init];
    id queueMock = OCMPartialMock(newQueue);
    MPPrintLaterJob *retrievedJob = [newQueue retrievePrintLaterJobWithID:originalJob.id];
    OCMVerify([queueMock attemptDecodeJobWithId:originalJob.id]);
    
    XCTAssert(
              [retrievedJob.id isEqualToString:originalJob.id],
              @"Expected retrieved job ID ('%@') to equal original job ID ('%@')",
              retrievedJob.id,
              originalJob.id);
}

- (void)testRetrieveLegacyJob
{
    MPLayoutOrientation expectedOrientation = MPLayoutOrientationLandscape;
    CGRect expectedAssetPosition = CGRectMake(5.0, 5.0, 90.0, 90.0);
    CGFloat expectedBorderInches = 0.5;
    MPLayoutHorizontalPosition expectedHorizontalPosition = MPLayoutHorizontalPositionRight;
    MPLayoutVerticalPosition expectedVerticalPosition = MPLayoutVerticalPositionBottom;
    
    // 2.5.10
    // - Private pod version used in Cards 1.4 and Snapshots 1.6
    // - Before border feature worked, should default to 0.0 in newer versions
    // - Still had bug around restoring horizontal/vertical position, default to middle/middle
    MPPrintLaterJob *job = [self verifyLegacyJob:@"2.5.10.fit"
                                       itemClass:[MPPrintItemImage class]
                                      layoutClass:[MPLayoutFit class]
                                     orientation:expectedOrientation
                                   assetPosition:expectedAssetPosition
                                    borderInches:0.0];
    
    [self verifyLegacyFitJob:job horizontalPosition:MPLayoutHorizontalPositionMiddle verticalPosition:MPLayoutVerticalPositionMiddle];
    
    [self verifyLegacyJob:@"2.5.10.fill"
           itemClass:[MPPrintItemImage class]
              layoutClass:[MPLayoutFill class]
              orientation:expectedOrientation
            assetPosition:[MPLayout completeFillRectangle]
             borderInches:0.0];
    
    // 2.6.11
    // - Last released private pod version
    // - Border feature working
    // - Still had bug around restoring horizontal/vertical position, default to middle/middle
    job = [self verifyLegacyJob:@"2.6.11.fit"
                      itemClass:[MPPrintItemImage class]
                    layoutClass:[MPLayoutFit class]
                    orientation:expectedOrientation
                  assetPosition:expectedAssetPosition
                   borderInches:expectedBorderInches];
    
    [self verifyLegacyFitJob:job horizontalPosition:MPLayoutHorizontalPositionMiddle verticalPosition:MPLayoutVerticalPositionMiddle];
    
    [self verifyLegacyJob:@"2.6.11.fill"
                itemClass:[MPPrintItemImage class]
              layoutClass:[MPLayoutFill class]
              orientation:expectedOrientation
            assetPosition:[MPLayout completeFillRectangle]
             borderInches:0.0];
    
    // 3.0.0
    // - First public version of pod
    job = [self verifyLegacyJob:@"3.0.0.fit"
                      itemClass:[MPPrintItemImage class]
                    layoutClass:[MPLayoutFit class]
                    orientation:expectedOrientation
                  assetPosition:expectedAssetPosition
                   borderInches:expectedBorderInches];
    
    [self verifyLegacyFitJob:job horizontalPosition:MPLayoutHorizontalPositionMiddle verticalPosition:MPLayoutVerticalPositionMiddle];
    
    [self verifyLegacyJob:@"3.0.0.fill"
                itemClass:[MPPrintItemImage class]
              layoutClass:[MPLayoutFill class]
              orientation:expectedOrientation
            assetPosition:[MPLayout completeFillRectangle]
             borderInches:0.0];
    
    [self verifyLegacyJob:@"3.0.0.pdf"
                itemClass:[MPPrintItemPDF class]
              layoutClass:[MPLayoutFit class]
              orientation:MPLayoutOrientationBestFit
            assetPosition:[MPLayout completeFillRectangle]
             borderInches:0.0];
    
    // 3.0.1
    // - Fix bug so that horizontal/vertical position restores from queue correctly
    job = [self verifyLegacyJob:@"3.0.1.fit"
                      itemClass:[MPPrintItemImage class]
                    layoutClass:[MPLayoutFit class]
                    orientation:expectedOrientation
                  assetPosition:expectedAssetPosition
                   borderInches:expectedBorderInches];
    
    [self verifyLegacyFitJob:job horizontalPosition:expectedHorizontalPosition verticalPosition:expectedVerticalPosition];
    
    [self verifyLegacyJob:@"3.0.1.fill"
                itemClass:[MPPrintItemImage class]
              layoutClass:[MPLayoutFill class]
              orientation:expectedOrientation
            assetPosition:[MPLayout completeFillRectangle]
             borderInches:0.0];
    
    [self verifyLegacyJob:@"3.0.1.pdf"
                itemClass:[MPPrintItemPDF class]
              layoutClass:[MPLayoutFit class]
              orientation:MPLayoutOrientationBestFit
            assetPosition:[MPLayout completeFillRectangle]
             borderInches:0.0];

    // 3.0.2
    // - No queue related changes
    job = [self verifyLegacyJob:@"3.0.2.fit"
                      itemClass:[MPPrintItemImage class]
                    layoutClass:[MPLayoutFit class]
                    orientation:expectedOrientation
                  assetPosition:expectedAssetPosition
                   borderInches:expectedBorderInches];
    
    [self verifyLegacyFitJob:job horizontalPosition:expectedHorizontalPosition verticalPosition:expectedVerticalPosition];
    
    [self verifyLegacyJob:@"3.0.2.fill"
                itemClass:[MPPrintItemImage class]
              layoutClass:[MPLayoutFill class]
              orientation:expectedOrientation
            assetPosition:[MPLayout completeFillRectangle]
             borderInches:0.0];
    
    [self verifyLegacyJob:@"3.0.2.pdf"
                itemClass:[MPPrintItemPDF class]
              layoutClass:[MPLayoutFit class]
              orientation:MPLayoutOrientationBestFit
            assetPosition:[MPLayout completeFillRectangle]
             borderInches:0.0];
}

- (void)testDeleteJob
{
    MPPrintLaterJob *originalJob = [self printLaterJob];
    [[MPPrintLaterQueue sharedInstance] addPrintLaterJob:originalJob fromController:nil];
    
    NSInteger numberOfJobs = [[MPPrintLaterQueue sharedInstance] retrieveNumberOfPrintLaterJobs];
    XCTAssert(1 == numberOfJobs, @"Expected 1 job but got %ld", (long)numberOfJobs);
    
    [[MPPrintLaterQueue sharedInstance] deletePrintLaterJob:originalJob];
    
    numberOfJobs = [[MPPrintLaterQueue sharedInstance] retrieveNumberOfPrintLaterJobs];
    XCTAssert(0 == numberOfJobs, @"Expected 0 jobs but got %ld", (long)numberOfJobs);
    
    MPPrintLaterJob *retrievedJob = [[MPPrintLaterQueue sharedInstance] retrievePrintLaterJobWithID:originalJob.id];
    XCTAssert(nil == retrievedJob, @"Expected print job to be removed from file and cache");
}

- (void)testDeleteAllJobs
{
    NSArray *jobs = @[
                      [self printLaterJob],
                      [self printLaterJob],
                      [self printLaterJob],
                      [self printLaterJob],
                      [self printLaterJob]
                      ];
    
    for (MPPrintLaterJob *job in jobs) {
        [[MPPrintLaterQueue sharedInstance] addPrintLaterJob:job fromController:nil];
    }
    
    NSInteger numberOfJobs = [[MPPrintLaterQueue sharedInstance] retrieveNumberOfPrintLaterJobs];
    XCTAssert(jobs.count == numberOfJobs, @"Expected %ld job but got %ld", (long)jobs.count, (long)numberOfJobs);
    
    [[MPPrintLaterQueue sharedInstance] deleteAllPrintLaterJobs];
    
    numberOfJobs = [[MPPrintLaterQueue sharedInstance] retrieveNumberOfPrintLaterJobs];
    XCTAssert(0 == numberOfJobs, @"Expected 0 jobs but got %ld", (long)numberOfJobs);
    
    for (MPPrintLaterJob *job in jobs) {
        MPPrintLaterJob *retrievedJob = [[MPPrintLaterQueue sharedInstance] retrievePrintLaterJobWithID:job.id];
        XCTAssert(nil == retrievedJob, @"Expected print job to be removed from file and cache");
    }
}

#pragma mark - Utilities

- (MPPrintLaterJob *)printLaterJob
{
    MPPrintItem *printItem = [MPPrintItemFactory printItemWithAsset:[UIImage imageNamed:@"Cat.jpg"]];
    MPPrintLaterJob *job = [[MPPrintLaterJob alloc] init];
    job.id = [[MPPrintLaterQueue sharedInstance] retrievePrintLaterJobNextAvailableId];
    job.printItems = @{ [MP sharedInstance].defaultPaper.sizeTitle:printItem };
    return job;
}

- (MPPrintLaterJob *)verifyLegacyJob:(NSString *)filename
                           itemClass:(Class)itemClass
                         layoutClass:(Class)layoutClass
                         orientation:(MPLayoutOrientation)orientation
                       assetPosition:(CGRect)assetPosition
                        borderInches:(CGFloat)borderInches
{
    NSBundle *bundle = [NSBundle bundleForClass:[self class]];
    NSString *jobId = @"ID00000001";
    NSString *jobPath = [[MPPrintLaterQueue sharedInstance].printLaterJobsDirectoryPath stringByAppendingPathComponent:jobId];
    
    [[MPPrintLaterQueue sharedInstance] deleteAllPrintLaterJobs];
    NSString *bundlePath = [bundle pathForResource:filename ofType:@"dat"];
    [[NSFileManager defaultManager] copyItemAtPath:bundlePath toPath:jobPath error:nil];
    
    NSInteger jobCount = [[MPPrintLaterQueue sharedInstance] retrieveNumberOfPrintLaterJobs];
    XCTAssert(
              1 == jobCount,
              @"Expected 1 job in queue, got %ld",
              (long)jobCount);
    
    
    MPPrintLaterJob *job = [[MPPrintLaterQueue sharedInstance] retrievePrintLaterJobWithID:jobId];
    XCTAssert(
              [job.id isEqualToString:jobId],
              @"Expected job ID '%@' but got '%@'",
              jobId,
              job.id);
    
    for (NSString *key in job.printItems.allKeys) {
        
        MPPrintItem *printItem = [job.printItems objectForKey:key];
        
        XCTAssert(
                  [printItem isKindOfClass:itemClass],
                  @"Expected print item %@ to be subclass of %@",
                  NSStringFromClass([printItem class]),
                  NSStringFromClass(itemClass));
        
        XCTAssert(
                  [printItem.layout isKindOfClass:layoutClass],
                  @"Expected layout %@ to be subclass of %@",
                  NSStringFromClass([printItem.layout class]),
                  NSStringFromClass(layoutClass));
        
        XCTAssert(
                  orientation == printItem.layout.orientation,
                  @"Expected orientation %d but got %d",
                  orientation,
                  printItem.layout.orientation);
        
        XCTAssert(
                  fabs(printItem.layout.borderInches - borderInches) < CGFLOAT_MIN,
                  @"Expected border %.1f but got %.1f",
                  borderInches,
                  printItem.layout.borderInches);
        
        XCTAssert(
                  CGRectEqualToRect(assetPosition, printItem.layout.assetPosition),
                  @"Expected asset position (%.1f,%.1f,%.1f,%.1f) but got (%.1f,%.1f,%.1f,%.1f)",
                  assetPosition.origin.x,
                  assetPosition.origin.y,
                  assetPosition.size.width,
                  assetPosition.size.height,
                  printItem.layout.assetPosition.origin.x,
                  printItem.layout.assetPosition.origin.y,
                  printItem.layout.assetPosition.size.width,
                  printItem.layout.assetPosition.size.height);
    }
    
    return job;
}

- (void)verifyLegacyFitJob:(MPPrintLaterJob *)job horizontalPosition:(MPLayoutHorizontalPosition)horizontalPosition verticalPosition:(MPLayoutVerticalPosition)verticalPosition
{
    for (NSString *key in job.printItems.allKeys) {
        
        MPPrintItem *printItem = [job.printItems objectForKey:key];
        MPLayoutFit *fitLayout = (MPLayoutFit *)printItem.layout;
        
        XCTAssert(
                  fitLayout.horizontalPosition == horizontalPosition,
                  @"Expected horizontal position %d but got %d",
                  horizontalPosition,
                  fitLayout.horizontalPosition);
        
        XCTAssert(
                  fitLayout.verticalPosition == verticalPosition,
                  @"Expected vertical position %d but got %d",
                  verticalPosition,
                  fitLayout.verticalPosition);
    }
}

@end
