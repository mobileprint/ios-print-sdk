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

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "MPAppearance.h"
#import "MPPrintActivity.h"
#import "MPPrintLaterActivity.h"
#import "MPPrintLaterJob.h"
#import "MPSupportAction.h"
#import "MPLogger.h"
#import "MPInterfaceOptions.h"
#import "MPPrintSettings.h"

@class MPPaper;
@class MPPrintItem;
@protocol MPPrintPaperDelegate;
@protocol MPSprocketDelegate;

#define LAST_PRINTER_USED_URL_SETTING @"lastPrinterUrlUsed"
#define MP_ERROR_DOMAIN @"com.hp.mp"
#define MP_ANIMATION_DURATION 0.6F

#define IS_IPHONE (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
#define IS_IPAD (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)

#define IS_OS_8_OR_LATER ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0)

#define IS_IPHONE_4 ([[UIScreen mainScreen] bounds].size.height == 480.0f)
#define IS_IPHONE_5 ([[UIScreen mainScreen] bounds].size.height == 568.0f)
#define IS_IPHONE_6 ([[UIScreen mainScreen] bounds].size.height == 667.0f)
#define IS_IPHONE_6_PLUS ([[UIScreen mainScreen] bounds].size.height == 736.0f)

#define IS_USING_FULL_SCREEN CGRectEqualToRect([UIApplication sharedApplication].delegate.window.frame, [UIApplication sharedApplication].delegate.window.screen.bounds)

#define IS_SPLIT_VIEW_CONTROLLER_IMPLEMENTATION (IS_OS_8_OR_LATER && IS_IPAD && IS_USING_FULL_SCREEN)

#define IS_PORTRAIT UIDeviceOrientationIsPortrait([UIDevice currentDevice].orientation)
#define IS_LANDSCAPE UIDeviceOrientationIsLandscape([UIDevice currentDevice].orientation)

#define DEGREES_TO_RADIANS(x) (x * M_PI/180.0)

extern NSString * const kLaterActionIdentifier;
extern NSString * const kPrintActionIdentifier;
extern NSString * const kPrintCategoryIdentifier;

@protocol MPPrintDelegate;
@protocol MPPrintDataSource;
@protocol MPAddPrintLaterDelegate;

/*!
 * @abstract Main Mobile Print SDK manager class
 * @discussion This singleton class manages configuration settings and stored job information.
 */
@interface MP : NSObject

/*!
 * @abstract Indicates the version of the print library
 * @discussion Full version history can be found at: https://github.com/IPGPTP/mobile_print_sdk/wiki/Release-Notes
 */
extern NSString * const kMPLibraryVersion;

/*!
 * @abstract Notifies subscribers that a bluetooth print job was started
 * @discussion Clients can use this notification to indicate that a print has been started on a bluetooth device
 */
extern NSString * const kMPBTPrintJobStartedNotification;

/*!
 * @abstract Notifies subscribers that a bluetooth print job has completed
 * @discussion Clients can use this notification to indicate that a print has completed on a bluetooth device
 */
extern NSString * const kMPBTPrintJobCompletedNotification;

/*!
 * @abstract Used to retrieve the printer ID from bluetooth print job notifications
 * @discussion Clients can use this to retrieve the printer id from a notification's userInfo argument
 * @seealso kMPBTPrintJobStartedNotification
 * @seealso kMPBTPrintJobCompletedNotification
 */
extern NSString * const kMPBTPrintJobPrinterIdKey;

/*!
 * @abstract Used to retrieve the print job error from bluetooth print job completion notifications
 * @discussion Clients can use this to retrieve the error code from a notification's userInfo argument
 * @seealso kMPBTPrintJobCompletedNotification
 */
extern NSString * const kMPBTPrintJobErrorKey;

/*!
 * @abstract Used to retrieve the raw unlocalized the print job error from bluetooth print job completion notifications
 * @discussion Clients can use this to retrieve the error code from a notification's userInfo argument
 * @seealso kMPBTPrintJobCompletedNotification
 */
extern NSString * const kMPBTPrintJobErrorRawKey;

/*!
 * @abstract Notifies subscribers that a bluetooth operation could not be completed due to not having a bluetooth printer connected
 * @discussion Clients can use this notification to indicate that a printer could not be connected
 */
extern NSString * const kMPBTPrinterNotConnectedNotification;

