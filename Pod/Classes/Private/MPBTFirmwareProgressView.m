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

@interface MPBTFirmwareProgressView()

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

- (void)setup
{
    self.label.text = MPLocalizedString(@"Downloading Firmware Upgrade", @"Indicates that the firmware upgrade is being loaded onto the printer");
    self.label.font = [[MP sharedInstance].appearance.settings objectForKey:kMPSelectionOptionsPrimaryFont];
    self.label.textColor = [[MP sharedInstance].appearance.settings objectForKey:kMPSelectionOptionsPrimaryFontColor];
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

@end
