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

- (void)refreshInfo;
- (void)print:(MPPrintItem *)printItem numCopies:(NSInteger)numCopies;
- (void)reflash:(NSData *)reflashData;

+ (BOOL)supportedAccessory:(EAAccessory *)accessory;
+ (NSString *)errorString:(MantaError)error;

@end

@protocol MPBTSprocketDelegate <NSObject>

@optional
- (void)didRefreshMantaInfo:(MPBTSprocket *)manta error:(MantaError)error;
- (void)didStartSendingPrint:(MPBTSprocket *)manta error:(MantaError)error;
- (void)didFinishSendingPrint:(MPBTSprocket *)manta;
- (void)didStartPrinting:(MPBTSprocket *)manta;
- (void)didReceiveError:(MPBTSprocket *)manta error:(MantaError)error;
- (void)didSetAccessoryInfo:(MPBTSprocket *)manta error:(MantaError)error;

@end