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

#import "UIColor+MPStyle.h"

@implementation UIColor (MPStyle)

+ (UIColor *)MPHPGrayBackgroundColor
{
    return [UIColor colorWithRed:239.0f/255.0f green:239.0f/255.0f blue:244.0f/255.0f alpha:1.0f];
}

+ (UIColor *)MPHPBlueColor
{
    return [UIColor colorWithRed:0x00/255.0 green:0x96/255.0 blue:0xD6/255.0 alpha:1.0];
}

+ (UIColor *)MPHPTabBarSelectedColor
{
    return [UIColor colorWithRed:0x40/255.0f green:0x46/255.0f blue:0x4D/255.0f alpha:1.0f];
}

@end
