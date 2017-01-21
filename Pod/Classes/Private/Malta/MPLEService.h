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

extern NSString *kManufacturerNameCharacteristicUUIDString;

@protocol MPLEMaltaProtocol<NSObject>
@end

@interface MPLEService : NSObject

- (id) initWithMalta:(MPLEMalta *)malta controller:(id<MPLEMaltaProtocol>)controller;
- (void)start;
- (void)reset;

@property (strong, readonly) MPLEMalta *malta;
@property (strong, readonly) CBPeripheral *servicePeripheral;
@property (assign, readonly) CGFloat manufacturerName;

@end
