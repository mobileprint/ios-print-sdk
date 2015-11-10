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

#import "MPSupportAction.h"

@implementation MPSupportAction

- (id)initWithIcon:(UIImage *)icon title:(NSString *)title url:(NSURL *)url
{
    self = [super init];
    
    if (self) {
        self.icon = icon;
        self.title = title;
        self.url = url;
    }
    
    return self;
}

- (id)initWithIcon:(UIImage *)icon title:(NSString *)title viewController:(UINavigationController *)viewController
{
    self = [super init];
    
    if (self) {
        self.icon = icon;
        self.title = title;
        self.viewController = viewController;
    }
    
    return self;
}

@end
