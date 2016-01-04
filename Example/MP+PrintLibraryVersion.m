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

#import "MP+PrintLibraryVersion.h"
#import <objc/runtime.h>

@interface MP ()

// Expose this private method so it can be swizzled below
- (NSString *)printLibraryVersion;

@end

@implementation MP (PrintLibraryVersion)

#pragma  mark - Custom print library property

static NSString *kCustomPrintLibraryVersion = nil;

- (NSString *)customPrintLibraryVersion
{
    return kCustomPrintLibraryVersion;
}

- (void)setCustomPrintLibraryVersion:(NSString *)version
{
    kCustomPrintLibraryVersion = version;
}

#pragma mark - Method Swizzling

// Adapted from http://nshipster.com/method-swizzling/
+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        Class class = [self class];
        
        SEL originalSelector = @selector(printLibraryVersion);
        SEL swizzledSelector = @selector(custom_printLibraryVersion);
        
        Method originalMethod = class_getInstanceMethod(class, originalSelector);
        Method swizzledMethod = class_getInstanceMethod(class, swizzledSelector);
        
        BOOL didAddMethod =
        class_addMethod(class,
                        originalSelector,
                        method_getImplementation(swizzledMethod),
                        method_getTypeEncoding(swizzledMethod));
        
        if (didAddMethod) {
            class_replaceMethod(class,
                                swizzledSelector,
                                method_getImplementation(originalMethod),
                                method_getTypeEncoding(originalMethod));
        } else {
            method_exchangeImplementations(originalMethod, swizzledMethod);
        }
    });
}


- (NSString *)custom_printLibraryVersion {
    return self.customPrintLibraryVersion ? self.customPrintLibraryVersion : [self custom_printLibraryVersion];
}

@end