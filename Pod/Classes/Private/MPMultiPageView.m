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

#import "MPMultiPageView.h"
#import "MPLayoutPaperView.h"
#import "UIColor+MPHexString.h"
#import "MPLayoutFactory.h"
#import "MPLayoutPaperCellView.h"
#import "MP.h"

@interface MPMultiPageView() <UIScrollViewDelegate>

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *horizontalLeftConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *horizontalRightConstraint;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (assign, nonatomic) NSUInteger actualGutter;
@property (assign, nonatomic) NSUInteger currentPage;
@property (strong, nonatomic) UIScrollView *zoomScrollView;
@property (assign, nonatomic) NSUInteger minimumGutter;
@property (assign, nonatomic) NSUInteger maximumGutter;
@property (assign, nonatomic) NSUInteger bleed;
@property (assign, nonatomic) CGFloat backgroundPageScale;
@property (assign, nonatomic) BOOL doubleTapEnabled;
@property (assign, nonatomic) BOOL zoomOnSingleTap;
@property (assign, nonatomic) BOOL zoomOnDoubleTap;
@property (strong, nonatomic) UITapGestureRecognizer *singleTapRecognizer;
@property (strong, nonatomic) UITapGestureRecognizer *doubleTapRecognizer;
@property (assign, nonatomic) CGPoint zoomInitialOffset;
@property (strong, nonatomic) NSMutableArray *blackAndWhitePageImages;
@property (strong, nonatomic) NSMutableArray *pageViews;
@property (assign, nonatomic) NSInteger startingIdx;
@property (assign, nonatomic) NSInteger endingIdx;
@property (assign, nonatomic) BOOL switchedToBlackAndWhite;
@property (assign, nonatomic) BOOL switchedToColor;
@property (weak, nonatomic) UIActivityIndicatorView *spinner;
@property (weak, nonatomic) UILabel *pageNumberLabel;
@property (assign, nonatomic) NSInteger blackAndWhiteCallNum;
@property (strong, nonatomic) NSMutableArray *sporadicBlackAndWhite;

@end

@implementation MPMultiPageView

NSUInteger const kMPMultiPageDefaultMinimumGutter = 20; // pixels
NSUInteger const kMPMultiPageDefaultMaximumGutter = 40; // pixels
NSUInteger const kMPMultiPageDefaultBleed = 20; // pixels
CGFloat const kMPMultiPageDefaultBackgroundPageScale = 1.0;

CGFloat const kMPPageFadeInTime = MP_ANIMATION_DURATION; // seconds
CGFloat const kMPPageFadeOutTime = MP_ANIMATION_DURATION*2; // seconds
CGFloat const kMPPageBaseTag = 1000;

CGFloat const kMPZoomFadeTime = MP_ANIMATION_DURATION; // seconds
CGFloat const kMPZoomInset = 20.0; // pixels
CGFloat const kMPZoomOverlayAlpha = 0.8;
CGFloat const kMPZoomMinimumScale = 1.0;
CGFloat const kMPZoomMaximumScale = 8.0;
CGFloat const kMPZoomInitialScale = 2.0;
CGFloat const kMPZoomAutoCloseScale = 1.1;

CGFloat const kMPMultiPageViewPageLabelWidth = 100.0;
CGFloat const kMPMultiPageViewPageLabelHeight = 15.0;

NSUInteger const kMPZoomScrollViewTag = 99;

NSUInteger const kMPMultiPageDefaultNumBufferPages = 5;

static NSNumber *lastPinchScale = nil;

#pragma mark - Class Methods

#pragma mark - Initialization

-(id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        self.minimumGutter = kMPMultiPageDefaultMinimumGutter;
        self.maximumGutter = kMPMultiPageDefaultMaximumGutter;
        self.bleed = kMPMultiPageDefaultBleed;
        self.backgroundPageScale = kMPMultiPageDefaultBackgroundPageScale;
        self.backgroundColor = [self getColor:@"Background"];
        self.scrollView.backgroundColor = [self getColor:@"Scroll View"];
        self.numBufferPages = kMPMultiPageDefaultNumBufferPages;
        self.pageImages = [[NSMutableArray alloc] init];
        self.pageViews = [[NSMutableArray alloc] init];
        self.blackAndWhitePageImages = [[NSMutableArray alloc] init];
        self.startingIdx = 0;
        self.endingIdx = 0;
        self.switchedToBlackAndWhite = NO;
        self.switchedToColor = NO;
        self.blackAndWhiteCallNum = 0;
        self.scrollView.showsHorizontalScrollIndicator = NO;
        self.scrollView.showsVerticalScrollIndicator = NO;
        self.rotationInProgress = NO;
        
        UIActivityIndicatorView *spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        [self addSubview:spinner];
        self.spinner = spinner;
        
        UILabel *label = [[UILabel alloc] init];
        label.font = [UIFont fontWithName:@"HelveticaNeue" size:14];
        label.textColor = [UIColor blackColor];
        label.backgroundColor = [UIColor colorWithRed:0xF4/255.0F green:0xF4/255.0F blue:0xF4/255.0F alpha:1.0F];
        label.textAlignment = NSTextAlignmentCenter;
        label.clipsToBounds = YES;
        label.layer.cornerRadius = 8;
        label.alpha = 0.0;

        [self addSubview:label];
        self.pageNumberLabel = label;
        
        _currentPage = 1;
        
        [self initializePageGestures];
    }
    return self;
}

