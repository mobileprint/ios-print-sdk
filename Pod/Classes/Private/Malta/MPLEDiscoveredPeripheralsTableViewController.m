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

#import "MP.h"
#import "MPLEDiscoveredPeripheralsTableViewController.h"
#import "MPLEDiscovery.h"
#import "MPLEService.h"
#import "MPLEMaltaInfoTableViewController.h"

@interface MPLEDiscoveredPeripheralsTableViewController ()<MPLEDiscoveryDelegate, UITableViewDataSource>

@property (strong, nonatomic) NSArray *maltas;

@end

@implementation MPLEDiscoveredPeripheralsTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tableView.dataSource = self;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self clearTable];
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
    [[MPLEDiscovery sharedInstance] clearDevices];
    self.maltas = [[NSMutableArray alloc] init];
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

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
#ifndef TARGET_IS_EXTENSION
    MPLEMalta	    *malta;
    NSArray			*maltas;
    NSInteger		row	= [indexPath row];
    
    maltas = [[MPLEDiscovery sharedInstance] foundMaltas];
    malta = (MPLEMalta*)[maltas objectAtIndex:row];
    
    // show device info screen
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"MP" bundle:[NSBundle bundleForClass:[MP class]]];
    MPLEMaltaInfoTableViewController *infoViewController = (MPLEMaltaInfoTableViewController *)[storyboard instantiateViewControllerWithIdentifier:@"MPLEMaltaInfoTableViewController"];
    
    infoViewController.malta = malta;
    
    UIViewController *topController = [UIApplication sharedApplication].keyWindow.rootViewController;
    
    while (topController.presentedViewController) {
        topController = topController.presentedViewController;
    }
    
    [((UINavigationController *)topController) pushViewController:infoViewController animated:YES];
#endif
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.maltas count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = nil;
    
    cell = [tableView dequeueReusableCellWithIdentifier:@"MPLEPeripheralTableViewCell"];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"MPLEPeripheralTableViewCell"];
    }
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    MPLEMalta *malta = [self.maltas objectAtIndex:indexPath.row];
    CBPeripheral *peripheral = malta.peripheral;
    cell.textLabel.text = [NSString stringWithFormat:@"Name: %@, UUID: %@", peripheral.name, peripheral.identifier];
    
    return cell;
}

#pragma mark MPLEDiscoveryDelegate

- (void) discoveryDidRefresh
{
    self.maltas = [MPLEDiscovery sharedInstance].foundMaltas;
    [self.tableView reloadData];
}

- (void) discoveryStatePoweredOff
{
    [self clearTable];
}

@end
