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

#import "MPBTDeviceInfoViewController.h"
#import "MPBTSprocket.h"

@interface MPBTDeviceInfoViewController() <MPBTSprocketDelegate>

@property (strong, nonatomic) MPBTSprocket *sprocket;

@property (weak, nonatomic) IBOutlet UILabel *errorValueLabel;
@property (weak, nonatomic) IBOutlet UILabel *printCountValueLabel;
@property (weak, nonatomic) IBOutlet UILabel *batteryStatusValueLabel;
@property (weak, nonatomic) IBOutlet UILabel *macAddressValueLabel;
@property (weak, nonatomic) IBOutlet UILabel *firmwareVersionValueLabel;
@property (weak, nonatomic) IBOutlet UILabel *hardwareVersionValueLabel;
@property (weak, nonatomic) IBOutlet UISegmentedControl *printModeSegmentedControl;
@property (weak, nonatomic) IBOutlet UISegmentedControl *autoExposureSegmentedControl;
@property (weak, nonatomic) IBOutlet UISegmentedControl *autoPowerOffSegmentedControl;
@property (strong, nonatomic) UIAlertController* alert;

@end

@implementation MPBTDeviceInfoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setTitle:@"Device Info"];
    
    self.alert = [UIAlertController alertControllerWithTitle:@"Upgrade Status"
                                                     message:@"This is an alert."
                                              preferredStyle:UIAlertControllerStyleAlert];
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}


- (void)setDevice:(EAAccessory *)device
{
    self.sprocket = [MPBTSprocket sharedInstance];
    self.sprocket.accessory = device;
    self.sprocket.delegate = self;
    [self.sprocket refreshInfo];
}

#pragma mark - UI Event Handlers

- (IBAction)didSelectPrintMode:(id)sender {
    
    self.sprocket.printMode = (MantaPrintMode)self.printModeSegmentedControl.selectedSegmentIndex + 1;
}

- (IBAction)didSelectAutoExposure:(id)sender {
    self.sprocket.autoExposure = (MantaAutoExposure)self.autoExposureSegmentedControl.selectedSegmentIndex;
}

- (IBAction)didSelectPowerOffInterval:(id)sender {
    
    NSUInteger selectedIndex = self.autoPowerOffSegmentedControl.selectedSegmentIndex;
    switch (selectedIndex) {
        case 0:
            self.sprocket.powerOffInterval = MantaAutoOffAlwaysOn;
            break;
        case 1:
            self.sprocket.powerOffInterval = MantaAutoOffTenMin;
            break;
        case 2:
            self.sprocket.powerOffInterval = MantaAutoOffFiveMin;
            break;
        case 3:
            self.sprocket.powerOffInterval = MantaAutoOffThreeMin;
            break;
            
        default:
            NSAssert(FALSE, @"Unrecognized MantaAutoPowerOffInteval: %ld", selectedIndex);
            break;
    };
}

- (IBAction)didPressFirmwareUpdateHP:(id)sender {
    [[MPBTSprocket sharedInstance] reflash:MPBTSprocketReflashHP];
}

- (IBAction)didPressFirmwareUpdateV2:(id)sender {
    [[MPBTSprocket sharedInstance] reflash:MPBTSprocketReflashV2];
}

- (IBAction)didPressFirmwareUpdateV3:(id)sender {
    [[MPBTSprocket sharedInstance] reflash:MPBTSprocketReflashV3];
}

#pragma mark - SprocketDelegate