- (void)initializePageGestures
{
    [self.scrollView removeGestureRecognizer:self.singleTapRecognizer];
    [self.scrollView removeGestureRecognizer:self.doubleTapRecognizer];
    
    UITapGestureRecognizer *singleTapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handlePageSingleTap:)];
    singleTapRecognizer.cancelsTouchesInView = YES;
    singleTapRecognizer.numberOfTapsRequired = 1;
    singleTapRecognizer.numberOfTouchesRequired = 1;
    [self.scrollView addGestureRecognizer:singleTapRecognizer];
    
    if (self.doubleTapEnabled) {
        UITapGestureRecognizer *doubleTapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handlePageDoubleTap:)];
        doubleTapGesture.numberOfTapsRequired = 2;
        doubleTapGesture.numberOfTouchesRequired = 1;
        [self.scrollView addGestureRecognizer:doubleTapGesture];
        
        [singleTapRecognizer requireGestureRecognizerToFail:doubleTapGesture];
    }
    
    UIPinchGestureRecognizer *pinchRecognizer = [[UIPinchGestureRecognizer  alloc] initWithTarget:self action:@selector(handlePinchToZoom:)];
    [self.scrollView addGestureRecognizer:pinchRecognizer];
}

- (void)setInterfaceOptions:(MPInterfaceOptions *)options
{
    self.minimumGutter = options.multiPageMinimumGutter;
    self.maximumGutter = options.multiPageMaximumGutter;
    self.bleed = options.multiPageBleed;
    self.backgroundPageScale = options.multiPageBackgroundPageScale;
    self.doubleTapEnabled = options.multiPageDoubleTapEnabled;
    self.zoomOnSingleTap = options.multiPageZoomOnSingleTap;
    self.zoomOnDoubleTap = options.multiPageZoomOnDoubleTap;
    [self initializePageGestures];
    [self layoutPagesIfNeeded];
}

#pragma mark - Touches

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
    return [self pointInside:point withEvent:event] ? self.scrollView : nil;
}

#pragma mark - Property setters

- (void)setPaper:(MPPaper *)paper
{
    _paper = paper;
    if (self.layout) {
        self.layout.paper = paper;
    }
    [self layoutPagesIfNeeded];
}

- (void)setLayout:(MPLayout *)layout
{
    _layout = layout;
    _layout.paper = self.paper;
    [self layoutPagesIfNeeded];
}

- (void)setBlackAndWhite:(BOOL)blackAndWhite
{
    _blackAndWhite = blackAndWhite;
    _switchedToColor = !_blackAndWhite;
    
    if (blackAndWhite) {
        _sporadicBlackAndWhite = nil;
    }
    
    [self updatePages];
}

#pragma mark - Pages

- (void)configurePages:(NSUInteger)numPages paper:(MPPaper *)paper layout:(MPLayout *)layout
{
    _paper = paper;
    _layout = layout;
    _layout.paper = _paper;
    
    for (NSUInteger i=0; i<numPages; i++) {
        self.pageImages[i] = [NSNull null];
        self.blackAndWhitePageImages[i] = [NSNull null];
        self.pageViews[i] = [NSNull null];
        for (UIView *view in self.scrollView.subviews) {
            [view removeFromSuperview];
        }
    }
    
    [self updatePageImages:self.currentPage];
    [self positionSpinner];
}

// This is the starting point of updating the UIScrollView
//  updatePageImages -> updatePages -> createPageViews -> layoutPagesIfNeeded
- (void)updatePageImages:(NSUInteger)newPageNumber
{
    NSUInteger oldPageNumber = self.currentPage;
    if (oldPageNumber != newPageNumber  ||  0 == self.scrollView.subviews.count) {
        _currentPage = newPageNumber;
        MPLogDebug(@"Changed from page %lu to page %lu", (unsigned long)oldPageNumber, (unsigned long)newPageNumber);
        
        if (self.delegate && [self.delegate respondsToSelector:@selector(multiPageView:getImageForPage:)]) {
            
            for (NSInteger i = 0; i < [self lowBufferIndex]; i++) {
                self.pageImages[i] = [NSNull null];
            }
            
            for (NSInteger i = [self lowBufferIndex]; i <= [self highBufferIndex]; i++) {
                if( [NSNull null] == self.pageImages[i] ) {
                    UIImage *newImage = [self.delegate multiPageView:self getImageForPage:i+1];                    
                    if( nil != newImage ) {
                        self.pageImages[i] = newImage;
                    } else {
                        MPLogError(@"Page %ld returned a nil image", (long)i+1);
                    }
                }
            }
            
            for (NSInteger i = [self highBufferIndex] + 1; i < self.pageImages.count; i++) {
                self.pageImages[i] = [NSNull null];
            }
        }
        
        [self updatePages];
        
        if (self.delegate && [self.delegate respondsToSelector:@selector(multiPageView:didChangeFromPage:ToPage:)]) {
            [self.delegate multiPageView:self didChangeFromPage:oldPageNumber ToPage:newPageNumber];
        }
        
    }

    [self setZoomLevels];
}

