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
#import "MPLEMalta.h"

@protocol MPLEDiscoveryDelegate <NSObject>
- (void) discoveryDidRefresh;
- (void) discoveryStatePoweredOff;
@end

@interface MPLEDiscovery : NSObject

+ (MPLEDiscovery *) sharedInstance;

@property (strong, nonatomic) NSMutableArray    *foundMaltas;
@property (strong, nonatomic) NSMutableArray	*connectedServices;

// Setting the discoveryDelegate starts the discovery of Bluetooth LE devices
@property (weak, nonatomic) id<MPLEDiscoveryDelegate> discoveryDelegate;

- (void) connectMalta:(MPLEMalta*)malta;
- (void) disconnectPeripheral:(CBPeripheral*)peripheral;

- (void) startScan;
- (void) stopScanning;
- (void) clearDevices;

@end
