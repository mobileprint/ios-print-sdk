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

#import "UIImage+Resize.h"


@implementation UIImage (Resize)

- (CGRect)rectForImageResize:(CGSize)resize
{
    CGFloat oldWidth = self.size.width;
    CGFloat scaleFactor = resize.width / oldWidth;
    
    CGFloat newHeight = self.size.height * scaleFactor;
    CGFloat newWidth = oldWidth * scaleFactor;
    
    return CGRectMake(0, 0, newWidth, newHeight);
}

- (UIImage *)imageResize:(CGSize)resize
{
    CGRect newRect = [self rectForImageResize:resize];
    
    UIGraphicsBeginImageContextWithOptions(newRect.size, YES, 0.0);
    
    [self drawInRect:newRect];
    
    UIImage *scaledImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return scaledImage;
}

- (UIImage *)cropImageResize:(CGSize)resize
{
    CGRect newRect;
    
    CGFloat scaleWidth = resize.width / self.size.width;
    CGFloat scaleHeight = resize.height / self.size.height;
    
    if (scaleHeight > scaleWidth) {
        // Crop the right and left borders
        CGFloat oldWidth = self.size.width;
        CGFloat newHeight = self.size.height * scaleHeight;
        CGFloat newWidth = oldWidth * scaleHeight;
        CGFloat spaceToCrop = (newWidth - resize.width) / 2;
        newRect = CGRectMake(-spaceToCrop, 0, newWidth, newHeight);
    } else {
        // Crop the top and bottom borders
        CGFloat oldHeight = self.size.height;
        CGFloat newWidth = self.size.width * scaleWidth;
        CGFloat newHeight = oldHeight * scaleWidth;
        CGFloat spaceToCrop = (newHeight - resize.height) / 2;
        newRect = CGRectMake(0, -spaceToCrop, newWidth, newHeight);
    }
    
    UIGraphicsBeginImageContextWithOptions(resize, YES, 0);
    
    [self drawInRect:newRect];
    
    UIImage *scaledImage = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return scaledImage;
}

- (CGSize)imageFinalSizeAfterContentModeApplied:(UIViewContentMode)contentMode containerSize:(CGSize)containerSize
{
    CGFloat scaleX = containerSize.width / self.size.width;
    CGFloat scaleY = containerSize.height / self.size.height;
    CGFloat scale = 1.0;
    
    CGSize finalSizeScale;
    
    switch (contentMode) {
        case UIViewContentModeScaleAspectFit:
            scale = fminf(scaleX, scaleY);
            finalSizeScale = CGSizeMake(scale, scale);
            break;
            
        case UIViewContentModeScaleAspectFill:
            scale = fmaxf(scaleX, scaleY);
            finalSizeScale = CGSizeMake(scale, scale);
            break;
            
        case UIViewContentModeScaleToFill:
            finalSizeScale = CGSizeMake(scaleX, scaleY);
            break;
            
        default:
            finalSizeScale = CGSizeMake(scale, scale);
            break;
    }
    
    return CGSizeMake(finalSizeScale.width * self.size.width, finalSizeScale.height * self.size.height);
}

- (UIImage *)rotate
{
    UIImage *image = [[UIImage alloc]initWithCGImage:self.CGImage
                                                scale:self.scale
                                          orientation:UIImageOrientationLeft];
    
    return image;
}

- (BOOL)isPortraitImage
{
    return (self.size.width < self.size.height);
}

@end
