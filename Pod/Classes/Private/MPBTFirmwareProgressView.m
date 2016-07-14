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

#import "MPBTFirmwareProgressView.h"
#import "MP.h"
#import "NSBundle+MPLocalizable.h"

static CGFloat    const kProgressViewAnimationDuration = 1.0F;
static NSString * const kSettingShowFirmwareUpgrade    = @"SettingShowFirmwareUpgrade";

@interface MPBTFirmwareProgressView() <MPBTSprocketDelegate>

@property (weak, nonatomic) IBOutlet UIProgressView *progressBar;
@property (weak, nonatomic) IBOutlet UILabel *label;

@end

@implementation MPBTFirmwareProgressView

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self setup];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setup];
    }
    return self;
}

#pragma mark - Getters/Setters

- (void)setProgress:(CGFloat)progress
{
    self.progressBar.progress = progress;
}

- (void)setStatus:(MantaUpgradeStatus)status
{
    switch (status) {
        case MantaUpgradeStatusStart:
            [self.label setText:MPLocalizedString(@"Upgrade Started", "Indicates that a firmware upgrade has started")];
            [self setProgress:0.9F];
            break;
            
        case MantaUpgradeStatusFinish:
            [self.label setText:MPLocalizedString(@"Upgrade Complete", @"Indicates that a firmware upgrade has completed")];
            [self setProgress:1.0F];
            break;
            
        case MantaUpgradeStatusFail:
            [self.label setText:MPLocalizedString(@"Upgrade Failed", @"Indicates that a firmware update has failed")];
            break;
            
        default:
            break;
    }
}

#pragma mark - Util

- (void)setup
{
    self.label.text = MPLocalizedString(@"Downloading Firmware Upgrade", @"Indicates that the firmware upgrade is being loaded onto the printer");
    self.label.font = [[MP sharedInstance].appearance.settings objectForKey:kMPSelectionOptionsPrimaryFont];
    self.label.textColor = [[MP sharedInstance].appearance.settings objectForKey:kMPSelectionOptionsPrimaryFontColor];
}

- (void)reflashDevice
{
    self.alpha = 0.0;
    
    [self.navController.view addSubview:self];
    [MPBTSprocket sharedInstance].delegate = self;
    [[MPBTSprocket sharedInstance] reflash:MPBTSprocketReflashHP];
    
    [UIView animateWithDuration:[MPBTFirmwareProgressView animationDuration]/2 animations:^{
        self.alpha = 1.0;
    }];
}

+ (CGFloat)animationDuration
{
    return kProgressViewAnimationDuration;
}

+ (BOOL)needFirmwareUpdate
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if (nil == [defaults objectForKey:kSettingShowFirmwareUpgrade]) {
        [defaults setBool:NO forKey:kSettingShowFirmwareUpgrade];
        [defaults synchronize];
    }
    return [defaults boolForKey:kSettingShowFirmwareUpgrade];
}

- (void)removeProgressView
{
    [UIView animateWithDuration:[MPBTFirmwareProgressView animationDuration] animations:^{
        self.alpha = 0.0F;
    } completion:^(BOOL finished){
        [self removeFromSuperview];
    }];
}

#pragma mark - SprocketDelegate

- (void)didRefreshMantaInfo:(MPBTSprocket *)sprocket error:(MantaError)error
{
    if (self.sprocketDelegate  &&  [self.sprocketDelegate respondsToSelector:@selector(didRefreshMantaInfo:error:)]) {
        [self.sprocketDelegate didRefreshMantaInfo:sprocket error:error];
    }
}

- (void)didSendPrintData:(MPBTSprocket *)sprocket percentageComplete:(NSInteger)percentageComplete error:(MantaError)error
{
    if (self.sprocketDelegate  &&  [self.sprocketDelegate respondsToSelector:@selector(didSendPrintData:percentageComplete:error:)]) {
        [self.sprocketDelegate didSendPrintData:sprocket percentageComplete:percentageComplete error:error];
    }
}

- (void)didFinishSendingPrint:(MPBTSprocket *)sprocket
{
    if (self.sprocketDelegate  &&  [self.sprocketDelegate respondsToSelector:@selector(didFinishSendingPrint:)]) {
        [self.sprocketDelegate didFinishSendingPrint:sprocket];
    }
}

- (void)didStartPrinting:(MPBTSprocket *)sprocket
{
    if (self.sprocketDelegate  &&  [self.sprocketDelegate respondsToSelector:@selector(didStartPrinting:)]) {
        [self.sprocketDelegate didStartPrinting:sprocket];
    }
}

- (void)didReceiveError:(MPBTSprocket *)sprocket error:(MantaError)error
{
    [self removeProgressView];

    if (self.sprocketDelegate  &&  [self.sprocketDelegate respondsToSelector:@selector(didReceiveError:error:)]) {
        [self.sprocketDelegate didReceiveError:sprocket error:error];
    }
}

- (void)didSetAccessoryInfo:(MPBTSprocket *)sprocket error:(MantaError)error
{
    if (self.sprocketDelegate  &&  [self.sprocketDelegate respondsToSelector:@selector(didSetAccessoryInfo:error:)]) {
        [self.sprocketDelegate didSetAccessoryInfo:sprocket error:error];
    }
}

- (void)didSendDeviceUpgradeData:(MPBTSprocket *)manta percentageComplete:(NSInteger)percentageComplete error:(MantaError)error
{
    [self setProgress:(((CGFloat)percentageComplete)/100.0F)*0.8F];
    
    if (MantaErrorBusy == error) {
        NSLog(@"Covering up busy error due to bug in firmware...");
    } else if (MantaErrorNoError != error) {
        [self didReceiveError:manta error:error];
    }
    
    if (self.sprocketDelegate  &&  [self.sprocketDelegate respondsToSelector:@selector(didSendDeviceUpgradeData:percentageComplete:error:)]) {
        [self.sprocketDelegate didSendDeviceUpgradeData:manta percentageComplete:percentageComplete error:error];
    }
}

- (void)didFinishSendingDeviceUpgrade:(MPBTSprocket *)manta
{
    if (self.sprocketDelegate  &&  [self.sprocketDelegate respondsToSelector:@selector(didFinishSendingDeviceUpgrade:)]) {
        [self.sprocketDelegate didFinishSendingDeviceUpgrade:manta];
    }
}

- (void)didChangeDeviceUpgradeStatus:(MPBTSprocket *)manta status:(MantaUpgradeStatus)status
{
    [self setStatus:status];
    
    if (MantaUpgradeStatusStart != status) {
        [self removeProgressView];
    }
    
    if (self.sprocketDelegate  &&  [self.sprocketDelegate respondsToSelector:@selector(didChangeDeviceUpgradeStatus:status:)]) {
        [self.sprocketDelegate didChangeDeviceUpgradeStatus:manta status:status];
    }
}

@end
