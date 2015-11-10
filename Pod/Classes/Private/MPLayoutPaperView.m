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

#import "MPLayoutPaperView.h"

@implementation MPLayoutPaperView

- (void)drawRect:(CGRect)rect {
    CGFloat adjustedBorder = rect.size.width * self.layout.borderInches / self.referenceWidthInches;
    CGRect insetRect = CGRectInset(rect, adjustedBorder, adjustedBorder);
    [self.layout drawContentImage:self.image inRect:insetRect];
}

@end
