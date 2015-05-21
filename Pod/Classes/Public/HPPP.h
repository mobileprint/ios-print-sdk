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
#import "HPPPAppearance.h"
#import "HPPPPaper.h"
#import "HPPPPrintActivity.h"
#import "HPPPPrintLaterActivity.h"
#import "HPPPPrintLaterJob.h"
#import "HPPPSupportAction.h"
#import "HPPPLogger.h"

@class HPPPPrintItem;

#define LAST_PRINTER_USED_URL_SETTING @"lastPrinterUrlUsed"

#define IS_IPHONE (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
#define IS_IPAD (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)

#define IS_OS_8_OR_LATER ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0)

#define IS_IPHONE_4 ([[UIScreen mainScreen] bounds].size.height == 480.0f)
#define IS_IPHONE_5 ([[UIScreen mainScreen] bounds].size.height == 568.0f)
#define IS_IPHONE_6 ([[UIScreen mainScreen] bounds].size.height == 667.0f)
#define IS_IPHONE_6_PLUS ([[UIScreen mainScreen] bounds].size.height == 736.0f)

#define IS_SPLIT_VIEW_CONTROLLER_IMPLEMENTATION (IS_OS_8_OR_LATER && IS_IPAD)

#define IS_PORTRAIT UIDeviceOrientationIsPortrait([UIApplication sharedApplication].statusBarOrientation)
#define IS_LANDSCAPE UIDeviceOrientationIsLandscape([UIApplication sharedApplication].statusBarOrientation)

#define DEGREES_TO_RADIANS(x) (x * M_PI/180.0)

extern NSString * const kLaterActionIdentifier;
extern NSString * const kPrintActionIdentifier;
extern NSString * const kPrintCategoryIdentifier;

@protocol HPPPPrintDelegate;
@protocol HPPPPrintDataSource;

/*!
 * @abstract Main HP Photo Print manager class
 * @discussion This singleton class manages configuration settings and stored job information.
 */
@interface HPPP : NSObject

/*!
 * @abstract Notifies subscribers that a share action was completed
 * @discussion Clients can use this notification to indicate that the user completed a sharing action. This is useful for collecting and reporting analytics.
 */
extern NSString * const kHPPPShareCompletedNotification;

/*!
 * @abstract Notifies subscribers that a trackable screen was visited
 * @discussion Clients can use this notification to indicate that the user visited a trackable screen. This is useful for collecting and reporting analytics.
 * @seealso kHPPPTrackableScreenNameKey
 */
extern NSString * const kHPPPTrackableScreenNotification;

/*!
 * @abstract Used to retrieve name of the trackable screen
 * @discussion This key works with the trackable screen notification to inform the client application when a trackable screen was visited.
 * @seealso kHPPPTrackableScreenNotification
 */
extern NSString * const kHPPPTrackableScreenNameKey;

/*!
 * @abstract Notifies subscribers with the result of the printer avaiability check
 * @discussion Clients can use this notification to update the user interface with printer status
 * @seealso kHPPPPrinterAvailableKey
 * @seealso kHPPPPrinterAvailabilityNotification
 */
extern NSString * const kHPPPPrinterAvailabilityNotification;

/*!
 * @abstract Used to retrieve availability of the printer
 * @discussion This key works with the printer available notification to inform the client application whether the printer was available or not.
 * @seealso kHPPPPrinterAvailabilityNotification
 * @seealso kHPPPPrinterKey
 */
extern NSString * const kHPPPPrinterAvailableKey;

/*!
 * @abstract Used to retrieve printer that was checked for avaiability
 * @discussion This key works with the printer available notification to communicate the UIPrinter object that was checked for availability.
 * @seealso kHPPPPrinterAvailabilityNotification
 * @seealso kHPPPPrinterAvailableKey
 */
extern NSString * const kHPPPPrinterKey;

/*!
 * @abstract Notifies subscribers that a print queue operation was completed (print or delete)
 * @seealso kHPPPPrintQueueActionKey
 * @seealso kHPPPPrintQueueJobsKey
 */
extern NSString * const kHPPPPrintQueueNotification;

/*!
 * @abstract The notification sent when a job is added to the print queue
 */
extern NSString * const kHPPPPrintJobAddedToQueueNotification;

