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

#import "UIImage+MPResize.h"


@implementation UIImage (MPResize)

- (UIImage *)MPCropImageResize:(CGSize)resize
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

- (BOOL)MPIsPortraitImage
{
    return (self.size.width < self.size.height);
}

- (UIImage *)MPRotate
{
    UIImage *image = [[UIImage alloc] initWithCGImage:self.CGImage
                                               scale:self.scale
                                         orientation:UIImageOrientationLeft];
    
    return image;
}

@end
