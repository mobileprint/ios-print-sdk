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

#import "MPLEMaltaInfoTableViewController.h"
#import "MPLEDiscovery.h"

@interface MPLEMaltaInfoTableViewController ()

@end

@implementation MPLEMaltaInfoTableViewController

typedef enum MPLEMaltaProperties
{
    MPLEMaltaPropertiesCompanyId = 0,
    MPLEMaltaPropertiesFormat,
    MPLEMaltaPropertiesCalibratedRssi,
    MPLEMaltaPropertiesConnectableStatus,
    MPLEMaltaPropertiesDeviceColor,
    MPLEMaltaPropertiesPrinterStatus,
    MPLEMaltaPropertiesManufacturer,
    MPLEMaltaPropertiesModelNumber,
    MPLEMaltaPropertiesSystemId,
    MPLEMaltaPropertiesFirmwareVersion,
    MPLEMaltaPropertiesBatteryLevel,
    MPLEMaltaPropertiesNumProperties
};

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleMaltaUpdatedNotification:) name:kMPLEMaltaUpdatedNotification object:nil];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if (self.malta.peripheral.state != CBPeripheralStateConnected) {
        [[MPLEDiscovery sharedInstance] connectMalta:self.malta];
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [[MPLEDiscovery sharedInstance] disconnectPeripheral:self.malta.peripheral];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)handleMaltaUpdatedNotification:(NSNotification *)notification
{
    [self.tableView reloadData];
}

- (void)setMalta:(MPLEMalta *)malta
{
    _malta = malta;
    if (self.malta.peripheral.state != CBPeripheralStateConnected) {
        [[MPLEDiscovery sharedInstance] connectMalta:self.malta];
    }
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return MPLEMaltaPropertiesNumProperties;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MPLEMaltaPropertiesCellIdentifier" forIndexPath:indexPath];
    
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"MPLEMaltaPropertiesCellIdentifier"];
    }

    switch (indexPath.row) {
        case MPLEMaltaPropertiesCompanyId:
            cell.textLabel.text = @"Company ID";
            cell.detailTextLabel.text = [NSString stringWithFormat:@"0x%04x", self.malta.companyId];
            break;
            
        case MPLEMaltaPropertiesFormat:
            cell.textLabel.text = @"Format";
            cell.detailTextLabel.text = [NSString stringWithFormat:@"%d", self.malta.format];
            break;

        case MPLEMaltaPropertiesCalibratedRssi:
            cell.textLabel.text = @"Calibrated RSSI";
            cell.detailTextLabel.text = [NSString stringWithFormat:@"%#x", self.malta.calibratedRssi];
            break;

        case MPLEMaltaPropertiesConnectableStatus:
            cell.textLabel.text = @"Connectable Status";
            cell.detailTextLabel.text = [NSString stringWithFormat:@"%d", self.malta.connectableStatus];
            break;

        case MPLEMaltaPropertiesDeviceColor:
            cell.textLabel.text = @"Case Color";
            cell.detailTextLabel.text = [NSString stringWithFormat:@"%@", [MPLEMalta deviceColorString:self.malta.deviceColor]];
            break;

        case MPLEMaltaPropertiesPrinterStatus:
            cell.textLabel.text = @"Printer Status";
            cell.detailTextLabel.text = [NSString stringWithFormat:@"%@", [MPLEMalta printerStatusString:self.malta.printerStatus]];
            break;

        case MPLEMaltaPropertiesManufacturer:
            cell.textLabel.text = @"Manufacturer";
            cell.detailTextLabel.text = [NSString stringWithFormat:@"%@", self.malta.manufacturer];
            NSLog(@"manufacturer: %@", self.malta.manufacturer);
            break;

        case MPLEMaltaPropertiesModelNumber:
            cell.textLabel.text = @"Model Number";
            cell.detailTextLabel.text = [NSString stringWithFormat:@"%@", self.malta.modelNumber];
            break;

        case MPLEMaltaPropertiesSystemId:
            cell.textLabel.text = @"System ID";
            cell.detailTextLabel.text = [NSString stringWithFormat:@"%@", self.malta.systemId];
            break;

        case MPLEMaltaPropertiesFirmwareVersion:
            cell.textLabel.text = @"Firmware Version";
            cell.detailTextLabel.text = [NSString stringWithFormat:@"%@", self.malta.firmwareVersion];
            break;

        case MPLEMaltaPropertiesBatteryLevel:
            cell.textLabel.text = @"Battery Level";
            cell.detailTextLabel.text = [NSString stringWithFormat:@"%d%@", self.malta.batteryLevel, @"%"];
            break;

        default:
            break;
    }
    
    return cell;
}

@end
