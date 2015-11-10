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

#import "MPLogger.h"

@implementation MPLogger

+ (MPLogger *)sharedInstance
{
    static MPLogger *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[MPLogger alloc] init];
    });
    
    return sharedInstance;
}

- (void) logError:(NSString*)msg
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(logError:)]) {
        [self.delegate logError:msg];
    } else {
        NSLog(@"%@", msg);
    }
}

- (void) logWarn:(NSString*)msg
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(logWarn:)]) {
        [self.delegate logWarn:msg];
    } else {
        NSLog(@"%@", msg);
    }
}

- (void) logInfo:(NSString*)msg
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(logInfo:)]) {
        [self.delegate logInfo:msg];
    } else {
        NSLog(@"%@", msg);
    }
}

- (void) logDebug:(NSString*)msg
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(logDebug:)]) {
        [self.delegate logDebug:msg];
    } else {
        NSLog(@"%@", msg);
    }
}

- (void) logVerbose:(NSString*)msg
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(logVerbose:)]) {
        [self.delegate logVerbose:msg];
    } else {
        NSLog(@"%@", msg);
    }
}


@end
