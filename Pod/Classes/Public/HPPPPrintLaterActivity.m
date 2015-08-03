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

#import "HPPP.h"
#import "HPPPPrintLaterActivity.h"
#import "HPPPPrintLaterQueue.h"
#import "HPPPAddPrintLaterJobTableViewController.h"
#import "NSBundle+HPPPLocalizable.h"

@interface HPPPPrintLaterActivity () <HPPPAddPrintLaterDelegate>

@end

@implementation HPPPPrintLaterActivity

- (NSString *)activityType
{
    return @"HPPPPrintLaterActivity";
}

- (NSString *)activityTitle
{
    return HPPPLocalizedString(@"Print Queue", @"Activity title of the print queue when the share button is tapped");
}

- (UIImage *)_activityImage
{
    return [UIImage imageNamed:@"HPPPPrintLater"];
}

- (BOOL)canPerformWithActivityItems:(NSArray *)activityItems
{
    return YES;
}

- (UIViewController *)activityViewController
{
//    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"HPPP" bundle:[NSBundle mainBundle]];
//    
//    UINavigationController *navigationController = (UINavigationController *)[storyboard instantiateViewControllerWithIdentifier:@"HPPPAddPrintLaterJobNavigationController"];
//    
//    HPPPAddPrintLaterJobTableViewController *addPrintLaterJobTableViewController = (HPPPAddPrintLaterJobTableViewController *) navigationController.topViewController;
//    
//    addPrintLaterJobTableViewController.printLaterJob = self.printLaterJob;
//    addPrintLaterJobTableViewController.delegate = self;
//    
//    return navigationController;
    return [[HPPP sharedInstance] printLaterViewControllerWithDelegate:self printLaterJob:self.printLaterJob];
}

#pragma mark - HPPPAddPrintLaterJobTableViewControllerDelegate

- (void)didFinishAddPrintLaterFlow:(HPPPAddPrintLaterJobTableViewController *)addPrintLaterJobTableViewController
{
    dispatch_async(dispatch_get_main_queue(), ^ {
        [self activityDidFinish:YES];
    });
}

- (void)didCancelAddPrintLaterFlow:(HPPPAddPrintLaterJobTableViewController *)addPrintLaterJobTableViewController
{
    dispatch_async(dispatch_get_main_queue(), ^ {
        [self activityDidFinish:NO];
    });
}

@end
