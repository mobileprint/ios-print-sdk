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
    
    if( (NSNull *)self.image != [NSNull null] ) {
        if (self.useMultiPageIndicator) {
            
            CGFloat multiPageEndGap = 30.0F;

            UIImage *multiPageImage = [UIImage imageNamed:@"MPMultipage"];
            UIGraphicsBeginImageContextWithOptions(self.image.size, NO, 0.0);
            [multiPageImage drawInRect:CGRectMake(0, 0, self.image.size.width-multiPageEndGap, self.image.size.height-multiPageEndGap)];
            UIImage *newMultiPageImage = UIGraphicsGetImageFromCurrentImageContext();
            UIGraphicsEndImageContext();
            
            [self.layout drawContentImage:newMultiPageImage inRect:insetRect];

            insetRect.origin.x += 30;
            insetRect.origin.y += 25;
            insetRect.size.width -= 30;
            insetRect.size.height -= 25;
        }

        
        [self.layout drawContentImage:self.image inRect:insetRect];
    }
}

@end
