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

#import "MPLEMalta.h"
#import "NSBundle+MPLocalizable.h"

NSString * const kMPLEMaltaUpdatedNotification = @"kMPLEMaltaUpdatedNotification";

@implementation MPLEMalta

- (void) setName:(NSString *)name
{
    _name = @"Fredy's super duper sprocket";

    if ([name length]) {
        _name = name;
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:kMPLEMaltaUpdatedNotification object:self userInfo:nil];
}

- (void) setCompanyId:(NSInteger)companyId
{
    _companyId = companyId;
    [[NSNotificationCenter defaultCenter] postNotificationName:kMPLEMaltaUpdatedNotification object:self userInfo:nil];
}

- (void) setFormat:(NSInteger)format
{
    _format = format;
    [[NSNotificationCenter defaultCenter] postNotificationName:kMPLEMaltaUpdatedNotification object:self userInfo:nil];
}

- (void) setCalibratedRssi:(NSInteger)calibratedRssi
{
    _calibratedRssi = calibratedRssi;
    [[NSNotificationCenter defaultCenter] postNotificationName:kMPLEMaltaUpdatedNotification object:self userInfo:nil];
}

- (void) setConnectableStatus:(NSInteger)connectableStatus
{
    _connectableStatus = connectableStatus;
    [[NSNotificationCenter defaultCenter] postNotificationName:kMPLEMaltaUpdatedNotification object:self userInfo:nil];
}

- (void) setDeviceColor:(NSInteger)deviceColor
{
    _deviceColor = deviceColor;
    [[NSNotificationCenter defaultCenter] postNotificationName:kMPLEMaltaUpdatedNotification object:self userInfo:nil];
}

- (void) setPrinterStatus:(NSInteger)printerStatus
{
    _printerStatus = printerStatus;
    [[NSNotificationCenter defaultCenter] postNotificationName:kMPLEMaltaUpdatedNotification object:self userInfo:nil];
}

- (void) setModelNumber:(NSString *)modelNumber
{
    _modelNumber = modelNumber;
    [[NSNotificationCenter defaultCenter] postNotificationName:kMPLEMaltaUpdatedNotification object:self userInfo:nil];
}

- (void) setSystemId:(NSString *)systemId
{
    _systemId = systemId;
    [[NSNotificationCenter defaultCenter] postNotificationName:kMPLEMaltaUpdatedNotification object:self userInfo:nil];
}

- (void) setFirmwareVersion:(NSString *)firmwareVersion
{
    _firmwareVersion = firmwareVersion;
    [[NSNotificationCenter defaultCenter] postNotificationName:kMPLEMaltaUpdatedNotification object:self userInfo:nil];
}

- (void) setManufacturer:(NSString *)manufacturer
{
    _manufacturer = manufacturer;
    [[NSNotificationCenter defaultCenter] postNotificationName:kMPLEMaltaUpdatedNotification object:self userInfo:nil];
}

- (void) setBatteryLevel:(NSInteger)batteryLevel
{
    _batteryLevel = batteryLevel;
    [[NSNotificationCenter defaultCenter] postNotificationName:kMPLEMaltaUpdatedNotification object:self userInfo:nil];
}

-(NSString *)description
{
    NSString *str = [NSString stringWithFormat:@"peripheral: %@", self.peripheral];
    str = [str stringByAppendingFormat:@"\ncompanyId: %#x", self.companyId];
    str = [str stringByAppendingFormat:@"\nformat: %d", self.format];
    str = [str stringByAppendingFormat:@"\ncalibratedRssi: %#x", self.calibratedRssi];
    str = [str stringByAppendingFormat:@"\nconnectableStatus: %d", self.connectableStatus];
    str = [str stringByAppendingFormat:@"\ndeviceColor: %d", self.deviceColor];
    str = [str stringByAppendingFormat:@"\nprinterStatus: %d", self.printerStatus];
    str = [str stringByAppendingFormat:@"\nmodelNumber: %@", self.modelNumber];
    str = [str stringByAppendingFormat:@"\nsystemId: %@", self.systemId];
    str = [str stringByAppendingFormat:@"\nfirmwareVersion: %@", self.firmwareVersion];
    str = [str stringByAppendingFormat:@"\nbatteryLevel: %d", self.batteryLevel];
    str = [str stringByAppendingFormat:@"\nmanufacturer: %@", self.manufacturer];

    return str;
}

+ (NSString *)deviceColorString:(MPLEMaltaDeviceColor)deviceColor
{
    NSString *str = MPLocalizedString(@"Unrecognized Color", @"A color we don't recognize");
    
    switch (deviceColor) {
        case MPLEMaltaDeviceColorWhite:
            str = MPLocalizedString(@"White", @"The color white");
            break;
            
        case MPLEMaltaDeviceColorRed:
            str = MPLocalizedString(@"Red", @"The color red");
            break;
            
        case MPLEMaltaDeviceColorGreen:
            str = MPLocalizedString(@"Green", @"The color green");
            break;
            
        case MPLEMaltaDeviceColorBlue:
            str = MPLocalizedString(@"Blue", @"The color blue");
            break;
            
        case MPLEMaltaDeviceColorPink:
            str = MPLocalizedString(@"Pink", @"The color pink");
            break;
            
        case MPLEMaltaDeviceColorYellow:
            str = MPLocalizedString(@"Yellow", @"The color yellow");
            break;
            
        case MPLEMaltaDeviceColorOrange:
            str = MPLocalizedString(@"Orange", @"The color orange");
            break;
            
        case MPLEMaltaDeviceColorPurple:
            str = MPLocalizedString(@"Purple", @"The color purple");
            break;
            
        case MPLEMaltaDeviceColorBrown:
            str = MPLocalizedString(@"Brown", @"The color brown");
            break;
            
        case MPLEMaltaDeviceColorGrey:
            str = MPLocalizedString(@"Grey", @"The color grey");
            break;
            
        case MPLEMaltaDeviceColorBlack:
            str = MPLocalizedString(@"Black", @"The color black");
            break;

        default:
            break;
    }
    
    return str;
}

+ (NSString *)printerStatusString:(MPLEMaltaPrinterStatus)printerStatus
{
    NSString *str = MPLocalizedString(@"Unrecognized Status", @"A status we don't recognize");
    
    switch (printerStatus) {
        case MPLEMaltaPrinterStatusReady:
            str = MPLocalizedString(@"Ready", @"The printer is ready to print");
            break;
            
        case MPLEMaltaPrinterStatusPrinting:
            str = MPLocalizedString(@"Printing", @"The printer is printing");
            break;
            
        case MPLEMaltaPrinterStatusOutOfPaper:
            str = MPLocalizedString(@"Out of Paper", @"The printer is out of paper");
            break;
            
        case MPLEMaltaPrinterStatusPrintBufferFull:
            str = MPLocalizedString(@"Print Buffer Full", @"The print buffer is full");
            break;
            
        case MPLEMaltaPrinterStatusCoverOpen:
            str = MPLocalizedString(@"Cover Open", @"The cover is open");
            break;
            
        case MPLEMaltaPrinterStatusPaperJam:
            str = MPLocalizedString(@"Paper Jam", @"There is a paper jam in the printer");
            break;

        default:
            break;
    }
    
    return str;
}

@end