/*!
 * @abstract Used to retrieve the source of a printer not connected notification
 * @discussion Clients can use this to retrieve the source of a printer not connected notification
 * @seealso kMPBTPrinterNotConnectedNotification
 */
extern NSString * const kMPBTPrinterNotConnectedSourceKey;

/*!
 * @abstract Notifies subscribers that a share action was completed
 * @discussion Clients can use this notification to indicate that the user completed a sharing action. This is useful for collecting and reporting analytics.
 */
extern NSString * const kMPShareCompletedNotification;

/*!
 * @abstract Notifies subscribers that a trackable screen was visited
 * @discussion Clients can use this notification to indicate that the user visited a trackable screen. This is useful for collecting and reporting analytics.
 * @seealso kMPTrackableScreenNameKey
 */
extern NSString * const kMPTrackableScreenNotification;

/*!
 * @abstract Used to retrieve name of the trackable screen
 * @discussion This key works with the trackable screen notification to inform the client application when a trackable screen was visited.
 * @seealso kMPTrackableScreenNotification
 */
extern NSString * const kMPTrackableScreenNameKey;

/*!
 * @abstract Notifies subscribers with the result of the printer avaiability check
 * @discussion Clients can use this notification to update the user interface with printer status
 * @seealso kMPPrinterAvailableKey
 * @seealso kMPPrinterAvailabilityNotification
 */
extern NSString * const kMPPrinterAvailabilityNotification;

/*!
 * @abstract Used to retrieve availability of the printer
 * @discussion This key works with the printer available notification to inform the client application whether the printer was available or not.
 * @seealso kMPPrinterAvailabilityNotification
 * @seealso kMPPrinterKey
 */
extern NSString * const kMPPrinterAvailableKey;

/*!
 * @abstract Used to retrieve printer that was checked for avaiability
 * @discussion This key works with the printer available notification to communicate the UIPrinter object that was checked for availability.
 * @seealso kMPPrinterAvailabilityNotification
 * @seealso kMPPrinterAvailableKey
 */
extern NSString * const kMPPrinterKey;

/*!
 * @abstract Notifies subscribers that a print queue operation was completed (print or delete)
 * @seealso kMPPrintQueueActionKey
 * @seealso kMPPrintQueueJobKey
 * @seealso kMPPrintQueuePrintItemKey
 */
extern NSString * const kMPPrintQueueNotification;

/*!
 * @abstract The notification sent when a job is added to the print queue
 */
extern NSString * const kMPPrintJobAddedToQueueNotification;

/*!
 * @abstract The notification sent when a job is removed from the print queue
 */
extern NSString * const kMPPrintJobRemovedFromQueueNotification;

/*!
 * @abstract The notification sent when all jobs are removed from the print queue
 */
extern NSString * const kMPAllPrintJobsRemovedFromQueueNotification;

/*!
 * @abstract Used to retrieve the action performed on the job
 * @seealso kMPPrintQueueNotification
 * @seealso kMPPrintQueueJobKey
 * @seealso kMPPrintQueuePrintItemKey
 */
extern NSString * const kMPPrintQueueActionKey;

/*!
 * @abstract Used to retrieve the MPPrintLater job that was printed or deleted
 * @seealso kMPPrintQueueNotification
 * @seealso kMPPrintQueueActionKey
 * @seealso kMPPrintQueuePrintItemKey
 */
extern NSString * const kMPPrintQueueJobKey;

/*!
 * @abstract Used to retrieve the specific print item from the job that was printed or deleted
 * @seealso kMPPrintQueueNotification
 * @seealso kMPPrintQueueActionKey
 * @seealso kMPPrintQueueJobKey
 */
extern NSString * const kMPPrintQueuePrintItemKey;

/*!
 * @abstract Notification used to indicate when Wi-Fi connection is established
 */
extern NSString * const kMPWiFiConnectionEstablished;

/*!
 * @abstract Notification used to indicate when Wi-Fi connection is lost
 */
extern NSString * const kMPWiFiConnectionLost;

/*!
 * @abstract Used to retrieve last paper size used
 * @discussion This key works with the dictionary contained in the @link lastOptionsUsed @/link property. If the last job was successful, the value for this key will contain the paper size used.
 * @seealso lastOptionsUsed
 */
extern NSString * const kMPPaperSizeId;

