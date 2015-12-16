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

#import <Foundation/Foundation.h>
#import "MPLayout.h"

@interface MPLayoutPrepStep : NSObject <NSCoding>

- (UIImage *)imageForImage:(UIImage *)image inContainer:(CGRect)containerRect;
- (CGRect)contentRectForContent:(CGRect)contentRect inContainer:(CGRect)containerRect;
- (CGRect)containerRectForContent:(CGRect)contentRect inContainer:(CGRect)containerRect;

@end
