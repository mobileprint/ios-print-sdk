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
#import "HPPPPageViewController.h"
#import "HPPP.h"

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
@property (nonatomic, weak) id<HPPPPrintDelegate> delegate;

/*!
 * @abstract Provides the printable image asset
 * @discussion The data source is used to provide an image to use for printing. A new image is requested whenever relevant parameters change (e.g. the user picks a new page size).
 * @seealso HPPPPrintDataSource
 */
@property (nonatomic, weak) id<HPPPPrintDataSource> dataSource;

/*!
 * @abstract The graphical page representation part of the print preview
 * @discussion The pageViewController is reponsible for displaying a graphical representation of the print on the page. It is one part of the overall page settings view also known as the print preview.
 */
@property (nonatomic, weak) HPPPPageViewController *pageViewController;

/*!
 * @abstract Indicates whether printing was initiated from the print queue
 */
@property (assign, nonatomic) BOOL printFromQueue;

/*!
 * @abstract Indicates whether controller is used for settings only rather than actual printing
 */
@property (assign, nonatomic) BOOL settingsOnly;

/*!
 * @abstract Causes a refresh of the data displayed by the view controller
 */
- (void)refreshData;

@end
