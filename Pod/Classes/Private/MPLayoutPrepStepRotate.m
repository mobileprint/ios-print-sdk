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

MPLayoutOrientation const kMPDefaultOrientation = MPLayoutOrientationBestFit;

#pragma mark - Initialization

- (id)init
{
    return [self initWithOrientation:kMPDefaultOrientation];
}

- (id)initWithOrientation:(MPLayoutOrientation)orientation
{
    self = [super init];
    if (self) {
        _orientation = orientation;
        _rotated = NO;
    }
    return self;
}

#pragma mark - Layout

- (UIImage *)imageForImage:(UIImage *)image inContainer:(CGRect)containerRect
{
    CGRect contentRect = CGRectMake(0, 0, image.size.width, image.size.height);
    UIImage *adjustedImage = image;
    _rotated = NO;
    if ([self rotationNeededForContent:contentRect withContainer:containerRect]) {
        adjustedImage = [image MPRotate];
        _rotated = YES;
    }
    return adjustedImage;
}

- (CGRect)contentRectForContent:(CGRect)contentRect inContainer:(CGRect)containerRect
{
    CGRect adjustedRect = contentRect;
    _rotated = NO;
    if ([self rotationNeededForContent:contentRect withContainer:containerRect]) {
        adjustedRect = CGRectMake(contentRect.origin.x, contentRect.origin.y, contentRect.size.height, contentRect.size.width);
        _rotated = YES;
    }
    return adjustedRect;
}

#pragma mark - Computation

- (BOOL)rotationNeededForContent:(CGRect)contentRect withContainer:(CGRect)containerRect
{
    BOOL contentIsSquare = (CGFLOAT_MIN >= fabs(contentRect.size.width - contentRect.size.height));
    BOOL containerIsSquare = (CGFLOAT_MIN >= fabs(containerRect.size.width - containerRect.size.height));
    
    BOOL rotationNeeded = NO;
    if (self.orientation != MPLayoutOrientationFixed) {
        BOOL contentIsPortrait = contentIsSquare || (contentRect.size.width < contentRect.size.height);
        BOOL contentIsLandscape = !contentIsPortrait;
        
        BOOL containerIsPortrait = containerIsSquare || (containerRect.size.width < containerRect.size.height);
        BOOL containerIsLandscape = !containerIsPortrait;
        
        BOOL contentMatchesContainer = ((contentIsPortrait && containerIsPortrait) || (contentIsLandscape && containerIsLandscape));
        
        if (MPLayoutOrientationPortrait == self.orientation) {
            rotationNeeded = containerIsLandscape;
        } else if (MPLayoutOrientationLandscape == self.orientation) {
            rotationNeeded = containerIsPortrait;
        } else if (MPLayoutOrientationBestFit == self.orientation) {
            if (!containerIsSquare && !contentIsSquare) {
                rotationNeeded = !contentMatchesContainer;
            } else {
                MPLogWarn(@"Cannot use MPLayoutOrientationBestFit when content or container is square. Will NOT rotate content.");
            }
        }
    }
    
    return rotationNeeded;
}

#pragma mark - NSCoding interface

static NSString * const kMPLayoutPrepStepRotateOrientationKey = @"kMPLayoutPrepStepRotateOrientationKey";

- (void)encodeWithCoder:(NSCoder *)encoder
{
    [encoder encodeInteger:self.orientation forKey:kMPLayoutPrepStepRotateOrientationKey];
}

- (id)initWithCoder:(NSCoder *)decoder
{
    MPLayoutOrientation orientation = (MPLayoutOrientation)[decoder decodeIntegerForKey:kMPLayoutPrepStepRotateOrientationKey];
    self = [self initWithOrientation:orientation];
    return self;
}

@end

