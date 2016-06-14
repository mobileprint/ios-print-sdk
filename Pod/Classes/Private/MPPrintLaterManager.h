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
#import <CoreLocation/CoreLocation.h>

extern const CLLocationDistance kDefaultPrinterRadiusInMeters;

/*!
 * @abstract Class that manages the print later feature
 * @discussion This class handles aspect of the print later feature including permissions and notifications.
 */
@interface MPPrintLaterManager : NSObject

/*!
 * @abstract User notification category used for print later notification
 * @property printLaterUserNotificationCategory
 * @discussion UIUserNotificationCategory to register in the clients for push notifications of the print later. The clients must do the registration because it may happen that the client have other notification categories to register, and all the registration must be do at the same time, otherwise the new category will override the previous one.
 */
@property (strong, nonatomic) UIUserNotificationCategory *printLaterUserNotificationCategory;

/*!
 * @abstract Boolean indicating whether or not the notification permission has already been set
 */
@property (assign, nonatomic) BOOL userNotificationsPermissionSet;

/*!
 * @abstract Boolean indicating whether or not the location permission has already been set
 */
@property (assign, nonatomic, readonly) BOOL currentLocationPermissionSet;

/*!
 * @abstract Used to access the singleton instance of this class
 */
+ (MPPrintLaterManager *)sharedInstance;

/*!
 * @abstract Sets up the location manager to monitor location
 */
- (void)initLocationManager;

/*!
 * @abstract Retrieves the current device GPS location
 */
- (CLLocationCoordinate2D)retrieveCurrentLocation;

/*!
 * @abstract Handles when the user taps an action button on the notification dialog
 */
- (void)handleNotification:(UILocalNotification *)notification action:(NSString *)action;

/*!
 * @abstract Handles when the user taps the notification itself
 * @discussion This method is called when the user taps the notification body itself rather than one of the specific action buttons
 */
- (void)handleNotification:(UILocalNotification *)notification;

/*!
 * @abstract Sets up the notification system
 */
- (void)initUserNotifications;

- (BOOL)isDefaultPrinterRegion:(CLRegion *)region;

@end
