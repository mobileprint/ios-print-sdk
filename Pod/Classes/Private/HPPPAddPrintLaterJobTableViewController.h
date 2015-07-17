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

#import <UIKit/UIKit.h>
#import "HPPPPrintLaterJob.h"
#import "HPPPPageRangeView.h"

@protocol HPPPAddPrintLaterJobTableViewControllerDelegate;

/*!
 * @abstract The view controller class for adding a job to the print queue
 */
@interface HPPPAddPrintLaterJobTableViewController : UITableViewController <HPPPPageRangeViewDelegate>

/*!
 * @abstract A delegate that is called when the user cancels or completes the "add job to print queue" process
 * @seealso HPPPAddPrintLaterJobTableViewControllerDelegate
 */
@property (nonatomic, weak) id<HPPPAddPrintLaterJobTableViewControllerDelegate> delegate;

/*!
 * @abstract The job to be added to the print queue
 */
@property (strong, nonatomic) HPPPPrintLaterJob *printLaterJob;

@end


/*!
 * @abstract Protocol used to indicate that the "add job to print queue" flow has been finished or cancelled
 */
@protocol HPPPAddPrintLaterJobTableViewControllerDelegate <NSObject>

- (void)addPrintLaterJobTableViewControllerDidFinishPrintFlow:(HPPPAddPrintLaterJobTableViewController *)addPrintLaterJobTableViewController;

- (void)addPrintLaterJobTableViewControllerDidCancelPrintFlow:(HPPPAddPrintLaterJobTableViewController *)addPrintLaterJobTableViewController;

@end