- (void)createPageViews
{
    NSArray *pageImages = (self.blackAndWhite || self.sporadicBlackAndWhite) ? self.blackAndWhitePageImages : self.pageImages;
    
    self.startingIdx = [self lowBufferIndex];
    self.endingIdx   = [self highBufferIndex];
    
    for (NSInteger idx = 0; idx < [self lowBufferIndex]; idx++) {
        if( [NSNull null] != self.pageViews[idx] ) {
            [(MPLayoutPaperCellView *)self.pageViews[idx] removeFromSuperview];
            self.pageViews[idx] = [NSNull null];
        }
    }
    
    for (NSInteger idx = self.startingIdx; idx < pageImages.count  &&  idx <= self.endingIdx; idx++) {
        if( [NSNull null] == self.pageViews[idx]  ||  self.switchedToBlackAndWhite || self.switchedToColor ) {
            
            MPLayoutPaperView *paperView = nil;
            MPLayoutPaperCellView *paperCell = nil;
            
            if( [NSNull null] != self.pageViews[idx] ) {
                paperCell = self.pageViews[idx];
                paperView = paperCell.paperView;
            } else {
                paperView = [[MPLayoutPaperView alloc] init];
                paperView.layout = self.layout;
                paperView.backgroundColor = [UIColor whiteColor];
                
                // The paperCell's frame is correctly set in layoutPagesIfNeeded
                paperCell = [[MPLayoutPaperCellView alloc] initWithFrame:CGRectMake(0, 0, 0, 0) paperView:paperView paper:self.paper];
                
                paperCell.backgroundColor = [self getColor:@"Page Cell"];
                paperCell.tag = kMPPageBaseTag + idx;
                
                // Add the multi-page indicator?
                if (self.delegate && [self.delegate respondsToSelector:@selector(multiPageView:useMultiPageIndicatorForPage:)]) {
                    if ([self.delegate multiPageView:self useMultiPageIndicatorForPage:idx+1]) {
                        paperView.useMultiPageIndicator = YES;
                        paperView.backgroundColor = self.backgroundColor;
                    }
                }
            }
            
            // We synchronize the reading of pageImages in case we are reading from self.blackAndWhiteImages
            NSObject *image = [NSNull null];
            @synchronized(self.blackAndWhitePageImages) {
               image = pageImages[idx];
            }

            // if the black and white images aren't ready yet, display the color images
            if( pageImages == self.blackAndWhitePageImages  &&  [NSNull null] == image ) {
                if( [NSNull null] != self.pageImages[idx] ) {
                    paperView.image = self.pageImages[idx];
                }
            } else if( [NSNull null] != pageImages[idx] ) {
                paperView.image = (UIImage *)image;
            }
            
            [self.scrollView addSubview:paperCell];
            self.pageViews[idx] = paperCell;
        } else {
            [self.scrollView addSubview:self.pageViews[idx]];
        }
    }
    
    for (NSInteger idx = [self highBufferIndex] + 1; idx < pageImages.count; idx++) {
        if( [NSNull null] != self.pageViews[idx] ) {
            [(MPLayoutPaperCellView *)self.pageViews[idx] removeFromSuperview];
            self.pageViews[idx] = [NSNull null];
        }
    }
}

- (void)changeToPage:(NSUInteger)pageNumber animated:(BOOL)animated
{
    if (pageNumber >= 1 && pageNumber <= self.pageImages.count) {
        CGFloat scrollWidth = self.scrollView.bounds.size.width;
        
        [self.scrollView setContentOffset:CGPointMake(scrollWidth * (pageNumber - 1), 0) animated:animated];
        [self scrollViewDidEndDecelerating:self.scrollView];
        [self updatePageImages:pageNumber];
    }
}

- (void)updatePages
{
    [self createPageViews];
    [self layoutPagesIfNeeded];

    // for black and white images, update a second time once the black-and-white conversion finishes
    if (self.blackAndWhite  ||  self.sporadicBlackAndWhite) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
            
            if ([self processAllBlackAndWhiteImages:++self.blackAndWhiteCallNum]) {
                self.switchedToBlackAndWhite = YES;
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self createPageViews];
                    [self layoutPagesIfNeeded];
                });
            }
        });
    }
}

- (void)setPageNum:(NSInteger)pageNum blackAndWhite:(BOOL)blackAndWhite
{
    // make sure the array of sporadic markers exists
    if (nil == self.sporadicBlackAndWhite) {
        self.sporadicBlackAndWhite = [[NSMutableArray alloc] init];
        NSInteger count = self.pageImages.count;
        for (NSInteger i=0; i<count; i++) {
            self.sporadicBlackAndWhite[i] = [NSNull null];
        }
    }
    
    // store the appropriate sporadic marker
    NSObject *value = [NSNull null];
    if (blackAndWhite) {
        self.blackAndWhite = NO;
        value = [NSNumber numberWithBool:YES];
    }
    
    self.sporadicBlackAndWhite[pageNum-1] = value;
    
    [self updatePages];
}

