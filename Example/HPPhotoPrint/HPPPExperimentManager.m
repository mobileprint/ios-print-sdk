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

#import "HPPPExperimentManager.h"

@implementation HPPPExperimentManager

#pragma mark - Initialization

+ (HPPPExperimentManager *)sharedInstance
{
    static HPPPExperimentManager *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[HPPPExperimentManager alloc] init];
    });
    
    return sharedInstance;
}

- (id)init
{
    self = [super init];
    if (self) {
        _showPrintIcon = [self oddDeviceID];
    }
    return self;
}

#pragma mark - Selection

- (BOOL)oddDeviceID
{
    NSArray *oddDigits = @[@"1", @"3", @"5", @"7", @"9", @"B", @"D", @"F"];
    return [oddDigits containsObject:[self lastDigitOfDeviceID]];
}

- (NSString *)lastDigitOfDeviceID
{
    NSString *deviceID = [[UIDevice currentDevice].identifierForVendor UUIDString];
    NSString *lastDigit = [deviceID substringFromIndex:[deviceID length] - 1];
    return lastDigit;
}

@end
