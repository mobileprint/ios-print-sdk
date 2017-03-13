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
#import "MPLEService.h"
#import "MPLogger.h"

static const NSString *MALTA_DISCOVERY_PREFIX = @"HPMalta-";

@interface MPLEDiscovery () <CBCentralManagerDelegate, CBPeripheralDelegate, MPLEMaltaProtocol>
    @property (strong, nonatomic) CBCentralManager *centralManager;
	@property (assign, nonatomic) BOOL pendingInit;
    @property (strong, nonatomic) MPLEService *leService;
    @property (strong, nonatomic) MPLEMalta *connectingMalta;
@end


@implementation MPLEDiscovery

#pragma mark - init

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
        self.foundMaltas = [[NSMutableArray alloc] init];
		self.connectedServices = [[NSMutableArray alloc] init];
	}
    return self;
}

- (void) dealloc
{
    // We are a singleton and as such, dealloc shouldn't be called.
    assert(NO);
}

#pragma mark - Manually start discovery

- (void) setDiscoveryDelegate:(id<MPLEDiscoveryDelegate>)discoveryDelegate
{
    _discoveryDelegate = discoveryDelegate;
    
    // We don't want to leave discovery running amuck in the background for no reason.
    //  So, we only scan for devices when a delegate is listening.
    if (nil == discoveryDelegate) {
        [self stopScanning];
    } else {
        // The scan will begin once the centralManager's state is set to CBCentralManagerStatePoweredOn
        self.pendingInit = YES;
        self.centralManager = [[CBCentralManager alloc] initWithDelegate:self queue:dispatch_get_main_queue()];
    }
}

- (void) startScan
{
    if (nil != self.discoveryDelegate && !self.pendingInit) {
        [self clearDevices];
        [self startScanningForUUIDString:nil];
    } else {
        [self stopScanning];
        [self clearDevices];
    }
}

- (void) startScanningForUUIDString:(NSString *)uuidString
{
    NSArray *uuidArray = nil;
    NSDictionary *options = [NSDictionary dictionaryWithObject:[NSNumber numberWithBool:NO] forKey:CBCentralManagerScanOptionAllowDuplicatesKey];
    
    if (uuidString) {
        uuidArray = [NSArray arrayWithObjects:[CBUUID UUIDWithString:uuidString], nil];
    }
    
    [self.centralManager scanForPeripheralsWithServices:uuidArray options:options];
}

- (void) stopScanning
{
    [self.centralManager stopScan];
}

#pragma mark - CBCentralManagerDelegate

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
    MPLogError(@"Failed to retrieve peripheral for UUID: %@ with Error: %@", UUID, error.localizedDescription);
}

- (void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary *)advertisementData RSSI:(NSNumber *)RSSI
{
	if (![self alreadyFound:peripheral]) {
        MPLogDebug(@"Peripheral Name: %@", peripheral.name);

        if ([peripheral.name hasPrefix:MALTA_DISCOVERY_PREFIX]) {
            MPLogDebug(@"%@", advertisementData);
            
            NSData *manufacturerData = [advertisementData objectForKey:@"kCBAdvDataManufacturerData"];
            unsigned char *bytes = [manufacturerData bytes];
            
            NSInteger companyIdentifier = (bytes[1] << 8  |  bytes[0]);
            
            // Weird bug... sporadically get bad advertising data (all 0's)
            if (0 != companyIdentifier) {
                MPLEMalta *malta = [[MPLEMalta alloc] init];
                malta.peripheral = peripheral;
                [self.foundMaltas addObject:malta];
                
                [self.discoveryDelegate discoveryDidRefresh];

                NSString *name              = [peripheral.name substringFromIndex:MALTA_DISCOVERY_PREFIX.length];
                NSInteger format            = bytes[2];
                NSInteger calibratedRssi    = bytes[3];
                NSInteger connectableStatus = bytes[4];
                NSInteger deviceColor       = bytes[5];
                NSInteger printerStatus     = bytes[6];
                
                MPLogDebug(@"name              : %@", name);
                MPLogDebug(@"companyIdentifier : %#x", companyIdentifier);
                MPLogDebug(@"format            : %d",  format);
                MPLogDebug(@"calibratedRssi    : %#x", calibratedRssi);
                MPLogDebug(@"connectableStatus : %d",  connectableStatus);
                MPLogDebug(@"deviceColor       : %d",  deviceColor);
                MPLogDebug(@"printerStatus     : %d",  printerStatus);
                
                malta.name = name;
                malta.companyId = companyIdentifier;
                malta.format = format;
                malta.calibratedRssi = calibratedRssi;
                malta.connectableStatus = connectableStatus;
                malta.deviceColor = deviceColor;
                malta.printerStatus = printerStatus;
            } else {
                MPLogDebug(@"Reject Malta discovery due to incomplete advertisement data");
            }
        }
	}
}

