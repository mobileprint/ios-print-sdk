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

#import "UIImage+MPBundle.h"
#import "MP.h"

@implementation UIImage (MPBundle)

+ (UIImage *)imageResource:(NSString *)resource ofType:(NSString *)extension
{
    NSBundle *bundle = [NSBundle bundleForClass:[MP class]];
    
    // Note: The bundle-aware version of 'imagedNamed' is only available in iOS >= 8
    if ([[UIImage class] respondsToSelector:@selector(imageNamed:inBundle:compatibleWithTraitCollection:)]) {
        NSString *name = [NSString stringWithFormat:@"%@.%@", resource, extension];
        return [UIImage imageNamed:name inBundle:bundle compatibleWithTraitCollection:nil];
    } else {
        // In iOS 7 we must perform the bundle search manually
        NSArray *resources = @[
                           resource,
                           [NSString stringWithFormat:@"%@@2x", resource],
                           [NSString stringWithFormat:@"%@@3x", resource],
                           [NSString stringWithFormat:@"%@@2x~iphone", resource],
                           [NSString stringWithFormat:@"%@@2x~ipad", resource],
                           [NSString stringWithFormat:@"%@@3x~iphone", resource],
                           [NSString stringWithFormat:@"%@@3x~ipad", resource]
                           ];
        for (NSString *variation in resources) {
            NSString *path = [bundle pathForResource:variation ofType:extension];
            if (path) {
                return [UIImage imageWithContentsOfFile:path];
            }
        }
    }
    return nil;
}

@end