/*!
 * @abstract Used to retrieve last paper type used
 * @discussion This key works with the dictionary contained in the @link lastOptionsUsed @/link property. If the last job was successful, the value for this key will contain the paper type used.
 * @seealso lastOptionsUsed
 */
extern NSString * const kMPPaperTypeId;


/*!
 * @abstract Used to retrieve width of the last paper size used
 * @discussion This key works with the dictionary contained in the @link lastOptionsUsed @/link property. If the last job was successful, the value for this key will contain the width in inches of the last paper used.
 * @seealso lastOptionsUsed
 */
extern NSString * const kMPPaperWidthId;

/*!
 * @abstract Used to retrieve height of the last paper size used
 * @discussion This key works with the dictionary contained in the @link lastOptionsUsed @/link property. If the last job was successful, the value for this key will contain the height in inches of the last paper used.
 * @seealso lastOptionsUsed
 */
extern NSString * const kMPPaperHeightId;

/*!
 * @abstract Used to retrieve last black/white setting used
 * @discussion This key works with the dictionary contained in the @link lastOptionsUsed @/link property. If the last job was successful, the value for this key will contain a true/false value indicating if black/white was chosen.
 * @seealso lastOptionsUsed
 */
extern NSString * const kMPBlackAndWhiteFilterId;

/*!
 * @abstract Used to retrieve ID of the printer used for the last job
 * @discussion This key works with the dictionary contained in the @link lastOptionsUsed @/link property. If the last job was successful, the value for this key will contain the ID of the printer that was used.
 * @seealso lastOptionsUsed
 */
extern NSString * const kMPPrinterId;

/*!
 * @abstract Used to retrieve display name of the printer used for the last job
 * @discussion This key works with the dictionary contained in the @link lastOptionsUsed @/link property. Only available in iOS 8 after the printer has been contacted successfully.
 * @seealso lastOptionsUsed
 */
extern NSString * const kMPPrinterDisplayName;

/*!
 * @abstract Used to retrieve the total number of pages in the document used for the last job
 */
extern NSString * const kMPNumberPagesDocument;

/*!
 * @abstract Used to retrieve the total number of pages the user selected to print for the last job
 */
extern NSString * const kMPNumberPagesPrint;

/*!
 * @abstract Used to retrieve display location of the printer used for the last job
 * @discussion This key works with the dictionary contained in the @link lastOptionsUsed @/link property. Only available in iOS 8 after the printer has been contacted successfully.
 * @seealso lastOptionsUsed
 */
extern NSString * const kMPPrinterDisplayLocation;

/*!
 * @abstract Used to retrieve ID of the printer used for the last job
 * @discussion This key works with the dictionary contained in the @link lastOptionsUsed @/link property. Only available in iOS 8 after the printer has been contacted successfully.
 * @seealso lastOptionsUsed
 */
extern NSString * const kMPPrinterMakeAndModel;

/*!
 * @abstract Used to retrieve number of copies used for the last job
 * @discussion This key works with the dictionary contained in the @link lastOptionsUsed @/link property. If the last job was successful, the value for this key will contain the number of copies that was used.
 * @seealso lastOptionsUsed
 */
extern NSString * const kMPNumberOfCopies;

/*!
 * @abstract Used to retrieve the width of the paper (in points) for the last job
 * @discussion This key works with the dictionary contained in the @link lastOptionsUsed @/link property. If the last job was successful, the value for this key will contain the width of the paper in points.
 * @seealso lastOptionsUsed
 */
extern NSString * const kMPPrinterPaperWidthPoints;

/*!
 * @abstract Used to retrieve the height of the paper (in points) for the last job
 * @discussion This key works with the dictionary contained in the @link lastOptionsUsed @/link property. If the last job was successful, the value for this key will contain the height of the paper in points.
 * @seealso lastOptionsUsed
 */
extern NSString * const kMPPrinterPaperHeightPoints;

/*!
 * @abstract Used to retrieve the width of the printing rectangle (in points) for the last job
 * @discussion This key works with the dictionary contained in the @link lastOptionsUsed @/link property. If the last job was successful, the value for this key will contain the width of the printing rectangle in points.
 * @seealso lastOptionsUsed
 */
extern NSString * const kMPPrinterPaperAreaWidthPoints;

/*!
 * @abstract Used to retrieve the height of the printing rectangle (in points) for the last job
 * @discussion This key works with the dictionary contained in the @link lastOptionsUsed @/link property. If the last job was successful, the value for this key will contain the height of the printing rectangle in points.
 * @seealso lastOptionsUsed
 */
