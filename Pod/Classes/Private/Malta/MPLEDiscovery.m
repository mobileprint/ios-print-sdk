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

#import "MPLEDiscovery.h"


@interface MPLEDiscovery () <CBCentralManagerDelegate, CBPeripheralDelegate> {
	CBCentralManager    *centralManager;
	BOOL				pendingInit;
}
@end


@implementation MPLEDiscovery

#pragma mark Init

+ (MPLEDiscovery *) sharedInstance
{
	static MPLEDiscovery *sharedDiscovery = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
		sharedDiscovery = [[MPLEDiscovery alloc] init];
    });
    
	return sharedDiscovery;
}


- (id) init
{
    self = [super init];
    if (self) {
		pendingInit = YES;
		centralManager = [[CBCentralManager alloc] initWithDelegate:self queue:dispatch_get_main_queue()];

		_foundPeripherals = [[NSMutableArray alloc] init];
		_connectedServices = [[NSMutableArray alloc] init];
	}
    return self;
}


- (void) dealloc
{
    // We are a singleton and as such, dealloc shouldn't be called.
    assert(NO);
}



#pragma mark Restoring

/* Reload from file. */
- (void) loadSavedDevices
{
	NSArray	*storedDevices	= [[NSUserDefaults standardUserDefaults] arrayForKey:@"StoredDevices"];

	if (![storedDevices isKindOfClass:[NSArray class]]) {
        NSLog(@"No stored array to load");
        return;
    }
     
    for (id deviceUUIDString in storedDevices) {
        
        if (![deviceUUIDString isKindOfClass:[NSString class]])
            continue;
        
        CFUUIDRef uuid = CFUUIDCreateFromString(NULL, (CFStringRef)deviceUUIDString);
        if (!uuid)
            continue;
        
        [centralManager retrieveConnectedPeripheralsWithServices:[NSArray arrayWithObject:(__bridge id)uuid]];
        CFRelease(uuid);
    }

}


