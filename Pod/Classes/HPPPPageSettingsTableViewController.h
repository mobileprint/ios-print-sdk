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

#import "HPPPPageViewController.h"

@protocol PGPageSettingsTableViewControllerDelegate;

@interface HPPPPageSettingsTableViewController : UITableViewController

@property (assign, nonatomic) BOOL hideBlackAndWhiteOption;
@property (strong, nonatomic) UIImage *image;
@property (nonatomic, weak) id<PGPageSettingsTableViewControllerDelegate> delegate;
@property (nonatomic, weak) HPPPPageViewController *pageViewController;

@end


@protocol PGPageSettingsTableViewControllerDelegate <NSObject>

- (void)pageSettingsTableViewControllerDidFinishPrintFlow:(HPPPPageSettingsTableViewController *)pageSettingsTableViewController;
- (void)pageSettingsTableViewControllerDidCancelPrintFlow:(HPPPPageSettingsTableViewController *)pageSettingsTableViewController;

@end