extern NSString * const kMPPrinterPaperAreaHeightPoints;

/*!
 * @abstract Used to retrieve the x coordinate of the printing rectangle origin (in points) for the last job
 * @discussion This key works with the dictionary contained in the @link lastOptionsUsed @/link property. If the last job was successful, the value for this key will contain the x coordinate of the printing rectangle origin in points.
 * @seealso lastOptionsUsed
 */
extern NSString * const kMPPrinterPaperAreaXPoints;

/*!
 * @abstract Used to retrieve the y coordinate of the printing rectangle origin (in points) for the last job
 * @discussion This key works with the dictionary contained in the @link lastOptionsUsed @/link property. If the last job was successful, the value for this key will contain the y coordinate of the printing rectangle origin in points.
 * @seealso lastOptionsUsed
 */
extern NSString * const kMPPrinterPaperAreaYPoints;

@property (assign, nonatomic) BOOL useBluetooth;

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
 * @seealso defaultPaper
 */
@property (assign, nonatomic) BOOL hidePaperSizeOption;

/*!
 * @abstract Indicates whether the paper type option should be hidden
 * @discussion If this value is true, the paper type option is hidden on the print preview page and the default paper type is used if applicable (e.g. 4x6 always uses photo paper regardless of the value of the default paper type). The default value is false (not hidden).
 * @seealso defaultPaper
 */
@property (assign, nonatomic) BOOL hidePaperTypeOption;

/*!
 * @abstract List of supported paper sizes
 * @discussion An array of MPPaper objects specifying the list of supported papers
 * @seealso MPPaper
 */
@property (strong, nonatomic) NSArray *supportedPapers;

/*!
 * @abstract Default paper
 * @discussion An @link MPPaper @/link object specifying the default paper size and type to use. 
 * This object is used to set the initial selection for paper size and paper type. It is also used as the value for paper size when the paper size selection is hidden. 
 * Default initial value is @link MPPaperSize5x7 @/link .  Note that paper type does not apply to all paper sizes (e.g. 4x6 always uses photo paper regardless what paper type is specified). 
 * Default value is @link MPPaperTypePhoto @/link .
 */
@property (strong, nonatomic) MPPaper *defaultPaper;

/*!
 * @abstract A dictionary of the most recent print options used
 * @discussion If the last print job was successful this property contains a dictionary of various options used for the job. If the last print job failed or was canceled then this property contains an empty dictionary.
 * @seealso kMPBlackAndWhiteFilterId
 * @seealso kMPPaperSizeId
 * @seealso kMPPaperTypeId
 * @seealso kMPPaperWidthId
 * @seealso kMPPaperHeightId
 * @seealso kMPPrinterId
 * @seealso kMPPrinterDisplayName
 * @seealso kMPPrinterDisplayLocation
 * @seealso kMPPrinterMakeAndModel
 * @seealso kMPNumberOfCopies
 * @seealso kMPPrinterPaperWidthPoints
 * @seealso kMPPrinterPaperHeightPoints
 * @seealso kMPPrinterPaperAreaWidthPoints
 * @seealso kMPPrinterPaperAreaHeightPoints
 * @seealso kMPPrinterPaperAreaXPoints
 * @seealso kMPPrinterPaperAreaYPoints
 */
@property (strong, nonatomic) NSDictionary *lastOptionsUsed;

/*!
 * @abstract An array of support actions to display on the print preview page
 * @discussion This is an array of @link MPSupportAction @/link objects, each describing a single support action. Support actions include an icon and a title and are displayed in a support section at the bottom of the print preview page. An action can either open a URL or present a view controller.
 * @seealso MPSupportAction
 */
@property (strong, nonatomic) NSArray *supportActions;

/*!
 * @abstract Causes the HPPrintProvider pod to handle metrics for the print activity.
 * @discussion Defaults to YES. If set to NO, the pod will not send metrics for the print activity automatically. However, the client application can still record print metrics using the notification kMPShareCompletedNotification.
 * @seealso kMPShareCompletedNotification
 */
@property (assign, nonatomic) BOOL handlePrintMetricsAutomatically;

/*!
 * @abstract Used to customize look and feel
 * @discussion Allows customization of the look and feel of the print later screens (e.g. fonts, colors, buttons, etc.).
 */
