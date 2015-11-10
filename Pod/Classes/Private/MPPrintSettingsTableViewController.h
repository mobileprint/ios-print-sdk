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

#import <UIKit/UIKit.h>
#import "MPPrintSettings.h"

@protocol MPPrintSettingsTableViewControllerDelegate;

/*!
 * @abstract Controls the view that allows user to configure print settings
 */
@interface MPPrintSettingsTableViewController : UITableViewController

/*!
 * @abstract Delegate used to indicate when print settings are changed by the user
 * @seealso MPPrintSettingsTableViewControllerDelegate
 */
@property (nonatomic, weak) id<MPPrintSettingsTableViewControllerDelegate> delegate;

/*!
 * @abstract Represents the current print settings
 * @seealso MPPrintSettings
 */
@property (nonatomic, strong) MPPrintSettings *printSettings;

/*!
 * @abstract A boolean indicating if the default printer should be used
 * @discussion If the default printer is not used then the last printer will be used instead (if available)
 */
@property (nonatomic, assign) BOOL useDefaultPrinter;

@end

/*!
 * @abstract Protocol that is used to notify when print settings are changed
 */
@protocol MPPrintSettingsTableViewControllerDelegate <NSObject>

- (void)printSettingsTableViewController:(MPPrintSettingsTableViewController *)paperTypeTableViewController didChangePrintSettings:(MPPrintSettings *)printSettings;

@end

