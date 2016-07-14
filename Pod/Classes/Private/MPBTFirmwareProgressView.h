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

#import <UIKit/UIKit.h>
#import "MPView.h"
#import "MPBTSprocket.h"

@interface MPBTFirmwareProgressView : MPView

@property (weak, nonatomic) id<MPBTSprocketDelegate> sprocketDelegate;
@property (weak, nonatomic) UINavigationController *navController;

+ (CGFloat)animationDuration;
+ (BOOL)needFirmwareUpdate;

- (void)setProgress:(CGFloat)progress;
- (void)setStatus:(MantaUpgradeStatus)status;
- (void)reflashDevice;

@end
