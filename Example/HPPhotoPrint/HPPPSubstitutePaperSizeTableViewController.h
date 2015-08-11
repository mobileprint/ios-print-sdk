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
#import "HPPPPaper.h"

@protocol HPPPSubstitutePaperSizeTableViewControllerDelegate;

/*!
 * @abstract Controls paper size table view selection
 */
@interface HPPPSubstitutePaperSizeTableViewController : UITableViewController

/*!
 * @abstract A delegate that is called when the user selects paper
 * @seealso HPPPPaperSizeTableViewControllerDelegate
 */
@property (nonatomic, weak) id<HPPPSubstitutePaperSizeTableViewControllerDelegate> delegate;

/*!
 * @abstract The current paper (if any) that is selected
 */
@property (nonatomic, strong) HPPPPaper *currentPaper;

@end

/*!
 * @abstract Protocol used to indicate paper was selected
 */
@protocol HPPPSubstitutePaperSizeTableViewControllerDelegate <NSObject>

/*!
 * @abstract Called when the user selects a paper size
 * @param paperSizeTableViewController The paper size controller
 * @param paper The paper that was selected
 */
- (void)paperSizeTableViewController:(HPPPSubstitutePaperSizeTableViewController *)paperSizeTableViewController didSelectPaper:(HPPPPaper *)paper;

@end