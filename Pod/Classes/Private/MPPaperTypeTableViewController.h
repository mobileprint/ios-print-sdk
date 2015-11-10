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
#import "MPPaper.h"

@protocol MPPaperTypeTableViewControllerDelegate;

/*!
 * @abstract Controls paper type table view selection
 */
@interface MPPaperTypeTableViewController : UITableViewController

/*!
 * @abstract A delegate that is called when the user selects paper
 * @seealso MPPaperTypeTableViewControllerDelegate
 */
@property (nonatomic, weak) id<MPPaperTypeTableViewControllerDelegate> delegate;

/*!
 * @abstract The current paper (if any) that is selected
 */
@property (nonatomic, strong) MPPaper *currentPaper;

@end

/*!
 * @abstract Protocol used to indicate paper type was selected
 */
@protocol MPPaperTypeTableViewControllerDelegate <NSObject>

/*!
 * @abstract Called when the user selects a paper type
 * @param paperTypeTableViewController The paper type controller
 * @param paper The paper that was selected
 */
- (void)paperTypeTableViewController:(MPPaperTypeTableViewController *)paperTypeTableViewController didSelectPaper:(MPPaper *)paper;

@end
