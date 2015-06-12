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

@interface HPPPAddPrintLaterJobTableViewController : UITableViewController <HPPPPageRangeViewDelegate>

@property (nonatomic, weak) id<HPPPAddPrintLaterJobTableViewControllerDelegate> delegate;

@property (strong, nonatomic) HPPPPrintLaterJob *printLaterJob;

@end


@protocol HPPPAddPrintLaterJobTableViewControllerDelegate <NSObject>

- (void)addPrintLaterJobTableViewControllerDidFinishPrintFlow:(HPPPAddPrintLaterJobTableViewController *)addPrintLaterJobTableViewController;

- (void)addPrintLaterJobTableViewControllerDidCancelPrintFlow:(HPPPAddPrintLaterJobTableViewController *)addPrintLaterJobTableViewController;

@end