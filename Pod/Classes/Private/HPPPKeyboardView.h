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

@protocol HPPPKeyboardViewDelegate;

/*!
 * @abstract A class for displaying a single textfield and keyboard
 */
@interface HPPPKeyboardView : HPPPOverlayEditView

/*!
 * @abstract A delegate that is called when the user is finished entering text into the text field
 * @seealso HPPPKeyboardViewDelegate
 */
@property (weak, nonatomic) id<HPPPKeyboardViewDelegate> delegate;

@end

/*!
 * @abstract Protocol used to indicate that the user has completed entering text in the text field
 */
@protocol HPPPKeyboardViewDelegate <NSObject>
@optional

/*!
 * @abstract Called when the user has completed entering text in the text field
 * @param view The keyboard view
 * @param text The text entered by the user
 */
- (void)didFinishEnteringText:(HPPPKeyboardView *)view text:(NSString *)text;
@end
