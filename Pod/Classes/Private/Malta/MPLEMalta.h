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

extern NSString * const kMPLEMaltaUpdatedNotification;

typedef enum
{   MPLEMaltaDeviceColorWhite = 0,
    MPLEMaltaDeviceColorRed,
    MPLEMaltaDeviceColorGreen,
    MPLEMaltaDeviceColorBlue,
    MPLEMaltaDeviceColorPink,
    MPLEMaltaDeviceColorYellow,
    MPLEMaltaDeviceColorOrange,
    MPLEMaltaDeviceColorPurple,
    MPLEMaltaDeviceColorBrown,
    MPLEMaltaDeviceColorGrey,
    MPLEMaltaDeviceColorBlack
} MPLEMaltaDeviceColor;

typedef enum
{   MPLEMaltaPrinterStatusReady = 0,
    MPLEMaltaPrinterStatusPrinting,
    MPLEMaltaPrinterStatusOutOfPaper,
    MPLEMaltaPrinterStatusPrintBufferFull,
    MPLEMaltaPrinterStatusCoverOpen,
    MPLEMaltaPrinterStatusPaperJam
} MPLEMaltaPrinterStatus;

@interface MPLEMalta : NSObject

@property (strong, nonatomic) CBPeripheral *peripheral;
@property (assign, nonatomic) NSInteger companyId;
@property (assign, nonatomic) NSInteger format;
@property (assign, nonatomic) NSInteger calibratedRssi;
@property (assign, nonatomic) NSInteger connectableStatus;
@property (assign, nonatomic) MPLEMaltaDeviceColor deviceColor;
@property (assign, nonatomic) MPLEMaltaPrinterStatus printerStatus;
@property (strong, nonatomic) NSString *manufacturer;
@property (strong, nonatomic) NSString *modelNumber;
@property (strong, nonatomic) NSString *systemId;
@property (strong, nonatomic) NSString *firmwareVersion;
@property (assign, nonatomic) NSInteger batteryLevel;

+ (NSString *)deviceColorString:(MPLEMaltaDeviceColor)deviceColor;
+ (NSString *)printerStatusString:(MPLEMaltaPrinterStatus)printerStatus;

@end
