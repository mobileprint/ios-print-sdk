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

@protocol HPPPPageSettingsTableViewControllerDelegate;
@protocol HPPPPageSettingsTableViewControllerDataSource;

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
 * @abstract The image used for printing
 * @discussion This image is used for both displaying in the print preview and in the actual print job itself.
 */
@property (strong, nonatomic) UIImage *image;

/*!
 * @abstract Notified when print events occur
 * @discussion This delegate is notified whenever the print flow completes or gets canceled.
 * @seealso HPPPPageSettingsTableViewControllerDelegate
 */
@property (nonatomic, weak) id<HPPPPageSettingsTableViewControllerDelegate> delegate;

/*!
 * @abstract Provides the printable image asset
 * @discussion The data source is used to provide an image to use for printing. A new image is requested whenever relevant parameters change (e.g. the user picks a new page size).
 * @seealso HPPPPageSettingsTableViewControllerDataSource
 */
@property (nonatomic, weak) id<HPPPPageSettingsTableViewControllerDataSource> dataSource;

/*!
 * @abstract The graphical page representation part of the print preview
 * @discussion The pageViewController is reponsible for displaying a graphical representation of the print on the page. It is one part of the overall page settings view also known as the print preview.
 */
@property (nonatomic, weak) HPPPPageViewController *pageViewController;

/*!
 * @abstract Use the default printer instead of the last printer
 * @discussion Normally, the last printer used is pre-populated when the page settings are displayed. Set this to YES to attempt to use the default printer instead
 */
@property (nonatomic, assign) BOOL printFromQueue;

@end

/*!
 * @abstract Defines a delegate protocal for reporting print events
 * @seealso HPPPPageSettingsTableViewControllerDataSource
 */
@protocol HPPPPageSettingsTableViewControllerDelegate <NSObject>

/*!
 * @abstract Called when the print flow finishes successfully
 * @discussion This delegate method is called when the print flow finishes successfully. This means that the print job was sent to the printer without error. It does not mean that the job was completed and printed without error, just that the job was queued successfully. Errors such as out-of-paper could still occur after this method is called.
 * @param pageSettingsTableViewController The page settings view controller calling the method
 * @returns Nothing
 * @seealso pageSettingsTableViewControllerDidCancelPrintFlow:
 */
- (void)pageSettingsTableViewControllerDidFinishPrintFlow:(HPPPPageSettingsTableViewController *)pageSettingsTableViewController;

/*!
 * @abstract Called when the print flow is canceled
 * @discussion This method is called when the print flow is canceled by the user. If the print job is queued successfully but subsequently canceled by the user in the Print Center, this method is not called.
 * @param pageSettingsTableViewController The page settings view controller calling the method
 * @returns Nothing
 * @seealso pageSettingsTableViewControllerDidFinishPrintFlow:
 */
- (void)pageSettingsTableViewControllerDidCancelPrintFlow:(HPPPPageSettingsTableViewController *)pageSettingsTableViewController;

@end

/*!
 * @abstract Defines a data source protocal for requesting the printable image
 * @seealso HPPPPageSettingsTableViewControllerDelegate
 */
@protocol HPPPPageSettingsTableViewControllerDataSource <NSObject>

/*!
 * @abstract Called when a new printable image is needed
 * @discussion This method is called when initiating the print flow or whenever relevant parameters are changed (e.g. page size).
 * @param paper The @link HPPPPaper @/link object that the image will be laid out on
 * @seealso HPPPPaper
 */
- (void)pageSettingsTableViewControllerRequestImageForPaper:(HPPPPaper *)paper withCompletion:(void (^)(UIImage *))completion;

@optional

/*!
 * @abstract Called to request the total number of print jobs to print
 * @return The number of jobs to print
 * @seealso pageSettingsTableViewControllerRequestImagesForPaper:
 */
- (NSInteger)pageSettingsTableViewControllerRequestNumberOfImagesToPrint;

/*!
 * @abstract Called to request the images for each job
 * @param paper The type and size of paper being requested
 * @return An array of images for this paper size/type, one image per job
 * @seealso pageSettingsTableViewControllerRequestNumberOfImagesToPrint
 */
- (NSArray *)pageSettingsTableViewControllerRequestImagesForPaper:(HPPPPaper *)paper;

@end