- (UIImage *)getBlackAndWhiteImageForIndex:(NSInteger)index
{
    UIImage *pageImage = self.pageImages[index];
    UIImage *blackAndWhiteImage = pageImage;
    
    if ((UIImage *)[NSNull null] != pageImage) {
        
        @autoreleasepool {
            
            CIImage *image = [[CIImage alloc] initWithCGImage:pageImage.CGImage options:nil];
            CIFilter *filter = [CIFilter filterWithName:@"CIPhotoEffectNoir"];
            [filter setValue:image forKey:kCIInputImageKey];
            CIImage *result = [filter valueForKey:kCIOutputImageKey];
            CIContext *context = [CIContext contextWithOptions:nil];
            CGImageRef cgImage = [context createCGImage:result fromRect:[result extent]];
            
            blackAndWhiteImage = [UIImage imageWithCGImage:cgImage scale:pageImage.scale orientation:pageImage.imageOrientation];
            
            CGImageRelease(cgImage);
        }
    }
    
    return blackAndWhiteImage;
}

- (BOOL)processAllBlackAndWhiteImages:(NSInteger)callNum
{
    BOOL completed = YES;
    
    // This function is executed on a background thread
    //  The calls can queue up, but we only care about the last call made.
    //  self.blackAndWhiteCallNum ensures that we cancel older calls as soon as a new one is made.
    //  Also, this thread writes to self.blackAndWhitePageImages, thus we synchronize all reads/writes of this
    //  object both in this function and in functions that will be executed simultaneously on the main thread.
    
    for (NSUInteger i = 0; i < self.blackAndWhitePageImages.count; i++) {
        if (callNum == self.blackAndWhiteCallNum) {
            if (self.pageImages[i] != [NSNull null]  &&  (self.blackAndWhite || [NSNull null] != self.sporadicBlackAndWhite[i])) {
                
                NSObject *image = [NSNull null];
                @synchronized(self.blackAndWhitePageImages) {
                    image = self.blackAndWhitePageImages[i];
                }
                
                if ( image == [NSNull null] ) {
                    image = [self getBlackAndWhiteImageForIndex:i];
                    @synchronized(self.blackAndWhitePageImages) {
                        self.blackAndWhitePageImages[i] = image;
                    }

                }
            } else {
                @synchronized(self.blackAndWhitePageImages) {
                    self.blackAndWhitePageImages[i] = [NSNull null];
                }
            }
        } else {
            completed = NO;
        }
    }

    return completed;
}

- (MPLayoutPaperCellView *)currentPaperCellView
{
    MPLayoutPaperCellView *cell = nil;
    if (self.pageImages.count > 0) {
        cell = (MPLayoutPaperCellView *)[self viewWithTag:kMPPageBaseTag + self.currentPage - 1];
    }
    return cell;
}

- (NSInteger)lowBufferIndex
{
    NSInteger idx = _currentPage - 1 - kMPMultiPageDefaultNumBufferPages;
    idx = idx > 0 ? idx : 0;
    
    return idx;
}

- (NSInteger)highBufferIndex
{
    NSInteger maxAllowedIndex = self.pageImages.count - 1;
    
    NSInteger idx = _currentPage - 1 + kMPMultiPageDefaultNumBufferPages;
    idx = idx <= maxAllowedIndex ? idx : maxAllowedIndex;
    
    return idx;
}

- (CGRect)frameForPage:(NSInteger)pageNum
{
    CGRect frame = CGRectZero;
    
    if (self.pageImages.count > 0) {
        MPLayoutPaperCellView *cell = self.pageViews[pageNum-1];
        
        if ([NSNull null] != (NSNull *)cell) {
            MPLayoutPaperCellView *cell = self.pageViews[pageNum-1];
            
            if ([NSNull null] != (NSNull *)cell) {
                
                // convert the paperView frame from the paperViewCell's coordinate system to the MPMultiPageView system
                frame = [cell convertRect:cell.paperView.frame toView:self];
            }
        }
    }
    
    return frame;
}

- (CGRect)currentPageFrame
{
    return [self frameForPage:self.currentPage];
}

#pragma mark - Layout

- (void)refreshLayout
{
    [self setNeedsLayout];
    [self layoutIfNeeded];
    [self layoutPagesIfNeeded];
}

