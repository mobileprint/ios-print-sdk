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



/****************************************************************************/
/*							UI protocols									*/
/****************************************************************************/
@protocol MPLEDiscoveryDelegate <NSObject>
- (void) discoveryDidRefresh;
- (void) discoveryStatePoweredOff;
@end



/****************************************************************************/
/*							Discovery class									*/
/****************************************************************************/
@interface MPLEDiscovery : NSObject

+ (MPLEDiscovery *) sharedInstance;


/****************************************************************************/
/*								UI controls									*/
/****************************************************************************/
@property (nonatomic, assign) id<MPLEDiscoveryDelegate>           discoveryDelegate;
@property (nonatomic, assign) id/*<LeTemperatureAlarmProtocol>*/	peripheralDelegate;


/****************************************************************************/
/*								Actions										*/
/****************************************************************************/
- (void) startScanningForUUIDString:(NSString *)uuidString;
- (void) stopScanning;

- (void) connectPeripheral:(CBPeripheral*)peripheral;
- (void) disconnectPeripheral:(CBPeripheral*)peripheral;


/****************************************************************************/
/*							Access to the devices							*/
/****************************************************************************/
@property (retain, nonatomic) NSMutableArray    *foundPeripherals;
@property (retain, nonatomic) NSMutableArray	*connectedServices;	// Array of LeTemperatureAlarmService
@end
