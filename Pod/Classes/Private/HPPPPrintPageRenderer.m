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

#import "HPPPPrintPageRenderer.h"
#import "HPPPPaper.h"
#import "UIImage+Resize.h"

#define DEBUG_PRINT_LAYOUT NO

@implementation HPPPPrintPageRenderer

- (id)initWithImage:(UIImage *)image
{
    self = [super init];
    
    if (self) {
        self.image = image;
    }
    
    return self;
}

#pragma mark - UIPrintPageRenderer overrides

- (void)drawContentForPageAtIndex:(NSInteger)index inRect:(CGRect)contentRect
{
    // Check content rect and if is smaller than the size of the image, we need to resize the image (cropping it). Otherwise we center the image in the content rect
    UIImage *image = nil;
    if ((contentRect.size.height < self.image.size.height) || (contentRect.size.width < self.image.size.width)) {
        image = [self.image cropImageResize:contentRect.size];
    } else {
        image = self.image;
    }
    
    float width = image.size.width;
    float height = image.size.height;
    
    float x = (contentRect.size.width - width) / 2.0f;
    float y = (contentRect.size.height - height) / 2.0f;
    
    [image drawInRect:CGRectMake(x, y, width, height)];
}

@end
