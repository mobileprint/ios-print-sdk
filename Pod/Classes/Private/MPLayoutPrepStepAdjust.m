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

- (CGRect)containerForImage:(UIImage *)image inContainer:(CGRect)containerRect
{
    return CGRectMake(containerRect.origin.x + containerRect.size.width * self.layout.assetPosition.origin.x / 100.0f,
                      containerRect.origin.y + containerRect.size.height * self.layout.assetPosition.origin.y / 100.0f,
                      containerRect.size.width * self.layout.assetPosition.size.width / 100.0f,
                      containerRect.size.height * self.layout.assetPosition.size.height / 100.0f);
}

@end
