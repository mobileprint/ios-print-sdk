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

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import "HPPP.h"

/*!
 * @abstract All of the different possible configurations for the HPPPPageSettingsTableViewController screen
 * @discussion The HPPPPageSettingsTableViewController is used for print, print-from-queue, add-to-print-queue, etc.  
 *   The mode property on HPPPPageSettingsTableViewController is set to display the proper configuration.
 */
typedef enum {
    HPPPPageSettingsModePrint,
    HPPPPageSettingsModePrintFromQueue,
    HPPPPageSettingsModeAddToQueue,
    HPPPPageSettingsModeSettingsOnly
} HPPPPageSettingsMode;

/*!
 * @abstract The view controller class for displaying the print preview
 * @discussion This class implements the view controller used for displaying the print preview screen and associated page settings used for printing.
 */
@interface HPPPPageSettingsTableViewController : UITableViewController

/*!
 * @abstract Notification sent when a default printer is added
 */
extern NSString * const kHPPPDefaultPrinterAddedNotification;

/*!
 * @abstract Notification sent when a default printer is removed
 */
extern NSString * const kHPPPDefaultPrinterRemovedNotification;

/*!
 * @abstract The item to be printed
 * @discussion This item is used in the actual print job.
 */
@property (strong, nonatomic) HPPPPrintItem *printItem;

/*!
 * @abstract Notified when print events occur
 * @discussion This delegate is notified whenever the print flow completes or gets canceled.
 * @seealso HPPPPrintDelegate
 */
@property (nonatomic, weak) id<HPPPPrintDelegate> printDelegate;

/*!
 * @abstract Notified when print-later events occur
 * @discussion This delegate is notified whenever the print-later flow completes or gets canceled.
 * @seealso HPPPPrintDelegate
 */
@property (nonatomic, weak) id<HPPPAddPrintLaterDelegate> printLaterDelegate;

/*!
 * @abstract Provides the printable image asset
 * @discussion The data source is used to provide an image to use for printing. A new image is requested whenever relevant parameters change (e.g. the user picks a new page size).
 * @seealso HPPPPrintDataSource
 */
@property (nonatomic, weak) id<HPPPPrintDataSource> dataSource;

/*!
 * @abstract Indicates whether printing was initiated from the print queue
 */
//@property (assign, nonatomic) BOOL printFromQueue;

/*!
 * @abstract Indicates whether controller is used for settings only rather than actual printing
 */
//@property (assign, nonatomic) BOOL settingsOnly;

/*!
 * @abstract Indicates whether controller is used for printing or adding a job to the print queue
 */
//@property (assign, nonatomic) BOOL addToPrintQueue;

/*!
 * @abstract The printLaterJob, if any, associated with the page settings
 */
@property (assign, nonatomic) HPPPPrintLaterJob *printLaterJob;

/*!
 * @abstract The type of page settings screen to display
 */
@property (assign, nonatomic) HPPPPageSettingsMode mode;

@property (assign, nonatomic) BOOL previewPane;
@property (assign, nonatomic) BOOL pageSettingsPane;

/*!
 * @abstract Causes a refresh of the data displayed by the view controller
 */
- (void)refreshData;

@end
