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
#import "MPView.h"
#import "MPPaper.h"
#import "MPLayout.h"
#import "MPInterfaceOptions.h"

@protocol MPMultiPageViewDelegate;

@interface MPMultiPageView : MPView

@property (strong, nonatomic) NSMutableArray *pageImages;
@property (strong, nonatomic) MPPaper *paper;
@property (strong, nonatomic) MPLayout *layout;
@property (weak, nonatomic) id<MPMultiPageViewDelegate>delegate;
@property (assign, nonatomic) BOOL blackAndWhite;
@property (assign, nonatomic, readonly) NSUInteger currentPage;
@property (assign, nonatomic) NSInteger numBufferPages;
@property (assign, nonatomic) BOOL rotationInProgress;

- (void)configurePages:(NSUInteger)numPages paper:(MPPaper *)paper layout:(MPLayout *)layout;
- (void)changeToPage:(NSUInteger)pageNumber animated:(BOOL)animated;
- (void)refreshLayout;
- (void)setInterfaceOptions:(MPInterfaceOptions *)options;
- (void)showPageNumberLabel:(BOOL)show;
- (void)cancelZoom;
- (void)setPageNum:(NSInteger)pageNum blackAndWhite:(BOOL)blackAndWhite;
- (CGRect)currentPageFrame;

@end

@protocol MPMultiPageViewDelegate <NSObject>

@optional
- (void)multiPageView:(MPMultiPageView *)multiPageView didChangeFromPage:(NSUInteger)oldPageNumber ToPage:(NSUInteger)newPageNumber;
- (void)multiPageView:(MPMultiPageView *)multiPageView didSingleTapPage:(NSUInteger)pageNumber;
- (void)multiPageView:(MPMultiPageView *)multiPageView didDoubleTapPage:(NSUInteger)pageNumber;
- (UIImage *)multiPageView:(MPMultiPageView *)multiPageView getImageForPage:(NSUInteger)pageNumber;
- (BOOL)multiPageView:(MPMultiPageView *)multiPageView useMultiPageIndicatorForPage:(NSUInteger)pageNumber;
- (CGFloat)multiPageView:(MPMultiPageView *)multiPageView shrinkPageVertically:(NSInteger)pageNum;

@end