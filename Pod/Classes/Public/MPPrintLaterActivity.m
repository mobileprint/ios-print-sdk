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
#import "MPPrintLaterActivity.h"
#import "MPPrintLaterQueue.h"
#import "MPPageSettingsTableViewController.h"
#import "NSBundle+MPLocalizable.h"

@interface MPPrintLaterActivity () <MPAddPrintLaterDelegate>

@end

@implementation MPPrintLaterActivity

- (NSString *)activityType
{
    return @"MPPrintLaterActivity";
}

- (NSString *)activityTitle
{
    return MPLocalizedString(@"Print Queue", @"Activity title of the print queue when the share button is tapped");
}

- (UIImage *)_activityImage
{
    return [[MP sharedInstance].appearance.settings objectForKey:kMPActivityPrintQueueIcon];
}

- (BOOL)canPerformWithActivityItems:(NSArray *)activityItems
{
    return YES;
}

- (UIViewController *)activityViewController
{
    return [[MP sharedInstance] printLaterViewControllerWithDelegate:self printLaterJob:self.printLaterJob];
}

#pragma mark - MPAddPrintLaterJobTableViewControllerDelegate

- (void)didFinishAddPrintLaterFlow:(MPPageSettingsTableViewController *)addPrintLaterJobTableViewController
{
    dispatch_async(dispatch_get_main_queue(), ^ {
        [self activityDidFinish:YES];
    });
}

- (void)didCancelAddPrintLaterFlow:(MPPageSettingsTableViewController *)addPrintLaterJobTableViewController
{
    dispatch_async(dispatch_get_main_queue(), ^ {
        [self activityDidFinish:NO];
    });
}

@end
