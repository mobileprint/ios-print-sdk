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
#import "HPPPPageSettingsTableViewController.h"
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
    return [[HPPP sharedInstance].appearance.settings objectForKey:kHPPPActivityPrintQueueIcon];
}

- (BOOL)canPerformWithActivityItems:(NSArray *)activityItems
{
    return YES;
}

- (UIViewController *)activityViewController
{
    return [[HPPP sharedInstance] printLaterViewControllerWithDelegate:self printLaterJob:self.printLaterJob];
}

#pragma mark - HPPPAddPrintLaterJobTableViewControllerDelegate

- (void)didFinishAddPrintLaterFlow:(HPPPPageSettingsTableViewController *)addPrintLaterJobTableViewController
{
    dispatch_async(dispatch_get_main_queue(), ^ {
        [self activityDidFinish:YES];
    });
}

- (void)didCancelAddPrintLaterFlow:(HPPPPageSettingsTableViewController *)addPrintLaterJobTableViewController
{
    dispatch_async(dispatch_get_main_queue(), ^ {
        [self activityDidFinish:NO];
    });
}

@end
