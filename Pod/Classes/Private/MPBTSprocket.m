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

#import "MPBTSprocket.h"
#import "MPBTSessionController.h"
#import "MPPrintItemImage.h"

const char MANTA_PACKET_LENGTH = 34;

static const NSString *polaroidProtocol = @"com.polaroid.mobileprinter";
static const NSString *hpProtocol = @"com.hp.protocol";

// Common to all packets
static const char START_CODE_BYTE_1    = 0x1B;
static const char START_CODE_BYTE_2    = 0x2A;
static const char POLAROID_CUSTOMER_CODE_BYTE_1 = 0x43;
static const char POLAROID_CUSTOMER_CODE_BYTE_2 = 0x41;
static const char HP_CUSTOMER_CODE_BYTE_1 = 0x48;
static const char HP_CUSTOMER_CODE_BYTE_2 = 0x50;

// Commands
static const char CMD_PRINT_READY_CMD       = 0x00;
static const char CMD_PRINT_READY_SUB_CMD   = 0x00;

static const char CMD_GET_INFO_CMD          = 0x01;
static const char CMD_GET_INFO_SUB_CMD      = 0x00;

static const char CMD_SET_INFO_CMD          = 0x01;
static const char CMD_SET_INFO_SUB_CMD      = 0x01;

static const char CMD_UPGRADE_READY_CMD     = 0x03;
static const char CMD_UPGRADE_READY_SUB_CMD = 0x00;

// Responses
static const char RESP_PRINT_START_CMD            = 0x00;
static const char RESP_PRINT_START_SUB_CMD        = 0x02;

static const char RESP_ACCESSORY_INFO_ACK_CMD     = 0x01;
static const char RESP_ACCESSORY_INFO_ACK_SUB_CMD = 0x02;

static const char RESP_START_OF_SEND_ACK_CMD      = 0x02;
static const char RESP_START_OF_SEND_ACK_SUB_CMD  = 0x00;

static const char RESP_END_OF_RECEIVE_ACK_CMD     = 0x02;
static const char RESP_END_OF_RECEIVE_ACK_SUB_CMD = 0x01;

static const char RESP_UPGRADE_ACK_CMD            = 0x03;
static const char RESP_UPGRADE_ACK_SUB_CMD        = 0x02;

static const char RESP_ERROR_MESSAGE_ACK_CMD      = 0x04;
static const char RESP_ERROR_MESSAGE_ACK_SUB_CMD  = 0x00;


@import UIKit;

@interface MPBTSprocket ()

@property (strong, nonatomic) MPBTSessionController *session;
@property (strong, nonatomic) NSString *fileToPrint;
@property (strong, nonatomic) NSString *fileType;
@property (strong, nonatomic) NSData* imageData;
@property (strong, nonatomic) NSData* upgradeData;
@property (strong, nonatomic) NSArray *supportedProtocols;

@end

@implementation MPBTSprocket

#pragma mark - Public methods

+ (MPBTSprocket *)sharedInstance
{
    static MPBTSprocket *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[MPBTSprocket alloc] init];
    });
    
    return sharedInstance;
}

#pragma mark - Initialization

- (instancetype)init
{
    self = [super init];
    if (self) {

        self.supportedProtocols = @[polaroidProtocol, hpProtocol/*, @"com.lge.pocketphoto"*/];
        
        // watch for received data from the accessory
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_sessionDataReceived:) name:MPBTSessionDataReceivedNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_sessionDataSent:) name:MPBTSessionDataSentNotification object:nil];

        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_accessoryDidConnect:) name:EAAccessoryDidConnectNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_accessoryDidDisconnect:) name:EAAccessoryDidDisconnectNotification object:nil];
        [[EAAccessoryManager sharedAccessoryManager] registerForLocalNotifications];
        
        self.fileToPrint = @"BoxMan640x960";
        self.fileType = @"jpg";
    }
    
    return self;
}

- (void)refreshInfo
{
    [self.session writeData:[self accessoryInfoRequest]];
}

- (void)print:(MPPrintItem *)printItem numCopies:(NSInteger)numCopies
{
    UIImage *asset = ((NSArray*)printItem.printAsset)[0];
    UIImage *image = [self imageByScalingAndCroppingForSize:asset targetSize:CGSizeMake(640,960)];
    self.imageData = UIImageJPEGRepresentation(image, 0.9);
    
    [self.session writeData:[self printReadyRequest:numCopies]];
}

