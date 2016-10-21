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

#import "MPBTStatusChecker.h"
#import "MPLogger.h"
#import <CoreBluetooth/CBCentralManager.h>

@interface MPBTStatusChecker()<CBCentralManagerDelegate>

    @property (strong, nonatomic) CBCentralManager* cbManager;
    
@end

@implementation MPBTStatusChecker

+ (MPBTStatusChecker *)sharedInstance
{
    static MPBTStatusChecker *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc] init];
    });
    
    return sharedInstance;
}

- (void)startChecking
{
    if (nil == self.cbManager) {
        NSDictionary *options = @{ CBCentralManagerOptionShowPowerAlertKey:[NSNumber numberWithBool:FALSE] };
        
        self.cbManager = [[CBCentralManager alloc] initWithDelegate:self queue:nil options:options];
    }
}
    
- (BOOL) isBluetoothEnabled
{
    BOOL enabled = NO;
    
    if (CBManagerStatePoweredOn == self.cbManager.state) {
        enabled = YES;
    }
    
    return enabled;
}

- (void)centralManagerDidUpdateState:(CBCentralManager *)central
{
    switch (central.state) {
        case CBManagerStateUnknown:
        MPLogInfo(@"CBManagerStateUnknown");
        
        case CBManagerStateResetting:
        MPLogInfo(@"CBManagerStateResetting");
        break;
        
        case CBManagerStateUnsupported:
        MPLogInfo(@"CBManagerStateUnsupported");
        break;
        
        case CBManagerStateUnauthorized:
        MPLogInfo(@"CBManagerStateUnauthorized");
        break;
        
        case CBManagerStatePoweredOff:
        MPLogInfo(@"CBManagerStatePoweredOff");
        break;
        
        case CBManagerStatePoweredOn:
        MPLogInfo(@"CBManagerStatePoweredOn");
        break;
        
        default:
        MPLogInfo(@"Unrecognized bluetooth state: %d", central.state);
    };
}
    
@end