- (void)layoutPagesIfNeeded
{
    if (!self.paper || !self.layout || !self.pageImages) {
        return;
    }
    
    static CGSize lastScrollViewSize = {0, 0};
    
    [self resetZoomLevels];
    [self updateHorizontalConstraints];
    CGFloat scrollWidth = self.scrollView.bounds.size.width;
    CGFloat scrollHeight = self.scrollView.bounds.size.height;
    CGFloat pageWidth = scrollWidth - self.actualGutter;
    CGFloat pageHeight = self.scrollView.bounds.size.height;
    self.scrollView.contentSize = CGSizeMake(scrollWidth * self.pageImages.count, scrollHeight);
    NSInteger idx = [self lowBufferIndex];
    
    for (UIView *subview in self.scrollView.subviews) {
        if ([subview isKindOfClass:[MPLayoutPaperCellView class]]) {
            if (subview.frame.origin.x < 0.5 * self.actualGutter  ||
                self.switchedToBlackAndWhite                      ||
                self.switchedToColor                              ||
                !CGSizeEqualToSize(lastScrollViewSize, self.scrollView.bounds.size)) {
                
                CGFloat currentPageHeight = pageHeight;
                if ([self.delegate respondsToSelector:@selector(multiPageView:shrinkPageVertically:)]) {
                    currentPageHeight -= [self.delegate multiPageView:self shrinkPageVertically:idx+1];
                }

                MPLayoutPaperCellView *paperCellView = (MPLayoutPaperCellView *)subview;
                CGRect cellFrame = CGRectMake(0.5 * self.actualGutter + idx * scrollWidth, 0, pageWidth , currentPageHeight);
                paperCellView.frame = cellFrame;
                paperCellView.paper = self.paper;
            }
            idx++;
        }
    }
    
    self.switchedToBlackAndWhite = NO;
    self.switchedToColor = NO;
    
    [self.scrollView setNeedsLayout];
    if (self.currentPage > self.pageImages.count + 1) {
        [self updatePageImages:1];
    }
    [self changeToPage:self.currentPage animated:NO];
    
    [self showSpinner:NO];
    
    if (!CGSizeEqualToSize(lastScrollViewSize, self.scrollView.bounds.size)) {
        [self updatePageNumberLabelText];
        [self positionSpinner];
        lastScrollViewSize = self.scrollView.bounds.size;
    }
}

- (void)updateHorizontalConstraints
{
    if (!self.paper || !self.layout || !self.pageImages) {
        return;
    }
    
    CGFloat paperAspectRatio = self.paper.width / self.paper.height;
    for (UIImage *image in self.pageImages) {
        if( (NSNull *)image != [NSNull null] ) {
            if (MPLayoutOrientationLandscape == [MPLayout paperOrientationForImage:image andLayout:self.layout]) {
                paperAspectRatio = self.paper.height / self.paper.width;
                break;
            }
        }
    }
    
    NSUInteger bleed = self.pageImages.count == 1 ? 0 : self.bleed;
    NSUInteger minimumEdgeSpace = bleed + self.minimumGutter;
    CGSize availableSize = CGSizeMake(self.bounds.size.width - 2 * minimumEdgeSpace, self.bounds.size.height);
    CGFloat availableAspectRatio = availableSize.width / availableSize.height;
    CGFloat paperCellWidth = availableSize.width;
    if (paperAspectRatio < availableAspectRatio) {
        paperCellWidth = availableSize.height * paperAspectRatio;
    }
    
    self.actualGutter = (self.bounds.size.width - paperCellWidth - 2 * bleed) / 2.0;
    if (self.maximumGutter > 0) {
        self.actualGutter = fminf(self.actualGutter, self.maximumGutter);
    }
    
    CGFloat scrollViewWidth = paperCellWidth + self.actualGutter;
    CGFloat edgeSpace = (self.bounds.size.width - scrollViewWidth) / 2.0;
    self.horizontalLeftConstraint.constant = edgeSpace;
    self.horizontalRightConstraint.constant = edgeSpace;
    [self setNeedsLayout];
    [self layoutIfNeeded];
}

- (void)resetZoomLevels
{
    for (UIView *subview in self.scrollView.subviews) {
        if ([subview isKindOfClass:[MPLayoutPaperCellView class]]) {
            subview.transform = CGAffineTransformIdentity;
        }
    }
}