/*!
 * @abstract The notification sent when a job is removed from the print queue
 */
extern NSString * const kHPPPPrintJobRemovedFromQueueNotification;

/*!
 * @abstract The notification sent when all jobs are removed from the print queue
 */
extern NSString * const kHPPPAllPrintJobsRemovedFromQueueNotification;

/*!
 * @abstract Used to retrieve the action performed on the job
 * @seealso kHPPPPrintQueueNotification
 * @seealso kHPPPPrintQueueJobsKey
 */
extern NSString * const kHPPPPrintQueueActionKey;

/*!
 * @abstract Used to retrieve the HPPPPrintLater job that was printed or deleted
 * @seealso kHPPPPrintQueueNotification
 * @seealso kHPPPPrintQueueActionKey
 */
extern NSString * const kHPPPPrintQueueJobsKey;

/*!
 * @abstract Used to retrieve last paper size used
 * @discussion This key works with the dictionary contained in the @link lastOptionsUsed @/link property. If the last job was successful, the value for this key will contain the paper size used.
 * @seealso lastOptionsUsed
 */
extern NSString * const kHPPPPaperSizeId;

/*!
 * @abstract Used to retrieve last paper type used
 * @discussion This key works with the dictionary contained in the @link lastOptionsUsed @/link property. If the last job was successful, the value for this key will contain the paper type used.
 * @seealso lastOptionsUsed
 */
extern NSString * const kHPPPPaperTypeId;

/*!
 * @abstract Used to retrieve last black/white setting used
 * @discussion This key works with the dictionary contained in the @link lastOptionsUsed @/link property. If the last job was successful, the value for this key will contain a true/false value indicating if black/white was chosen.
 * @seealso lastOptionsUsed
 */
extern NSString * const kHPPPBlackAndWhiteFilterId;

/*!
 * @abstract Used to retrieve ID of the printer used for the last job
 * @discussion This key works with the dictionary contained in the @link lastOptionsUsed @/link property. If the last job was successful, the value for this key will contain the ID of the printer that was used.
 * @seealso lastOptionsUsed
 */
extern NSString * const kHPPPPrinterId;

/*!
 * @abstract Used to retrieve display name of the printer used for the last job
 * @discussion This key works with the dictionary contained in the @link lastOptionsUsed @/link property. Only available in iOS 8 after the printer has been contacted successfully.
 * @seealso lastOptionsUsed
 */
extern NSString * const kHPPPPrinterDisplayName;

/*!
 * @abstract Used to retrieve display location of the printer used for the last job
 * @discussion This key works with the dictionary contained in the @link lastOptionsUsed @/link property. Only available in iOS 8 after the printer has been contacted successfully.
 * @seealso lastOptionsUsed
 */
extern NSString * const kHPPPPrinterDisplayLocation;

/*!
 * @abstract Used to retrieve ID of the printer used for the last job
 * @discussion This key works with the dictionary contained in the @link lastOptionsUsed @/link property. Only available in iOS 8 after the printer has been contacted successfully.
 * @seealso lastOptionsUsed
 */
extern NSString * const kHPPPPrinterMakeAndModel;

/*!
 * @abstract Used to retrieve number of copies used for the last job
 * @discussion This key works with the dictionary contained in the @link lastOptionsUsed @/link property. If the last job was successful, the value for this key will contain the number of copies that was used.
 * @seealso lastOptionsUsed
 */
extern NSString * const kHPPPNumberOfCopies;

/*!
 * @abstract Job name of the print
 */
@property (strong, nonatomic) NSString *printJobName;

/*!
 * @abstract Indicates whether the black and white option should be hidden
 * @discussion If this value is true, the black and white filter option is hidden on the print preview page and the black and white filter is not used. The default values is false (not hidden).
 *   The black and white filter option is only available for iOS version 8.0 and above.
 */
@property (assign, nonatomic) BOOL hideBlackAndWhiteOption;

/*!
 * @abstract Indicates whether the paper size option should be hidden
 * @discussion If this value is true, the paper size option is hidden on the print preview page and the default paper size is used. The default values is false (not hidden).
 * @seealso defaultPaperWidth
 * @seealso defaultPaperHeight
 */
