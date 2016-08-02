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

#import "MPLayoutAlgorithmFit.h"

@implementation MPLayoutAlgorithmFit

MPLayoutHorizontalPosition const kMPDefaultHorizontalPosition = MPLayoutHorizontalPositionMiddle;
MPLayoutVerticalPosition const kMPDefaultVerticalPosition = MPLayoutVerticalPositionMiddle;

#pragma mark - Initialization

- (id)init
{
    return [self initWithHorizontalPosition:kMPDefaultHorizontalPosition
                        andVerticalPosition:kMPDefaultVerticalPosition];
}

- (id)initWithHorizontalPosition:(MPLayoutHorizontalPosition)horizontalPosition andVerticalPosition:(MPLayoutVerticalPosition)verticalPosition
{
    self = [super init];
    if (self) {
        _horizontalPosition = horizontalPosition;
        _verticalPosition = verticalPosition;
    }
    return self;
}

#pragma mark - Layout

- (void)drawImage:(UIImage *)image inContainer:(CGRect)containerRect
{
    CGRect computedRect = [self getContainerForImage:image inContainer:containerRect];
    
    MPLogDebug(@"~~~~~~~~~~~~~~~~~~~~~");
    MPLogDebug(@"LAYOUT ALGORITHM FIT");
    MPLogDebug(@"~~~~~~~~~~~~~~~~~~~~~");
    [[MPLogger sharedInstance] logSize:image.size withName:@"IMAGE"];
    [[MPLogger sharedInstance] logRect:containerRect withName:@"CONTAINER"];
    [[MPLogger sharedInstance] logRect:computedRect withName:@"LAYOUT"];
    MPLogDebug(@"~~~~~~~~~~~~~~~~~~~~~");
    
    [image drawInRect:computedRect];
}

- (CGRect)getContainerForImage:(UIImage *)image inContainer:(CGRect)containerRect
{
    CGRect contentRect = CGRectMake(0, 0, image.size.width, image.size.height);
    CGRect layoutContainer = [self computeRectWithContentRect:contentRect andContainerRect:containerRect];

    return layoutContainer;
}

- (void)resizeContentView:(UIView *)contentView containerView:(UIView *)containerView contentRect:(CGRect)contentRect containerRect:(CGRect)containerRect
{
    CGRect contentframe = [self computeRectWithContentRect:contentRect andContainerRect:containerRect];
    [self applyConstraintsWithFrame:contentframe toContentView:contentView inContainerView:containerView];
}

#pragma mark - Computation

- (CGRect)computeRectWithContentRect:(CGRect)contentRect andContainerRect:(CGRect)containerRect
{
    CGFloat contentAspectRatio = contentRect.size.width / contentRect.size.height;
    CGFloat containerAspectRatio = containerRect.size.width / containerRect.size.height;
    CGFloat width = containerRect.size.height * contentAspectRatio;
    CGFloat height = containerRect.size.height;
    if (contentAspectRatio > containerAspectRatio) {
        width = containerRect.size.width;
        height = containerRect.size.width / contentAspectRatio;
    }
    CGFloat x = containerRect.origin.x + (containerRect.size.width - width) / 2.0;
    CGFloat y = containerRect.origin.y + (containerRect.size.height - height) / 2.0;
    
    if( MPLayoutVerticalPositionTop == self.verticalPosition ) {
        y = containerRect.origin.y;
    } else if( MPLayoutVerticalPositionBottom == self.verticalPosition ) {
        y = containerRect.origin.y + containerRect.size.height - height;
    }
    
    if( MPLayoutHorizontalPositionLeft == self.horizontalPosition ) {
        x = containerRect.origin.x;
    } else if( MPLayoutHorizontalPositionRight == self.horizontalPosition ) {
        x = containerRect.origin.x + containerRect.size.width - width;
    }
    
    return CGRectMake(roundf(x), roundf(y), roundf(width), roundf(height));
}

#pragma mark - NSCoding interface

static NSString * const kMPLayoutAlgorithmFitHorizontalPositionKey = @"kMPLayoutAlgorithmFitHorizontalPositionKey";
static NSString * const kMPLayoutAlgorithmFitVerticalPositionKey = @"kMPLayoutAlgorithmFitVerticalPositionKey";

- (void)encodeWithCoder:(NSCoder *)encoder
{
    [encoder encodeInteger:self.horizontalPosition forKey:kMPLayoutAlgorithmFitHorizontalPositionKey];
    [encoder encodeInteger:self.verticalPosition forKey:kMPLayoutAlgorithmFitVerticalPositionKey];
}

- (id)initWithCoder:(NSCoder *)decoder
{
    MPLayoutHorizontalPosition horizontalPosition = (MPLayoutHorizontalPosition)[decoder decodeIntegerForKey:kMPLayoutAlgorithmFitHorizontalPositionKey];
    MPLayoutVerticalPosition verticalPosition = (MPLayoutVerticalPosition)[decoder decodeIntegerForKey:kMPLayoutAlgorithmFitVerticalPositionKey];
    self = [self initWithHorizontalPosition:horizontalPosition andVerticalPosition:verticalPosition];
    return self;
}

@end