- (void)reflash:(MPBTSprocketReflashOption)reflashOption
{
    if ([self.protocolString isEqualToString:polaroidProtocol]  ||
        [self.protocolString isEqualToString:hpProtocol]) {
        
        NSString *myFile = [[NSBundle mainBundle] pathForResource:@"HP_protocol" ofType:@"rbn"];
        if (MPBTSprocketReflashV2 == reflashOption) {
            myFile = [[NSBundle mainBundle] pathForResource:@"Polaroid_v200" ofType:@"rbn"];
        } else if (MPBTSprocketReflashV3 == reflashOption) {
            myFile = [[NSBundle mainBundle] pathForResource:@"Polaroid_v300" ofType:@"rbn"];
        }
        
        self.upgradeData = [NSData dataWithContentsOfFile:myFile];
        
        [self.session writeData:[self upgradeReadyRequest]];
    } else {
        NSLog(@"No reflash files for non-Polaroid and non-HP devices");
    }
}

#pragma mark - Getters/Setters

- (MPBTSessionController *)session
{
    _session = nil;
    
    NSString *protocolString = nil;
    if (self.accessory) {
        _session = [MPBTSessionController sharedController];
        [_session setupControllerForAccessory:self.accessory
                           withProtocolString:self.protocolString];
        
        BOOL success = [_session openSession];
        NSAssert(success, @"Failed to open session with device");
    } else {
        NSLog(@"Can't open a session with a nil device / accessory");
    }
    
    return _session;
}

- (void)setAccessory:(EAAccessory *)accessory
{
    _accessory = nil;
    
    self.protocolString = [self supportedProtocolString:accessory];
    
    if( self.protocolString ) {
        _accessory = accessory;
    } else {
        NSLog(@"Unsupported device");
    }
}

- (void)setPrintMode:(MantaPrintMode)printMode
{
    if (_printMode != printMode) {
        _printMode = printMode;
        [self.session writeData:[self setInfoRequest]];
    }
}

- (void)setPowerOffInterval:(MantaAutoPowerOffInterval)powerOffInterval
{
    if (_powerOffInterval != powerOffInterval) {
        _powerOffInterval = powerOffInterval;
        [self.session writeData:[self setInfoRequest]];
    }
}

- (void)setAutoExposure:(MantaAutoExposure)autoExposure
{
    if (_autoExposure != autoExposure) {
        _autoExposure = autoExposure;
        [self.session writeData:[self setInfoRequest]];
    }
}

- (NSString *)displayName
{
    return [NSString stringWithFormat:@"%@ (%@)", self.accessory.name, self.accessory.serialNumber];
}

#pragma mark - Util

- (NSString *)supportedProtocolString:(EAAccessory *)accessory
{
    NSString *protocolString = nil;
    if (accessory) {
        
        for (NSString *protocol in [accessory protocolStrings]) {
            
            for (NSString *supportedProtocol in self.supportedProtocols) {
                if( [supportedProtocol isEqualToString:protocol] ) {
                    protocolString = supportedProtocol;
                }
            }
        }
    }
    
    return protocolString;
}

#pragma mark - Packet Creation

- (void)setupPacket:(char[MANTA_PACKET_LENGTH])packet command:(char)command subcommand:(char)subcommand
{
    memset(packet, 0, MANTA_PACKET_LENGTH);

    packet[0] = START_CODE_BYTE_1;
    packet[1] = START_CODE_BYTE_2;
    
    if ([self.protocolString isEqualToString:polaroidProtocol]) {
        packet[2] = POLAROID_CUSTOMER_CODE_BYTE_1;
        packet[3] = POLAROID_CUSTOMER_CODE_BYTE_2;
    } else if ([self.protocolString isEqualToString:hpProtocol]){
        packet[2] = HP_CUSTOMER_CODE_BYTE_1;
        packet[3] = HP_CUSTOMER_CODE_BYTE_2;
    } else {
        NSLog(@"Unexpected protocol string: %@, defaulting to HP customer code", self.protocolString);
        packet[2] = HP_CUSTOMER_CODE_BYTE_1;
        packet[3] = HP_CUSTOMER_CODE_BYTE_2;
    }
    
    packet[6] = command;
    packet[7] = subcommand;
}

