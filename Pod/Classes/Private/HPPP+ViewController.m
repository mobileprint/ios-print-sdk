//
// Hewlett-Packard Company
// All rights reserved.
//
// This file, its contents, concepts, methods, behavior, and operation
// (collectively the "Software") are protected by trade secret, patent,
// and copyright laws. The use of the Software is governed by a license
// agreement. Disclosure of the Software to third parties, in any form,
// in whole or in part, is expressly prohibited except as authorized by
// the license agreement.
//

#import "HPPP+ViewController.h"

@implementation HPPP (ViewController)

+ (UIViewController *)activityViewControllerWithOwner:(id<HPPPPageSettingsTableViewControllerDelegate, HPPPPageSettingsTableViewControllerDataSource>)owner andImage:(UIImage *)image andUseDefaultPrinter:(BOOL)useDefaultPrinter
{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"HPPP" bundle:[NSBundle mainBundle]];
    
    if (IS_SPLIT_VIEW_CONTROLLER_IMPLEMENTATION) {
        UISplitViewController *pageSettingsSplitViewController = (UISplitViewController *)[storyboard instantiateViewControllerWithIdentifier:@"HPPPPageSettingsSplitViewController"];
        
        UINavigationController *detailsNavigationController = pageSettingsSplitViewController.viewControllers[1];
        detailsNavigationController.navigationBar.translucent = NO;
        HPPPPageViewController *pageViewController = (HPPPPageViewController *)detailsNavigationController.topViewController;
        pageViewController.image = image;
        
        UINavigationController *masterNavigationController = pageSettingsSplitViewController.viewControllers[0];
        masterNavigationController.navigationBar.translucent = NO;
        HPPPPageSettingsTableViewController *pageSettingsTableViewController = (HPPPPageSettingsTableViewController *)masterNavigationController.topViewController;
        pageSettingsTableViewController.delegate = owner;
        pageSettingsTableViewController.dataSource = owner;
        pageSettingsTableViewController.useDefaultPrinter = useDefaultPrinter;
        
        pageSettingsTableViewController.image = image;
        pageSettingsTableViewController.pageViewController = pageViewController;
        pageSettingsSplitViewController.preferredDisplayMode = UISplitViewControllerDisplayModeAllVisible;
        
        return pageSettingsSplitViewController;
    } else {
        // Is not possible to use UISplitViewController in iOS 7 without been the first view controller of the app. You can however do tricky workarounds like embbeding the Split View Controller in a Container View Controller, but that can end up in difficult bugs to find.
        // From Apple Documentation (iOS 7):
        // "you must always install the view from a UISplitViewController object as the root view of your application’s window. [...] Split view controllers cannot be presented modally."
        HPPPPageSettingsTableViewController *pageSettingsTableViewController = (HPPPPageSettingsTableViewController *)[storyboard instantiateViewControllerWithIdentifier:@"HPPPPageSettingsTableViewController"];
        
        pageSettingsTableViewController.image = image;
        pageSettingsTableViewController.delegate = owner;
        pageSettingsTableViewController.dataSource = owner;
        pageSettingsTableViewController.useDefaultPrinter = useDefaultPrinter;

        UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:pageSettingsTableViewController];
        navigationController.navigationBar.translucent = NO;
        navigationController.modalPresentationStyle = UIModalPresentationFormSheet;
        
        return navigationController;
    }
}

@end
