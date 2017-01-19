//
//  MPLEService.h
//  Pods
//
//  Created by Susy Snowflake on 1/17/17.
//
//

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>

extern NSString *kManufacturerNameCharacteristicUUIDString;

@protocol MPLEMaltaProtocol<NSObject>
@end

@interface MPLEService : NSObject

- (id) initWithPeripheral:(CBPeripheral *)peripheral controller:(id<MPLEMaltaProtocol>)controller;
- (void)start;

@property (readonly) CBPeripheral *servicePeripheral;
@property (readonly) CGFloat manufacturerName;

@end
