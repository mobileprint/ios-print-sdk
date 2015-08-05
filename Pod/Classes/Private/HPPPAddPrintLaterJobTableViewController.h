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
#import "HPPP.h"
#import "HPPPPrintLaterJob.h"
#import "HPPPPageRangeView.h"
#import "HPPPPageViewController.h"

/*!
 * @abstract The view controller class for adding a job to the print queue
 */
@interface HPPPAddPrintLaterJobTableViewController : UITableViewController <HPPPPageRangeViewDelegate>

/*!
 * @abstract A delegate that is called when the user cancels or completes the "add job to print queue" process
 * @seealso HPPPAddPrintLaterJobTableViewControllerDelegate
 */
@property (nonatomic, weak) id<HPPPAddPrintLaterDelegate> delegate;

/*!
 * @abstract The job to be added to the print queue
 */
@property (strong, nonatomic) HPPPPrintLaterJob *printLaterJob;

/*!
 * @abstract The graphical page representation part of the print preview
 * @discussion The pageViewController is reponsible for displaying a graphical representation of the print on the page. It is one part of the overall page settings view also known as the print preview.
 */
@property (nonatomic, weak) HPPPPageViewController *pageViewController;

@end
