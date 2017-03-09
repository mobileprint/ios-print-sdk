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

#import "MPLEService.h"
#import "MPLogger.h"

NSString *kDeviceInfoServiceUUIDString = @"0000180a-0000-1000-8000-00805f9b34fb";
NSString *kManufacturerNameCharacteristicUUIDString = @"00002a29-0000-1000-8000-00805f9b34fb";
NSString *kModelNumberCharacteristicUUIDString = @"00002a24-0000-1000-8000-00805f9b34fb";
NSString *kSerialNumberCharacteristicUUIDString = @"00002a25-0000-1000-8000-00805f9b34fb";
NSString *kFirmwareRevisionCharacteristicUUIDString = @"0000180a-0000-1000-8000-00805f9b34fb";
NSString *kSystemIdCharacteristicUUIDString = @"00002a23-0000-1000-8000-00805f9b34fb";

NSString *kBatteryInfoServiceUUIDString = @"0000180f-0000-1000-8000-00805f9b34fb";
NSString *kBatteryLevelCharacteristicUUIDString = @"00002a19-0000-1000-8000-00805f9b34fb";

static const NSInteger MPLEMaltaManufacturerKey = 0x2A29;
static const NSInteger MPLEMaltaSystemIdKey = 0x2A23;
static const NSInteger MPLEMaltaFirmwareVersionKey = 0x2A26;
static const NSInteger MPLEMaltaModelNumberKey = 0x2A24;
static const NSInteger MPLEMaltaBatteryLevelKey = 0x2A19;

@interface MPLEService()<CBPeripheralDelegate>

@property (strong, nonatomic) CBService *deviceInfoService;
@property (strong, nonatomic) CBService *batteryInfoService;

@property (strong, nonatomic) CBCharacteristic *manufacturerNameCharacteristic;
@property (strong, nonatomic) CBUUID *manufacturerNameUUID;
@property (weak, nonatomic) id<MPLEMaltaProtocol>	peripheralDelegate;

@end


@implementation MPLEService

- (id) initWithMalta:(MPLEMalta *)malta controller:(id<MPLEMaltaProtocol>)controller
{
    self = [super init];
    if (self) {
        _malta = malta;
        [malta.peripheral setDelegate:self];
        self.peripheralDelegate = controller;
        
        self.manufacturerNameUUID = [CBUUID UUIDWithString:kManufacturerNameCharacteristicUUIDString];
    }
    return self;
}

- (void) reset
{
    CBPeripheral *peripheral = _malta.peripheral;
    
    // See if we are subscribed to a characteristic on the peripheral
    //  Not sure if this applies to our single queries as well as ongoing notifications, but just in case...
    if (peripheral.services != nil) {
        for (CBService *service in peripheral.services) {
            if (service.characteristics != nil) {
                for (CBCharacteristic *characteristic in service.characteristics) {
                    if (characteristic.isNotifying) {
                        [peripheral setNotifyValue:NO forCharacteristic:characteristic];
                    }
                }
            }
        }
    }

    _malta = nil;
}

#pragma mark - Service Interaction

- (void) start
{
    CBUUID	*deviceInfoServiceUUID	= [CBUUID UUIDWithString:kDeviceInfoServiceUUIDString];
    CBUUID	*batteryInfoServiceUUID	= [CBUUID UUIDWithString:kBatteryInfoServiceUUIDString];
    NSArray	*serviceArray	= [NSArray arrayWithObjects:deviceInfoServiceUUID, batteryInfoServiceUUID, nil];
    
    if (self.malta.peripheral.services) {
        [self peripheral:self.malta.peripheral didDiscoverServices:nil];
    } else {
        [self.malta.peripheral discoverServices:serviceArray];
    }
}

- (void) peripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error
{
    NSArray		*services	= nil;
    
    if (peripheral != self.malta.peripheral) {
        MPLogError(@"Wrong Peripheral.\n");
        return ;
    }
    
    if (error != nil) {
        MPLogError(@"Error %@\n", error);
        return ;
    }
    
    services = [peripheral services];
    if (!services || ![services count]) {
        return ;
    }
    
    self.deviceInfoService = nil;
    
    for (CBService *service in services) {
        if ([[service UUID] isEqual:[CBUUID UUIDWithString:kDeviceInfoServiceUUIDString]]) {
            self.deviceInfoService = service;
            [peripheral discoverCharacteristics:nil forService:self.deviceInfoService];
        } else if ([[service UUID] isEqual:[CBUUID UUIDWithString:kBatteryInfoServiceUUIDString]]) {
            self.batteryInfoService = service;
            [peripheral discoverCharacteristics:nil forService:self.batteryInfoService];
        }
    }
}

- (void) peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error
{
    if ([[service UUID] isEqual:[CBUUID UUIDWithString:kDeviceInfoServiceUUIDString]] ||
        [[service UUID] isEqual:[CBUUID UUIDWithString:kBatteryInfoServiceUUIDString]]) {
        CBCharacteristic *characteristic;
        for (characteristic in service.characteristics) {
            [peripheral readValueForCharacteristic:characteristic];
        }
    }
}

- (void)peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error {
    if (error) {
        MPLogError(@"Error reading characteristics: %@", [error localizedDescription]);
        return;
    }
    
    if (characteristic.value != nil) {
        NSString *stringValue = [[NSString alloc] initWithData:characteristic.value encoding:NSUTF8StringEncoding];
        MPLogDebug(@"characteristic: %@\n\nvalue: %@", characteristic, stringValue);
        unsigned char *bytes = characteristic.UUID.data.bytes;
        NSInteger value = bytes[0] << 8 | bytes[1];
        
        if (MPLEMaltaManufacturerKey == value) {
            self.malta.manufacturer = stringValue;
        } else if (MPLEMaltaSystemIdKey == value) {
            self.malta.systemId = stringValue;
        } else if (MPLEMaltaFirmwareVersionKey == value) {
            self.malta.firmwareVersion = stringValue;
        } else if (MPLEMaltaModelNumberKey == value) {
            self.malta.modelNumber = stringValue;
        } else if (MPLEMaltaBatteryLevelKey == value) {
            unsigned char *batteryLevelBytes = characteristic.value.bytes;
            self.malta.batteryLevel = batteryLevelBytes[0];
        }
    }
}

@end
