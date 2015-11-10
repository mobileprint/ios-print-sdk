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
#import "MPPaper.h"
#import "MPLayoutPaperView.h"

@interface MPLayoutPaperCellView : UIView

@property (strong, nonatomic) MPLayoutPaperView *paperView;
@property (strong, nonatomic) MPPaper *paper;

- (id)initWithFrame:(CGRect)frame paperView:(MPLayoutPaperView *)paperView paper:(MPPaper *)paper;

@end