@property (assign, nonatomic) BOOL hidePaperSizeOption;

/*!
 * @abstract Indicates whether the paper type option should be hidden
 * @discussion If this value is true, the paper type option is hidden on the print preview page and the default paper type is used if applicable (e.g. 4x6 always uses photo paper regardless of the value of the default paper type). The default value is false (not hidden).
 * @seealso defaultPaperType
 */
@property (assign, nonatomic) BOOL hidePaperTypeOption;

/*!
 * @abstract List of supported paper sizes
 * @discussion An array of string values specifying the title of the paper sizes to display. These titles are shown in the paper size selection page and must map to known @link PaperSize @/link defined in @link HPPPPaper @/link .
 * @seealso HPPPPaper
 * @seealso PaperSize
 * @seealso titleFromSize:
 */
@property (strong, nonatomic) NSArray *paperSizes;

/*!
 * @abstract Default paper
 * @discussion An @link HPPPPaper @/link object specifying the default paper size and type to use. This object is used to set the initial selection for paper size and paper type. It is also used as the value for paper size when the paper size selection is hidden. Default initial value is @link Size5x7 @/link .  Note that paper type does not apply to all paper sizes (e.g. 4x6 always uses photo paper regardless what paper type is specified). Default value is @link Photo @/link .
 * @seealso hidePaperSizeOption
 * @seealso PaperSize
 * @seealso hidePaperTypeOption
 * @seealso PaperType
 */
@property (strong, nonatomic) HPPPPaper *defaultPaper;

/*!
 * @abstract Zoom and crop
 * @discussion Specify if the image should zoom and crop in case the image size doesn't match with the paper size.
 */
@property (assign, nonatomic) BOOL zoomAndCrop;

/*!
 * @abstract Font used for the ruler labels
 */
@property (strong, nonatomic) UIFont *rulesLabelFont;

/*!
 * @abstract Font used for the print label
 * @discussion Used for the print label on the print preview page.
 */
@property (strong, nonatomic) UIFont *tableViewCellPrintLabelFont;

/*!
 * @abstract Color used for the print label
 * @discussion Used for the print label on the print preview page.
 */
@property (strong, nonatomic) UIColor *tableViewCellPrintLabelColor;

/*!
 * @abstract Font used for the support header label
 * @discussion Used for the support header label warning on the print preview page.
 */
@property (strong, nonatomic) UIFont *tableViewSupportHeaderLabelFont;

/*!
 * @abstract Color used for the support header label
 * @discussion Used for the support header label warning on the print preview page.
 */
@property (strong, nonatomic) UIColor *tableViewSupportHeaderLabelColor;

/*!
 * @abstract Font used for the footer label warning
 * @discussion Used for the footer label warning on the print preview page.
 */
@property (strong, nonatomic) UIFont *tableViewFooterWarningLabelFont;

/*!
 * @abstract Color used for the footer label warning
 * @discussion Used for the footer label warning on the print preview page.
 */
@property (strong, nonatomic) UIColor *tableViewFooterWarningLabelColor;

/*!
 * @abstract Font used for the label of properties
 * @discussion Used for the name of properties on the print preview page (e.g. Paper Size, Paper Type).
 */
@property (strong, nonatomic) UIFont *tableViewCellLabelFont;

/*!
 * @abstract Color used for the label of properties
 * @discussion Used for the name of properties on the print preview page (e.g. Paper Size, Paper Type).
 */
@property (strong, nonatomic) UIColor *tableViewCellLabelColor;

/*!
 * @abstract Font used for the value of properties
 * @discussion Used for the value of properties on the print preview page (e.g. 4 x 6, Plain Paper).
 */
@property (strong, nonatomic) UIFont *tableViewCellValueFont;

/*!
 * @abstract Color used for the value of properties
 * @discussion Used for the currently selected value of properties on the print preview page (e.g. 4 x 6, Plain Paper).
 */
@property (strong, nonatomic) UIColor *tableViewCellValueColor;

/*!
 * @abstract Font used for the settings value of properties
 * @discussion Used for the value of properties on the print preview page (e.g. 4 x 6, Plain Paper).
 */
@property (strong, nonatomic) UIFont *tableViewSettingsCellValueFont;