- (NSData *)accessoryInfoRequest
{
    NSMutableData *data;
    char byteArray[MANTA_PACKET_LENGTH];
    
    [self setupPacket:byteArray command:CMD_GET_INFO_CMD subcommand:CMD_GET_INFO_SUB_CMD];

    data = [NSMutableData dataWithBytes:byteArray length:MANTA_PACKET_LENGTH];

    NSLog(@"accessoryInfoRequest: %@", data);

    return data;
}

- (NSData *)printReadyRequest:(NSInteger)numCopies
{
    NSMutableData *data;
    char byteArray[MANTA_PACKET_LENGTH];
    
    [self setupPacket:byteArray command:CMD_PRINT_READY_CMD subcommand:CMD_PRINT_READY_SUB_CMD];
    
    // imageSize
    NSUInteger imageSize = self.imageData.length;
    byteArray[8] = (0xFF0000 & imageSize) >> 16;
    byteArray[9] = (0x00FF00 & imageSize) >>  8;
    byteArray[10] = 0x0000FF & imageSize;
    
    // printCount
    byteArray[11] = numCopies <= 4 ? numCopies : 4;
    
    // printMode
    byteArray[15] = 0x00;
    
    data = [NSMutableData dataWithBytes:byteArray length:MANTA_PACKET_LENGTH];
    
    NSLog(@"printReadyRequest: %@", data);
    
    return data;
}

- (NSData *)upgradeReadyRequest
{
    NSMutableData *data;
    char byteArray[MANTA_PACKET_LENGTH];
    
    [self setupPacket:byteArray command:CMD_UPGRADE_READY_CMD subcommand:CMD_UPGRADE_READY_SUB_CMD];
    
    // imageSize
    NSUInteger imageSize = self.upgradeData.length;
    byteArray[8] = (0xFF0000 & imageSize) >> 16;
    byteArray[9] = (0x00FF00 & imageSize) >>  8;
    byteArray[10] = 0x0000FF & imageSize;
    
    // dataClassification
    byteArray[11] = MantaDataClassFirmware;
    
    data = [NSMutableData dataWithBytes:byteArray length:MANTA_PACKET_LENGTH];
    
    NSLog(@"upgradeReadyRequest: %@", data);

    return data;
}

- (NSData *)setInfoRequest
{
    NSMutableData *data;
    char byteArray[MANTA_PACKET_LENGTH];
    
    [self setupPacket:byteArray command:CMD_SET_INFO_CMD subcommand:CMD_SET_INFO_SUB_CMD];
    
    byteArray[8]  = self.autoExposure;
    byteArray[9]  = self.powerOffInterval;
    byteArray[10] = self.printMode;

    data = [NSMutableData dataWithBytes:byteArray length:MANTA_PACKET_LENGTH];
    
    NSLog(@"setInfoRequest: %@", data);

    return data;
}

#pragma mark - Parsers

- (void)parseAccessoryInfo:(NSData *)payload
{
    char errorCode[]       = {0};
    char totalPrintCount[] = {0,0};
    char printMode[]       = {0};
    char batteryStatus[]   = {0};
    char autoExposure[]    = {0};
    char autoPowerOff[]    = {0};
    char macAddress[]      = {0,0,0,0,0,0};
    char fwVersion[]       = {0,0,0};
    char hwVersion[]       = {0,0,0};
    // Note: maxPayloadSize is only available on Android... not forgotten here
    
    [payload getBytes:errorCode       range:NSMakeRange( 0,1)];
    [payload getBytes:totalPrintCount range:NSMakeRange( 1,2)];
    [payload getBytes:printMode       range:NSMakeRange( 3,1)];
    [payload getBytes:batteryStatus   range:NSMakeRange( 4,1)];
    [payload getBytes:autoExposure    range:NSMakeRange( 5,1)];
    [payload getBytes:autoPowerOff    range:NSMakeRange( 6,1)];
    [payload getBytes:macAddress      range:NSMakeRange( 7,6)];
    [payload getBytes:fwVersion       range:NSMakeRange(13,3)];
    [payload getBytes:hwVersion       range:NSMakeRange(16,3)];
    
    NSData *macAddressData = [[NSData alloc] initWithBytes:macAddress length:6];
    NSUInteger printCount = totalPrintCount[0] << 8 | totalPrintCount[1];
    NSUInteger firmwareVersion = fwVersion[0] << 16 | fwVersion[1] << 8 | fwVersion[2];
    NSUInteger hardwareVersion = hwVersion[0] << 16 | hwVersion[1] << 8 | hwVersion[2];
    
    NSLog(@"\n\nAccessoryInfo:\n\terrorCode: %@  \n\ttotalPrintCount: 0x%04x  \n\tprintMode: %@  \n\tbatteryStatus: 0x%x => %d percent  \n\tautoExposure: %@  \n\tautoPowerOff: %@  \n\tmacAddress: %@  \n\tfwVersion: 0x%06x  \n\thwVersion: 0x%06x",
          [MPBTSprocket errorString:errorCode[0]],
          printCount,
          [MPBTSprocket printModeString:printMode[0]],
          batteryStatus[0], batteryStatus[0],
          [MPBTSprocket autoExposureString:autoExposure[0]],
          [MPBTSprocket autoPowerOffIntervalString:autoPowerOff[0]],
          [MPBTSprocket macAddress:macAddressData],
          firmwareVersion,
          hardwareVersion);
    
    if (MantaErrorNoError == errorCode[0]) {
        _totalPrintCount = printCount;
        _batteryStatus = batteryStatus[0];
        _macAddress = macAddressData;
        _firmwareVersion = firmwareVersion;
        _hardwareVersion = hardwareVersion;
        
        // purposely bypass the setters for these properties
        _printMode = printMode[0];
        _autoExposure = autoExposure[0];
        _powerOffInterval = autoPowerOff[0];
    }
}

