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

/*!
 * @abstract Controller that manages the list of print jobs
 */
@interface MPPrintJobsViewController : UIViewController

/*!
 * @abstract Displays the list of print jobs modally
 * @discussion This method prepares an instance of MPPrintJobsViewController with the contents of the print queue and displays it modally.
 * @param animated A boolean indicating whether or not to animate the display
 * @param hostController The controller used as the parent for displaying the modal view controller
 * @param completion A block to call when the display animation is complete
 */
+ (void)presentAnimated:(BOOL)animated usingController:(UIViewController *)hostController andCompletion:(void(^)(void))completion;

@end
