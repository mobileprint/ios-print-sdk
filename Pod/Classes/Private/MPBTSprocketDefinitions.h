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

#ifndef MPBTSprocketDefinitions_h
#define MPBTSprocketDefinitions_h

typedef enum {
    MantaAutoExposureOff = 0x00,
    MantaAutoExposureOn  = 0x01
} MantaAutoExposure;

typedef enum {
    MantaAutoOffThreeMin  = 0x04,
    MantaAutoOffFiveMin   = 0x08,
    MantaAutoOffTenMin    = 0x0C,
    MantaAutoOffAlwaysOn  = 0x00
} MantaAutoPowerOffInterval;

typedef enum {
    MantaPrintModePaperFull = 0x01,
    MantaPrintModeImageFull = 0x02
} MantaPrintMode;

typedef enum {
    MantaDataClassImage    = 0x00,
    MantaDataClassTMD      = 0x01,
    MantaDataClassFirmware = 0x02
} MantaDataClassification;

typedef enum {
    MantaUpgradeStatusStart  = 0x00,
    MantaUpgradeStatusFinish = 0x01,
    MantaUpgradeStatusFail   = 0x02
} MantaUpgradeStatus;

typedef enum {
    MantaErrorNoError         = 0x00,
    MantaErrorBusy            = 0x01,
    MantaErrorPaperJam        = 0x02,
    MantaErrorPaperEmpty      = 0x03,
    MantaErrorPaperMismatch   = 0x04,
    MantaErrorDataError       = 0x05,
    MantaErrorCoverOpen       = 0x06,
    MantaErrorSystemError     = 0x07,
    MantaErrorBatteryLow      = 0x08,
    MantaErrorBatteryFault    = 0x09,
    MantaErrorHighTemperature = 0x0A,
    MantaErrorLowTemperature  = 0x0B,
    MantaErrorCoolingMode     = 0x0C,
    // Cancel is for Android only
    MantaErrorWrongCustomer   = 0x0E
} MantaError;

#endif /* MantDefinitions_h */