- (void)parseMantaResponse:(NSData *)data
{
    char startCode[2]    = {0,0};
    char customerCode[2] = {0,0};
    char hostId[1]       = {0};
    char productCode[1]  = {0};
    char cmdId[1]        = {0};
    char subCmdId[1]     = {0};
    char payload[26];    memset(payload, 0, sizeof(*payload));
           
    [data getBytes:startCode range:NSMakeRange(0, 2)];
    [data getBytes:customerCode range:NSMakeRange(2,2)];
    [data getBytes:hostId range:NSMakeRange(4,1)];
    [data getBytes:productCode range:NSMakeRange(5,1)];
    [data getBytes:cmdId range:NSMakeRange(6,1)];
    [data getBytes:subCmdId range:NSMakeRange(7,1)];
    [data getBytes:payload range:NSMakeRange(8,26)];
    
    NSData *payloadData = [[NSData alloc] initWithBytes:payload length:26];
    
    if (RESP_START_OF_SEND_ACK_CMD     == cmdId[0]  &&
        RESP_START_OF_SEND_ACK_SUB_CMD == subCmdId[0]) {
        NSLog(@"\n\nStartOfSendAck: %@", data);
        NSLog(@"\tPayload Classification: %@", [MPBTSprocket dataClassificationString:payload[0]]);
        NSLog(@"\tError: %@\n\n", [MPBTSprocket errorString:payload[1]]);
        
// TODO: Remove MFI workaround
if (MantaErrorNoError == payload[1]  ||  MantaErrorBusy == payload[1]) {
            if (MantaDataClassImage == payload[0]) {
                
                NSAssert( nil != self.imageData, @"No image data");
                MPBTSessionController *session = [MPBTSessionController sharedController];
                [session writeData:self.imageData];
                
            } else if (MantaDataClassFirmware == payload[0]) {
                
                NSAssert( nil != self.upgradeData, @"No upgrade data");
                MPBTSessionController *session = [MPBTSessionController sharedController];
                [session writeData:self.upgradeData];
            }
        } else {
            NSLog(@"Error returned in StartOfSendAck: %@", [MPBTSprocket errorString:payload[1]]);
        }
        
        // let any callers know the process is finished
        if (MantaDataClassImage == payload[0]) {
            if (self.delegate  &&  [self.delegate respondsToSelector:@selector(didSendPrintData:percentageComplete:error:)]) {
                [self.delegate didSendPrintData:self percentageComplete:0 error:payload[1]];
            }
        } else if (MantaDataClassFirmware == payload[0]) {
            if (self.delegate  &&  [self.delegate respondsToSelector:@selector(didSendDeviceUpgradeData:percentageComplete:error:)]) {
                [self.delegate didSendDeviceUpgradeData:self percentageComplete:0 error:payload[1]];
            }
        }
    } else if (RESP_END_OF_RECEIVE_ACK_CMD == cmdId[0]  &&
               RESP_END_OF_RECEIVE_ACK_SUB_CMD == subCmdId[0]) {
        NSLog(@"\n\nEndOfReceiveAck: %@", data);
        NSLog(@"\tPayload Classification: %@\n\n", [MPBTSprocket dataClassificationString:payload[0]]);
        
        // let any callers know the process is finished
        if (MantaDataClassImage == payload[0]) {
            if (self.delegate  &&  [self.delegate respondsToSelector:@selector(didFinishSendingPrint:)]) {
                [self.delegate didFinishSendingPrint:self];
            }
        } else if (MantaDataClassFirmware == payload[0]) {
            if (self.delegate  &&  [self.delegate respondsToSelector:@selector(didFinishSendingDeviceUpgrade:)]) {
                [self.delegate didFinishSendingDeviceUpgrade:self];
            }
        }
        
    } else if (RESP_ACCESSORY_INFO_ACK_CMD == cmdId[0]  &&
               RESP_ACCESSORY_INFO_ACK_SUB_CMD == subCmdId[0]) {
        NSLog(@"\n\nAccessoryInfoAck: %@\n\n", data);
        [self parseAccessoryInfo:payloadData];
        
        if (self.delegate  &&  [self.delegate respondsToSelector:@selector(didRefreshMantaInfo:error:)]) {
            [self.delegate didRefreshMantaInfo:self error:payload[1]];
        }
        
    } else if (RESP_PRINT_START_CMD == cmdId[0]  &&
               RESP_PRINT_START_SUB_CMD == subCmdId[0]) {
        NSLog(@"\n\nPrintStart: %@\n\n", data);

        if (self.delegate  &&  [self.delegate respondsToSelector:@selector(didStartPrinting:)]) {
            [self.delegate didStartPrinting:self];
        }
    } else if (RESP_ERROR_MESSAGE_ACK_CMD == cmdId[0]  &&
               RESP_ERROR_MESSAGE_ACK_SUB_CMD == subCmdId[0]) {
        NSLog(@"\n\nErrorMessageAck %@", data);
        NSLog(@"\tError: %@\n\n", [MPBTSprocket errorString:payload[0]]);
        
        if (self.delegate  &&  [self.delegate respondsToSelector:@selector(didReceiveError:error:)]) {
            [self.delegate didReceiveError:self error:payload[0]];
        }
    } else if (RESP_UPGRADE_ACK_CMD == cmdId[0]  &&
               RESP_UPGRADE_ACK_SUB_CMD == subCmdId[0]) {
        NSLog(@"\n\nUpgradeAck %@", data);
        NSLog(@"\tUpgrade status: %@\n\n", [MPBTSprocket upgradeStatusString:payload[0]]);
        
        if (self.delegate  &&  [self.delegate respondsToSelector:@selector(didChangeDeviceUpgradeStatus:status:)]) {
            [self.delegate didChangeDeviceUpgradeStatus:self status:payload[0]];
        }
    } else {
        NSLog(@"\n\nUnrecognized response: %@\n\n", data);
    }
}