@property (strong, nonatomic) MPAppearance *appearance;

/*!
 * @abstract Options used to configure the user interface
 * @discussion Options are used to configure the UI and other behavior of the print activity
 * @seealso MPInterfaceOptions
 */
@property (strong, nonatomic) MPInterfaceOptions *interfaceOptions;

/*!
 * @abstract Specifies an object implementing the MPPrintPaperDelegate protocol
 * @discussion The print paper delegate is used to control paper-related features
 * @seealso MPPrintPaperDelegate
 */
@property (weak, nonatomic) id<MPPrintPaperDelegate>printPaperDelegate;

/*!
 * @abstract Specifies that each app is assigned a unique device ID regardless of vendor
 * @discussion By default, Apple assigns a common device ID that is shared among all apps owned by a given vender. This setting causes a unique ID to be assigned to all apps regardless of vendor.
 */
@property (assign, nonatomic) BOOL uniqueDeviceIdPerApp;

/*!
 * @abstract Indicates whether the cancel button on page settings screen is on the left or right of the navigationItem
 * @discussion If this value is true, the cancel button will show on the left of the navigation item on PageSettings otherwise it will appear on the right.  Default is right.
 */
@property (assign, nonatomic) BOOL pageSettingsCancelButtonLeft;

/*!
 * @abstract Indicates the minimum allowed battery level for performing a firmware upgrade on a sprocket device.
 * @discussion The sprocket devices report their batteryStatus on a scale of 1-100.  If the sprocket's battery level is below this number, it will not be allowed to perform a firmware upgrade.  The default value is 75.
 */
@property (assign, nonatomic) NSUInteger minimumSprocketBatteryLevelForUpgrade;

/*!
 * @abstract View Controller used on extensions
 * @discussion View Controller allow to present new screens on extensions
 */
@property (strong, nonatomic) UIViewController *extensionController;


- (UIViewController *)keyWindowTopMostController;

/*!
 * @abstract Prepares a view controller suitable for the device and OS
 * @description This method prepares a view controller for displaying the print flow. It takes into consideration the device type and OS and prepares either a split view controller (iPad with iOS 8 or above) or a standard view controller. Both types are wrapped in a navigation controller. The controller returned is suitable for using with the UIActivity method 'activityViewController'.
 * @param delegate An optional delegate object that implements the MPPrintDelegate protocol
 * @param dataSource An optional data source object that implements the MPPrintDataSource protocol
 * @param printItem The item to print
 * @param fromQueue Indicates if controller being requested from the print queue
 * @param settingsOnly Indicates that the controller will be used for settings only and not for printing
 * @return The view controller that the client should present
 */
- (UIViewController *)printViewControllerWithDelegate:(id<MPPrintDelegate>)delegate dataSource:(id<MPPrintDataSource>)dataSource printItem:(MPPrintItem *)printItem fromQueue:(BOOL)fromQueue settingsOnly:(BOOL)settingsOnly;

/*!
 * @abstract Prepares a view controller suitable for the device and OS
 * @description This method prepares a view controller for displaying the print flow. It takes into consideration the device type and OS and prepares either a split view controller (iPad with iOS 8 or above) or a standard view controller. Both types are wrapped in a navigation controller. The controller returned is suitable for using with the UIActivity method 'activityViewController'.
 * @param delegate An optional delegate object that implements the MPPrintDelegate protocol
 * @param dataSource An optional data source object that implements the MPPrintDataSource protocol
 * @param printLaterJobs The MPPrintLaterJobs to print
 * @param fromQueue Indicates if controller being requested from the print queue
 * @param settingsOnly Indicates that the controller will be used for settings only and not for printing
 * @return The view controller that the client should present
 */
- (UIViewController *)printViewControllerWithDelegate:(id<MPPrintDelegate>)delegate dataSource:(id<MPPrintDataSource>)dataSource printLaterJobs:(NSArray *)printLaterJobs fromQueue:(BOOL)fromQueue settingsOnly:(BOOL)settingsOnly;

/*!
 * @abstract Prepares a view controller suitable for the device and OS
 * @description This method prepares a view controller for displaying the "add to print queue" flow. It takes into consideration the device type and OS and prepares either a split view controller (iPad with iOS 8 or above) or a standard view controller. Both types are wrapped in a navigation controller. The controller returned is suitable for using with the UIActivity method 'activityViewController'.
 * @param delegate An optional delegate object that implements the MPAddPrintLaterDelegate protocol
 * @param printLaterJob The printLaterJob populated with appropriate printItem(s)
 * @return The view controller that the client should present
 */
