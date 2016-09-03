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

#import "MPBTProgressView.h"
#import "MP.h"
#import "MPBTPairedAccessoriesViewController.h"
#import "NSBundle+MPLocalizable.h"

static CGFloat    const kProgressViewAnimationDuration = 1.0F;
static NSString * const kSettingShowFirmwareUpgrade    = @"SettingShowFirmwareUpgrade";

@interface MPBTProgressView() <MPBTSprocketDelegate>

@property (weak, nonatomic) IBOutlet UIProgressView *progressBar;
@property (weak, nonatomic) IBOutlet UILabel *label;
@property (strong, nonatomic) UIAlertController* alert;
@property (assign, nonatomic) BOOL performingFileDownload;
@property (assign, nonatomic) BOOL printJob;
@property (assign, nonatomic) BOOL newJob;

@end

@implementation MPBTProgressView

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
            [self.label setText:MPLocalizedString(@"Finishing Firmware Upgrade", "Indicates that a firmware upgrade has started")];
            [self setProgress:0.9F];
            break;
            
        case MantaUpgradeStatusFinish:
            [self.label setText:MPLocalizedString(@"Firmware Upgrade Complete", @"Indicates that a firmware upgrade has completed")];
            [self setProgress:1.0F];
            break;
            
        case MantaUpgradeStatusFail:
            [self.label setText:MPLocalizedString(@"Firmware Upgrade Failed", @"Indicates that a firmware update has failed")];
            break;
            
        default:
            break;
    }
}

#pragma mark - Util

- (void)setup
{
    self.alpha = 0.0;

    self.label.font = [[MP sharedInstance].appearance.settings objectForKey:kMPOverlayPrimaryFont];
    self.label.textColor = [[MP sharedInstance].appearance.settings objectForKey:kMPOverlayLinkFontColor];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(becomeActive:) name:UIApplicationDidBecomeActiveNotification object:nil];
    
    self.alert = [UIAlertController alertControllerWithTitle:@"Upgrade Status"
                                                     message:@"This is an alert."
                                              preferredStyle:UIAlertControllerStyleAlert];

    self.completion = nil;
    self.performingFileDownload = NO;
}

- (void)reflashDevice
{
    self.printJob = NO;
    self.label.text = MPLocalizedString(@"Downloading Firmware Upgrade", @"Indicates that the firmware upgrade is being downloaded from the internet");
    
    [self.viewController.view addSubview:self];
    [MPBTSprocket sharedInstance].delegate = self;
    [[MPBTSprocket sharedInstance] reflash];
    
    [UIView animateWithDuration:[MPBTProgressView animationDuration]/2 animations:^{
        self.alpha = 1.0;
    }];
}

- (void)printToDevice:(UIImage *)image
{
    self.printJob = YES;
    self.newJob   = YES;
    self.label.text = MPLocalizedString(@"Sending to printer", @"Indicates that the phone is sending an image to the printer");

    [self.viewController.view addSubview:self];
    [MPBTSprocket sharedInstance].delegate = self;
    
    NSMutableDictionary *lastOptionsUsed = [NSMutableDictionary dictionaryWithDictionary:[MP sharedInstance].lastOptionsUsed];
    [lastOptionsUsed addEntriesFromDictionary:[MPBTSprocket sharedInstance].analytics];
    [MP sharedInstance].lastOptionsUsed = [NSDictionary dictionaryWithDictionary:lastOptionsUsed];

    [[MPBTSprocket sharedInstance] printImage:image numCopies:1];
    
    [UIView animateWithDuration:[MPBTProgressView animationDuration]/2 animations:^{
        self.alpha = 1.0;
    }];
}

+ (CGFloat)animationDuration
{
    return kProgressViewAnimationDuration;
}

- (void)removeProgressView
{
    [UIView animateWithDuration:[MPBTProgressView animationDuration] animations:^{
        self.alpha = 0.0F;
    } completion:^(BOOL finished){
        [self removeFromSuperview];
    }];
}

