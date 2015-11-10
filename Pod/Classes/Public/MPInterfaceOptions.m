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

#import "MPInterfaceOptions.h"

@implementation MPInterfaceOptions

- (id)init
{
    self = [super init];
    if (self)  {
        self.multiPageMinimumGutter = 20;
        self.multiPageMaximumGutter = 0;
        self.multiPageBleed = 20;
        self.multiPageBackgroundPageScale = 1.0;
        self.multiPageDoubleTapEnabled = NO;
        self.multiPageZoomOnSingleTap = NO;
        self.multiPageZoomOnDoubleTap = NO;
    }
    return self;
}
@end
