//
//  MPLayoutPrepStepAdjust.m
//  Pods
//
//  Created by James Trask on 12/9/15.
//
//

#import "MPLayoutPrepStepAdjust.h"

@implementation MPLayoutPrepStepAdjust

- (CGRect)containerForImage:(UIImage *)image inContainer:(CGRect)containerRect
{
    return CGRectMake(containerRect.origin.x + containerRect.size.width * self.layout.assetPosition.origin.x / 100.0f,
                      containerRect.origin.y + containerRect.size.height * self.layout.assetPosition.origin.y / 100.0f,
                      containerRect.size.width * self.layout.assetPosition.size.width / 100.0f,
                      containerRect.size.height * self.layout.assetPosition.size.height / 100.0f);
}

@end
