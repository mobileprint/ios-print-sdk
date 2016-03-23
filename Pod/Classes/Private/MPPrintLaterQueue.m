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
#import "MPLegacyPrintLaterJob.h"
#import "MPLegacyPageRange.h"
#import "MPLegacyPrintItemImage.h"
#import "MPLegacyPrintItemPDF.h"

@interface MPPrintLaterQueue() <NSKeyedUnarchiverDelegate>

@property (nonatomic, strong) NSString *printLaterJobsDirectoryPath;

@end

@implementation MPPrintLaterQueue
{
    NSMutableDictionary *_cachedPrintJobs;
}

#define PRINT_LATER_JOBS_DIRECTORY_NAME @"PrintLaterJobs"

NSString * const kMPPrintLaterJobNextAvailableId = @"kMPPrintLaterJobNextAvailableId";
NSInteger  const kMPPrintLaterJobFirstId = 100;

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

- (id)init
{
    self = [super init];
    if (self) {
        _cachedPrintJobs = [NSMutableDictionary dictionary];
    }
    return self;
}

- (NSString *)retrievePrintLaterJobNextAvailableId
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    NSInteger printLaterJobNextAvailableId = [defaults integerForKey:kMPPrintLaterJobNextAvailableId];
    
    // Preventing id collisions with previous versions of MobilePrintSDK
    if (0 == printLaterJobNextAvailableId) {
        printLaterJobNextAvailableId = kMPPrintLaterJobFirstId;
    }
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
        
        [self addCachedJob:printLaterJob];
        
        [[NSNotificationCenter defaultCenter] postNotificationName:kMPPrintJobAddedToQueueNotification object:printLaterJob userInfo:nil];
        
        NSString *offramp = kMPOfframpAddToQueueCustom;
        if (!controller) {
            offramp = kMPOfframpAddToQueueDirect;
        } else if ([controller.printLaterDelegate class] == [MPPrintLaterActivity class]) {
            offramp = kMPOfframpAddToQueueShare;
        }
        
        [printLaterJob prepareMetricsForOfframp:offramp];
        
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
        
        [self removeCachedJob:printLaterJob.id];
        
        [printLaterJob prepareMetricsForOfframp:kMPOfframpDeleteFromQueue];
        
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
        [self removeAllCachedJobs];
        [[NSNotificationCenter defaultCenter] postNotificationName:kMPAllPrintJobsRemovedFromQueueNotification object:self userInfo:nil];
    }
    
    return  success;
}

- (MPPrintLaterJob *)retrievePrintLaterJobWithID:(NSString *)jobId
{
    MPPrintLaterJob *job = [self retrieveCachedJob:jobId];
    if (!job) {
        job = [self attemptDecodeJobWithId:jobId];
        if (job) {
            [self addCachedJob:job];
        }
    }
    
    return job;
}

- (MPPrintLaterJob *)attemptDecodeJobWithId:(NSString *)jobId
{
    MPPrintLaterJob *job = nil;
    NSString *filename = [self.printLaterJobsDirectoryPath stringByAppendingPathComponent:jobId];
    NSData *data = [NSData dataWithContentsOfFile:filename];
    NSKeyedUnarchiver *unarchiver = [[NSKeyedUnarchiver alloc] initForReadingWithData:data];
    unarchiver.delegate = self;
    @try {
        job = [unarchiver decodeObjectForKey:NSKeyedArchiveRootObjectKey];
    }
    @catch (NSException *exception) {
        MPLogError(@"Unable to decode print later job:\n\tFile: %@\n\tError: %@", filename, exception.reason);
        MPLogInfo(@"Deleting job with ID '%@'", jobId);
        [self deleteFile:jobId atPath:self.printLaterJobsDirectoryPath];
    }
    @finally {
        [unarchiver finishDecoding];
    }
    
    return job;
}

- (NSArray *)retrieveAllPrintLaterJobs
{
    NSMutableArray *printLaterJobs = [NSMutableArray array];
    NSArray *fileArray = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:self.printLaterJobsDirectoryPath error:nil];
    
    for (NSString *filename in fileArray)  {
        MPPrintLaterJob *job = [self retrievePrintLaterJobWithID:filename];
        if (job) {
            [printLaterJobs addObject:job];
        }
    }
    
    return [[printLaterJobs reverseObjectEnumerator] allObjects];
}

- (NSInteger)retrieveNumberOfPrintLaterJobs
{
    NSArray *jobs = [self retrieveAllPrintLaterJobs];
    return jobs.count;
}

#pragma mark - Filesystem manipulation methods

- (BOOL)createDirectory:(NSString *)directoryName atPath:(NSString *)path
{
    BOOL success = YES;
    
    NSString *pathAndDirectory = [path stringByAppendingPathComponent:directoryName];
    NSError *error;
    
    BOOL isDirectory;
    BOOL pathExists = [[NSFileManager defaultManager] fileExistsAtPath:pathAndDirectory isDirectory:&isDirectory];
    
    if (pathExists && !isDirectory) {
        MPLogError(@"File exists at path for directory:  %@", pathAndDirectory);
        success = NO;
    } else if (!pathExists && ![[NSFileManager defaultManager] createDirectoryAtPath:pathAndDirectory
                                                         withIntermediateDirectories:NO
                                                                          attributes:nil
                                                                               error:&error]) {
        MPLogError(@"Create directory error:  %@", error);
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

#pragma mark - Cached jobs

- (void)removeCachedJob:(NSString *)jobId
{
    @synchronized(self) {
        [_cachedPrintJobs removeObjectForKey:jobId];
    }
}

- (void)removeAllCachedJobs
{
    @synchronized(self) {
        [_cachedPrintJobs removeAllObjects];
    }
}

- (void)addCachedJob:(MPPrintLaterJob *)job
{
    @synchronized(self) {
        [self removeCachedJob:job.id];
        [_cachedPrintJobs addEntriesFromDictionary:@{ job.id:job }];
    }
}

- (MPPrintLaterJob *)retrieveCachedJob:(NSString *)jobId
{
    @synchronized(self) {
        return [_cachedPrintJobs objectForKey:jobId];
    }
}

#pragma mark - NSKeyedUnarchiverDelegate

- (Class)unarchiver:(NSKeyedUnarchiver *)unarchiver cannotDecodeObjectOfClassName:(NSString *)name originalClasses:(NSArray *)classNames {
    
    Class legacyClass = nil;
    if ([name isEqualToString:@"HPPPPrintLaterJob"]) {
        legacyClass = [MPLegacyPrintLaterJob class];
    } else if ([name isEqualToString:@"HPPPPageRange"]) {
        legacyClass = [MPLegacyPageRange class];
    } else if ([name isEqualToString:@"HPPPPrintItemImage"]) {
        legacyClass = [MPLegacyPrintItemImage class];
    } else if ([name isEqualToString:@"HPPPPrintItemPDF"]) {
        legacyClass = [MPLegacyPrintItemPDF class];
    } else {
        MPLogError(@"Unknown class in print job archive:  %@", name);
    }
    
    return legacyClass;
}

@end