- (void)setZoomLevels
{
    CGFloat backgroundScale = self.backgroundPageScale;
    CGFloat scrollOffset = self.scrollView.contentOffset.x;
    CGFloat scrollWidth = self.scrollView.bounds.size.width;
    
    NSUInteger viewIndex = scrollOffset / scrollWidth;
    CGFloat viewRatio = (scrollOffset - scrollWidth * viewIndex) / scrollWidth;
    
    NSUInteger leavingViewIndex = viewIndex;
    CGFloat leavingRatio = (1.0 - viewRatio);
    CGFloat leavingViewScale = backgroundScale + (1.0 - backgroundScale) * leavingRatio;
    
    NSUInteger enteringViewIndex = viewIndex + 1;
    CGFloat enteringRatio = viewRatio;
    CGFloat enteringViewScale = backgroundScale + (1.0 - backgroundScale) * enteringRatio;
    
    NSInteger idx = self.startingIdx;
    
    for (UIView *subview in self.scrollView.subviews) {
        if ([subview isKindOfClass:[MPLayoutPaperCellView class]]) {
            subview.transform = CGAffineTransformIdentity;
            CGFloat scale = backgroundScale;
            CGFloat progress = 1.0;
            CGFloat direction = (idx < enteringViewIndex) ? 1.0 : -1.0;
            if (idx == enteringViewIndex) {
                scale = enteringViewScale;
                progress = 1.0 - enteringRatio;
            } else if (idx == leavingViewIndex) {
                scale = leavingViewScale;
                progress = 1.0 - leavingRatio;
            }
            CGAffineTransform scaleTransform = CGAffineTransformMakeScale(scale, scale);
            CGFloat correctionX = (subview.bounds.size.width * (1.0 - scale)) * progress * direction / 2.0 * (1.0 / scale);
            CGAffineTransform combinedTransform = CGAffineTransformTranslate(scaleTransform, correctionX, 0);
            subview.transform = combinedTransform;
            idx++;
            
        }
    }
    
    if (self.scrollView.alpha < 1.0) {
        [UIView animateWithDuration:kMPPageFadeInTime animations:^{
            self.scrollView.alpha = 1.0;
        }];
    }
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidZoom:(UIScrollView *)scrollView
{
    if (kMPZoomScrollViewTag == scrollView.tag) {
        [self centerInScrollView];
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    if (kMPZoomScrollViewTag != scrollView.tag) {
        NSUInteger newPageNumber = (int)scrollView.contentOffset.x / (int)scrollView.bounds.size.width + 1;
        [self updatePageImages:newPageNumber];
    }
    
    [UIView animateWithDuration:kMPPageFadeOutTime animations:^{
        self.pageNumberLabel.alpha = 0.0;
    }];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (kMPZoomScrollViewTag != scrollView.tag) {
        
        if (!self.rotationInProgress) {
            [self setZoomLevels];
        }
        
        if (scrollView.contentOffset.x > 0 &&
            (scrollView.contentOffset.x < scrollView.bounds.size.width * self.startingIdx  ||
             scrollView.contentOffset.x > scrollView.bounds.size.width * self.endingIdx) &&
            scrollView.contentOffset.x < scrollView.bounds.size.width * (self.pageImages.count-1)) {
            [self showSpinner:YES];
        } else {
            [self showSpinner:NO];
        }
        
        [self updatePageNumberLabelText];
        if (self.pageNumberLabel.alpha < 1.0) {
            [UIView animateWithDuration:kMPPageFadeInTime animations:^{
                self.pageNumberLabel.alpha = 0.6;
            }];
        }
    }
}

- (void)scrollViewDidEndZooming:(UIScrollView *)scrollView withView:(UIView *)view atScale:(CGFloat)scale
{
    if (kMPZoomScrollViewTag == scrollView.tag) {
        if (scrollView.zoomScale <= 1.0) {
            [self removeZoomView];
        }
    }
}

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    UIView *zoomView = nil;
    if (kMPZoomScrollViewTag == scrollView.tag) {
        zoomView = [scrollView.subviews firstObject];
    }
    return zoomView;
}

#pragma mark - UIPinchGestureRecognizer

- (void)handlePinchToZoom:(UIGestureRecognizer *)gestureRecognizer
{
    UIPinchGestureRecognizer *pinchRecognizer = (UIPinchGestureRecognizer *)gestureRecognizer;
    if (lastPinchScale && pinchRecognizer.scale > [lastPinchScale floatValue]) {
        [self showZoomViewWithScale:kMPZoomInitialScale Animated:YES] ;
    }
    lastPinchScale = [NSNumber numberWithFloat:pinchRecognizer.scale];
}

#pragma mark - UITapGestureRecognizer

- (void)handlePageSingleTap:(UIGestureRecognizer *)gestureRecognizer
{
    UITapGestureRecognizer *tapGestureRecognizer = (UITapGestureRecognizer *)gestureRecognizer;
    CGPoint point = [tapGestureRecognizer locationInView:self.scrollView];
    CGFloat scrollWidth = self.scrollView.bounds.size.width;
    NSUInteger pageTapped = point.x / scrollWidth + 1;
    if (pageTapped >= 1 && pageTapped <= self.pageImages.count) {
        if (pageTapped == self.currentPage) {
            [self didSingleTapPage:self.currentPage];
        } else {
            [self changeToPage:pageTapped animated:YES];
        }
    }
}

- (void)handlePageDoubleTap:(UIGestureRecognizer *)gestureRecognizer
{
    UITapGestureRecognizer *tapGestureRecognizer = (UITapGestureRecognizer *)gestureRecognizer;
    CGPoint point = [tapGestureRecognizer locationInView:self.scrollView];
    CGFloat scrollWidth = self.scrollView.bounds.size.width;
    NSUInteger pageTapped = point.x / scrollWidth + 1;
    if (pageTapped == self.currentPage) {
        [self didDoubleTapPage:self.currentPage];
    }
}

- (void)handleZoomSingleTap:(UIGestureRecognizer *)gestureRecognizer
{
    // do nothing
}

- (void)handleZoomDoubleTap:(UIGestureRecognizer *)gestureRecognizer
{
    [self hideZoomViewAnimated:YES];
}

#pragma mark - MPMultPageViewDelegate

- (void)didSingleTapPage:(NSUInteger)pageNumber
{
    MPLogInfo(@"Page %lu was single tapped", (unsigned long)pageNumber);
    
    if (self.zoomOnSingleTap) {
        [self showZoomViewWithScale:kMPZoomInitialScale Animated:YES];
    }
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(multiPageView:didSingleTapPage:)]) {
        [self.delegate multiPageView:self didSingleTapPage:pageNumber];
    }
}