/*!
 * @abstract Color used for the settings value of properties
 * @discussion Used for the currently selected value of properties on the print preview page (e.g. 4 x 6, Plain Paper).
 */
@property (strong, nonatomic) UIColor *tableViewSettingsCellValueColor;

/*!
 * @abstract Color used for action link text
 * @discussion Used for one or more action links shown at the bottom of the print preview page
 */
@property (strong, nonatomic) UIColor *tableViewCellLinkLabelColor;

/*!
 * @abstract A string with the default date format
 * @discussion The default date format applies to all the screens where a date is present.
 */
@property (strong, nonatomic) NSString *defaultDateFormat;

/*!
 * @abstract If TRUE, rulers will be displayed beneath and to the right of the preview image to show the image size.
 * @discussion The default value is FALSE, which causes the size to be specified in a label centered beneath the image.
 */
@property (assign, nonatomic) BOOL showRulers;

/*!
 * @abstract A dictionary of the most recent print options used
 * @discussion If the last print job was successful this property contains a dictionary of various options used for the job. If the last print job failed or was canceled then this property contains an empty dictionary.
 * @seealso kHPPPBlackAndWhiteFilterId
 * @seealso kHPPPPaperSizeId
 * @seealso kHPPPPaperTypeId
 * @seealso kHPPPPrinterId
 * @seealso kHPPPPrinterDisplayName
 * @seealso kHPPPPrinterDisplayLocation
 * @seealso kHPPPPrinterMakeAndModel
 * @seealso kHPPPNumberOfCopies
 */
@property (strong, nonatomic) NSDictionary *lastOptionsUsed;

/*!
 * @abstract An array of support actions to display on the print preview page
 * @discussion This is an array of @link HPPPSupportAction @/link objects, each describing a single support action. Support actions include an icon and a title and are displayed in a support section at the bottom of the print preview page. An action can either open a URL or present a view controller.
 * @seealso HPPPSupportAction
 */
@property (strong, nonatomic) NSArray *supportActions;

/*!
 * @abstract Causes the HPPrintProvider pod to handle metrics for the print activity.
 * @discussion Defaults to YES. If set to NO, the pod will not send metrics for the print activity automatically. However, the client application can still record print metrics using the notification kHPPPShareCompletedNotification.
 * @seealso kHPPPShareCompletedNotification
 */
@property (assign, nonatomic) BOOL handlePrintMetricsAutomatically;

/*!
 * @abstract Used to customize look and feel
 * @discussion Allows customization of the look and feel of the print later screens (e.g. fonts, colors, buttons, etc.).
 */
@property (strong, nonatomic) HPPPAppearance *appearance;

/*!
 * @abstract Indicates if an offramp is a printing offramp
 * @description Identifies print-related offramps such as print, add to queue, and delete from queue.
 * @return YES or NO indicating if the offramp provided is a print-related offramp
 */
- (BOOL)printingOfframp:(NSString *)offramp;

/*!
 * @abstract Prepares a view controller suitable for the device and OS
 * @description This method prepares a view controller for displaying the print flow. It takes into consideration the device type and OS and prepares either a split view controller (iPad with iOS 8 or above) or a standard view controller. Both types are wrapped in a navigation controller. The controller returned is suitable for using with the UIActivity method 'activityViewController'.
 * @param delegate An optional delegate object that implements the HPPPPrintDelegate protocol
 * @param dataSource An optional data source object that implements the HPPPPrintDataSource protocol
 * @param printingItem The item to print
 * @param previewImage The initial image to use for the print preview
 * @param fromQueue A boolean value indicating if this job is being printed from the print queue
 * @return The view controller that the client should present
 */
- (UIViewController *)printViewControllerWithDelegate:(id<HPPPPrintDelegate>)delegate dataSource:(id<HPPPPrintDataSource>)dataSource printItem:(HPPPPrintItem *)printItem fromQueue:(BOOL)fromQueue;

/*!
 * @abstract User notification category used for print reminder
 * @discussion UIUserNotificationCategory to register in the clients for push notifications of the print later. The clients must do the registration because it may happen that the client have other notification categories to register, and all the registration must be do at the same time, otherwise the new category will override the previous one.
 */
- (UIUserNotificationCategory *)printLaterUserNotificationCategory;