#pragma mark - Accessory Data Listeners

- (void)_sessionDataReceived:(NSNotification *)notification
{
    MPBTSessionController *sessionController = (MPBTSessionController *)[notification object];
    NSArray *packets = [sessionController getPackets];
    
    for (NSData *packet in packets) {
        [self parseMantaResponse:packet];
    }
}

- (void)_sessionDataSent:(NSNotification *)notification
{
    NSInteger bytesWritten = [[notification.userInfo objectForKey:MPBTSessionDataBytesWritten] integerValue];
    long long totalBytesWritten = [[notification.userInfo objectForKey:MPBTSessionDataTotalBytesWritten] longLongValue];
    long long totalBytes = self.imageData ? self.imageData.length : self.upgradeData.length;
    NSInteger percentageComplete = ((float)totalBytesWritten/(float)totalBytes) * 100;
    
    if (self.imageData) {
        if (self.delegate  &&  [self.delegate respondsToSelector:@selector(didSendPrintData:percentageComplete:error:)]) {
            [self.delegate didSendPrintData:self percentageComplete:percentageComplete error:nil];
        }
    } else if (self.upgradeData) {
        if (self.delegate  &&  [self.delegate respondsToSelector:@selector(didSendDeviceUpgradeData:percentageComplete:error:)]) {
            [self.delegate didSendDeviceUpgradeData:self percentageComplete:percentageComplete error:nil];
        }
    }
    
    if (totalBytes - totalBytesWritten <= 0) {
        self.upgradeData = nil;
        self.imageData = nil;
    }
}

