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

#import "MPLayoutPrepStepRotate.h"
#import "UIImage+MPResize.h"

@implementation MPLayoutPrepStepRotate

- (UIImage *)imageForImage:(UIImage *)image inContainer:(CGRect)containerRect
{
    CGRect contentRect = CGRectMake(0, 0, image.size.width, image.size.height);
    UIImage *adjustedImage = image;
    if ([self rotationNeededForContent:contentRect withContainer:containerRect]) {
        adjustedImage = [image MPRotate];
    }
    return adjustedImage;
}

- (BOOL)rotationNeededForContent:(CGRect)contentRect withContainer:(CGRect)containerRect
{
    BOOL contentIsSquare = (CGFLOAT_MIN >= fabs(contentRect.size.width - contentRect.size.height));
    BOOL containerIsSquare = (CGFLOAT_MIN >= fabs(containerRect.size.width - containerRect.size.height));
    
    BOOL rotationNeeded = NO;
    if (self.layout.orientation != MPLayoutOrientationFixed) {
        BOOL contentIsPortrait = contentIsSquare || (contentRect.size.width < contentRect.size.height);
        BOOL contentIsLandscape = !contentIsPortrait;
        
        BOOL containerIsPortrait = containerIsSquare || (containerRect.size.width < containerRect.size.height);
        BOOL containerIsLandscape = !containerIsPortrait;
        
        BOOL contentMatchesContainer = ((contentIsPortrait && containerIsPortrait) || (contentIsLandscape && containerIsLandscape));
        
        if (MPLayoutOrientationPortrait == self.layout.orientation) {
            rotationNeeded = containerIsLandscape;
        } else if (MPLayoutOrientationLandscape == self.layout.orientation) {
            rotationNeeded = containerIsPortrait;
        } else if (MPLayoutOrientationBestFit == self.layout.orientation) {
            if (!containerIsSquare && !contentIsSquare) {
                rotationNeeded = !contentMatchesContainer;
            } else {
                MPLogWarn(@"Cannot use MPLayoutOrientationBestFit when content or container is square. Will NOT rotate content.");
            }
        }
    }
    
    return rotationNeeded;
}

@end

