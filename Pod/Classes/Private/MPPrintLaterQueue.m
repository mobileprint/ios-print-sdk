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

#import "MP.h"
#import "MPPageRange.h"
#import "MPPrintLaterQueue.h"
#import "MPPrintLaterActivity.h"
#import "MPAnalyticsManager.h"
#import "MPPrintItem.h"

@interface MPPrintLaterQueue()

@property (nonatomic, strong) NSString *printLaterJobsDirectoryPath;

@end

@implementation MPPrintLaterQueue

#define PRINT_LATER_JOBS_DIRECTORY_NAME @"PrintLaterJobs"

NSString * const kMPPrintLaterJobNextAvailableId = @"kMPPrintLaterJobNextAvailableId";

NSString * const kMPOfframpAddToQueueShare = @"AddToQueueFromShare";
NSString * const kMPOfframpAddToQueueCustom = @"AddToQueueFromClientUI";
NSString * const kMPOfframpAddToQueueDirect = @"AddToQueueWithNoUI";
NSString * const kMPOfframpDeleteFromQueue = @"DeleteFromQueue";

+ (MPPrintLaterQueue *)sharedInstance
{
    static MPPrintLaterQueue *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[MPPrintLaterQueue alloc] init];
    });
    
    return sharedInstance;
}

- (NSString *)retrievePrintLaterJobNextAvailableId
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    NSInteger printLaterJobNextAvailableId = [defaults integerForKey:kMPPrintLaterJobNextAvailableId];
    
    printLaterJobNextAvailableId++;
    
    [defaults setInteger:printLaterJobNextAvailableId forKey:kMPPrintLaterJobNextAvailableId];
    [defaults synchronize];
    
    return [NSString stringWithFormat:@"ID%08lX", (long)printLaterJobNextAvailableId];
}

#pragma mark - Getter methods

-(NSString *)printLaterJobsDirectoryPath
{
    if (nil == _printLaterJobsDirectoryPath) {
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentsDirectory = [paths objectAtIndex:0];
        _printLaterJobsDirectoryPath = [documentsDirectory stringByAppendingPathComponent: PRINT_LATER_JOBS_DIRECTORY_NAME];
        
        [self createDirectory:PRINT_LATER_JOBS_DIRECTORY_NAME atPath:documentsDirectory];
    }
    
    return _printLaterJobsDirectoryPath;
}

#pragma mark - Utils methods

- (BOOL)addPrintLaterJob:(MPPrintLaterJob *)printLaterJob fromController:(MPPageSettingsTableViewController *)controller
{
    NSString *fileName = [self.printLaterJobsDirectoryPath stringByAppendingPathComponent:printLaterJob.id];
    BOOL success = [NSKeyedArchiver archiveRootObject:printLaterJob toFile:fileName];
    
    if (success) {

        [[NSNotificationCenter defaultCenter] postNotificationName:kMPPrintJobAddedToQueueNotification object:printLaterJob userInfo:nil];
        
        NSString *offramp = kMPOfframpAddToQueueCustom;
        if (!controller) {
            offramp = kMPOfframpAddToQueueDirect;
        } else if ([controller.printLaterDelegate class] == [MPPrintLaterActivity class]) {
            offramp = kMPOfframpAddToQueueShare;
        }
        
        [printLaterJob prepareMetricswithOfframp:offramp];
        
        if ([MP sharedInstance].handlePrintMetricsAutomatically) {
            [[MPAnalyticsManager sharedManager] trackShareEventWithPrintItem:printLaterJob.defaultPrintItem andOptions:printLaterJob.extra];
        }
    }
    
    return success;
}

