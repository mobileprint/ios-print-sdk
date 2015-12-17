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

#import "MPLayoutPrepStepAdjust.h"

@implementation MPLayoutPrepStepAdjust

CGFloat const kMPLayoutPrepStepAdjustDefaultX = 0.0;
CGFloat const kMPLayoutPrepStepAdjustDefaultY = 0.0;
CGFloat const kMPLayoutPrepStepAdjustDefaultWidth = 100.0;
CGFloat const kMPLayoutPrepStepAdjustDefaultHeight = 100.0;

#pragma mark - Initialization

- (id)init
{
    return [self initWithAdjustment:CGRectMake(kMPLayoutPrepStepAdjustDefaultX,
                                               kMPLayoutPrepStepAdjustDefaultY,
                                               kMPLayoutPrepStepAdjustDefaultWidth,
                                               kMPLayoutPrepStepAdjustDefaultHeight)];
}

- (id)initWithAdjustment:(CGRect)adjustment
{
    self = [super init];
    if (self) {
        _adjustment = adjustment;
    }
    return self;
}

#pragma mark - Layout

- (CGRect)containerRectForContent:(CGRect)contentRect inContainer:(CGRect)containerRect
{
    return CGRectMake(containerRect.origin.x + containerRect.size.width * self.adjustment.origin.x / 100.0f,
                      containerRect.origin.y + containerRect.size.height * self.adjustment.origin.y / 100.0f,
                      containerRect.size.width * self.adjustment.size.width / 100.0f,
                      containerRect.size.height * self.adjustment.size.height / 100.0f);
}

#pragma mark - NSCoding interface

static NSString * const kMPLayoutPrepStepAdjustAdjustmentKey = @"kMPLayoutPrepStepAdjustAdjustmentKey";

- (void)encodeWithCoder:(NSCoder *)encoder
{
    [encoder encodeCGRect:self.adjustment forKey:kMPLayoutPrepStepAdjustAdjustmentKey];
}

- (id)initWithCoder:(NSCoder *)decoder
{
    CGRect adjustment = [decoder decodeCGRectForKey:kMPLayoutPrepStepAdjustAdjustmentKey];
    self = [self initWithAdjustment:adjustment];
    return self;
}

@end
