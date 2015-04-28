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

#import "HPPPLog.h"

#ifdef DEBUG
int ddLogLevel = LOG_LEVEL_VERBOSE;
#else
int ddLogLevel = LOG_LEVEL_INFO;
#endif

#import <DDASLLogger.h>
#import <DDTTYLogger.h>
#import "HPPPLogger.h"

@interface HPPPLogger()

@end

@implementation HPPPLogger

+ (id)sharedInstance
{
    static HPPPLogger *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[HPPPLogger alloc] init];
    });
    
    return sharedInstance;
}

- (void)configureLogging
{
    // Which log level(s) should be included in the logs?
    [DDLog addLogger:[DDASLLogger sharedInstance] withLogLevel:LOG_LEVEL_VERBOSE];
    [DDLog addLogger:[DDTTYLogger sharedInstance] withLogLevel:LOG_LEVEL_VERBOSE];
}

-(void)setDdLogLevel:(NSInteger)logLevel
{
    ddLogLevel = (int)logLevel;
}

- (NSMutableArray *)errorLogData
{
    NSUInteger maximumLogFilesToReturn = self.fileLogger.logFileManager.maximumNumberOfLogFiles;
    NSMutableArray *errorLogFiles = [NSMutableArray arrayWithCapacity:maximumLogFilesToReturn];
    
    NSArray *sortedLogFileInfos = [self.fileLogger.logFileManager sortedLogFileInfos];
    for (int i = 0; i < MIN(sortedLogFileInfos.count, maximumLogFilesToReturn); i++) {
        DDLogFileInfo *logFileInfo = [sortedLogFileInfos objectAtIndex:i];
        NSData *fileData = [NSData dataWithContentsOfFile:logFileInfo.filePath];
        [errorLogFiles addObject:fileData];
    }
    return errorLogFiles;
}

@end