- (void)didRefreshMantaInfo:(MPBTSprocket *)sprocket error:(MantaError)error
{
    self.errorValueLabel.text = [MPBTSprocket errorString:error];
    self.printCountValueLabel.text = [NSString stringWithFormat:@"%lu", (unsigned long)sprocket.totalPrintCount];
    self.batteryStatusValueLabel.text = [NSString stringWithFormat:@"%lu%@", (unsigned long)sprocket.batteryStatus, @"%"];
    self.macAddressValueLabel.text = [MPBTSprocket macAddress:sprocket.macAddress];
    self.firmwareVersionValueLabel.text = [NSString stringWithFormat:@"0x%06x", sprocket.firmwareVersion];
    self.hardwareVersionValueLabel.text = [NSString stringWithFormat:@"0x%06x", sprocket.hardwareVersion];
    
    self.printModeSegmentedControl.selectedSegmentIndex = sprocket.printMode - 1;
    self.autoExposureSegmentedControl.selectedSegmentIndex = sprocket.autoExposure;
    
    switch (sprocket.powerOffInterval) {
        case MantaAutoOffAlwaysOn:
            self.autoPowerOffSegmentedControl.selectedSegmentIndex = 0;
            break;
            
        case MantaAutoOffThreeMin:
            self.autoPowerOffSegmentedControl.selectedSegmentIndex = 3;
            break;
        
        case MantaAutoOffFiveMin:
            self.autoPowerOffSegmentedControl.selectedSegmentIndex = 2;
            break;
        
        case MantaAutoOffTenMin:
            self.autoPowerOffSegmentedControl.selectedSegmentIndex = 1;
            break;
        
        default:
            NSAssert(FALSE, @"Unrecognized MantaAutoPowerOffInteval: %d", sprocket.powerOffInterval);
            break;
    };
    
    [self setTitle:[NSString stringWithFormat:@"%@", sprocket.accessory.name]];
}

- (void)didSendPrintData:(MPBTSprocket *)sprocket percentageComplete:(NSInteger)percentageComplete error:(MantaError)error
{
    
}

- (void)didFinishSendingPrint:(MPBTSprocket *)sprocket
{
    
}

- (void)didStartPrinting:(MPBTSprocket *)sprocket
{
    
}

- (void)didReceiveError:(MPBTSprocket *)sprocket error:(MantaError)error
{
    NSLog(@"%s", __FUNCTION__);
    self.alert.title = @"Error";
    self.alert.message = [NSString stringWithFormat:@"Error sending print: %@", [MPBTSprocket errorString:error]];
    [self addActionToBluetoothStatus];
    if (self.view.window  &&  !(self.alert.isViewLoaded  &&  self.alert.view.window)) {
        [self presentViewController:self.alert animated:YES completion:nil];
    }
}

- (void)didSetAccessoryInfo:(MPBTSprocket *)sprocket error:(MantaError)error
{
    
}

- (void)didSendDeviceUpgradeData:(MPBTSprocket *)manta percentageComplete:(NSInteger)percentageComplete error:(MantaError)error
{
    self.alert.message = [NSString stringWithFormat:@"Sending upgrade data to device... \n%d%@ complete", percentageComplete, @"%"];
    if (!(self.alert.isViewLoaded  &&  self.alert.view.window)) {
        [self presentViewController:self.alert animated:YES completion:nil];
    }
    
    if (MantaErrorNoError != error) {
        [self didReceiveError:manta error:error];
    }
}

- (void)didFinishSendingDeviceUpgrade:(MPBTSprocket *)manta
{
    self.alert.message = @"Finished sending upgrade data...";
}

- (void)didChangeDeviceUpgradeStatus:(MPBTSprocket *)manta status:(MantaUpgradeStatus)status
{
    
    if (MantaUpgradeStatusStart == status) {
        self.alert.message = @"Upgrade started";
    } else {
        UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault
                                                              handler:^(UIAlertAction * action) {[self.alert dismissViewControllerAnimated:YES completion:nil];}];
        [self.alert addAction:defaultAction];

        if (MantaUpgradeStatusFinish == status) {
            self.alert.message = @"Upgrade complete";
        } else if (MantaUpgradeStatusFail == status){
            self.alert.message = @"Upgrade failed";
        } else {
            self.alert.message = [NSString stringWithFormat:@"Unknown status: %d", status];
        }
    }
}

- (void)addActionToBluetoothStatus
{
    if (0 == self.alert.actions.count) {
        UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault
                                                              handler:^(UIAlertAction * action) {[self.alert dismissViewControllerAnimated:YES completion:nil];}];
        [self.alert addAction:defaultAction];
    }
}

@end
