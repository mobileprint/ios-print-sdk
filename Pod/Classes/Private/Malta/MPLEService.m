//
//  MPLEService.m
//  Pods
//
//  Created by Susy Snowflake on 1/17/17.
//
//

#import "MPLEService.h"

NSString *kDeviceInfoServiceUUIDString = @"0000180a-0000-1000-8000-00805f9b34fb";
NSString *kManufacturerNameCharacteristicUUIDString = @"00002a29-0000-1000-8000-00805f9b34fb";
NSString *kModelNumberCharacteristicUUIDString = @"00002a24-0000-1000-8000-00805f9b34fb";
NSString *kSerialNumberCharacteristicUUIDString = @"00002a25-0000-1000-8000-00805f9b34fb";
NSString *kFirmwareRevisionCharacteristicUUIDString = @"0000180a-0000-1000-8000-00805f9b34fb";
NSString *kSystemIdCharacteristicUUIDString = @"00002a23-0000-1000-8000-00805f9b34fb";

NSString *kBatteryInfoServiceUUIDString = @"0000180f-0000-1000-8000-00805f9b34fb";
NSString *kBatteryLevelCharacteristicUUIDString = @"00002a19-0000-1000-8000-00805f9b34fb";

@interface MPLEService()<CBPeripheralDelegate>

@property (strong, nonatomic) CBService *deviceInfoService;

@property (strong, nonatomic) CBCharacteristic *manufacturerNameCharacteristic;
@property (strong, nonatomic) CBUUID *manufacturerNameUUID;
@property (strong, nonatomic) id<MPLEMaltaProtocol>	peripheralDelegate;

@end


@implementation MPLEService

- (id) initWithPeripheral:(CBPeripheral *)peripheral controller:(id<MPLEMaltaProtocol>)controller
{
    self = [super init];
    if (self) {
        _servicePeripheral = peripheral;
        [self.servicePeripheral setDelegate:self];
        self.peripheralDelegate = controller;
        
        self.manufacturerNameUUID = [CBUUID UUIDWithString:kManufacturerNameCharacteristicUUIDString];
    }
    return self;
}

- (void) reset
{
    _servicePeripheral = nil;
}

#pragma mark - Service Interaction

- (void) start
{
    CBUUID	*deviceInfoServiceUUID	= [CBUUID UUIDWithString:kDeviceInfoServiceUUIDString];
    CBUUID	*batteryInfoServiceUUID	= [CBUUID UUIDWithString:kBatteryInfoServiceUUIDString];
    NSArray	*serviceArray	= [NSArray arrayWithObjects:deviceInfoServiceUUID, batteryInfoServiceUUID, nil];
    
    if (self.servicePeripheral.services) {
        [self peripheral:self.servicePeripheral didDiscoverServices:nil];
    } else {
        [self.servicePeripheral discoverServices:serviceArray];
    }
}

- (void) peripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error
{
    NSArray		*services	= nil;
    NSArray		*uuids	= [NSArray arrayWithObjects:self.manufacturerNameUUID,nil];
    
    if (peripheral != self.servicePeripheral) {
        NSLog(@"Wrong Peripheral.\n");
        return ;
    }
    
    if (error != nil) {
        NSLog(@"Error %@\n", error);
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
            break;
        }
    }
    
    if (self.deviceInfoService) {
        [peripheral discoverCharacteristics:nil forService:self.deviceInfoService];
    }
}

- (void) peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error
{
    if ([[service UUID] isEqual:[CBUUID UUIDWithString:kDeviceInfoServiceUUIDString]]) {
        CBCharacteristic *characteristic;
        for (characteristic in service.characteristics) {
            [peripheral readValueForCharacteristic:characteristic];
        }
    }
}

- (void)peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error {
    if (error) {
        NSLog(@"Error reading characteristics: %@", [error localizedDescription]);
        return;
    }
    
    if (characteristic.value != nil) {
        NSString *stringValue = [[NSString alloc] initWithData:characteristic.value encoding:NSUTF8StringEncoding];
        NSLog(@"characteristic: %@\n\nvalue: %@", characteristic, stringValue);
    }
}

@end
