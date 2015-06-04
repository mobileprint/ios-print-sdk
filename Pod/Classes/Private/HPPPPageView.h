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
#import "HPPPView.h"
#import "HPPPPaper.h"
#import "HPPPPrintItem.h"
#import "HPPPLayout.h"

/*!
 * @abstract View that represents the graphical preview portion of the print preview
 */
@interface HPPPPageView : HPPPView

/*!
 * @abstract Indicates whether or not there are multiple images being printed
 */
@property (assign, nonatomic, getter=isMultipleImages) BOOL multipleImages;

/*!
 * @abstract Indicates if the page curl animation is still in progress
 */
@property (assign, nonatomic) BOOL isAnimating;

/*!
 * @abstract The actual data to be printed (e.g. image, PDF, etc.)
 */
@property (strong, nonatomic) HPPPPrintItem *printItem;

/*!
 * @abstract Indicates whether or not image should be shown in black and white
 */
@property (assign, nonatomic) BOOL blackAndWhite;

/*!
 * @abstract Sets the preview to color mode
 * @param completion A block to be called when animation to color completes
 */
- (void)setColorWithCompletion:(void (^)(void))completion;

/*!
 * @abstract Sets the preview to black and white mode
 * @param completion A block to be called when animation to black and white completes
 */
- (void)setBlackAndWhiteWithCompletion:(void (^)(void))completion;

/*!
 * @abstract Changes the paper size with an optional animation
 * @param paperSize The new paper size
 * @param animated Boolean indicating whether or not to animate the transition to the new paper size
 * @param completion A block to be called when the paper transition is complete
 */
- (void)setPaperSize:(HPPPPaper *)paperSize animated:(BOOL)animated completion:(void (^)(void))completion;

/*!
 * @abstract Redraws the page layout
 */
- (void)refreshLayout;


/*!
 * @abstract Shows the page with a fade-in effect
 */
- (void)showPageAnimated:(BOOL)animated completion:(void (^)(void))completion;

/*!
 * @abstract Initiates the page curl
 */
- (void)curlPage;

@end
