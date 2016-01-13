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

#import "MPLayoutComposite.h"

@interface MPLayoutComposite()

@property (strong, nonatomic) MPLayoutAlgorithm *algorithm;
@property (strong, nonatomic) NSArray *prepSteps;

@end

@implementation MPLayoutComposite

#pragma mark - Initialization

- (id)initWithAlgorithm:(MPLayoutAlgorithm *)algorithm andPrepSteps:(NSArray *)prepSteps
{
    self = [super init];
    
    if (self) {
        self.algorithm = algorithm;
        self.prepSteps = prepSteps;
    }
    
    return self;
}

#pragma mark - Layout

- (void)drawContentImage:(UIImage *)image inRect:(CGRect)rect
{
    UIImage *layoutImage = [[UIImage alloc] init];
    CGRect layoutContainer = CGRectMake(0.0, 0.0, 0.0, 0.0);
    [self getImageAndContainerForImage:image inRect:rect finalImage:&layoutImage finalRect:&layoutContainer];
    
    [self.algorithm drawImage:layoutImage inContainer:layoutContainer];
}

- (CGRect)contentImageLocation:(UIImage *)image inRect:(CGRect)rect
{
    UIImage *layoutImage = [[UIImage alloc] init];
    CGRect layoutContainer = CGRectMake(0.0, 0.0, 0.0, 0.0);
    [self getImageAndContainerForImage:image inRect:rect finalImage:&layoutImage finalRect:&layoutContainer];    
    layoutContainer = [self.algorithm getContainerForImage:layoutImage inContainer:layoutContainer];

    return layoutContainer;
}

- (void)layoutContentView:(UIView *)contentView inContainerView:(UIView *)containerView
{
    CGRect layoutContent = contentView.bounds;
    CGRect layoutContainer = containerView.bounds;
    for (MPLayoutPrepStep *step in self.prepSteps) {
        CGRect newContent = [step contentRectForContent:layoutContent inContainer:layoutContainer];
        CGRect newContainer = [step containerRectForContent:layoutContent inContainer:layoutContainer];
        layoutContent = newContent;
        layoutContainer = newContainer;
    }
    
    [self.algorithm resizeContentView:contentView containerView:containerView contentRect:layoutContent containerRect:layoutContainer];
}

- (void)getImageAndContainerForImage:(UIImage *)image inRect:(CGRect)rect finalImage:(UIImage **)finalImage finalRect:(CGRect *)finalRect
{
    UIImage *layoutImage = image;
    CGRect layoutContent = CGRectMake(0, 0, layoutImage.size.width, layoutImage.size.height);
    CGRect layoutContainer = rect;
    for (MPLayoutPrepStep *step in self.prepSteps) {
        UIImage *newImage = [step imageForImage:layoutImage inContainer:layoutContainer];
        CGRect newContainer = [step containerRectForContent:layoutContent inContainer:layoutContainer];
        layoutImage = newImage;
        layoutContent = CGRectMake(0, 0, newImage.size.width, newImage.size.height);
        layoutContainer = newContainer;
    }
    
    *finalImage = layoutImage;
    *finalRect = layoutContainer;
}

#pragma mark - NSCoding interface

static NSString * const kMPLayoutCompositeAlgorithmKey = @"MPLayoutCompositeAlgorithmKey";
static NSString * const kMPLayoutCompositePrepStepsKey = @"MPLayoutCompositePrepStepsKey";

- (void)encodeWithCoder:(NSCoder *)encoder
{
    [super encodeWithCoder:encoder];
    [encoder encodeObject:self.algorithm forKey:kMPLayoutCompositeAlgorithmKey];
    [encoder encodeObject:self.prepSteps forKey:kMPLayoutCompositePrepStepsKey];
}

- (id)initWithCoder:(NSCoder *)decoder
{
    if (self = [super initWithCoder:decoder]) {
        MPLayoutAlgorithm *algorithm = [decoder decodeObjectForKey:kMPLayoutCompositeAlgorithmKey];
        NSArray *prepSteps = [decoder decodeObjectForKey:kMPLayoutCompositePrepStepsKey];
        self.algorithm = algorithm;
        self.prepSteps = prepSteps;
    }
    
    return self;
}

@end
