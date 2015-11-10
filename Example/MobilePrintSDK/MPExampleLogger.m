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


#import "MPExampleLogger.h"

@implementation MPExampleLogger

- (void) logError:(NSString*)msg
{
    NSLog(@"Delegate Logger: %@", msg);
}

- (void) logWarn:(NSString*)msg
{
    NSLog(@"Delegate Logger: %@", msg);
}

- (void) logInfo:(NSString*)msg
{
    NSLog(@"Delegate Logger: %@", msg);
}

- (void) logDebug:(NSString*)msg
{
    NSLog(@"Delegate Logger: %@", msg);
}

- (void) logVerbose:(NSString*)msg
{
    NSLog(@"Delegate Logger: %@", msg);
}

@end
