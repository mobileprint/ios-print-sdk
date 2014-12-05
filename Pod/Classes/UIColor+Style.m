//
// Hewlett-Packard Company
// All rights reserved.
//
// This file, its contents, concepts, methods, behavior, and operation
// (collectively the "Software") are protected by trade secret, patent,
// and copyright laws. The use of the Software is governed by a license
// agreement. Disclosure of the Software to third parties, in any form,
// in whole or in part, is expressly prohibited except as authorized by
// the license agreement.
//

#import "UIColor+Style.h"

@implementation UIColor (Style)

+ (UIColor *)HPBlueColor
{
    return [UIColor colorWithRed:0x00/255.0 green:0x96/255.0 blue:0xD6/255.0 alpha:1.0];
}

+ (UIColor *)HPGrayColor
{
    return [UIColor colorWithRed:0x33/255.0f green:0x33/255.0f blue:0x33/255.0f alpha:1.0f];
}

+ (UIColor *)HPBlueButtonColor
{
    return [self HPBlueColor];
}

+ (UIColor *)HPGrayBackgroundColor
{
    return [UIColor colorWithRed:239.0f/255.0f green:239.0f/255.0f blue:244.0f/255.0f alpha:1.0f];
}

+ (UIColor *)HPGrayButtonColor
{
    return [UIColor colorWithRed:0x76/255.0f green:0x76/255.0f blue:0x76/255.0f alpha:1.0f];
}

+ (UIColor *)HPTabBarSelectedColor
{
    return [UIColor colorWithRed:0x40/255.0f green:0x46/255.0f blue:0x4D/255.0f alpha:1.0f];
}

+ (UIColor *)HPTabBarUnselectedColor
{
    return [UIColor colorWithRed:0x5A/255.0f green:0x64/255.0f blue:0x6D/255.0f alpha:1.0f];
}

+ (UIColor *)HPTableRowSelectionColor
{
    return [UIColor colorWithRed:0x68/255.0f green:0xB2/255.0f blue:0xE3/255.0f alpha:1.0f];
}

+ (UIImage *)imageWithColor:(UIColor *)color rect:(CGRect)rect
{
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}

@end