- (UIViewController *)printLaterViewControllerWithDelegate:(id<MPAddPrintLaterDelegate>)delegate printLaterJob:(MPPrintLaterJob *)printLaterJob;

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
- (void)addJobToQueue:(MPPrintLaterJob *)job;

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
 * @abstract Indicates how many sprockets are paired with the iPhone/iPad
 * @return The number of sprockets paired with the iPhone/iPad
 */
- (NSInteger)numberOfPairedSprockets;

/*! 
 * @abstract Indicates sprocket printer firmware version number
 * @return The sprocket printer firmware version
 */
- (NSString *)printerVersion;

/*!
 * @abstract Close session on current connected accessory
 */
- (void)closeAccessorySession;

/*!
 * @abstract Displays the list of sprockets paired with the iPhone/iPad
 * @discussion This method prepares an instance of a view controller with the paired sprockets, and displays it modally.
 * @param controller The controller used as the parent for displaying the modal view controller
 * @param animated A boolean indicating whether or not to animate the display
 * @param completion A block to call when the display animation is complete
 */
- (void)presentBluetoothDevicesFromController:(UIViewController *)controller animated:(BOOL)animated completion:(void(^)(void))completion;

/*!
 * @abstract Launches a headless print, only displaying device selection if multiple devices are connected
 * @discussion This method launches a bluetooth print.
 * @param controller The controller used to display the print job's status
 * @param animated A boolean indicating whether or not to animate the display
 * @param completion A block to call when the display animation is complete
 */
- (void)headlessBluetoothPrintFromController:(UIViewController *)controller image:(UIImage *)image animated:(BOOL)animated printCompletion:(void(^)(void))completion;


/*!
 * @abstract Indicates whether a single sprocket is paired and needs to be updated
 * @discussion This call will result in a call to the delegate's didRefreshMantaInfo:error: function
 * @param delegate An object that implements the MPSprocketDelegate protocol.  It's didReceiveSprocketBatteryLevel: and didCompareSprocketWithLatestFirmwareVersion:batteryLevel:needsUpgrade: function will be called once the check has been completed.
 */
- (void)checkSprocketForUpdates:(id<MPSprocketDelegate>)delegate;

/*!
 * @abstract Causes a reflash of the first paired sprocket.
 * @param viewController The UIViewController to host the reflash progress view
 */
- (void)reflashBluetoothDevice:(UIViewController *)viewController;

/*!
 * @abstract Causes a metric value to be obfuscated before it is posted to the server.
 * @param keyName The key of the value that is to be obfuscated.  Any metric identified by this key will be obfuscated.
 */
- (void)obfuscateMetric:(NSString *)keyName;

/*!
 * @abstract Used to access the singleton instance of this class
 */
+ (MP *)sharedInstance;

@end

/*!
 * @abstract Defines a delegate protocal for reporting print events
 * @seealso MPPrintDataSource
 */
@protocol MPPrintDelegate <NSObject>

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
 * @seealso MPPrintDelegate
 */
@protocol MPPrintDataSource <NSObject>

/*!
 * @abstract Called when a new printing item is needed
 * @discussion This method is called when initiating the print flow or whenever relevant parameters are changed (e.g. page size).
 * @param paper The @link MPPaper @/link object that the item will be laid out on
 * @seealso MPPaper
 */
- (void)printingItemForPaper:(MPPaper *)paper withCompletion:(void (^)(MPPrintItem * printItem))completion;

/*!
 * @abstract Called when a new preview image is needed
 * @discussion This method is called when initiating the print flow or whenever relevant parameters are changed (e.g. page size).
 * @param paper The @link MPPaper @/link object that the item will be laid out on
 * @seealso MPPaper
 */
- (void)previewImageForPaper:(MPPaper *)paper withCompletion:(void (^)(UIImage *previewImage))completion;

@optional

/*!
 * @abstract Called to request the total number of print jobs to print
 * @return The number of jobs to print
 * @seealso printingItemsForPaper:
 */
- (NSInteger)numberOfPrintingItems;

