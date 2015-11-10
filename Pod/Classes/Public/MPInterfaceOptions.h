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

/*!
 * @abstract The class used to define user interface options
 */
@interface MPInterfaceOptions : NSObject

/*!
 * @abstract Specifies the minimum allowable space between (in pixels)
 */
@property (assign, nonatomic) NSUInteger multiPageMinimumGutter;

/*!
 * @abstract Specifies the minimum allowable space betwen pages (in pixels). Setting the value less than or equal to 0 indicates no maximum and the gutter between pages has no upper limit.
 */
@property (assign, nonatomic) NSUInteger multiPageMaximumGutter;

/*!
 * @abstract Specifies the amount (in pixels) of the previous and next page that is revealed at the edges of the multi-page view.
 */
@property (assign, nonatomic) NSUInteger multiPageBleed;

/*!
 * @abstract Specifies the size of the previous and next pages relative to full size (e.g. 1.0 indicates full size, 0.5 indicates half size, etc.)
 */
@property (assign, nonatomic) CGFloat multiPageBackgroundPageScale;


/*!
 * @abstract Specifies whether or not the double tap gesture is recognized. If double tap is enabled then the multiPageView:didDoubleTapPage: method will be called on the MPMultiPageViewDelegate. Note that single tap response will experience a slight delay when double tap is enabled and no delay when double tap is disabled.
 */
@property (assign, nonatomic) BOOL multiPageDoubleTapEnabled;

/*!
 * @abstract Specifies whether to initiate zoom when page is single tapped
 */
@property (assign, nonatomic) BOOL multiPageZoomOnSingleTap;

/*!
 * @abstract Specifies whether to initiate zoom when page is double tapped. Note that double tap must be enabled for this feature to function properly.
 * @seealso multiPageDoubleTapEnabled
 */
@property (assign, nonatomic) BOOL multiPageZoomOnDoubleTap;

@end
