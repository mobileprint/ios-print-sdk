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
#import "NSBundle+MPLocalizable.h"
#import "MPBTDeviceInfoTableViewController.h"
#import "MPBTProgressView.h"
#import <ExternalAccessory/ExternalAccessory.h>

static NSString *kMPBTLastPrinterNameSetting = @"kMPBTLastPrinterNameSetting";
static NSString * const kDeviceListScreenName = @"Devices Screen";
static const NSInteger kMPBTPairedAccessoriesRecentSection = 0;
static const NSInteger kMPBTPairedAccessoriesOtherSection  = 1;

@interface MPBTPairedAccessoriesViewController () <UITableViewDelegate, UITableViewDataSource>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) NSArray *pairedDevices;
@property (strong, nonatomic) EAAccessory *recentDevice;
@property (strong, nonatomic) NSMutableArray *otherDevices;
@property (weak, nonatomic) IBOutlet UIView *topView;
@property (weak, nonatomic) IBOutlet UIView *bottomView;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (strong, nonatomic) IBOutlet UIView *containerView;
@property (weak, nonatomic) IBOutlet UIView *noDevicesView;
@property (weak, nonatomic) IBOutlet UILabel *noDevicesLabel;
@property (weak, nonatomic) IBOutlet UILabel *descriptionLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *topViewHeightConstraint;
@property (strong, nonatomic) UIImage *image;
@property (weak, nonatomic) UIViewController *hostController;
@property (strong, nonatomic) void (^printCompletionBlock)(void);

@end

@implementation MPBTPairedAccessoriesViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    
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

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(becomeActive:) name:UIApplicationDidBecomeActiveNotification object:nil];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
 
    if ([UINavigationController class] == [self.parentViewController class]) {
        self.topViewHeightConstraint.constant = 0;
        self.topView.hidden = YES;
    }
    
    [self setTitle];
    [self refreshPairedDevices];
    
    if (0 == self.pairedDevices.count) {
        [MPBTPairedAccessoriesViewController presentNoPrinterConnectedAlert:self];
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kMPTrackableScreenNotification object:nil userInfo:[NSDictionary dictionaryWithObject:kDeviceListScreenName forKey:kMPTrackableScreenNameKey]];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)setTitle
{
    if (nil == self.image) {
        [self setTitle:MPLocalizedString(@"Devices",@"Title for screen listing all available sprocket printers")];
    } else {
        [self setTitle:MPLocalizedString(@"Select Printer",@"Title for screen listing all available sprocket printers")];
    }
}

- (void)setImage:(UIImage *)image
{
    _image = image;
    [self setTitle];
    [self refreshPairedDevices];
}

+ (void)presentAnimatedForDeviceInfo:(BOOL)animated usingController:(UIViewController *)hostController andCompletion:(void(^)(void))completion
{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"MP" bundle:nil];
    UINavigationController *navigationController = (UINavigationController *)[storyboard instantiateViewControllerWithIdentifier:@"MPBTPairedAccessoriesNavigationController"];
    [hostController presentViewController:navigationController animated:animated completion:^{
        if (completion) {
            completion();
        }
    }];
}

+ (void)presentAnimatedForPrint:(BOOL)animated image:(UIImage *)image usingController:(UIViewController *)hostController andPrintCompletion:(void(^)(void))completion
{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"MP" bundle:nil];
    UINavigationController *navigationController = (UINavigationController *)[storyboard instantiateViewControllerWithIdentifier:@"MPBTPairedAccessoriesNavigationController"];
    if ([MPBTPairedAccessoriesViewController class] == [[navigationController topViewController] class]) {
        MPBTPairedAccessoriesViewController *vc = (MPBTPairedAccessoriesViewController *)[navigationController topViewController];
        vc.image = image;
        vc.hostController = hostController;
        vc.printCompletionBlock = completion;
        [vc.tableView reloadData];
    }
    
    [hostController presentViewController:navigationController animated:animated completion:nil];
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
    if ([self numberOfSectionsInTableView:tableView] > 1) {
        
        if (kMPBTPairedAccessoriesRecentSection == indexPath.section) {
            accessory = self.recentDevice;
        } else {
            accessory = (EAAccessory *)[self.otherDevices objectAtIndex:indexPath.row];
        }
    }
    
    [[cell textLabel] setText:[MPBTSprocket displayNameForAccessory:accessory]];
    cell.backgroundColor = [[MP sharedInstance].appearance.settings objectForKey:kMPSelectionOptionsBackgroundColor];
    cell.textLabel.font = [[MP sharedInstance].appearance.settings objectForKey:kMPSelectionOptionsPrimaryFont];
    cell.textLabel.textColor = [[MP sharedInstance].appearance.settings objectForKey:kMPSelectionOptionsPrimaryFontColor];
    if (self.image) {
        cell.accessoryType = UITableViewCellAccessoryNone;
    } else {
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    
    return cell;
}

- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView
{
    NSInteger numSections = (self.recentDevice) ? 2 : 1;
    
    return numSections;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    NSString *title = @"";
    if ([self numberOfSectionsInTableView:tableView] > 1) {
        if (kMPBTPairedAccessoriesRecentSection == section) {
            title = MPLocalizedString(@"Recent Printer", @"Table heading for the printer that has most recently been printed to");
        } else if (kMPBTPairedAccessoriesOtherSection == section) {
            title = MPLocalizedString(@"Other Printers", @"Table heading for list of all available printers, except for the most recently used printer");
        }
    }
    
    return title;
}

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSInteger numRows = self.pairedDevices.count;
    self.noDevicesView.hidden = (0 == numRows) ? NO : YES;
    
    if ([self numberOfSectionsInTableView:tableView] > 1) {
        self.noDevicesView.hidden = YES;
        
        if (kMPBTPairedAccessoriesRecentSection == section) {
            numRows = 1;
        } else {
            numRows = self.otherDevices.count;
        }
    }
    
    return numRows;
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    CGFloat height = tableView.sectionHeaderHeight;
    
    if ([self numberOfSectionsInTableView:tableView] > 1) {
        height = 35.0F;
    }
    
    return height;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    CGFloat height = tableView.sectionHeaderHeight;
    
    if ([self numberOfSectionsInTableView:tableView] > 1) {
        height = 10.0F;
    }
    
    return height;
}

- (void)tableView:(UITableView *)tableView willDisplayHeaderView:(UIView *)view forSection:(NSInteger)section {
    UITableViewHeaderFooterView *header = (UITableViewHeaderFooterView *)view;
    header.contentView.backgroundColor = [[MP sharedInstance].appearance.settings objectForKey:kMPGeneralBackgroundColor];
    header.textLabel.textColor = [[MP sharedInstance].appearance.settings objectForKey:kMPMainActionInactiveLinkFontColor];
    header.textLabel.font = [[MP sharedInstance].appearance.settings objectForKey:kMPSelectionOptionsPrimaryFont];
}

- (void)tableView:(UITableView *)tableView willDisplayFooterView:(UIView *)view forSection:(NSInteger)section {
    UITableViewHeaderFooterView *footer = (UITableViewHeaderFooterView *)view;
    footer.contentView.backgroundColor = [[MP sharedInstance].appearance.settings objectForKey:kMPGeneralBackgroundColor];
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // ensure that the device is still connected
    EAAccessory *accessory = nil;
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    NSString *displayName = cell.textLabel.text;
    
    NSArray *currentlyPairedDevices = [MPBTSprocket pairedSprockets];
    for (EAAccessory *acc in currentlyPairedDevices) {
        if ([displayName isEqualToString:[MPBTSprocket displayNameForAccessory:acc]]) {
            accessory = acc;
        }
    }
    
    if (nil != accessory) {
        MPBTSprocket *sprocket = [MPBTSprocket sharedInstance];
        sprocket.accessory = accessory;
        
        if (self.image  &&  self.hostController) {
            [self dismissViewControllerAnimated:YES completion:^{
                MPBTProgressView *progressView = [[MPBTProgressView alloc] initWithFrame:self.hostController.view.frame];
                progressView.viewController = self.hostController;
                [progressView printToDevice:self.image];
                if (self.printCompletionBlock) {
                    self.printCompletionBlock();
                    self.printCompletionBlock = nil;
                }
            }];
        }
        else if (self.delegate  &&  [self.delegate respondsToSelector:@selector(didSelectSprocket:)]) {
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
        } else {
            #ifndef TARGET_IS_EXTENSION
                // show device info screen
                UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"MP" bundle:[NSBundle bundleForClass:[MP class]]];
                MPBTDeviceInfoTableViewController *settingsViewController = (MPBTDeviceInfoTableViewController *)[storyboard instantiateViewControllerWithIdentifier:@"MPBTDeviceInfoTableViewController"];
                settingsViewController.device = sprocket.accessory;
                
                UIViewController *topController = [UIApplication sharedApplication].keyWindow.rootViewController;
                
                while (topController.presentedViewController) {
                    topController = topController.presentedViewController;
                }
                
                [((UINavigationController *)topController) pushViewController:settingsViewController animated:YES];
            #endif
        }
    } else {
        [self refreshPairedDevices];
    }
}

