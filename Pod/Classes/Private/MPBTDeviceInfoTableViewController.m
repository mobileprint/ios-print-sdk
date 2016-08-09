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

#import "MPBTDeviceInfoTableViewController.h"
#import "MPBTAutoOffTableViewController.h"
#import "MPBTProgressView.h"
#import "MPBTSprocket.h"
#import "MP.h"
#import "NSBundle+MPLocalizable.h"

typedef enum
{
    MPBTDeviceInfoOrderError           = 0,
    MPBTDeviceInfoOrderBatteryStatus   = 1,
    MPBTDeviceInfoOrderAutoOff         = 2,
    MPBTDeviceInfoOrderMacAddress      = 3,
    MPBTDeviceInfoOrderFirmwareVersion = 4,
    MPBTDeviceInfoOrderHardwareVersion = 5
} MPBTDeviceInfoOrder;

@interface MPBTDeviceInfoTableViewController () <MPBTAutoOffTableViewControllerDelegate, UITableViewDelegate, UITableViewDataSource>

@property (strong, nonatomic) MPBTSprocket *sprocket;
@property (strong, nonatomic) UIAlertController* alert;
@property (strong, nonatomic) NSString *lastError;
@property (assign, nonatomic) BOOL hideBackButton;

@property (weak, nonatomic) IBOutlet UIButton *fwUpgradeButton;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) MPBTProgressView *progressView;
@property (assign, nonatomic) BOOL receivedSprocketInfo;

@end

@implementation MPBTDeviceInfoTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.receivedSprocketInfo = NO;
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    
    [self setTitle:@" "];
    self.alert = [UIAlertController alertControllerWithTitle:@"Upgrade Status"
                                                     message:@"This is an alert."
                                              preferredStyle:UIAlertControllerStyleAlert];

    self.tableView.backgroundColor = [[MP sharedInstance].appearance.settings objectForKey:kMPGeneralBackgroundColor];
    self.tableView.tableHeaderView.backgroundColor = self.tableView.backgroundColor;
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    self.tableView.separatorColor = [[MP sharedInstance].appearance.settings objectForKey:kMPGeneralTableSeparatorColor];
    
    if (![MPBTProgressView needFirmwareUpdate]) {
        self.tableView.tableHeaderView = [[UIView alloc] initWithFrame:CGRectMake(0,0,10,10)];
    }

    
    self.fwUpgradeButton.titleLabel.font = [[MP sharedInstance].appearance.settings objectForKey:kMPSelectionOptionsPrimaryFont];
    self.fwUpgradeButton.titleLabel.textColor = [UIColor colorWithRed:47.0/255.0 green:184.0/255.0 blue:255.0/255.0 alpha:1.0];
    
    UIBarButtonItem *xButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"MPX"]
                                                               style:UIBarButtonItemStylePlain
                                                              target:self
                                                              action:@selector(didPressCancel)];
    self.navigationItem.rightBarButtonItem = xButton;
    
    if (!self.hideBackButton) {
        UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"Back"]
                                                                       style:UIBarButtonItemStylePlain
                                                                      target:self
                                                                      action:@selector(didPressBack)];
        self.navigationItem.leftBarButtonItem = backButton;
    }

    self.lastError = @"";
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)setCellAppearance:(UITableViewCell *)cell
{
    cell.backgroundColor = [[MP sharedInstance].appearance.settings objectForKey:kMPSelectionOptionsBackgroundColor];
    cell.textLabel.font = [[MP sharedInstance].appearance.settings objectForKey:kMPSelectionOptionsPrimaryFont];
    cell.textLabel.textColor = [[MP sharedInstance].appearance.settings objectForKey:kMPSelectionOptionsPrimaryFontColor];
    cell.detailTextLabel.font = [[MP sharedInstance].appearance.settings objectForKey:kMPSelectionOptionsPrimaryFont];
    cell.detailTextLabel.textColor = [[MP sharedInstance].appearance.settings objectForKey:kMPSelectionOptionsPrimaryFontColor];
    cell.accessoryType = UITableViewCellAccessoryNone;
}

- (void)setDevice:(EAAccessory *)device
{
    self.sprocket = [MPBTSprocket sharedInstance];
    self.sprocket.accessory = device;
    self.sprocket.delegate = self;
    [self.sprocket refreshInfo];
}

+ (void)presentAnimated:(BOOL)animated device:(EAAccessory *)device usingController:(UIViewController *)hostController andCompletion:(void(^)(void))completion
{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"MP" bundle:nil];
    MPBTDeviceInfoTableViewController *vc = (MPBTDeviceInfoTableViewController *)[storyboard instantiateViewControllerWithIdentifier:@"MPBTDeviceInfoTableViewController"];
    vc.device = device;
    vc.hideBackButton = YES;
    
    UINavigationController *navController = [[UINavigationController alloc] init];
    [navController pushViewController:vc animated:NO];
    [hostController presentViewController:navController animated:animated completion:^{
        if (completion) {
            completion();
        }
    }];
}

#pragma mark - Button handlers

- (void)didPressCancel
{
    [self dismissViewControllerAnimated:YES completion:nil];    
}

