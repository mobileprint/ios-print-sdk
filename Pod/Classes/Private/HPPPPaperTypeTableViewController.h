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

@protocol HPPPPaperTypeTableViewControllerDelegate;

/*!
 * @abstract Controls paper type table view selection
 */
@interface HPPPPaperTypeTableViewController : UITableViewController

/*!
 * @abstract A delegate that is called when the user selects paper
 * @seealso HPPPPaperTypeTableViewControllerDelegate
 */
@property (nonatomic, weak) id<HPPPPaperTypeTableViewControllerDelegate> delegate;

/*!
 * @abstract The current paper (if any) that is selected
 */
@property (nonatomic, strong) HPPPPaper *currentPaper;

@end

/*!
 * @abstract Protocol used to indicate paper type was selected
 */
@protocol HPPPPaperTypeTableViewControllerDelegate <NSObject>

/*!
 * @abstract Called when the user selects a paper type
 * @param paperTypeTableViewController The paper type controller
 * @param paper The paper that was selected
 */
- (void)paperTypeTableViewController:(HPPPPaperTypeTableViewController *)paperTypeTableViewController didSelectPaper:(HPPPPaper *)paper;

@end