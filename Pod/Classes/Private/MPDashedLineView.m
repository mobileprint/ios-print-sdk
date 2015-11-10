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

#import "MPDashedLineView.h"

@implementation MPDashedLineView

- (id)init
{
    self = [super init];
    if (self) {
        [self drawDashedLine];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self drawDashedLine];
    }
    return self;
}

- (void)drawDashedLine
{
    CAShapeLayer *shapeLayer = [CAShapeLayer layer];
    [shapeLayer setBounds:self.bounds];
    
    if (self.frame.size.width == 1) {
        [shapeLayer setPosition:CGPointMake(0.0f, self.frame.origin.y)];
    } else {
        [shapeLayer setPosition:CGPointMake(self.frame.origin.x, 0.0f)];
    }

    [shapeLayer setFillColor:[[UIColor clearColor] CGColor]];
    [shapeLayer setStrokeColor:[[UIColor lightGrayColor] CGColor]];
    [shapeLayer setLineWidth:1.0f];
    [shapeLayer setLineJoin:kCALineJoinMiter];
    [shapeLayer setLineDashPattern:@[@1, @1]];
    
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathMoveToPoint(path, NULL, 0.0f, 0.0f);
    CGPathAddLineToPoint(path, NULL, (self.bounds.size.width == 1.0f)? 0.0f : self.bounds.size.width, (self.bounds.size.height == 1.0f)? 0.0f : self.bounds.size.height);
    [shapeLayer setPath:path];
    CGPathRelease(path);
    
    [self.layer addSublayer:shapeLayer];
}

@end