#pragma mark - Accessory Event Listeners

- (void)_accessoryDidConnect:(NSNotification *)notification {
    //    EAAccessory *connectedAccessory = [[notification userInfo] objectForKey:EAAccessoryKey];
    //    [self.accessories addObject:connectedAccessory];
    //[self didPressRefreshButton:nil];
    NSLog(@"Accessory connected");
}

- (void)_accessoryDidDisconnect:(NSNotification *)notification {
    //    EAAccessory *disconnectedAccessory = [[notification userInfo] objectForKey:EAAccessoryKey];
    //[self didPressRefreshButton:nil];
    NSLog(@"Accessory disconnected");
    if (self.imageData) {
        if (self.delegate  &&  [self.delegate respondsToSelector:@selector(didSendPrintData:percentageComplete:error:)]) {
            [self.delegate didSendPrintData:self percentageComplete:0 error:MantaErrorDataError];
        }
    } else if (self.upgradeData) {
        if (self.delegate  &&  [self.delegate respondsToSelector:@selector(didChangeDeviceUpgradeStatus:status:)]) {
            [self.delegate didChangeDeviceUpgradeStatus:self status:MantaUpgradeStatusFail];
        }
    }
    
    self.imageData = nil;
    self.upgradeData = nil;
}

#pragma mark - Constant Helpers

+ (NSString *)macAddress:(NSData *)data
{
    NSUInteger dataLength = [data length];
    NSMutableString *string = [NSMutableString stringWithCapacity:dataLength*3 - 1];
    const unsigned char *dataBytes = [data bytes];
    for (NSInteger idx = 0; idx < dataLength; ++idx) {
        [string appendFormat:@"%02x", dataBytes[idx]];
        if (idx+1 != dataLength) {
            [string appendString:@":"];
        }
    }
    
    return string;
}

+ (BOOL)supportedAccessory:(EAAccessory *)accessory
{
    NSString *protocolString = [[MPBTSprocket sharedInstance] supportedProtocolString:accessory];

    return (nil != protocolString);
}

+ (NSString *)autoExposureString:(MantaAutoExposure)exp
{
    NSString *expString;
    
    switch (exp) {
        case MantaAutoExposureOff:
            expString = @"MantaAutoExposureOff";
            break;
        case MantaAutoExposureOn:
            expString = @"MantaAutoExposureOn";
            break;
            
        default:
            expString = [NSString stringWithFormat:@"Unrecognized auto exposure: %d", exp];
            break;
    };
    
    return expString;
}

+ (NSString *)autoPowerOffIntervalString:(MantaAutoPowerOffInterval)interval
{
    NSString *intervalString;
    
    switch (interval) {
        case MantaAutoOffThreeMin:
            intervalString = @"MantaAutoOffThreeMin";
            break;
        case MantaAutoOffFiveMin:
            intervalString = @"MantaAutoOffFiveMin";
            break;
        case MantaAutoOffTenMin:
            intervalString = @"MantaAutoOffTenMin";
            break;
        case MantaAutoOffAlwaysOn:
            intervalString = @"MantaAutoOffAlwaysOn";
            break;
            
        default:
            intervalString = [NSString stringWithFormat:@"Unrecognized interval: %d", interval];
            break;
    };
    
    return intervalString;
}

+ (NSString *)printModeString:(MantaPrintMode)mode
{
    NSString *modeString;
    
    switch (mode) {
        case MantaPrintModePaperFull:
            modeString = @"MantaPrintModePaperFull";
            break;
        case MantaPrintModeImageFull:
            modeString = @"MantaPrintModeImageFull";
            break;
            
        default:
            modeString = [NSString stringWithFormat:@"Unrecognized print mode: %d", mode];
            break;
    };
    
    return modeString;
}

+ (NSString *)dataClassificationString:(MantaDataClassification)class
{
    NSString *classString;
    
    switch (class) {
        case MantaDataClassImage:
            classString = @" MantaDataClassImage";
            break;
        case MantaDataClassTMD:
            classString = @"MantaDataClassTMD";
            break;
        case MantaDataClassFirmware:
            classString = @"MantaDataClassFirmware";
            break;
            
        default:
            classString = [NSString stringWithFormat:@"Unrecognized classification: %d", class];
            break;
    };
    
    return classString;
}

