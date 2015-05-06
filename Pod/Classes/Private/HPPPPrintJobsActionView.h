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

/*!
 * @abstract Delegate used to communicate button tap events
 */
@property (weak, nonatomic) id<HPPPPrintJobsActionViewDelegate> delegate;

/*!
 * @abstract Outlet for the select all button
 */
@property (weak, nonatomic) IBOutlet UIButton *selectAllButton;

/*!
 * @abstract Outlet for the delete button
 */
@property (weak, nonatomic) IBOutlet UIButton *deleteButton;

/*!
 * @abstract Outlet for the next button
 */
@property (weak, nonatomic) IBOutlet UIButton *nextButton;

/*!
 * @abstract Boolean that maintains the list's select all state
 */
@property (assign, nonatomic) BOOL selectAllState;

/*!
 * @abstract Hides the select all button
 */
- (void)hideSelectAllButton;

/*!
 * @abstract Shows the next button
 */
- (void)showNextButton;

/*!
 * @abstract Hides the next button
 */
- (void)hideNextButton;

@end

/*!
 * @abstract Protocol for handling print job actions
 */
@protocol HPPPPrintJobsActionViewDelegate <NSObject>

/*!
 * @abstract Called when the user taps the select all button
 * @param printJobsActionView The view containing the button
 */
- (void)printJobsActionViewDidTapSelectAllButton:(HPPPPrintJobsActionView *)printJobsActionView;

/*!
 * @abstract Called when the user taps the delete button
 * @param printJobsActionView The view containing the button
 */
- (void)printJobsActionViewDidTapDeleteButton:(HPPPPrintJobsActionView *)printJobsActionView;

/*!
 * @abstract Called when the user taps the next button
 * @param printJobsActionView The view containing the button
 */
- (void)printJobsActionViewDidTapNextButton:(HPPPPrintJobsActionView *)printJobsActionView;

@end
