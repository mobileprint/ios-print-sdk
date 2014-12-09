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

/*!
 If this value is true, the black & white filter option is shown together with the paper size and paper type in the page settings screen.
 
 By default, this value is false and the black & white filter option is shown.
 */
@property (assign, nonatomic) BOOL hideBlackAndWhiteOption;

/*!
 The image to show in the preview view.
 */
@property (strong, nonatomic) UIImage *image;

@property (nonatomic, weak) id<PGPageSettingsTableViewControllerDelegate> delegate;
@property (nonatomic, weak) HPPPPageViewController *pageViewController;

@end


@protocol PGPageSettingsTableViewControllerDelegate <NSObject>

/*!
 Indicates when the print flows finishes after the print job is sent to the print pool.
 \param pageSettingsTableViewController The class that calls the delegate
 \returns N/A.
 */
- (void)pageSettingsTableViewControllerDidFinishPrintFlow:(HPPPPageSettingsTableViewController *)pageSettingsTableViewController;
- (void)pageSettingsTableViewControllerDidCancelPrintFlow:(HPPPPageSettingsTableViewController *)pageSettingsTableViewController;

@end