+ (NSString *)upgradeStatusString:(MantaUpgradeStatus)status
{
    NSString *statusString;
    
    switch (status) {
        case MantaUpgradeStatusStart:
            statusString = @"MantaUpgradeStatusStart";
            break;
        case MantaUpgradeStatusFinish:
            statusString = @"MantaUpgradeStatusFinish";
            break;
        case MantaUpgradeStatusFail:
            statusString = @"MantaUpgradeStatusFail";
            break;
            
        default:
            statusString = [NSString stringWithFormat:@"Unrecognized status: %d", status];
            break;
    };
    
    return statusString;
}

+ (NSString *)errorString:(MantaError)error
{
    NSString *errString;
    
    switch (error) {
        case MantaErrorNoError:
            errString = @"MantaErrorNoError";
            break;
        case MantaErrorBusy:
            errString = @"MantaErrorBusy";
            break;
        case MantaErrorPaperJam:
            errString = @"MantaErrorPaperJam";
            break;
        case MantaErrorPaperEmpty:
            errString = @"MantaErrorPaperEmpty";
            break;
        case MantaErrorPaperMismatch:
            errString = @"MantaErrorPaperMismatch";
            break;
        case MantaErrorDataError:
            errString = @"MantaErrorDataError";
            break;
        case MantaErrorCoverOpen:
            errString = @"MantaErrorCoverOpen";
            break;
        case MantaErrorSystemError:
            errString = @"MantaErrorSystemError";
            break;
        case MantaErrorBatteryLow:
            errString = @"MantaErrorBatteryLow";
            break;
        case MantaErrorBatteryFault:
            errString = @"MantaErrorBatteryFault";
            break;
        case MantaErrorHighTemperature:
            errString = @"MantaErrorHighTemperature";
            break;
        case MantaErrorLowTemperature:
            errString = @"MantaErrorLowTemperature";
            break;
        case MantaErrorCoolingMode:
            errString = @"MantaErrorCoolingMode";
            break;
        case MantaErrorWrongCustomer:
            errString = @"MantaErrorWrongCustomer";
            break;
            
        default:
            errString = [NSString stringWithFormat:@"Unrecognized Error: %d", error];
            break;
    };
    
    return errString;
}

#pragma mark -
#pragma mark Scale and crop image

- (UIImage*)imageByScalingAndCroppingForSize:(UIImage *)image targetSize:(CGSize)targetSize
{
    UIImage *sourceImage = image;
    UIImage *newImage = nil;
    CGSize imageSize = sourceImage.size;
    CGFloat width = imageSize.width;
    CGFloat height = imageSize.height;
    CGFloat targetWidth = targetSize.width;
    CGFloat targetHeight = targetSize.height;
    CGFloat scaleFactor = 0.0;
    CGFloat scaledWidth = targetWidth;
    CGFloat scaledHeight = targetHeight;
    CGPoint thumbnailPoint = CGPointMake(0.0,0.0);
    
    if (CGSizeEqualToSize(imageSize, targetSize) == NO)
    {
        CGFloat widthFactor = targetWidth / width;
        CGFloat heightFactor = targetHeight / height;
        
        if (widthFactor > heightFactor)
        {
            scaleFactor = widthFactor; // scale to fit height
        }
        else
        {
            scaleFactor = heightFactor; // scale to fit width
        }
        
        scaledWidth  = width * scaleFactor;
        scaledHeight = height * scaleFactor;
        
        // center the image
        if (widthFactor > heightFactor)
        {
            thumbnailPoint.y = (targetHeight - scaledHeight) * 0.5;
        }
        else
        {
            if (widthFactor < heightFactor)
            {
                thumbnailPoint.x = (targetWidth - scaledWidth) * 0.5;
            }
        }
    }
    
    UIGraphicsBeginImageContext(targetSize); // this will crop
    
    CGRect thumbnailRect = CGRectZero;
    thumbnailRect.origin = thumbnailPoint;
    thumbnailRect.size.width  = scaledWidth;
    thumbnailRect.size.height = scaledHeight;
    
    [sourceImage drawInRect:thumbnailRect];
    
    newImage = UIGraphicsGetImageFromCurrentImageContext();
    
    if(newImage == nil)
    {
        NSLog(@"could not scale image");
    }
    
    //pop the context to get back to the default
    UIGraphicsEndImageContext();
    
    return newImage;
}
@end
