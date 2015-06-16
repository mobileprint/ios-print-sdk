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
#import "HPPPPaper.h"
#import "HPPPLayout.h"
#import "HPPPInterfaceOptions.h"

@protocol HPPPMultiPageViewDelege;

@interface HPPPMultiPageView : HPPPView

@property (strong, nonatomic) NSArray *pageImages;
@property (strong, nonatomic) HPPPPaper *paper;
@property (strong, nonatomic) HPPPLayout *layout;
@property (weak, nonatomic) id<HPPPMultiPageViewDelege>delegate;
@property (assign, nonatomic) BOOL blackAndWhite;

- (void)setPages:(NSArray *)pages paper:(HPPPPaper *)paper layout:(HPPPLayout *)layout;
- (void)changeToPage:(NSUInteger)pageNumber animated:(BOOL)animated;
- (void)refreshLayout;
- (void)setInterfaceOptions:(HPPPInterfaceOptions *)options;

@end

@protocol HPPPMultiPageViewDelege <NSObject>

- (void)multiPageView:(HPPPMultiPageView *)multiPageView didChangeFromPage:(NSUInteger)oldPageNumber ToPage:(NSUInteger)newPageNumber;
- (void)multiPageView:(HPPPMultiPageView *)multiPageView didSingleTapPage:(NSUInteger)pageNumber;
- (void)multiPageView:(HPPPMultiPageView *)multiPageView didDoubleTapPage:(NSUInteger)pageNumber;

@end