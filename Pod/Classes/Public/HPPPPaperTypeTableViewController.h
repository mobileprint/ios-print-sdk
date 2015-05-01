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

@property (nonatomic, weak) id<HPPPPaperTypeTableViewControllerDelegate> delegate;
@property (nonatomic, strong) HPPPPaper *currentPaper;

@end

/*!
 * @abstract Protocol used to indicate paper type was selected
 */
@protocol HPPPPaperTypeTableViewControllerDelegate <NSObject>

- (void)paperTypeTableViewController:(HPPPPaperTypeTableViewController *)paperTypeTableViewController didSelectPaper:(HPPPPaper *)paper;

@end