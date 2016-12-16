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

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>

//#import "LeTemperatureAlarmService.h"

@protocol MPLEDiscoveryDelegate <NSObject>
- (void) discoveryDidRefresh;
- (void) discoveryStatePoweredOff;
@end

@interface MPLEDiscovery : NSObject

+ (MPLEDiscovery *) sharedInstance;

@property (retain, nonatomic) NSMutableArray    *foundPeripherals;
@property (retain, nonatomic) NSMutableArray	*connectedServices;	// Array of LeTemperatureAlarmService
@property (nonatomic, assign) id/*<LeTemperatureAlarmProtocol>*/ peripheralDelegate;

// Setting the discoveryDelegate starts the discovery of Bluetooth LE devices
@property (nonatomic, assign) id<MPLEDiscoveryDelegate> discoveryDelegate;

- (void) connectPeripheral:(CBPeripheral*)peripheral;
- (void) disconnectPeripheral:(CBPeripheral*)peripheral;

@end
