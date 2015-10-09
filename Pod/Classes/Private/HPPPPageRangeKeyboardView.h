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
#import "HPPPPageRange.h"

@protocol HPPPPageRangeViewDelegate;

/*!
 * @abstract A view for selecting a page range.  
 * @discussion This view contains a keyboard and text field tailored for page range entry.
 */
@interface HPPPPageRangeKeyboardView : UIView

/*!
 * @abstract Initializer for HPPPPageRangeView
 * @param frame The frame of the view with the UITextField
 * @param textField The textField that is making use of the HPPPPageRangeView
 * @param maxPageNum The maximum allowed page number for the page range
 */
- (id)initWithFrame:(CGRect)frame textField:(UITextField *)textField maxPageNum:(NSInteger)maxPageNum;

/*!
 * @abstract A delegate that is called when the user selects a page range
 * @seealso HPPPPageRangeViewDelegate
 */
@property (weak, nonatomic) id<HPPPPageRangeViewDelegate> delegate;

/*!
 * @abstract String used to inform users that all pages are selected
 */
extern NSString * const kPageRangeAllPages;

/*!
 * @abstract String used to inform users when no pages are selected
 */
extern NSString * const kPageRangeNoPages;

@end


/*!
 * @abstract Protocol used to indicate that a page range was selected
 */
@protocol HPPPPageRangeViewDelegate <NSObject>
@optional

/*!
 * @abstract Called when the user selects a page range
 * @param view The page range view
 * @param pageRange The selected page range
 */
- (void)didSelectPageRange:(HPPPPageRangeKeyboardView *)pageRangeView pageRange:(HPPPPageRange *)pageRange;
@end
