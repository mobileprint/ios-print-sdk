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
@property (strong, nonatomic) NSArray<MPLayoutPrepStep *> *prepSteps;

@end

@implementation MPLayoutComposite

#pragma mark - Initialization

- (id)initWithAlgorithm:(MPLayoutAlgorithm *)algorithm andPrepSteps:(NSArray<MPLayoutPrepStep *> *)prepSteps
{
    self = [super init];
    
    if (self) {
        self.algorithm = algorithm;
        self.prepSteps = prepSteps;
    }
    
    return self;
}

- (id)initWithOrientation:(MPLayoutOrientation)orientation andAlgorithm:(MPLayoutAlgorithm *)algorithm andPrepSteps:(NSArray<MPLayoutPrepStep *> *)prepSteps
{
    self = [super initWithOrientation:orientation assetPosition:CGRectMake(0,0, 100,100)];
    
    if (self) {
        self.algorithm = algorithm;
        self.prepSteps = prepSteps;
    }
    
    return self;
}

#pragma mark - Layout

- (void)drawContentImage:(UIImage *)image inRect:(CGRect)rect
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
    
    [self.algorithm drawImage:layoutImage inContainer:layoutContainer];
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

#pragma mark - NSCoding interface

static NSString * const kMPAlgorithm = @"kMPAlgorithm";
static NSString * const kMPPrepSteps = @"kMPPrepSteps";
static NSString * const kMPOrientation = @"kMPOrientation";

- (void)encodeWithCoder:(NSCoder *)encoder
{
    [encoder encodeObject:self.algorithm forKey:kMPAlgorithm];
    [encoder encodeObject:self.prepSteps forKey:kMPPrepSteps];
    [encoder encodeObject:[NSNumber numberWithInteger:self.orientation] forKey:kMPOrientation];
}

- (id)initWithCoder:(NSCoder *)decoder
{
    MPLayoutAlgorithm *algorithm = [decoder decodeObjectForKey:kMPAlgorithm];
    NSArray *prepSteps = [decoder decodeObjectForKey:kMPPrepSteps];
    NSNumber *orientation = [decoder decodeObjectForKey:kMPOrientation];

    self = [self initWithOrientation:(MPLayoutOrientation)[orientation integerValue] andAlgorithm:algorithm andPrepSteps:prepSteps];
    
    return self;
}

@end
