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

#import "MPPageSettingsSplitViewController.h"
#import "MPPageSettingsTableViewController.h"

@interface MPPageSettingsSplitViewController () <UISplitViewControllerDelegate>

@end

@implementation MPPageSettingsSplitViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.delegate = self;
}

- (void)willTransitionToTraitCollection:(UITraitCollection *)newCollection withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator
{
    if (self.traitCollection.horizontalSizeClass != newCollection.horizontalSizeClass) {
        for (UINavigationController *nav in self.viewControllers) {
            for (MPPageSettingsTableViewController *vc in nav.viewControllers) {
                if ([vc isKindOfClass:[MPPageSettingsTableViewController class]]) {
                    [vc respondToSplitControllerTraitChange:newCollection];
                }
            }
        }
    }
    
    [super willTransitionToTraitCollection:newCollection withTransitionCoordinator:coordinator];
}

#pragma mark - UISplitViewControllerDelegate

- (UISplitViewControllerDisplayMode)targetDisplayModeForActionInSplitViewController:(UISplitViewController *)svc
{
    UISplitViewControllerDisplayMode retVal = UISplitViewControllerDisplayModeAutomatic;
    if (UIUserInterfaceSizeClassCompact == self.traitCollection.horizontalSizeClass) {
        retVal = UISplitViewControllerDisplayModeAllVisible;
    }
    
    return retVal;
}

- (UIViewController *)primaryViewControllerForCollapsingSplitViewController:(UISplitViewController *)splitViewController
{
    UINavigationController *primary = nil;
    for (UINavigationController *nav in self.viewControllers) {
        for (MPPageSettingsTableViewController *vc in nav.viewControllers) {
            if ([vc isKindOfClass:[MPPageSettingsTableViewController class]]) {
                [vc respondToSplitControllerTraitChange:self.traitCollection];
                if (nil != vc.previewViewController) {
                    primary = nav;
                }
            }
        }
    }

    return primary;
}

- (BOOL)splitViewController:(UISplitViewController *)splitViewController collapseSecondaryViewController:(UIViewController *)secondaryViewController ontoPrimaryViewController:(UIViewController *)primaryViewController
{
    BOOL retVal = NO;
    if (UIUserInterfaceSizeClassCompact == self.traitCollection.horizontalSizeClass) {
        retVal = YES;
    }
    
    return retVal;
}

- (UIViewController *)splitViewController:(UISplitViewController *)splitViewController separateSecondaryViewControllerFromPrimaryViewController:(UIViewController *)primaryViewController
{
    UIViewController *retVal = nil;
    
    if ([primaryViewController isKindOfClass:[UINavigationController class]]) {
        UINavigationController *navController = primaryViewController;
        if (navController.viewControllers            &&
            navController.viewControllers.count > 0  &&
            [navController.viewControllers[0] isKindOfClass:[MPPageSettingsTableViewController class]]) {
            
            MPPageSettingsTableViewController *vc = navController.viewControllers[0];
            retVal = vc.previewViewController.navigationController;
        }
    }
    return retVal;
}

@end