#pragma mark - Button Listeners

- (IBAction)didPressCancel:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Util

- (EAAccessory *)lastAccessoryUsed
{
    EAAccessory *lastAccessory = nil;
    NSString *lastPrinterUsedName = [MPBTPairedAccessoriesViewController lastPrinterUsed];
    
    for (EAAccessory *acc in self.pairedDevices) {
        if ([[MPBTSprocket displayNameForAccessory:acc] isEqualToString:lastPrinterUsedName]) {
            lastAccessory = acc;
            break;
        }
    }
    
    return lastAccessory;
}

+ (void)setLastPrinterUsed:(NSString *)lastPrinterUsed
{
    [[NSUserDefaults standardUserDefaults] setObject:lastPrinterUsed forKey:kMPBTLastPrinterNameSetting];
}

+ (NSString *)lastPrinterUsed
{
    return [[NSUserDefaults standardUserDefaults] objectForKey:kMPBTLastPrinterNameSetting];
}

+ (void)presentNoPrinterConnectedAlert:(UIViewController *)hostController
{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:MPLocalizedString(@"Printer not connected to device", @"Title of dialog letting the user know that there is no sprocket paired with their phone")
                                                                   message:MPLocalizedString(@"Make sure the printer is turned on and check the Bluetooth connection.", @"Body of dialog letting the user know that there is no sprocket paired with their phone")
                                                            preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:MPLocalizedString(@"OK", @"Dismisses dialog without taking action")
                                                       style:UIAlertActionStyleCancel
                                                     handler:nil];
    [alert addAction:okAction];
    
    [hostController presentViewController:alert animated:YES completion:nil];
    
    NSString *source = @"Print";
    if ([hostController isKindOfClass:[MPBTPairedAccessoriesViewController class]]) {
        if (nil == ((MPBTPairedAccessoriesViewController *)hostController).image) {
            source = @"DeviceInfo";
        }
    }
    NSDictionary *dictionary = @{kMPBTPrinterNotConnectedSourceKey : source};
    [[NSNotificationCenter defaultCenter] postNotificationName:kMPBTPrinterNotConnectedNotification object:nil userInfo:dictionary];
}

- (void)becomeActive:(NSNotification *)notification {
    [self refreshPairedDevices];
}

- (void)refreshPairedDevices
{
    self.otherDevices = [[NSMutableArray alloc] init];
    self.recentDevice = nil;
    self.pairedDevices = [MPBTSprocket pairedSprockets];
    
    if (self.image) {
        self.recentDevice = [self lastAccessoryUsed];
        if (self.recentDevice) {
            for (EAAccessory *acc in self.pairedDevices) {
                if (![[MPBTSprocket displayNameForAccessory:acc] isEqualToString:[MPBTSprocket displayNameForAccessory:self.recentDevice]]) {
                    [self.otherDevices addObject:acc];
                }
            }
        }
    }
    
    [self.tableView reloadData];
}

@end