- (BOOL)deletePrintLaterJob:(MPPrintLaterJob *)printLaterJob
{
    BOOL success = [self deleteFile:printLaterJob.id atPath:self.printLaterJobsDirectoryPath];
    
    if (success) {
    
        [printLaterJob prepareMetricswithOfframp:kMPOfframpDeleteFromQueue];
        
        NSDictionary *values = @{
                                 kMPPrintQueueActionKey:kMPOfframpDeleteFromQueue,
                                 kMPPrintQueueJobKey:printLaterJob,
                                 kMPPrintQueuePrintItemKey:printLaterJob.defaultPrintItem };

        [[NSNotificationCenter defaultCenter] postNotificationName:kMPPrintQueueNotification object:values];
        [[NSNotificationCenter defaultCenter] postNotificationName:kMPPrintJobRemovedFromQueueNotification object:printLaterJob userInfo:nil];
        if ([self retrieveNumberOfPrintLaterJobs] == 0) {
            [[NSNotificationCenter defaultCenter] postNotificationName:kMPAllPrintJobsRemovedFromQueueNotification object:self userInfo:nil];
        }

        if ([MP sharedInstance].handlePrintMetricsAutomatically) {
            [[MPAnalyticsManager sharedManager] trackShareEventWithPrintItem:printLaterJob.defaultPrintItem andOptions:printLaterJob.extra];
        }
    }
    
    return  success;
}

- (BOOL)deleteAllPrintLaterJobs
{
    BOOL success = [self deleteAllFilesAtPath:self.printLaterJobsDirectoryPath];
    
    if (success) {
        [[NSNotificationCenter defaultCenter] postNotificationName:kMPAllPrintJobsRemovedFromQueueNotification object:self userInfo:nil];
    }
    
    return  success;
}

- (MPPrintLaterJob *)retrievePrintLaterJobWithID:(NSString *)id
{
    NSString *fileName = [self.printLaterJobsDirectoryPath stringByAppendingPathComponent:id];
    
    return [NSKeyedUnarchiver unarchiveObjectWithFile:fileName];
}

- (NSArray *)retrieveAllPrintLaterJobs
{
    NSMutableArray *printLaterJobs = [NSMutableArray array];
    
    NSArray *fileArray = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:self.printLaterJobsDirectoryPath error:nil];
    
    for (NSString *filename in fileArray)  {
        NSString *completeFileName = [self.printLaterJobsDirectoryPath stringByAppendingPathComponent:filename];
        
        MPPrintLaterJob *printLaterJob = [NSKeyedUnarchiver unarchiveObjectWithFile:completeFileName];
        [printLaterJobs addObject:printLaterJob];
    }
    
    // Last one added first in the list
    return [[printLaterJobs reverseObjectEnumerator] allObjects];
}

- (NSInteger)retrieveNumberOfPrintLaterJobs
{
    NSArray *fileArray = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:self.printLaterJobsDirectoryPath error:nil];
    
    return fileArray.count;
}

#pragma mark - Filesystem manipulation methods

- (BOOL)createDirectory:(NSString *)directoryName atPath:(NSString *)path
{
    BOOL success = YES;
    
    NSString *pathAndDirectory = [path stringByAppendingPathComponent:directoryName];
    NSError *error;
    
    if (![[NSFileManager defaultManager] createDirectoryAtPath:pathAndDirectory
                                   withIntermediateDirectories:NO
                                                    attributes:nil
                                                         error:&error]) {
        MPLogError(@"Create directory error: %@", error);
        success = NO;
    }
    
    return success;
}

- (BOOL)deleteFile:(NSString *)fileName atPath:(NSString *)path
{
    BOOL success = YES;
    
    NSString *filePath = [path stringByAppendingPathComponent:fileName];
    NSError *error = nil;
    if (![[NSFileManager defaultManager] removeItemAtPath:filePath error:&error]) {
        MPLogError(@"Delete file error: %@", error);
        success = NO;
    }
    
    return success;
}

- (BOOL)deleteAllFilesAtPath:(NSString *)path
{
    BOOL success = YES;
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSArray *files = [fileManager contentsOfDirectoryAtPath:path error:nil];
    for (NSString *filename in files)  {
        NSError *error = nil;
        if (![fileManager removeItemAtPath:[path stringByAppendingPathComponent:filename] error:&error]) {
            MPLogError(@"Delete file error: %@", error);
            success = NO;
        }
    }
    
    return success;
}

@end