- (id) traverseResponderChainForUIViewController:(UIResponder *)responder {
    id nextResponder = [responder nextResponder];
    if ([nextResponder isKindOfClass:[UIViewController class]]) {
        return nextResponder;
    } else if ([nextResponder isKindOfClass:[UIView class]]) {
        return [self traverseResponderChainForUIViewController:nextResponder];
    } else {
        return nil;
    }
}

- (void)becomeActive:(NSNotification *)notification {
    if (!self.performingFileDownload) {
        [self removeFromSuperview];
    }
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
    [self setProgress:(((CGFloat)percentageComplete)/100.0F)*0.8F];
    
    if (MantaErrorNoError != error) {
        [self didReceiveError:sprocket error:error];
    }

    if (self.sprocketDelegate  &&  [self.sprocketDelegate respondsToSelector:@selector(didSendPrintData:percentageComplete:error:)]) {
        [self.sprocketDelegate didSendPrintData:sprocket percentageComplete:percentageComplete error:error];
    }
    
    if( self.newJob ) {
        [[NSNotificationCenter defaultCenter] postNotificationName:kMPBTPrintJobStartedNotification object:nil userInfo:[NSDictionary dictionaryWithObject:[sprocket.analytics objectForKey:kMPPrinterId] forKey:kMPBTPrintJobPrinterIdKey]];
        self.newJob = NO;
    }
}

- (void)didFinishSendingPrint:(MPBTSprocket *)sprocket
{
    [self setProgress:0.9F];
 
    if (self.sprocketDelegate  &&  [self.sprocketDelegate respondsToSelector:@selector(didFinishSendingPrint:)]) {
        [self.sprocketDelegate didFinishSendingPrint:sprocket];
    }
}

- (void)didStartPrinting:(MPBTSprocket *)sprocket
{
    [self setProgress:1.0F];

    [self removeProgressView];

    [MPBTPairedAccessoriesViewController setLastPrinterUsed:[MPBTSprocket sharedInstance].displayName];
    if (self.sprocketDelegate  &&  [self.sprocketDelegate respondsToSelector:@selector(didStartPrinting:)]) {
        [self.sprocketDelegate didStartPrinting:sprocket];
    }
    
    NSDictionary *dictionary = @{kMPBTPrintJobPrinterIdKey : [sprocket.analytics objectForKey:kMPPrinterId]};
    [[NSNotificationCenter defaultCenter] postNotificationName:kMPBTPrintJobCompletedNotification object:nil userInfo:dictionary];
}

- (void)didReceiveError:(MPBTSprocket *)sprocket error:(MantaError)error
{
    [self removeProgressView];

    UIAlertController *alert = [UIAlertController alertControllerWithTitle:[MPBTSprocket errorTitle:error]
                                                                   message:[MPBTSprocket errorDescription:error]
                                                            preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:MPLocalizedString(@"OK", @"Dismisses dialog without taking action")
                                                       style:UIAlertActionStyleCancel
                                                     handler:nil];
    [alert addAction:okAction];
    
    UIViewController *vc = [self traverseResponderChainForUIViewController:self];
    if (nil != vc ) {
        [vc presentViewController:alert animated:YES completion:nil];
    }
    
    if (self.sprocketDelegate  &&  [self.sprocketDelegate respondsToSelector:@selector(didReceiveError:error:)]) {
        [self.sprocketDelegate didReceiveError:sprocket error:error];
    }

    if (self.printJob) {
        NSDictionary *dictionary = @{kMPBTPrintJobPrinterIdKey : [sprocket.analytics objectForKey:kMPPrinterId],
                                     kMPBTPrintJobErrorKey     : [MPBTSprocket errorTitle:error]};
        [[NSNotificationCenter defaultCenter] postNotificationName:kMPBTPrintJobCompletedNotification object:nil userInfo:dictionary];
    }
}

