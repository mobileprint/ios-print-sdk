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
#import "NSBundle+MPLocalizable.h"
#import "MP.h"

const char MANTA_PACKET_LENGTH = 34;

static const NSString *kPolaroidProtocol = @"com.polaroid.mobileprinter";
static const NSString *kHpProtocol = @"com.hp.protocol";
static const NSString *kFirmwareUpdatePath = @"https://s3-us-west-2.amazonaws.com/sprocket-fw-updates-2/fw_release.json";

static const NSString *kMPBTFirmwareVersionKey = @"fw_version";
static const NSString *kMPBTTmdVersionKey = @"tmd_version";
static const NSString *kMPBTModelNumberKey = @"model_number";
static const NSString *kMPBTHardwareVersion = @"hw_version";

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

@interface MPBTSprocket () <NSURLSessionDownloadDelegate>

@property (strong, nonatomic) MPBTSessionController *session;
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

        self.supportedProtocols = @[kHpProtocol/*kPolaroidProtocol, @"com.lge.pocketphoto"*/];
        
        // watch for received data from the accessory
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_sessionDataReceived:) name:MPBTSessionDataReceivedNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_sessionDataSent:) name:MPBTSessionDataSentNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_accessoryDidDisconnect:) name:MPBTSessionAccessoryDisconnectedNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_sessionStreamError:) name:MPBTSessionStreamErrorNotification object:nil];
        [[EAAccessoryManager sharedAccessoryManager] registerForLocalNotifications];
    }
    
    return self;
}

- (void)refreshInfo
{
    [self.session writeData:[self accessoryInfoRequest]];
}

- (void)printImage:(UIImage *)image numCopies:(NSInteger)numCopies
{
    UIImage *scaledImage = [self imageByScalingAndCroppingForSize:image targetSize:CGSizeMake(640,960)];
    self.imageData = UIImageJPEGRepresentation(scaledImage, 0.9);
    
    [self.session writeData:[self printReadyRequest:numCopies]];
}

- (void)printItem:(MPPrintItem *)printItem numCopies:(NSInteger)numCopies
{
    UIImage *asset = ((NSArray*)printItem.printAsset)[0];
    UIImage *image = [self imageByScalingAndCroppingForSize:asset targetSize:CGSizeMake(640,960)];
    self.imageData = UIImageJPEGRepresentation(image, 0.9);
    
    [self.session writeData:[self printReadyRequest:numCopies]];
}

- (void)reflash
{
    [MPBTSprocket latestFirmwarePath:self.protocolString forExistingVersion:self.firmwareVersion completion:^(NSString *fwPath) {
        
        NSURLSession *httpSession = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration] delegate:self delegateQueue: [NSOperationQueue mainQueue]];
        
        [[httpSession downloadTaskWithURL:[NSURL URLWithString:fwPath]] resume];
    }];
}

#pragma mark - NSURLSessionDownloadDelegate

- (void)URLSession:(NSURLSession *)session
      downloadTask:(NSURLSessionDownloadTask *)downloadTask
 didResumeAtOffset:(int64_t)fileOffset
expectedTotalBytes:(int64_t)expectedTotalBytes
{
    MPLogDebug(@"Resuming firmware download");
}

- (void)URLSession:(NSURLSession *)session
      downloadTask:(NSURLSessionDownloadTask *)downloadTask
      didWriteData:(int64_t)bytesWritten
 totalBytesWritten:(int64_t)totalBytesWritten
totalBytesExpectedToWrite:(int64_t)totalBytesExpectedToWrite
{
    MPLogDebug(@"%d of %d bytes", totalBytesWritten, totalBytesExpectedToWrite);
    if (self.delegate  &&  [self.delegate respondsToSelector:@selector(didDownloadDeviceUpgradeData:percentageComplete:)]) {
        NSInteger percentageComplete = ((float)totalBytesWritten/(float)totalBytesExpectedToWrite) * 100;
        [self.delegate didDownloadDeviceUpgradeData:self percentageComplete:percentageComplete];
    }
}

- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didFinishDownloadingToURL:(NSURL *)location
{
    MPLogInfo(@"Finished downloading firmware");
    self.upgradeData = [NSData dataWithContentsOfURL:location];
    [self.session writeData:[self upgradeReadyRequest]];
}

- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error
{
    if (nil != error) {
        MPLogError(@"Error receiving firmware upgrade file: %@", error);
        if (self.delegate  &&  [self.delegate respondsToSelector:@selector(didChangeDeviceUpgradeStatus:status:)]) {
            [self.delegate didChangeDeviceUpgradeStatus:self status:MantaUpgradeStatusDownloadFail];
        }
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
        if (!success) {
            MPLogError(@"Failed to open session with device");
            if (self.delegate  &&  [self.delegate respondsToSelector:@selector(didReceiveError:error:)]) {
                [self.delegate didReceiveError:self error:MantaErrorNoSession];
            }
        }
    } else {
        MPLogError(@"Can't open a session with a nil device / accessory");
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
        MPLogError(@"Unsupported device");
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
    return [MPBTSprocket displayNameForAccessory:self.accessory];
}

- (NSDictionary *)analytics
{
    NSMutableDictionary *dictionary = [[NSMutableDictionary alloc] init];
    
    [dictionary setValue:[MPBTSprocket macAddress:self.macAddress] forKey:kMPPrinterId];
    [dictionary setValue:[MPBTSprocket displayNameForAccessory:self.accessory] forKey:kMPPrinterDisplayName];
    [dictionary setValue:[NSString stringWithFormat:@"HP sprocket"] forKey:kMPPrinterMakeAndModel];
    
    NSDictionary *customData = @{ kMPBTFirmwareVersionKey : [MPBTSprocket version:self.firmwareVersion],
                                  kMPBTTmdVersionKey      : [MPBTSprocket version:self.hardwareVersion],
                                  kMPBTModelNumberKey     : self.accessory.modelNumber,
                                  kMPBTHardwareVersion    : self.accessory.hardwareRevision };
    [dictionary setValue:customData forKey:kMPCustomAnalyticsKey];
    
    return dictionary;
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
    
    if ([self.protocolString isEqualToString:kPolaroidProtocol]) {
        packet[2] = POLAROID_CUSTOMER_CODE_BYTE_1;
        packet[3] = POLAROID_CUSTOMER_CODE_BYTE_2;
    } else if ([self.protocolString isEqualToString:kHpProtocol]){
        packet[2] = HP_CUSTOMER_CODE_BYTE_1;
        packet[3] = HP_CUSTOMER_CODE_BYTE_2;
    } else {
        MPLogError(@"Unexpected protocol string: %@, defaulting to HP customer code", self.protocolString);
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

    MPLogDebug(@"accessoryInfoRequest: %@", data);

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
    
    MPLogDebug(@"printReadyRequest: %@", data);
    
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
    
    MPLogDebug(@"upgradeReadyRequest: %@", data);

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
    
    MPLogDebug(@"setInfoRequest: %@", data);

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
    
    MPLogDebug(@"\n\nAccessoryInfo:\n\terrorCode: %@  \n\ttotalPrintCount: 0x%04x  \n\tprintMode: %@  \n\tbatteryStatus: 0x%x => %d percent  \n\tautoExposure: %@  \n\tautoPowerOff: %@  \n\tmacAddress: %@  \n\tfwVersion: 0x%06x  \n\thwVersion: 0x%06x",
          [MPBTSprocket errorTitle:errorCode[0]],
          printCount,
          [MPBTSprocket printModeString:printMode[0]],
          batteryStatus[0], batteryStatus[0],
          [MPBTSprocket autoExposureString:autoExposure[0]],
          [MPBTSprocket autoPowerOffIntervalString:autoPowerOff[0]],
          [MPBTSprocket macAddress:macAddressData],
          firmwareVersion,
          hardwareVersion);
    
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
        MPLogDebug(@"\n\nStartOfSendAck: %@", data);
        MPLogDebug(@"\tPayload Classification: %@", [MPBTSprocket dataClassificationString:payload[0]]);
        MPLogDebug(@"\tError: %@\n\n", [MPBTSprocket errorTitle:payload[1]]);
        
        if (MantaErrorNoError == payload[1]  ||
            (MantaErrorBusy == payload[1]  &&  MantaDataClassFirmware == payload[0])) {
            if (MantaDataClassImage == payload[0]) {
                
                NSAssert( nil != self.imageData, @"No image data");
                MPBTSessionController *session = [MPBTSessionController sharedController];
                [session writeData:self.imageData];
                
            } else if (MantaDataClassFirmware == payload[0]) {
                if (nil == self.upgradeData) {
                    if (self.delegate  &&  [self.delegate respondsToSelector:@selector(didChangeDeviceUpgradeStatus:status:)]) {
                        [self.delegate didChangeDeviceUpgradeStatus:self status:MantaUpgradeStatusDownloadFail];
                    }
                } else {
                    MPBTSessionController *session = [MPBTSessionController sharedController];
                    [session writeData:self.upgradeData];
                }
            }
        } else {
            MPLogDebug(@"Error returned in StartOfSendAck: %@", [MPBTSprocket errorTitle:payload[1]]);
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
        MPLogDebug(@"\n\nEndOfReceiveAck: %@", data);
        MPLogDebug(@"\tPayload Classification: %@\n\n", [MPBTSprocket dataClassificationString:payload[0]]);
        
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
        MPLogDebug(@"\n\nAccessoryInfoAck: %@\n\n", data);
        [self parseAccessoryInfo:payloadData];
        NSUInteger error = payload[0];
        
        if (self.delegate  &&  [self.delegate respondsToSelector:@selector(didRefreshMantaInfo:error:)]) {
            [self.delegate didRefreshMantaInfo:self error:error];
        }
        
        if (self.delegate  &&  [self.delegate respondsToSelector:@selector(didCompareWithLatestFirmwareVersion:needsUpgrade:)]) {
            if (MantaErrorNoError == error) {
                [MPBTSprocket latestFirmwareVersion:self.protocolString forExistingVersion:self.firmwareVersion completion:^(NSUInteger fwVersion) {
                    BOOL needsUpgrade = NO;
                    if (fwVersion > self.firmwareVersion) {
                        needsUpgrade = YES;
                    }
                    [self.delegate didCompareWithLatestFirmwareVersion:self needsUpgrade:needsUpgrade];
                }];
            } else {
                [self.delegate didCompareWithLatestFirmwareVersion:self needsUpgrade:NO];
            }
        }
    } else if (RESP_PRINT_START_CMD == cmdId[0]  &&
               RESP_PRINT_START_SUB_CMD == subCmdId[0]) {
        MPLogDebug(@"\n\nPrintStart: %@\n\n", data);

        if (self.delegate  &&  [self.delegate respondsToSelector:@selector(didStartPrinting:)]) {
            [self.delegate didStartPrinting:self];
        }
    } else if (RESP_ERROR_MESSAGE_ACK_CMD == cmdId[0]  &&
               RESP_ERROR_MESSAGE_ACK_SUB_CMD == subCmdId[0]) {
        MPLogDebug(@"\n\nErrorMessageAck %@", data);
        MPLogDebug(@"\tError: %@\n\n", [MPBTSprocket errorTitle:payload[0]]);
        
        if (self.delegate  &&  [self.delegate respondsToSelector:@selector(didReceiveError:error:)]) {
            [self.delegate didReceiveError:self error:payload[0]];
        }
    } else if (RESP_UPGRADE_ACK_CMD == cmdId[0]  &&
               RESP_UPGRADE_ACK_SUB_CMD == subCmdId[0]) {
        MPLogDebug(@"\n\nUpgradeAck %@", data);
        MPLogDebug(@"\tUpgrade status: %@\n\n", [MPBTSprocket upgradeStatusString:payload[0]]);
        
        if (self.delegate  &&  [self.delegate respondsToSelector:@selector(didChangeDeviceUpgradeStatus:status:)]) {
            [self.delegate didChangeDeviceUpgradeStatus:self status:payload[0]];
        }
    } else {
        MPLogDebug(@"\n\nUnrecognized response: %@\n\n", data);
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

- (void)_sessionStreamError:(NSNotification *)notification {
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

- (void)_accessoryDidDisconnect:(NSNotification *)notification {
    if (self.delegate  &&  [self.delegate respondsToSelector:@selector(didReceiveError:error:)]) {
        [self.delegate didReceiveError:self error:MantaErrorNoSession];
    }
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

+ (NSString *)version:(NSUInteger)version
{
    NSUInteger fw1, fw2, fw3;

    fw1 = (0xFF0000 & version) >> 16;
    fw2 = (0x00FF00 & version) >>  8;
    fw3 =  0x0000FF & version;
 
    return [NSString stringWithFormat:@"%d.%d.%d", fw1, fw2, fw3];
}

+ (BOOL)supportedAccessory:(EAAccessory *)accessory
{
    NSString *protocolString = [[MPBTSprocket sharedInstance] supportedProtocolString:accessory];

    return (nil != protocolString);
}

+ (NSString *)displayNameForAccessory:(EAAccessory *)accessory
{
    NSString *name = accessory.name;
    if ([name isEqualToString:@"HP Sprocket Photo Printer"]) {
        name = @"HP sprocket";
    }
    return [NSString stringWithFormat:@"%@ (%@)", name, accessory.serialNumber];
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
            intervalString = MPLocalizedString(@"3 minutes", @"The printer will shut off after 3 minutes");
            break;
        case MantaAutoOffFiveMin:
            intervalString = MPLocalizedString(@"5 minutes", @"The printer will shut off after 5 minutes");
            break;
        case MantaAutoOffTenMin:
            intervalString = MPLocalizedString(@"10 minutes", @"The printer will shut off after 10 minutes");
            break;
        case MantaAutoOffAlwaysOn:
            intervalString = MPLocalizedString(@"Always On", @"The printer will never shut off");
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

+ (NSString *)errorTitle:(MantaError)error
{
    NSString *errString;
    
    switch (error) {
        case MantaErrorNoError:
            errString = MPLocalizedString(@"Ready", @"Message given when sprocket has no known error");
            break;
        case MantaErrorBusy:
            errString = MPLocalizedString(@"Sprocket Printer in Use", @"Message given when sprocket cannot print due to being in use.");
            break;
        case MantaErrorPaperJam:
            errString = MPLocalizedString(@"Paper has Jammed", @"Message given when sprocket cannot print due to having a paper jam");
            break;
        case MantaErrorPaperEmpty:
            errString = MPLocalizedString(@"Out of Paper", @"Message given when sprocket cannot print due to having no paper");
            break;
        case MantaErrorPaperMismatch:
            errString = MPLocalizedString(@"Incorrect Paper Type", @"Message given when sprocket cannot print due to being loaded with the wrong kind of paper");
            break;
        case MantaErrorDataError:
            errString = MPLocalizedString(@"Photo Unsupported", @"Message given when sprocket cannot print due to an error with the image data.");
            break;
        case MantaErrorCoverOpen:
            errString = MPLocalizedString(@"Paper Cover Open", @"Message given when sprocket cannot print due to the cover being open");
            break;
        case MantaErrorSystemError:
            errString = MPLocalizedString(@"System Error Occured", @"Message given when sprocket cannot print due to a system error");
            break;
        case MantaErrorBatteryLow:
            errString = MPLocalizedString(@"Battery Low", @"Message given when sprocket cannot print due to having a low battery");;
            break;
        case MantaErrorBatteryFault:
            errString = MPLocalizedString(@"Battery Error", @"Message given when sprocket cannot print due to having an error related to the battery.");
            break;
        case MantaErrorHighTemperature:
            errString = MPLocalizedString(@"Sprocket is Warm", @"Message given when sprocket cannot print due to being too hot");
            break;
        case MantaErrorLowTemperature:
            errString = MPLocalizedString(@"Sprocket is Cold", @"Message given when sprocket cannot print due to being too cold");
            break;
        case MantaErrorCoolingMode:
            errString = MPLocalizedString(@"Cooling Down...", @"Message given when sprocket cannot print due to bing in a cooling mode");
            break;
        case MantaErrorWrongCustomer:
            errString = MPLocalizedString(@"Error", @"Message given when sprocket cannot print due to not recognizing data from our app");
            break;
        case MantaErrorNoSession:
            errString = MPLocalizedString(@"Sprocket Printer Not Connected", @"Message given when sprocket cannot be reached");
            break;
            
        default:
            errString = MPLocalizedString(@"Unrecognized Error", @"Message given when sprocket has an unrecgonized error");
            break;
    };
    
    return errString;
}

+ (NSString *)errorDescription:(MantaError)error
{
    NSString *errString;
    
    switch (error) {
        case MantaErrorNoError:
            errString = MPLocalizedString(@"Sprocket is ready to print.", @"Message given when sprocket has no known error");
            break;
        case MantaErrorBusy:
            errString = MPLocalizedString(@"The sprocket printer is already processing a job. Please wait to resend photo.", @"Message given when sprocket cannot print due to being in use.");
            break;
        case MantaErrorPaperJam:
            errString = MPLocalizedString(@"Clear paper jam and restart the printer by pressing and holding the power button.", @"Message given when sprocket cannot print due to having a paper jam");
            break;
        case MantaErrorPaperEmpty:
            errString = MPLocalizedString(@"Load paper with the included Smartsheet to continue printing.", @"Message given when sprocket cannot print due to having no paper");
            break;
        case MantaErrorPaperMismatch:
            errString = MPLocalizedString(@"Use HP branded ZINK Photo Paper. Load the blue Smartsheet, barcode down, and restart the printer. ", @"Message given when sprocket cannot print due to being loaded with the wrong kind of paper");
            break;
        case MantaErrorDataError:
            errString = MPLocalizedString(@"There was an error sending your photo. The photo format may not be supported on this printer. Choose another image. ", @"Message given when sprocket cannot print due to an error with the image data.");
            break;
        case MantaErrorCoverOpen:
            errString = MPLocalizedString(@"Close the cover to proceed.", @"Message given when sprocket cannot print due to the cover being open");
            break;
        case MantaErrorSystemError:
            errString = MPLocalizedString(@"Due to a system error, restart sprocket to continue printing.", @"Message given when sprocket cannot print due to a system error");
            break;
        case MantaErrorBatteryLow:
            errString = MPLocalizedString(@"Connect your sprocket to a power source to continue use.", @"Message given when sprocket cannot print due to having a low battery");
            break;
        case MantaErrorBatteryFault:
            errString = MPLocalizedString(@"A battery error has occured. Restart Sprocket to continue printing.", @"Message given when sprocket cannot print due to having an error related to the battery.");
            break;
        case MantaErrorHighTemperature:
            errString = MPLocalizedString(@"Printing is diabled until a lower temperature is reached. Wait to send another photo.", @"Message given when sprocket cannot print due to being too hot");
            break;
        case MantaErrorLowTemperature:
            errString = MPLocalizedString(@"Printing is diabled until a higher temperature is reached. Wait to send another photo.", @"Message given when sprocket cannot print due to being too cold");
            break;
        case MantaErrorCoolingMode:
            errString = MPLocalizedString(@"Sprocket needs to cool down before printing another job. Wait to send another photo.", @"Message given when sprocket cannot print due to bing in a cooling mode");
            break;
        case MantaErrorWrongCustomer:
            errString = MPLocalizedString(@"The device is not recognized.", @"Message given when sprocket cannot print due to not recognizing data from our app");
            break;
            
        case MantaErrorNoSession:
            errString = MPLocalizedString(@"Make sure the sprocket printer is on and bluetooth connected.", @"Message given when the printer can't be contacted.");
            break;

        default:
            errString = MPLocalizedString(@"Unrecognized Error", @"Message given when sprocket has an unrecgonized error");
            break;
    };
    
    return errString;
}

+ (void)getFirmwareUpdateInfo:(void (^)(NSDictionary *fwUpdateInfo))completion
{
    NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];
    config.URLCache = nil;
    NSURLSession *httpSession = [NSURLSession sessionWithConfiguration:config delegate: nil delegateQueue: [NSOperationQueue mainQueue]];
    
    [[httpSession dataTaskWithURL: [NSURL URLWithString:kFirmwareUpdatePath]
                completionHandler:^(NSData *data, NSURLResponse *response,
                                    NSError *error) {
                    NSDictionary *fwUpdateInfo = nil;
                    if (data  &&  !error) {
                        NSError *error;
                        NSDictionary *fwDictionary = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
                        if (fwDictionary) {
                            MPLogInfo(@"FW Update:  Result = %@", fwDictionary);
                            fwUpdateInfo = [fwDictionary valueForKey:@"firmware"];
                        } else {
                            MPLogError(@"FW Update:  Parse Error = %@", error);
                            NSString *returnString = [[NSString alloc] initWithBytes:[data bytes] length:[data length] encoding:NSUTF8StringEncoding];
                            MPLogInfo(@"FW Update:  Return string = %@", returnString);
                        }
                    } else {
                        MPLogError(@"FW Update Info failure: %@, data: %@", error, data);
                    }
                    
                    if (completion) {
                        completion(fwUpdateInfo);
                    }
                }] resume];
}

+ (NSUInteger)fwVersionFromString:(NSString *)strVersion
{
    NSUInteger fwVersion = 0;
    
    if (![strVersion isEqualToString:@"none"]) {
        NSArray *bytes = [strVersion componentsSeparatedByString:@"."];
        NSInteger topIdx = bytes.count-1;
        for (NSInteger idx = topIdx; idx >= 0; idx--) {
            NSString *strByte = bytes[idx];
            NSInteger byte = [strByte integerValue];
            
            NSInteger shiftValue = topIdx-idx;
            fwVersion += (byte << (8 * shiftValue));
        }
    }
    
    return fwVersion;
}

+ (NSDictionary *)getCorrectFirmwareVersion:(NSArray *)fwInfo forExistingVersion:(NSUInteger)existingFwVersion
{
    NSDictionary *correctFwVersionInfo = nil;
    
    if (nil != fwInfo) {
        
        // Create a dictionary for quick look-up of dependency versions
        NSMutableDictionary *fwVersions = [[NSMutableDictionary alloc] init];
        NSUInteger length = [fwInfo count];
        NSString *strVersion = nil;
        for (int idx=0; idx<length; ++idx) {
            NSDictionary *fwVersionInfo = [fwInfo objectAtIndex:idx];
            strVersion = [fwVersionInfo objectForKey:@"fw_ver"];
            [fwVersions setObject:fwVersionInfo forKey:strVersion];
        }
        
        // Start with the latest version. Install it, or any necessary dependency
        BOOL keepChecking = YES;
        while (keepChecking) {
            NSDictionary *fwVersionInfo = [fwVersions objectForKey:strVersion];
            strVersion = [fwVersionInfo objectForKey:@"fw_ver"];
            NSUInteger fwVersion = [MPBTSprocket fwVersionFromString:strVersion];
            
            if (existingFwVersion < fwVersion) {
                // check the dependency
                NSString *dependencyStrVersion = [fwVersionInfo objectForKey:@"dependency"];
                NSUInteger dependencyFwVersion = [MPBTSprocket fwVersionFromString:dependencyStrVersion];
                if (existingFwVersion < dependencyFwVersion) {
                    strVersion = dependencyStrVersion;
                    keepChecking = YES;
                } else {
                    keepChecking = NO;
                }
            } else {
                keepChecking = NO;
            }
        }
        
        correctFwVersionInfo = [fwVersions objectForKey:strVersion];
    }
    
    return correctFwVersionInfo;
}

+ (void)latestFirmwareVersion:(NSString *)protocolString forExistingVersion:(NSUInteger)existingFwVersion completion:(void (^)(NSUInteger fwVersion))completion
{
    [MPBTSprocket getFirmwareUpdateInfo:^(NSDictionary *fwUpdateInfo){
        NSUInteger fwVersion = 0;
        NSDictionary *deviceUpdateInfo = nil;
        
        if (nil != fwUpdateInfo) {
            if ([kPolaroidProtocol isEqualToString:protocolString]) {
                deviceUpdateInfo = [fwUpdateInfo objectForKey:@"Polaroid"];
            } else {
                deviceUpdateInfo = [fwUpdateInfo objectForKey:@"HP"];
                deviceUpdateInfo = [MPBTSprocket getCorrectFirmwareVersion:deviceUpdateInfo forExistingVersion:existingFwVersion];
            }
            
            if (deviceUpdateInfo) {
                NSString *strVersion = [deviceUpdateInfo objectForKey:@"fw_ver"];
                fwVersion = [MPBTSprocket fwVersionFromString:strVersion];
            } else {
                MPLogError(@"Unrecognized firmware update info: %@", fwUpdateInfo);
            }
            
            if (completion) {
                completion(fwVersion);
            }
        }
    }];
}

+ (void)latestFirmwarePath:(NSString *)protocolString forExistingVersion:(NSUInteger)existingFwVersion completion:(void (^)(NSString *fwPath))completion
{
    [MPBTSprocket getFirmwareUpdateInfo:^(NSDictionary *fwUpdateInfo){
        NSString *fwPath = nil;
        NSDictionary *deviceUpdateInfo = nil;
        
        if (nil != fwUpdateInfo) {
            if ([kPolaroidProtocol isEqualToString:protocolString]) {
                deviceUpdateInfo = [fwUpdateInfo objectForKey:@"Polaroid"];
            } else {
                deviceUpdateInfo = [fwUpdateInfo objectForKey:@"HP"];
                deviceUpdateInfo = [MPBTSprocket getCorrectFirmwareVersion:deviceUpdateInfo forExistingVersion:existingFwVersion];
            }
            
            if (deviceUpdateInfo) {
                fwPath = [deviceUpdateInfo objectForKey:@"fw_url"];
            } else {
                MPLogError(@"Unrecognized firmware update info: %@", fwUpdateInfo);
            }
            
            if (completion) {
                completion(fwPath);
            }
        }
    }];
}

+ (NSArray *)pairedSprockets
{
    NSArray *accs = [[EAAccessoryManager sharedAccessoryManager] connectedAccessories];
    NSMutableArray *pairedDevices = [[NSMutableArray alloc] init];
    
    for (EAAccessory *accessory in accs) {
        if ([MPBTSprocket supportedAccessory:accessory]) {
            [pairedDevices addObject:accessory];
        }
    }
    
    return pairedDevices;
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
        MPLogError(@"could not scale image");
    }
    
    //pop the context to get back to the default
    UIGraphicsEndImageContext();
    
    return newImage;
}
@end
