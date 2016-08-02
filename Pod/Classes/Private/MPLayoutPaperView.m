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
#import "UIImage+MPBundle.h"

static const NSInteger MPLAYOUTPAPERVIEW_MULTIPAGE_OFFSET_PORTRAIT = 10;
static const NSInteger MPLAYOUTPAPERVIEW_MULTIPAGE_OFFSET_LANDSCAPE = 8;
static const NSInteger MPLAYOUTPAPERVIEW_MULTIPAGE_END_GAP = 5;

@implementation MPLayoutPaperView

- (void)drawRect:(CGRect)rect {
    CGFloat adjustedBorder = rect.size.width * self.layout.borderInches / self.referenceWidthInches;
    CGRect insetRect = CGRectInset(rect, adjustedBorder, adjustedBorder);
    
    if( (NSNull *)self.image != [NSNull null] ) {
        if (self.useMultiPageIndicator) {
            NSInteger offset = MPLAYOUTPAPERVIEW_MULTIPAGE_OFFSET_PORTRAIT;
            CGRect layoutContainer = [self.layout contentImageLocation:self.image inRect:insetRect];
            BOOL isLandscape = (layoutContainer.size.width > layoutContainer.size.height);
            
            UIImage *multiPageImage = [UIImage imageResource:@"MPMultipageWire" ofType:@"png"];
            
            // rotate the multiPageWire image and adjust the spacing for landscape scenarios
            if (isLandscape) {
                UIImage *rotatedImage = [UIImage imageWithCGImage:multiPageImage.CGImage
                                                            scale:multiPageImage.scale
                                                      orientation:UIImageOrientationRightMirrored];
                multiPageImage = rotatedImage;
                
                offset = MPLAYOUTPAPERVIEW_MULTIPAGE_OFFSET_LANDSCAPE;
            }

            // now, get the proper sizes and locations for the view
            insetRect.origin.x += offset;
            insetRect.size.width -= offset;
            insetRect.size.height -= offset;

            layoutContainer = [self.layout contentImageLocation:self.image inRect:insetRect];
 
            CGRect multipageFrame = CGRectMake(layoutContainer.origin.x - offset,
                                               layoutContainer.origin.y + MPLAYOUTPAPERVIEW_MULTIPAGE_END_GAP,
                                               layoutContainer.size.width + (offset - MPLAYOUTPAPERVIEW_MULTIPAGE_END_GAP),
                                               layoutContainer.size.height + (offset - MPLAYOUTPAPERVIEW_MULTIPAGE_END_GAP));
            
            [multiPageImage drawInRect:multipageFrame];
        }

        MPLogDebug(@"~~~~~~~~~~~~~~~~~~~~~");
        MPLogDebug(@"UI LAYOUT (MPLayoutPaperView)");
        MPLogDebug(@"~~~~~~~~~~~~~~~~~~~~~");
        [self.layout drawContentImage:self.image inRect:insetRect];
    }
}

@end