- (void)didSetAccessoryInfo:(MPBTSprocket *)sprocket error:(MantaError)error
{
    if (self.sprocketDelegate  &&  [self.sprocketDelegate respondsToSelector:@selector(didSetAccessoryInfo:error:)]) {
        [self.sprocketDelegate didSetAccessoryInfo:sprocket error:error];
    }
}

- (void)didDownloadDeviceUpgradeData:(MPBTSprocket *)manta percentageComplete:(NSInteger)percentageComplete
{
    self.performingFileDownload = YES;
    
    [self setProgress:(((CGFloat)percentageComplete)/100.0F)];
    
    if (self.sprocketDelegate  &&  [self.sprocketDelegate respondsToSelector:@selector(didDownloadDeviceUpgradeData:percentageComplete:)]) {
        [self.sprocketDelegate didDownloadDeviceUpgradeData:manta percentageComplete:percentageComplete];
    }
}

- (void)didSendDeviceUpgradeData:(MPBTSprocket *)manta percentageComplete:(NSInteger)percentageComplete error:(MantaError)error
{
    self.performingFileDownload = NO;
    
    NSString *text = MPLocalizedString(@"Sending Firmware Upgrade to Printer", @"Indicates that the firmware upgrade is being sent to the printer");
    if (![text isEqualToString:self.label.text]) {
        self.label.text = text;
    }

    [self setProgress:(((CGFloat)percentageComplete)/100.0F)*0.8F];
    
    if (MantaErrorBusy == error) {
        MPLogError(@"Covering up busy error due to bug in firmware...");
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
    
    if (self.viewController) {
        UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"Upgrade Status"
                                                                       message:@"This is an alert."
                                                                preferredStyle:UIAlertControllerStyleAlert];
         if (MantaUpgradeStatusStart != status) {
             if (MantaUpgradeStatusFinish == status) {
                 self.alert.title = MPLocalizedString(@"Firmware Updated", @"Title for dialog given after a successful firmware update");
                 self.alert.message = MPLocalizedString(@"Your printer will shut down now. Turn your sprocket on and continue the fun!", @"Body of dialog giving instructions on how to proceed after a firmware upgrade");
             } else if (MantaUpgradeStatusFail == status) {
                self.alert.title = MPLocalizedString(@"Sprocket Not Connected", @"Title for firmware upgrade error dialog");
                self.alert.message = MPLocalizedString(@"Ensure the printer is on and bluetooth connected.", @"Body for firmware upgrade error dialog");
            } else if (MantaUpgradeStatusDownloadFail == status) {
                self.alert.title = MPLocalizedString(@"Downloading Firmware Error", @"Title for firmware download error dialog");
                self.alert.message = MPLocalizedString(@"Make sure you are connected to the internet and try again.", @"Body for firmware download error dialog");
            } else {
                self.alert.title = MPLocalizedString(@"Firmware Upgrade Error", @"Title for firmware upgrade error dialog");
                NSString *body = MPLocalizedString(@"Unknown status", @"Body for firmware upgrade error where the reason for the error is unknown");
                self.alert.message = [NSString stringWithFormat:@"%@: %d", body, status];
            }
            
            [self addActionToBluetoothStatus];
            
            if (self.viewController.view.window  &&  !(self.alert.isViewLoaded  &&  self.alert.view.window)) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.viewController presentViewController:self.alert animated:YES completion:nil];
                });
            }
        }
    }
    
    if (self.sprocketDelegate  &&  [self.sprocketDelegate respondsToSelector:@selector(didChangeDeviceUpgradeStatus:status:)]) {
        [self.sprocketDelegate didChangeDeviceUpgradeStatus:manta status:status];
    }
}

- (void)addActionToBluetoothStatus
{
    if (0 == self.alert.actions.count) {
        UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault
                                                              handler:^(UIAlertAction * action) {
                                                                  [self.alert dismissViewControllerAnimated:YES completion:nil];
                                                                  if (self.completion) {
                                                                      self.completion();
                                                                  }
                                                              }];
        [self.alert addAction:defaultAction];
    }
}

@end