- (void)didDoubleTapPage:(NSUInteger)pageNumber
{
    MPLogInfo(@"Page %lu was double tapped", (unsigned long)pageNumber);
    
    if (self.zoomOnDoubleTap) {
        [self showZoomViewWithScale:kMPZoomInitialScale Animated:YES];
    }
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(multiPageView:didDoubleTapPage:)]) {
        [self.delegate multiPageView:self didDoubleTapPage:pageNumber];
    }
}

#pragma mark - Zooming

- (void)showZoomViewWithScale:(CGFloat)scale Animated:(BOOL)animated
{
    if (self.zoomScrollView) {
        return;
    }
    
    NSArray *pageImages = self.blackAndWhite ? self.blackAndWhitePageImages : self.pageImages;
    
    MPLayoutPaperCellView *zoomSourceView = [self currentPaperCellView];
    
    self.zoomScrollView = [[UIScrollView alloc] initWithFrame:self.frame];
    self.zoomScrollView.minimumZoomScale = kMPZoomMinimumScale;
    self.zoomScrollView.maximumZoomScale = kMPZoomMaximumScale;
    self.zoomScrollView.bouncesZoom = NO;
    self.zoomScrollView.clipsToBounds = YES;
    self.zoomScrollView.autoresizingMask = UIViewAutoresizingNone;
    self.zoomScrollView.delegate = self;
    self.zoomScrollView.tag = kMPZoomScrollViewTag;
    self.zoomScrollView.showsHorizontalScrollIndicator = NO;
    self.zoomScrollView.showsVerticalScrollIndicator = NO;
    
    CGRect pageRect = CGRectMake(0, 0, zoomSourceView.bounds.size.width, zoomSourceView.bounds.size.height);
    MPLayoutPaperView *paperView = [[MPLayoutPaperView alloc] init];
    paperView.image = pageImages[self.currentPage - 1];
    paperView.layout = self.layout;
    paperView.backgroundColor = [UIColor whiteColor];
    MPLayoutPaperCellView *paperCell = [[MPLayoutPaperCellView alloc] initWithFrame:pageRect paperView:paperView paper:self.paper];
    paperCell.backgroundColor = [self getColor:@"Page Cell"];
    paperCell.tag = kMPZoomScrollViewTag + 1;
    [self.zoomScrollView addSubview:paperCell];
    
    CGFloat offsetX = (zoomSourceView.bounds.size.width - self.zoomScrollView.bounds.size.width) / 2.0;
    CGFloat offsetY = (zoomSourceView.bounds.size.height - self.zoomScrollView.bounds.size.height) / 2.0;
    self.zoomInitialOffset = CGPointMake(offsetX, offsetY);
    self.zoomScrollView.contentSize = paperCell.bounds.size;
    self.zoomScrollView.contentOffset = self.zoomInitialOffset;
    
    [self.superview addSubview:self.zoomScrollView];
    [self currentPaperCellView].hidden = YES;
    [self initializeZoomGestures];
    
    [self.zoomScrollView setZoomScale:scale animated:animated];
    [self setPagesVisible:NO animated:animated];
}

- (void)cancelZoom
{
    if (self.zoomScrollView) {
        [self removeZoomView];
    }
}

- (void)removeZoomView
{
    lastPinchScale = nil;
    [self setPagesVisible:YES animated:NO];
    [self currentPaperCellView].hidden = NO;
    [self.zoomScrollView removeFromSuperview];
    self.zoomScrollView = nil;
}

- (void)setPagesVisible:(BOOL)visible animated:(BOOL)animated
{
    CGFloat alpha = visible ? 1.0 : 0.0;
    if (animated) {
        [UIView animateWithDuration:kMPZoomFadeTime animations:^{
            [self setSidePageAlpha:alpha];
        }];
    } else {
        [self setSidePageAlpha:alpha];
    }
}

- (void)setSidePageAlpha:(CGFloat)alpha
{
    for (int idx = 0; idx < self.pageImages.count; idx++) {
        UIView *view = [self viewWithTag:kMPPageBaseTag + idx];
        if (view != [self currentPaperCellView]) {
            view.alpha = alpha;
        }
    }
}

- (void)hideZoomViewAnimated:(BOOL)animated
{
    [self.zoomScrollView setZoomScale:1.0 animated:animated];
    [self.zoomScrollView setContentOffset:CGPointZero animated:animated];
    [self setPagesVisible:YES animated:animated];
}