/*!
 * @abstract Handles when the user taps an action button on the notification dialog
 */
- (void)handleNotification:(UILocalNotification *)notification;

/*!
 * @abstract Handles when the user taps the notification itself
 * @discussion This method is called when the user taps the notification body itself rather than one of the specific action buttons
 */
- (void)handleNotification:(UILocalNotification *)notification action:(NSString *)action;

/*!
 * @abstract Displays the list of print jobs modally
 * @discussion This method prepares an instance of a view controller with the contents of the print queue and displays it modally.
 * @param controller The controller used as the parent for displaying the modal view controller
 * @param animated A boolean indicating whether or not to animate the display
 * @param completion A block to call when the display animation is complete
 */
- (void)presentPrintQueueFromController:(UIViewController *)controller animated:(BOOL)animated completion:(void(^)(void))completion;

/*!
 * @abstract Retrieves the total number of jobs currently in the print queue
 * @return An integer representing the number of jobs
 */
- (NSInteger)numberOfJobsInQueue;

/*!
 * @abstract Used to get the next available job ID
 * @return The next available job ID
 */
- (NSString *)nextPrintJobId;

/*!
 * @abstract Add a print job to the print queue
 */
- (void)addJobToQueue:(HPPPPrintLaterJob *)job;

/*!
 * @abstract Removes all jobs from the print queue
 */
- (void)clearQueue;

/*!
 * @abstract Indicates whether or not Wi-Fi is connected
 * @return YES or NO
 */
- (BOOL)isWifiConnected;

/*!
 * @abstract Used to access the singleton instance of this class
 */
+ (HPPP *)sharedInstance;

@end

/*!
 * @abstract Defines a delegate protocal for reporting print events
 * @seealso HPPPPrintDataSource
 */
@protocol HPPPPrintDelegate <NSObject>

/*!
 * @abstract Called when the print flow finishes successfully
 * @discussion This delegate method is called when the print flow finishes successfully. This means that the print job was sent to the printer without error. It does not mean that the job was completed and printed without error, just that the job was queued successfully. Errors such as out-of-paper could still occur after this method is called.
 * @param printViewController The view controller calling the method
 * @returns Nothing
 * @seealso didCancelPrintFlow:
 */
- (void)didFinishPrintFlow:(UIViewController *)printViewController;

/*!
 * @abstract Called when the print flow is canceled
 * @discussion This method is called when the print flow is canceled by the user. If the print job is queued successfully but subsequently canceled by the user in the Print Center, this method is not called.
 * @param printViewController The view controller calling the method
 * @returns Nothing
 * @seealso didFinishPrintFlow:
 */
- (void)didCancelPrintFlow:(UIViewController *)printViewController;

@end

/*!
 * @abstract Defines a data source protocol for requesting the printable image
 * @seealso HPPPPrintDelegate
 */
@protocol HPPPPrintDataSource <NSObject>

/*!
 * @abstract Called when a new printing item is needed
 * @discussion This method is called when initiating the print flow or whenever relevant parameters are changed (e.g. page size).
 * @param paper The @link HPPPPaper @/link object that the item will be laid out on
 * @seealso HPPPPaper
 */
- (void)printingItemForPaper:(HPPPPaper *)paper withCompletion:(void (^)(HPPPPrintItem * printItem))completion;

/*!
 * @abstract Called when a new preview image is needed
 * @discussion This method is called when initiating the print flow or whenever relevant parameters are changed (e.g. page size).
 * @param paper The @link HPPPPaper @/link object that the item will be laid out on
 * @seealso HPPPPaper
 */
- (void)previewImageForPaper:(HPPPPaper *)paper withCompletion:(void (^)(UIImage *previewImage))completion;

@optional

/*!
 * @abstract Called to request the total number of print jobs to print
 * @return The number of jobs to print
 * @seealso printingItemsForPaper:
 */
- (NSInteger)numberOfPrintingItems;

/*!
 * @abstract Called to request the printing item for each job
 * @param paper The type and size of paper being requested
 * @return An array of printing items for this paper size/type, one item per job
 * @seealso numberOfPrintingItems
 */
- (NSArray *)printingItemsForPaper:(HPPPPaper *)paper;

@end
