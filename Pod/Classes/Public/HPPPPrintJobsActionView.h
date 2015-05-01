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
#import "HPPPView.h"

@protocol HPPPPrintJobsActionViewDelegate;

/*!
 * @abstract View containing buttons for acting on one or more print jobs
 */
@interface HPPPPrintJobsActionView : HPPPView

@property (weak, nonatomic) id<HPPPPrintJobsActionViewDelegate> delegate;
@property (weak, nonatomic) IBOutlet UIButton *selectAllButton;
@property (weak, nonatomic) IBOutlet UIButton *deleteButton;
@property (weak, nonatomic) IBOutlet UIButton *nextButton;

@property (assign, nonatomic) BOOL selectAllState;

- (void)hideSelectAllButton;
- (void)showNextButton;
- (void)hideNextButton;

@end

/*!
 * @abstract Protocol for handling print job actions
 */
@protocol HPPPPrintJobsActionViewDelegate <NSObject>

- (void)printJobsActionViewDidTapSelectAllButton:(HPPPPrintJobsActionView *)printJobsActionView;
- (void)printJobsActionViewDidTapDeleteButton:(HPPPPrintJobsActionView *)printJobsActionView;
- (void)printJobsActionViewDidTapNextButton:(HPPPPrintJobsActionView *)printJobsActionView;

@end
