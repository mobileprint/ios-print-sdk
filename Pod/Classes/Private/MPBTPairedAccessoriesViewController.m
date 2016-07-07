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
#import "MP.h"
#import <ExternalAccessory/ExternalAccessory.h>

@interface MPBTPairedAccessoriesViewController () <UITableViewDelegate, UITableViewDataSource>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) NSMutableArray *pairedDevices;
@property (weak, nonatomic) IBOutlet UIView *topView;
@property (weak, nonatomic) IBOutlet UIView *bottomView;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (strong, nonatomic) IBOutlet UIView *containerView;
@property (weak, nonatomic) IBOutlet UIView *noDevicesView;
@property (weak, nonatomic) IBOutlet UILabel *noDevicesLabel;
@property (weak, nonatomic) IBOutlet UILabel *descriptionLabel;

@end

@implementation MPBTPairedAccessoriesViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    
    [self setTitle:@"Devices"];
    self.bottomView.backgroundColor = [[MP sharedInstance].appearance.settings objectForKey:kMPGeneralBackgroundColor];
    self.tableView.backgroundColor = [[MP sharedInstance].appearance.settings objectForKey:kMPGeneralBackgroundColor];
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    self.tableView.separatorColor = [[MP sharedInstance].appearance.settings objectForKey:kMPGeneralTableSeparatorColor];
    
    self.topView.backgroundColor = [[MP sharedInstance].appearance.settings objectForKey:kMPSelectionOptionsBackgroundColor];
    self.containerView.backgroundColor = [[MP sharedInstance].appearance.settings objectForKey:kMPSelectionOptionsBackgroundColor];
    if ([UINavigationBar appearance].barTintColor) {
        self.topView.backgroundColor = [UINavigationBar appearance].barTintColor;
        self.containerView.backgroundColor = [UINavigationBar appearance].barTintColor;
    }

    if ([UINavigationBar appearance].titleTextAttributes) {
        self.titleLabel.font = [[UINavigationBar appearance].titleTextAttributes objectForKey:NSFontAttributeName];
        self.titleLabel.textColor = [[UINavigationBar appearance].titleTextAttributes objectForKey:NSForegroundColorAttributeName];
    } else {
        self.titleLabel.font = [[MP sharedInstance].appearance.settings objectForKey:kMPSelectionOptionsPrimaryFont];
        self.titleLabel.textColor = [[MP sharedInstance].appearance.settings objectForKey:kMPSelectionOptionsPrimaryFontColor];
    }

    self.noDevicesLabel.font = [[MP sharedInstance].appearance.settings objectForKey:kMPSelectionOptionsPrimaryFont];
    self.noDevicesLabel.textColor = [[MP sharedInstance].appearance.settings objectForKey:kMPSelectionOptionsPrimaryFontColor];
    self.descriptionLabel.font = [[MP sharedInstance].appearance.settings objectForKey:kMPSelectionOptionsSecondaryFont];
    self.descriptionLabel.textColor = [[MP sharedInstance].appearance.settings objectForKey:kMPSelectionOptionsSecondaryFontColor];
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
    
    [[cell textLabel] setText:[NSString stringWithFormat:@"%@ (%@)", accessory.name, accessory.serialNumber]];
    cell.backgroundColor = [[MP sharedInstance].appearance.settings objectForKey:kMPSelectionOptionsBackgroundColor];
    cell.textLabel.font = [[MP sharedInstance].appearance.settings objectForKey:kMPSelectionOptionsPrimaryFont];
    cell.textLabel.textColor = [[MP sharedInstance].appearance.settings objectForKey:kMPSelectionOptionsPrimaryFontColor];
    
    return cell;
}


- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}


- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSInteger numRows = self.pairedDevices.count;
    
    self.noDevicesView.hidden = (0 == numRows) ? NO : YES;

    return numRows;
}

#pragma mark - UITableViewDelegate

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.delegate  &&  [self.delegate respondsToSelector:@selector(didSelectSprocket:)]) {
        EAAccessory *device = (EAAccessory *)[self.pairedDevices objectAtIndex:indexPath.row];
        
        MPBTSprocket *sprocket = [MPBTSprocket sharedInstance];
        sprocket.accessory = device;
        
        void (^completionBlock)(void) = ^{
            [self.delegate didSelectSprocket:sprocket];
            
            if (self.completionBlock) {
                self.completionBlock(YES);
            }
        };

        if (nil == self.parentViewController) {
            [self dismissViewControllerAnimated:YES completion:completionBlock];
        } else {
            completionBlock();
        }
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
