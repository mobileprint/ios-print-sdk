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

#import "NSBundle+MPLocalizable.h"
#import "MP.h"

@implementation NSBundle (MPLocalizable)

+ (NSBundle *)MPLocalizableBundle
{
    static dispatch_once_t once;
    static NSBundle *bundle = nil;
    
    dispatch_once(&once, ^{
        NSURL *url = [[NSBundle bundleForClass:[MP class]] URLForResource:HP_PHOTO_PRINT_LOCALIZATION_BUNDLE_NAME withExtension:@"bundle"];
        bundle = [[NSBundle alloc] initWithURL:url];
    });
    
    return bundle;
}

@end