/*!
 * @abstract Called to request the list of MPPrintLaterJob objects for printing.
 * @discussion This function offers an alternate method of printing a collection of print jobs to the other option of giving four parallel arrays of
 *  MPPrintItem, MPPageRange, NSNumbers (for wrapping black and white BOOL data), and NSNumbers (for wrapping number of copies NSInteger data).  
 *  If this function is implemented, the parallel arrays will be ignored (IE, printingItemsForPaper:, pageRangeSelections, blackAndWhiteSelections,
 *  and numCopiesSelections will not be called.
 * @return An array of MPPrintLaterJobs to be printed
 * @seealso numberOfPrintingItems
 */
- (NSArray *)printLaterJobs;

/*!
 * @abstract Called to request the printing item for each job
 * @discussion When using this function, the numberOfCopiesSelections, blackAndWhiteSelections, and MPPageRange selection 
 *  functions should also be implemented.  If they aren't used, default values will be used.
 * @param paper The type and size of paper being requested
 * @return An array of printing items for this paper size/type, one item per job
 * @seealso numberOfPrintingItems
 */
- (NSArray *)printingItemsForPaper:(MPPaper *)paper;

/*!
 * @abstract Called to request the page range for each job
 * @discussion This function is used in conjunction with printingItemsForPaper:.  This function should return an array with
 *  parallel values to the array returned by printingItemsForPaper:.
 * @return An array of page ranges for each job, in the same order as the array returned by printingItemsForPaper:
 *  The page ranges are stored in MPPageRange objects
 * @seealso numberOfPrintingItems
 * @seealso printingItemsForPaper:
 * @seealso numberOfCopiesSelections
 * @seealso blackAndWhiteSelections
 * @seealso MPPageRange
 */
- (NSArray *)pageRangeSelections;

/*!
 * @abstract Called to request the black-and-white preference for each job
 * @discussion This function is used in conjunction with printingItemsForPaper:.  This function should return an array with
 *  parallel values to the array returned by printingItemsForPaper:.
 * @return An array of black and white preferences for each job, in the same order as the array returned by printingItemsForPaper:
 *  The black and white preferences are BOOL values stored in NSNumber objects.
 * @seealso numberOfPrintingItems
 * @seealso printingItemsForPaper:
 * @seealso pageRangeSelections
 * @seealso numberOfCopiesSelections
 */
- (NSArray *)blackAndWhiteSelections;

/*!
 * @abstract Called to request the number of copies for each job
 * @discussion This function is used in conjunction with printingItemsForPaper:.  This function should return an array with
 *  parallel values to the array returned by printingItemsForPaper:.
 * @return An array of the number of copy preferences for each job, in the same order as the array returned by printingItemsForPaper:
 *  Each number of copies is stored in an NSNumber object.
 * @seealso numberOfPrintingItems
 * @seealso printingItemsForPaper:
 * @seealso pageRangeSelections
 * @seealso blackAndWhiteSelections
 */
- (NSArray *)numberOfCopiesSelections;

@end

/*!
 * @abstract Defines a delegate protocal for reporting that the "add job to print queue" flow has been finished or cancelled
 */
@protocol MPAddPrintLaterDelegate <NSObject>

/*!
 * @abstract Called when the "add to print queue" flow finishes successfully
 * @discussion This delegate method is called when the "add to print queue" flow finishes successfully.
 * @param addPrintLaterJobTableViewController The view controller calling the method
 * @returns Nothing
 * @seealso didCancelAddPrintLaterFlow:
 */
- (void)didFinishAddPrintLaterFlow:(UIViewController *)addPrintLaterJobTableViewController;

/*!
 * @abstract Called when the "add to print queue" flow is canceled
 * @discussion This delegate method is called when the "add to print queue" is canceled by the user..
 * @param addPrintLaterJobTableViewController The view controller calling the method
 * @returns Nothing
 * @seealso didFinishAddPrintLaterFlow:
 */
- (void)didCancelAddPrintLaterFlow:(UIViewController *)addPrintLaterJobTableViewController;

@end

/*!
 * @abstract Defines a protocol for adjusting paper settings based on print settings
 */
@protocol MPPrintPaperDelegate <NSObject>

@optional

/*!
 * @abstract Indicates whether or not the paper size should be hidden in the UI
 * @discussion This delegate method allows for hiding the paper size field depending on the current print settings (e.g. hide for a specific type of printer)
 * @param printSettings The print settings to use to decide if the paper size should be hidden
 * @returns YES or NO
 * @seealso hidePaperTypeForPrintSettings:
 */