- (void) addSavedDevice:(CFUUIDRef) uuid
{
	NSArray *storedDevices = [[NSUserDefaults standardUserDefaults] arrayForKey:@"StoredDevices"];
	NSMutableArray *newDevices = nil;
	CFStringRef uuidString = NULL;

	if (![storedDevices isKindOfClass:[NSArray class]]) {
        NSLog(@"Can't find/create an array to store the uuid");
        return;
    }

    newDevices = [NSMutableArray arrayWithArray:storedDevices];
    
    uuidString = CFUUIDCreateString(NULL, uuid);
    if (uuidString) {
        [newDevices addObject:(__bridge NSString*)uuidString];
        CFRelease(uuidString);
    }
    /* Store */
    [[NSUserDefaults standardUserDefaults] setObject:newDevices forKey:@"StoredDevices"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}


- (void) removeSavedDevice:(CFUUIDRef) uuid
{
	NSArray			*storedDevices	= [[NSUserDefaults standardUserDefaults] arrayForKey:@"StoredDevices"];
	NSMutableArray	*newDevices		= nil;
	CFStringRef		uuidString		= NULL;

	if ([storedDevices isKindOfClass:[NSArray class]]) {
		newDevices = [NSMutableArray arrayWithArray:storedDevices];

		uuidString = CFUUIDCreateString(NULL, uuid);
		if (uuidString) {
			[newDevices removeObject:(__bridge NSString*)uuidString];
            CFRelease(uuidString);
        }
		/* Store */
		[[NSUserDefaults standardUserDefaults] setObject:newDevices forKey:@"StoredDevices"];
		[[NSUserDefaults standardUserDefaults] synchronize];
	}
}


- (void) centralManager:(CBCentralManager *)central didRetrieveConnectedPeripherals:(NSArray *)peripherals
{
	CBPeripheral	*peripheral;
	
	/* Add to list. */
	for (peripheral in peripherals) {
		[central connectPeripheral:peripheral options:nil];
	}
	[_discoveryDelegate discoveryDidRefresh];
}


- (void) centralManager:(CBCentralManager *)central didRetrievePeripheral:(CBPeripheral *)peripheral
{
	[central connectPeripheral:peripheral options:nil];
	[_discoveryDelegate discoveryDidRefresh];
}


- (void) centralManager:(CBCentralManager *)central didFailToRetrievePeripheralForUUID:(CFUUIDRef)UUID error:(NSError *)error
{
	/* Nuke from plist. */
	[self removeSavedDevice:UUID];
}



#pragma mark Discovery

- (void) startScanningForUUIDString:(NSString *)uuidString
{
    NSArray *uuidArray = nil;
    NSDictionary *options = [NSDictionary dictionaryWithObject:[NSNumber numberWithBool:NO] forKey:CBCentralManagerScanOptionAllowDuplicatesKey];

    if (uuidString) {
        uuidArray = [NSArray arrayWithObjects:[CBUUID UUIDWithString:uuidString], nil];
    }

	[centralManager scanForPeripheralsWithServices:uuidArray options:options];
}


- (void) stopScanning
{
	[centralManager stopScan];
}


- (void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary *)advertisementData RSSI:(NSNumber *)RSSI
{
	if (![_foundPeripherals containsObject:peripheral]) {
		[_foundPeripherals addObject:peripheral];
		[_discoveryDelegate discoveryDidRefresh];
	}
}


- (void) setDiscoveryDelegate:(id<MPLEDiscoveryDelegate>)discoveryDelegate
{
    _discoveryDelegate = discoveryDelegate;
    
    if (nil != discoveryDelegate && !pendingInit) {
        [self startScanningForUUIDString:nil];
    } else {
        [self stopScanning];
        [self clearDevices];
    }
}

#pragma mark Connection/Disconnection
- (void) connectPeripheral:(CBPeripheral*)peripheral
{
	if (CBPeripheralStateDisconnected == peripheral.state) {
		[centralManager connectPeripheral:peripheral options:nil];
	}
}


- (void) disconnectPeripheral:(CBPeripheral*)peripheral
{
	[centralManager cancelPeripheralConnection:peripheral];
}


- (void) centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral
{
//	LeTemperatureAlarmService	*service	= nil;
//	
//	/* Create a service instance. */
//	service = [[[LeTemperatureAlarmService alloc] initWithPeripheral:peripheral controller:peripheralDelegate] autorelease];
//	[service start];
//
//	if (![connectedServices containsObject:service])
//		[connectedServices addObject:service];
//
//	if ([foundPeripherals containsObject:peripheral])
//		[foundPeripherals removeObject:peripheral];
//
//    [peripheralDelegate alarmServiceDidChangeStatus:service];
//	[discoveryDelegate discoveryDidRefresh];
}


- (void) centralManager:(CBCentralManager *)central didFailToConnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error
{
    NSLog(@"Attempted connection to peripheral %@ failed: %@", [peripheral name], [error localizedDescription]);
}


- (void) centralManager:(CBCentralManager *)central didDisconnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error
{
    NSLog(@"Disconnected peripheral %@", [peripheral name]);
//	LeTemperatureAlarmService	*service	= nil;
//
//	for (service in connectedServices) {
//		if ([service peripheral] == peripheral) {
//			[connectedServices removeObject:service];
//            [peripheralDelegate alarmServiceDidChangeStatus:service];
//			break;
//		}
//	}
//
//	[discoveryDelegate discoveryDidRefresh];
}


- (void) clearDevices
{
//    LeTemperatureAlarmService	*service;
    [_foundPeripherals removeAllObjects];
    
//    for (service in connectedServices) {
//        [service reset];
//    }
    [_connectedServices removeAllObjects];
}


- (void) centralManagerDidUpdateState:(CBCentralManager *)central
{
    static CBCentralManagerState previousState = -1;
    
	switch ([centralManager state]) {
		case CBCentralManagerStatePoweredOff:
		{
            [self clearDevices];
            [_discoveryDelegate discoveryDidRefresh];
            
			/* Tell user to power ON BT for functionality, but not on first run - the Framework will alert in that instance. */
            if (previousState != -1) {
                [_discoveryDelegate discoveryStatePoweredOff];
            }
			break;
		}
            
		case CBCentralManagerStateUnauthorized:
		{
			/* Tell user the app is not allowed. */
			break;
		}
            
		case CBCentralManagerStateUnknown:
		{
			/* Bad news, let's wait for another event. */
			break;
		}
            
		case CBCentralManagerStatePoweredOn:
		{
			pendingInit = NO;
            if (nil != self.discoveryDelegate) {
                [self loadSavedDevices];
                //[centralManager retrieveConnectedPeripheralsWithServices:[[NSArray alloc]init]];
                [self startScanningForUUIDString:nil];
            }
			break;
		}
            
		case CBCentralManagerStateResetting:
		{
			[self clearDevices];
            [_discoveryDelegate discoveryDidRefresh];
//            [peripheralDelegate alarmServiceDidReset];
            
			pendingInit = YES;
			break;
		}
	}
    
    previousState = [centralManager state];
}
@end
