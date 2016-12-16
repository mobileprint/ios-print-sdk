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

#import "MPLEDiscoveredPeripheralsTableViewController.h"
#import "MPLEDiscovery.h"

@interface MPLEDiscoveredPeripheralsTableViewController ()<MPLEDiscoveryDelegate, UITableViewDataSource>

@property (strong, nonatomic) NSArray *peripherals;

@end

@implementation MPLEDiscoveredPeripheralsTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tableView.dataSource = self;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self startDiscovery];
    [[NSNotificationCenter defaultCenter]addObserver:self
                                            selector:@selector(appWillEnterForeground)
                                                name:UIApplicationWillEnterForegroundNotification
                                              object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self
                                            selector:@selector(appWillEnterBackground)
                                                name:UIApplicationDidEnterBackgroundNotification
                                              object:nil];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [self clearTable];
    [self stopDiscovery];
    [[NSNotificationCenter defaultCenter]removeObserver:self];
    
    [super viewWillDisappear:animated];
}

- (void)appWillEnterForeground
{
    [self clearTable];
    [self startDiscovery];
}

- (void)appWillEnterBackground
{
    [self clearTable];
    [self stopDiscovery];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

+ (void)presentAnimated:(BOOL)animated usingController:(UIViewController *)hostController andCompletion:(void(^)(void))completion
{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"MP" bundle:nil];
    UINavigationController *navigationController = (UINavigationController *)[storyboard instantiateViewControllerWithIdentifier:@"MPLEDiscoveredPeripheralsNavigationController"];
   
    [hostController presentViewController:navigationController animated:animated completion:completion];
}

#pragma mark - Button Handlers

- (IBAction)done:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Utility Functions

- (void)clearTable
{
    self.peripherals = [[NSMutableArray alloc] init];
    [self.tableView reloadData];
}

- (void)startDiscovery
{
    [MPLEDiscovery sharedInstance].discoveryDelegate = self;
}

- (void)stopDiscovery
{
    [MPLEDiscovery sharedInstance].discoveryDelegate = nil;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.peripherals count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = nil;
    
    cell = [tableView dequeueReusableCellWithIdentifier:@"MPLEPeripheralTableViewCell"];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"MPLEPeripheralTableViewCell"];
    }
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    CBPeripheral *peripheral = [self.peripherals objectAtIndex:indexPath.row];
    cell.textLabel.text = [NSString stringWithFormat:@"Name: %@, UUID: %@", peripheral.name, peripheral.identifier];
    
    return cell;
}

#pragma mark MPLEDiscoveryDelegate

- (void) discoveryDidRefresh
{
    self.peripherals = [MPLEDiscovery sharedInstance].foundPeripherals;
    [self.tableView reloadData];
}

- (void) discoveryStatePoweredOff
{
    [self clearTable];
}

@end
