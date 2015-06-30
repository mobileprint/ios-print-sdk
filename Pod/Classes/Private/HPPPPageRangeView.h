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

@protocol HPPPPageRangeViewDelegate;

@interface HPPPPageRangeView : HPPPView

@property (weak, nonatomic) id<HPPPPageRangeViewDelegate> delegate;

- (void)addButtons;
- (void)finishEditing;
- (void)setCursorPosition;

@property (assign, nonatomic) NSInteger maxPageNum;

@end


@protocol HPPPPageRangeViewDelegate <NSObject>
@optional
- (void)didSelectPageRange:(HPPPPageRangeView *)view pageRange:(NSString *)pageRange;
@end