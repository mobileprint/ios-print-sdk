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

#import "MPLayoutPaperCellView.h"
#import "MPLayoutFactory.h"

@implementation MPLayoutPaperCellView

CGFloat const kPageAlpha = 1.0;

- (id)initWithFrame:(CGRect)frame paperView:(MPLayoutPaperView *)paperView paper:(MPPaper *)paper
{
    self = [super initWithFrame:frame];
    if (self) {
        self.paperView = paperView;
        self.paper = paper;
        self.alpha = kPageAlpha;
    }
    return self;
}

- (void)setPaperView:(MPLayoutPaperView *)paperView
{
    if (self.paperView) {
        [self.paperView removeFromSuperview];
    }
    _paperView = paperView;
    [self addSubview:self.paperView];
    [self refreshLayout];
}

- (void)setPaper:(MPPaper *)paper
{
    _paper = paper;
    [self refreshLayout];
}

- (void)refreshLayout
{
    if (self.paperView && self.paper) {
        MPLayout *paperLayout = [MPLayoutFactory layoutWithType:[MPLayoutFit layoutType] orientation:MPLayoutOrientationFixed assetPosition:[MPLayout completeFillRectangle]];
        [MPLayout preparePaperView:self.paperView withPaper:self.paper];
        [paperLayout layoutContentView:self.paperView inContainerView:self];
        self.paperView.hidden = NO;
    } else if (self.paperView) {
        self.paperView.hidden = YES;
    }
}

@end
