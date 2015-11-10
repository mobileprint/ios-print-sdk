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

/*!
 * @abstract Represents a support action
 * @discussion This class stores the properties needed to display and invoke a single support action. Support actions are shown at the bottom of the print preview.
 */
@interface MPSupportAction : NSObject

/*!
 * @abstract The icon displayed in the action row
 * @discussion This icon is displayed in the left side of the table view row for this support action
 * @seealso title
 * @seealso url
 * @seealso viewController
 */
@property (strong, nonatomic) UIImage *icon;

/*!
 * @abstract The title displayed in the action row
 * @discussion This title is displayed in the table view row for this support action
 * @seealso icon
 * @seealso url
 * @seealso viewController
 */
@property (strong, nonatomic) NSString *title;

/*!
 * @abstract The URL to open for this action
 * @discussion If this value is provided then tapping the action will open this URL in Safari. You may provide a URL or a view controller, but not both.
 * @seealso icon
 * @seealso title
 * @seealso viewController
 */
@property (strong, nonatomic) NSURL *url;

/*!
 * @abstract The view controller to open for this action
 * @discussion If this value is provided then tapping the action will open this view controller modally. In order to show navigation correctly you must embed your view controller in a navigation controller. You may provide a URL or a view controller, but not both.
 * @seealso icon
 * @seealso title
 * @seealso url
 */
@property (strong, nonatomic) UINavigationController *viewController;

/*!
 * @abstract Initializer for providing a URL action
 * @seealso url
 */
- (id)initWithIcon:(UIImage *)icon title:(NSString *)title url:(NSURL *)url;

/*!
 * @abstract Initializer for providing a view controller action
 * @seealso viewController
 */
- (id)initWithIcon:(UIImage *)icon title:(NSString *)title viewController:(UINavigationController *)viewController;

@end
