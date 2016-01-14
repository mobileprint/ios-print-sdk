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
#import <MPPrintLaterQueue.h>
#import <MPPrintLaterJob.h>
#import <MPLogger.h>
#import <MPAnalyticsManager.h>
#import <MPPrintItemFactory.h>
#import <OCMock/OCMock.h>

@interface MPPrintLaterQueue()

@property (nonatomic, strong) NSString *printLaterJobsDirectoryPath;

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
    NSString *filename = [originalQueue.printLaterJobsDirectoryPath stringByAppendingPathComponent:originalJob.id];
    [originalQueue addPrintLaterJob:originalJob fromController:nil];
    
    MPPrintLaterQueue *newQueue = [[MPPrintLaterQueue alloc] init];
    MPPrintLaterJob *retrievedJob = [newQueue retrievePrintLaterJobWithID:originalJob.id];

    OCMVerify([_unarchiverMock unarchiveObjectWithFile:filename]);
    XCTAssert(
              [retrievedJob.id isEqualToString:originalJob.id],
              @"Expected retrieved job ID ('%@') to equal original job ID ('%@')",
              retrievedJob.id,
              originalJob.id);
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

@end
