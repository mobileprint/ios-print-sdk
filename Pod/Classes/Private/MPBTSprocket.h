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
#import <ExternalAccessory/ExternalAccessory.h>
#import "MPBTSprocketDefinitions.h"
#import "MPPrintItem.h"

@protocol MPBTSprocketDelegate;

@interface MPBTSprocket : NSObject

@property (strong, nonatomic) EAAccessory *accessory;

+ (MPBTSprocket *)sharedInstance;

@property (weak, nonatomic) id<MPBTSprocketDelegate> delegate;

@property (strong, nonnull, nonatomic) NSString *protocolString;
@property (assign, nonatomic) MantaPrintMode printMode;
@property (assign, nonatomic) MantaAutoExposure autoExposure;
@property (assign, nonatomic) MantaAutoPowerOffInterval powerOffInterval;
@property (assign, nonatomic, readonly) NSUInteger totalPrintCount;
@property (assign, nonatomic, readonly) NSUInteger batteryStatus;
@property (strong, nonatomic, readonly) NSData *macAddress;
@property (assign, nonatomic, readonly) NSUInteger firmwareVersion;
@property (assign, nonatomic, readonly) NSUInteger hardwareVersion;
@property (strong, nonatomic, readonly) NSString *displayName;

- (void)refreshInfo;
- (void)printImage:(UIImage *)image numCopies:(NSInteger)numCopies;
- (void)printItem:(MPPrintItem *)printItem numCopies:(NSInteger)numCopies;
- (void)reflash;

+ (NSArray *)pairedSprockets;
+ (NSString *)displayNameForAccessory:(EAAccessory *)accessory;
+ (BOOL)supportedAccessory:(EAAccessory *)accessory;
+ (NSString *)macAddress:(NSData *)data;
+ (NSString *)errorTitle:(MantaError)error;
+ (NSString *)errorDescription:(MantaError)error;
+ (NSString *)autoPowerOffIntervalString:(MantaAutoPowerOffInterval)interval;

@end

@protocol MPBTSprocketDelegate <NSObject>

@optional
- (void)didRefreshMantaInfo:(MPBTSprocket *)manta error:(MantaError)error;
- (void)didSendPrintData:(MPBTSprocket *)manta percentageComplete:(NSInteger)percentageComplete error:(MantaError)error;
- (void)didFinishSendingPrint:(MPBTSprocket *)manta;
- (void)didStartPrinting:(MPBTSprocket *)manta;
- (void)didReceiveError:(MPBTSprocket *)manta error:(MantaError)error;
- (void)didSetAccessoryInfo:(MPBTSprocket *)manta error:(MantaError)error;
- (void)didDownloadDeviceUpgradeData:(MPBTSprocket *)manta percentageComplete:(NSInteger)percentageComplete;
- (void)didSendDeviceUpgradeData:(MPBTSprocket *)manta percentageComplete:(NSInteger)percentageComplete error:(MantaError)error;
- (void)didFinishSendingDeviceUpgrade:(MPBTSprocket *)manta;
- (void)didChangeDeviceUpgradeStatus:(MPBTSprocket *)manta status:(MantaUpgradeStatus)status;
- (void)didCompareWithLatestFirmwareVersion:(MPBTSprocket *)manta needsUpgrade:(BOOL)needsUpgrade;

@end