- (CGAffineTransform)computeTranformFromRect:(CGRect)sourceRect toRect:(CGRect)resultRect scale:(CGFloat)scale
{
    CGAffineTransform transform = CGAffineTransformIdentity;
    transform = CGAffineTransformTranslate(transform, -(CGRectGetMidX(sourceRect)-CGRectGetMidX(resultRect)), -(CGRectGetMidY(sourceRect)-CGRectGetMidY(resultRect)));
    transform = CGAffineTransformScale(transform, resultRect.size.width/sourceRect.size.width * scale, resultRect.size.height/sourceRect.size.height * scale);
    return transform;
}

- (void)initializeZoomGestures
{
    UITapGestureRecognizer *singleTapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleZoomSingleTap:)];
    singleTapRecognizer.cancelsTouchesInView = YES;
    singleTapRecognizer.numberOfTapsRequired = 1;
    singleTapRecognizer.numberOfTouchesRequired = 1;
    [self.zoomScrollView addGestureRecognizer:singleTapRecognizer];
    
    UITapGestureRecognizer *doubleTapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleZoomDoubleTap:)];
    doubleTapGesture.numberOfTapsRequired = 2;
    doubleTapGesture.numberOfTouchesRequired = 1;
    [self.zoomScrollView addGestureRecognizer:doubleTapGesture];
    
    [singleTapRecognizer requireGestureRecognizerToFail:doubleTapGesture];
}

// The following is adapted from http://stackoverflow.com/questions/1316451/center-content-of-uiscrollview-when-smaller
- (void)centerInScrollView
{
    UIView *subView = [self.zoomScrollView.subviews objectAtIndex:0];
    
    CGFloat offsetX = MAX((self.zoomScrollView.bounds.size.width - self.zoomScrollView.contentSize.width) * 0.5, 0.0);
    CGFloat offsetY = MAX((self.zoomScrollView.bounds.size.height - self.zoomScrollView.contentSize.height) * 0.5, 0.0);
    
    subView.center = CGPointMake(self.zoomScrollView.contentSize.width * 0.5 + offsetX,
                                 self.zoomScrollView.contentSize.height * 0.5 + offsetY);
}

#pragma mark - Page Number Label

- (void)showPageNumberLabel:(BOOL)show
{
    self.pageNumberLabel.hidden = !show;
}

- (void)setPageNumberLabelPosition:(NSInteger)pageNumber
{
    MPLayoutPaperCellView *cell = self.pageViews[pageNumber-1];
    
    if ([NSNull null] != (NSNull *)cell) {

        // convert the paperView frame from the paperViewCell's coordinate system to the MPMultiPageView system
        CGRect boundingFrame = [self frameForPage:pageNumber];
        
        // Now, place the label in the appropriate position
        CGRect labelFrame = self.pageNumberLabel.frame;
        labelFrame.size = [self.pageNumberLabel sizeThatFits:boundingFrame.size];
        labelFrame.size.height *= 1.75;
        labelFrame.size.width += (labelFrame.size.height * .75);
        
        labelFrame.origin.y = self.frame.size.height - labelFrame.size.height;
        labelFrame.origin.x = (self.frame.size.width - labelFrame.size.width)/2;
        
        self.pageNumberLabel.frame = labelFrame;
    }
}

- (void)updatePageNumberLabelText
{
    // The pageNumberLabel is updated as we scroll-- don't rely on currentPage, rely on scroll position
    NSInteger pageNumber = ((NSInteger)(self.scrollView.contentOffset.x / self.scrollView.bounds.size.width)) + 1;

    NSString *of = NSLocalizedString(@"of", @"Used to denote a page range.  IE: x 'of' y pages");
    self.pageNumberLabel.text = [NSString stringWithFormat:@"%ld %@ %lu", (long)pageNumber, of, (unsigned long)self.pageImages.count];
    [self setPageNumberLabelPosition:pageNumber];
}

#pragma mark - Spinner

- (void)positionSpinner
{
    CGRect frame = self.spinner.frame;
    frame.origin.x = (self.frame.size.width - frame.size.width)/2;
    frame.origin.y = (self.frame.size.height - frame.size.height)/2;
    self.spinner.frame = frame;
}

- (void)showSpinner:(BOOL)show
{
    if (show && self.spinner.hidden) {
        self.spinner.hidden = NO;
        [self.spinner startAnimating];
    } else if (!show && !self.spinner.hidden) {
        self.spinner.hidden = YES;
        [self.spinner stopAnimating];
    }
}

#pragma mark - Debug

- (UIColor *)getColor:(NSString *)identifier
{
    UIColor *color = [UIColor clearColor];
    if (/* DISABLES CODE */ (NO)) {
        if ([identifier isEqualToString:@"Background"]) {
            color = [UIColor MPColorWithHexString:@"93A3B1"];
        } else if ([identifier isEqualToString:@"Scroll View"]) {
            color = [UIColor MPColorWithHexString:@"AEB2B0"];
        } else if ([identifier isEqualToString:@"Page Cell"]) {
            color = [UIColor MPColorWithHexString:@"000000"];
        }
    }
    return color;
}

@end
