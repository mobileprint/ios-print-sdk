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
#import "HPPPOverlayEditView.h"

@protocol HPPPPageRangeViewDelegate;

/*!
 * @abstract A view for selecting a page range.  
 * @discussion This view contains a keyboard and text field tailored for page range entry.
 */
@interface HPPPPageRangeView : HPPPOverlayEditView

/*!
 * @abstract A delegate that is called when the user selects a page range
 * @seealso HPPPPageRangeViewDelegate
 */
@property (weak, nonatomic) id<HPPPPageRangeViewDelegate> delegate;

/*!
 * @abstract Indicates the maximum page number allowed in the page range
 */
@property (assign, nonatomic) NSInteger maxPageNum;

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
- (void)didSelectPageRange:(HPPPPageRangeView *)pageRangeView pageRange:(NSString *)pageRange;
@end