- (BOOL)hidePaperSizeForPrintSettings:(MPPrintSettings *)printSettings;


/*!
 * @abstract Indicates whether or not the paper type should be hidden in the UI
 * @discussion This delegate method allows for hiding the paper type field depending on the current print settings (e.g. hide for a specific type of printer)
 * @param printSettings The print settings to use to decide if the paper type should be hidden
 * @returns YES or NO
 * @seealso hidePaperSizeForPrintSettings:
 */
- (BOOL)hidePaperTypeForPrintSettings:(MPPrintSettings *)printSettings;

/*!
 * @abstract Allows for changing the default paper for certain print settings
 * @discussion The default paper specified must match one of the supported papers. If the default paper returned is not in the supported paper list, it will be ignored and the default paper will not change.
 * @param printSettings The print settings to use to decide what default paper to use
 * @returns An MPPaper object to use as the default paper
 * @seealso supportedPapersForPrintSettings:
 */
- (MPPaper *)defaultPaperForPrintSettings:(MPPrintSettings *)printSettings;

/*!
 * @abstract Allows for changing the list of supported papers for certain print settings
 * @param printSettings The print settings to use to decide what supported paper list to use
 * @returns An array of MPPaper objects to use for the list of supported papers
 * @seealso defaultPaperForPrintSettings:
 * @seealso supportedPapers
 */
- (NSArray *)supportedPapersForPrintSettings:(MPPrintSettings *)printSettings;

/*!
 * @abstract Allows for handling of choose paper delegate based on print settings used
 * @discussion This method provides a means of handling the low-level choosePaper delegate that is part of the UIPrintInteractionControllerDelegate protocol.
 * If implemented, the value returned by this method will be used instead of the default processing used by the MobilePrintSDK pod.
 * @param printInteractionController The print interaction controller being used to print
 * @param paperList The list of papers passed to the original low-level method
 * @param printSettings The print settings currently being used
 * @returns A UIPrintPaper object that specifies the desired print geometry
 * @seealso printInteractionController:cutLengthForPaper:forPrintSettings:
 */
- (UIPrintPaper *)printInteractionController:(UIPrintInteractionController *)printInteractionController choosePaper:(NSArray *)paperList forPrintSettings:(MPPrintSettings *)printSettings;

/*!
 * @abstract Allows for handling of cut length delegate based on print settings used
 * @discussion This method provides a means of handling the low-level cutLengthForPaper: delegate that is part of the UIPrintInteractionControllerDelegate protocol.
 * If implemented, the value returned by this method will be used instead of the default processing used by the MobilePrintSDK pod.
 * Cut length is used for roll-based printers.
 * @param printInteractionController The print interaction controller being used to print
 * @param paper The paper used to determine the cut length
 * @param printSettings The print settings currently being used
 * @returns An NSNumber object representing the desired cut length in points
 * @seealso printInteractionController:choosePaper:forPrintSettings:
 */
- (NSNumber *)printInteractionController:(UIPrintInteractionController *)printInteractionController cutLengthForPaper:(UIPrintPaper *)paper forPrintSettings:(MPPrintSettings *)printSettings;

@end

/*!
 * @abstract Defines a delegate protocal for reporting that a sprocket needs a firmware upgrade
 */
@protocol MPSprocketDelegate <NSObject>

@optional
/*!
 * @abstract Called when a sprocket needs a firmware upgrade
 * @discussion This delegate method is called when a sprocket needs a firmware upgrade.
 * @param batteryLevel The current battery level (on a scale of 1-100) of the device
 * @param needsUpgrade YES if the sprocket needs to be upgraded, NO otherwise
 * @returns Nothing
 */
- (void)didCompareSprocketWithLatestFirmwareVersion:(NSString *)deviceName batteryLevel:(NSUInteger)batteryLevel needsUpgrade:(BOOL)needsUpgrade;

/*!
 * @abstract Called when a sprocket battery level property is updated
 * @discussion This delegate method is called when a sprocket had its battery level updated from manta refresh info
 * @param batteryLevel The current battery level (on a scale of 1-100) of the device
 * @returns Nothing
 */
- (void)didReceiveSprocketBatteryLevel:(NSUInteger)batteryLevel;

@end