- (BOOL) alreadyFound:(CBPeripheral *)peripheral
{
    BOOL found = NO;
    
    for (MPLEMalta *malta in self.foundMaltas) {
        if (peripheral == malta.peripheral) {
            found = YES;
            break;
        }
    }
    
    return found;
}

#pragma mark - Connection/Disconnection

- (void) connectMalta:(MPLEMalta*)malta
{
	if (CBPeripheralStateConnected != malta.peripheral.state) {
        self.connectingMalta = malta;
		[self.centralManager connectPeripheral:malta.peripheral options:nil];
	}
}

- (void) disconnectPeripheral:(CBPeripheral*)peripheral
{
    self.connectingMalta = nil;
	[self.centralManager cancelPeripheralConnection:peripheral];
}

- (void) centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral
{
    self.leService = nil;

    if (self.connectingMalta.peripheral == peripheral) {
        self.leService = [[MPLEService alloc] initWithMalta:self.connectingMalta controller:self];
        [self.leService start];
        self.connectingMalta = nil;
    } else {
        MPLogDebug(@"Device is not a Malta");
    }
}

- (void) centralManager:(CBCentralManager *)central didFailToConnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error
{
    MPLogError(@"Attempted connection to peripheral %@ failed: %@", [peripheral name], [error localizedDescription]);
}

- (void) centralManager:(CBCentralManager *)central didDisconnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error
{
    MPLogDebug(@"Disconnected peripheral %@", [peripheral name]);

	for (MPLEService *service in _connectedServices) {
		if (service.servicePeripheral == peripheral) {
			[_connectedServices removeObject:service];
			break;
		}
	}

	[_discoveryDelegate discoveryDidRefresh];
}

- (void) clearDevices
{
    //[self.foundPeripherals removeAllObjects];
    [self.foundMaltas removeAllObjects];
    
    for (MPLEService *service in _connectedServices) {
        [service reset];
    }

    [self.connectedServices removeAllObjects];
}

- (void) centralManagerDidUpdateState:(CBCentralManager *)central
{
    static CBCentralManagerState previousState = -1;
    
	switch ([self.centralManager state]) {
		case CBCentralManagerStatePoweredOff:
		{
            MPLogDebug(@"CBCentralManagerStatePoweredOff");
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
            MPLogDebug(@"CBCentralManagerStateUnauthorized");
			/* Tell user the app is not allowed. */
			break;
		}
            
		case CBCentralManagerStateUnknown:
		{
            MPLogDebug(@"CBCentralManagerStateUnknown");
			/* Bad news, let's wait for another event. */
			break;
		}
            
		case CBCentralManagerStatePoweredOn:
		{
            MPLogDebug(@"CBCentralManagerStatePoweredOn");
			self.pendingInit = NO;
            [self startScan];
			break;
		}
            
		case CBCentralManagerStateResetting:
		{
            MPLogDebug(@"CBCentralManagerStateResetting");
			[self clearDevices];
            [_discoveryDelegate discoveryDidRefresh];
            
			self.pendingInit = YES;
			break;
		}
	}
    
    previousState = [self.centralManager state];
}

@end