- (void)didPressBack
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)didPressFirmwareUpgrade:(id)sender {
    if (nil == self.progressView) {
        self.progressView = [[MPBTProgressView alloc] initWithFrame:self.navigationController.view.frame];
        self.progressView.viewController = self.navigationController;
        self.progressView.sprocketDelegate = self;
        [self.progressView reflashDevice];
    }
}

#pragma mark - MPBTAutoOffTableViewControllerDelegate

- (void)didSelectAutoOffInterval:(MantaAutoPowerOffInterval)interval
{
    self.sprocket.powerOffInterval = interval;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (MPBTDeviceInfoOrderAutoOff == indexPath.row) {
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"MP" bundle:nil];
        MPBTAutoOffTableViewController *vc = (UIViewController *)[storyboard instantiateViewControllerWithIdentifier:@"MPBTAutoOffTableViewController"];
        vc.currentAutoOffValue = self.sprocket.powerOffInterval;
        vc.delegate = self;
        [self.navigationController pushViewController:vc animated:YES];
    }
}

#pragma mark - Table view data source

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    NSInteger fw1, fw2, fw3;
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"MPBTSprocketDeviceInfoCell"];
    
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"MPBTSprocketDeviceInfoCell"];
    }
    
    [self setCellAppearance:cell];
    
    if (self.receivedSprocketInfo) {
        switch (indexPath.row) {
            case MPBTDeviceInfoOrderError:
                cell.textLabel.text = MPLocalizedString(@"Errors", @"Title of field displaying latest errors");
                cell.detailTextLabel.text = self.lastError;
                NSLog(@"Table... lastError: %@", self.lastError);
                break;
                
            case MPBTDeviceInfoOrderBatteryStatus:
                cell.textLabel.text = MPLocalizedString(@"Battery Status", @"Title of field displaying battery level");
                cell.detailTextLabel.text = [NSString stringWithFormat:@"%lu%@", (unsigned long)self.sprocket.batteryStatus, @"%"];
                break;
                
            case MPBTDeviceInfoOrderAutoOff:
                cell.textLabel.text = MPLocalizedString(@"Auto Off", @"Title of field displaying how many minutes the device is on before it automatically powers off");
                cell.detailTextLabel.text = [MPBTSprocket autoPowerOffIntervalString:self.sprocket.powerOffInterval];
                cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                break;
                
            case MPBTDeviceInfoOrderMacAddress:
                cell.textLabel.text = MPLocalizedString(@"Mac Address", @"Title of field displaying the printer's mac address");
                cell.detailTextLabel.text = [MPBTSprocket macAddress:self.sprocket.macAddress];
                break;
                
            case MPBTDeviceInfoOrderFirmwareVersion:
                fw1 = (0xFF0000 & self.sprocket.firmwareVersion) >> 16;
                fw2 = (0x00FF00 & self.sprocket.firmwareVersion) >>  8;
                fw3 =  0x0000FF & self.sprocket.firmwareVersion;
                cell.textLabel.text = MPLocalizedString(@"Firmware Version", @"Title of field displaying the printer's firmware version");
                cell.detailTextLabel.text = [NSString stringWithFormat:@"%d.%d.%d", fw1, fw2, fw3];
                break;
                
            case MPBTDeviceInfoOrderHardwareVersion:
                cell.textLabel.text = MPLocalizedString(@"Hardware Version", @"Title of field displaying the printer's hardware version");
                cell.detailTextLabel.text = [NSString stringWithFormat:@"%x", self.sprocket.hardwareVersion];
                break;
                
            default:
                cell.textLabel.text = @"Unrecognized field";
                cell.detailTextLabel.text = @"";
                break;
        }
    }
    
    return cell;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 6;
}

#pragma mark - SprocketDelegate

- (void)didRefreshMantaInfo:(MPBTSprocket *)sprocket error:(MantaError)error
{
    self.lastError = [MPBTSprocket errorTitle:error];

    [self setTitle:[NSString stringWithFormat:@"%@", sprocket.displayName]];
    
    self.receivedSprocketInfo = YES;
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.tableView reloadData];
    });
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
    self.alert.title = [MPBTSprocket errorTitle:error];
    self.alert.message = [NSString stringWithFormat:@"Error sending device upgrade: %@", [MPBTSprocket errorDescription:error]];
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
    if (MantaErrorBusy == error) {
        NSLog(@"Covering up busy error due to bug in firmware...");
    } else if (MantaErrorNoError != error) {
        [self didReceiveError:manta error:error];
    }
}

- (void)didFinishSendingDeviceUpgrade:(MPBTSprocket *)manta
{
}

- (void)didChangeDeviceUpgradeStatus:(MPBTSprocket *)manta status:(MantaUpgradeStatus)status
{
    if (MantaUpgradeStatusStart != status  && MantaUpgradeStatusFinish != status) {
        if (MantaUpgradeStatusFail == status){
            self.alert.message = @"Upgrade failed";
        } else {
            self.alert.message = [NSString stringWithFormat:@"Unknown status: %d", status];
        }
        
        [self addActionToBluetoothStatus];
        
        if (self.view.window  &&  !(self.alert.isViewLoaded  &&  self.alert.view.window)) {
            [self presentViewController:self.alert animated:YES completion:nil];
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
