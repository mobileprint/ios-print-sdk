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

#define MPLAYOUTPAPERVIEW_MULTIPAGE_XOFFSET 30
#define MPLAYOUTPAPERVIEW_MULTIPAGE_YOFFSET 25
#define MPLAYOUTPAPERVIEW_MULTIPAGE_END_GAP 30

@implementation MPLayoutPaperView

- (void)drawRect:(CGRect)rect {
    CGFloat adjustedBorder = rect.size.width * self.layout.borderInches / self.referenceWidthInches;
    CGRect insetRect = CGRectInset(rect, adjustedBorder, adjustedBorder);
    
    if( (NSNull *)self.image != [NSNull null] ) {
        if (self.useMultiPageIndicator) {
            UIImage *multiPageImage = [UIImage imageNamed:@"MPMultipage"];
            UIGraphicsBeginImageContextWithOptions(self.image.size, NO, 0.0);
            [multiPageImage drawInRect:CGRectMake(0, 0, self.image.size.width-MPLAYOUTPAPERVIEW_MULTIPAGE_END_GAP, self.image.size.height-MPLAYOUTPAPERVIEW_MULTIPAGE_END_GAP)];
            UIImage *newMultiPageImage = UIGraphicsGetImageFromCurrentImageContext();
            UIGraphicsEndImageContext();
            
            [self.layout drawContentImage:newMultiPageImage inRect:insetRect];

            insetRect.origin.x += MPLAYOUTPAPERVIEW_MULTIPAGE_XOFFSET;
            insetRect.origin.y += MPLAYOUTPAPERVIEW_MULTIPAGE_YOFFSET;
            insetRect.size.width -= MPLAYOUTPAPERVIEW_MULTIPAGE_XOFFSET;
            insetRect.size.height -= MPLAYOUTPAPERVIEW_MULTIPAGE_YOFFSET;
        }

        [self.layout drawContentImage:self.image inRect:insetRect];
    }
}

@end
