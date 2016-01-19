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
#import "MPPageRange.h"

@protocol MPPageRangeKeyboardViewDelegate;

/*!
 * @abstract A view for selecting a page range.  
 * @discussion This view contains a keyboard and text field tailored for page range entry.
 */
@interface MPPageRangeKeyboardView : UIView

/*!
 * @abstract Initializer for MPPageRangeView
 * @param frame The frame of the view with the UITextField
 * @param textField The textField that is making use of the MPPageRangeView
 * @param maxPageNum The maximum allowed page number for the page range
 */
- (id)initWithFrame:(CGRect)frame textField:(UITextField *)textField maxPageNum:(NSInteger)maxPageNum;

/*!
 * @abstract Commits all edits made while the keyboard has been open
 */
- (void)commitEditing;

/*!
 * @abstract Cancels all editing done while the keyboard has been open
 */
- (void)cancelEditing;

/*!
 * @abstract Prepares the keyboard and textfield for display
 */
- (BOOL)prepareForDisplay;

/*!
 * @abstract A delegate that is called when the user selects a page range
 * @seealso MPPageRangeViewDelegate
 */
@property (weak, nonatomic) id<MPPageRangeKeyboardViewDelegate> delegate;

/*!
 * @abstract String used to inform users that all pages are selected
 */
extern NSString *kPageRangeAllPages;

/*!
 * @abstract String used to inform users when no pages are selected
 */
extern NSString *kPageRangeNoPages;

@end


/*!
 * @abstract Protocol used to indicate that a page range was selected
 */
@protocol MPPageRangeKeyboardViewDelegate <NSObject>
@optional

/*!
 * @abstract Called when the user selects a page range
 * @param view The page range view
 * @param pageRange The selected page range
 */
- (void)didSelectPageRange:(MPPageRangeKeyboardView *)pageRangeView pageRange:(MPPageRange *)pageRange;
@end
