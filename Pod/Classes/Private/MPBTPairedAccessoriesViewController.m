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

#import "MPBTPairedAccessoriesViewController.h"
#import "MPBTSessionController.h"
#import "MPBTSprocket.h"
#import <ExternalAccessory/ExternalAccessory.h>

@interface MPBTPairedAccessoriesViewController () <UITableViewDelegate, UITableViewDataSource>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) NSMutableArray *pairedDevices;

@end

@implementation MPBTPairedAccessoriesViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    
    [self setTitle:@"Paired Devices"];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
 
    [self didPressRefreshButton:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UITableViewDataSource

- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell	*cell;
    static NSString *cellID = @"EAAccessoryList";
    
    cell = [tableView dequeueReusableCellWithIdentifier:cellID];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID];
    }
    
    EAAccessory *accessory = (EAAccessory *)[self.pairedDevices objectAtIndex:indexPath.row];
    
    [[cell textLabel] setText:accessory.name];
    
    return cell;
}


- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}


- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.pairedDevices.count;
}

#pragma mark - UITableViewDelegate

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.delegate  &&  [self.delegate respondsToSelector:@selector(didSelectSprocket:)]) {
        EAAccessory *device = (EAAccessory *)[self.pairedDevices objectAtIndex:indexPath.row];
        
        MPBTSprocket *sprocket = [MPBTSprocket sharedInstance];
        sprocket.accessory = device;

        [self.delegate didSelectSprocket:sprocket];
        
        if (self.completionBlock) {
            self.completionBlock(YES);
        }
        
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

#pragma mark - Button Listeners

- (IBAction)didPressRefreshButton:(id)sender {
    NSArray *accs = [[EAAccessoryManager sharedAccessoryManager] connectedAccessories];
    self.pairedDevices = [[NSMutableArray alloc] init];
    
    for (EAAccessory *accessory in accs) {
        if ([MPBTSprocket supportedAccessory:accessory]) {
            [self.pairedDevices addObject:accessory];
        }
    }

    [self.tableView reloadData];
}

- (IBAction)didPressCancel:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
