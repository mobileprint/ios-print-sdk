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
#import "HPPP.h"
#import "HPPPPaper.h"
#import "UIImage+HPPPResize.h"

#define DEBUG_PRINT_LAYOUT NO
#define MAXIMUM_ENLARGEMENT 1.25f

@implementation HPPPPrintPageRenderer

- (id)initWithImages:(NSArray *)images
{
    self = [super init];
    
    if (self) {
        self.images = images;
    }
    
    return self;
}

- (NSInteger)numberOfPages
{
    return self.numberOfCopies * self.images.count;
}

#pragma mark - UIPrintPageRenderer overrides

- (void)drawContentForPageAtIndex:(NSInteger)index inRect:(CGRect)contentRect
{
    UIImage *image = self.images[(int) (index / self.numberOfCopies)];
    
    if ([HPPP sharedInstance].zoomAndCrop) {
        // Check content rect and if is smaller than the size of the image, we need to resize the image (cropping it). Otherwise we center the image in the content rect
        UIImage *resizeImage = nil;
        if ((contentRect.size.height < image.size.height) || (contentRect.size.width < image.size.width)) {
            resizeImage = [image HPPPCropImageResize:contentRect.size];
        } else {
            resizeImage = image;
        }
        
        float width = resizeImage.size.width;
        float height = resizeImage.size.height;
        
        float x = contentRect.origin.x + (contentRect.size.width - width) / 2.0f;
        float y = contentRect.origin.y + (contentRect.size.height - height) / 2.0f;
        
        [resizeImage drawInRect:CGRectMake(x, y, width, height)];
    } else {
        float width = image.size.width;
        float height = image.size.height;
        float scaleX = contentRect.size.width / width;
        
        if ( scaleX < 1.0f || (scaleX > 1.0f && scaleX <= MAXIMUM_ENLARGEMENT)) {
            width = width * scaleX;
            height = height * scaleX;
        }
        
        float x = (contentRect.size.width - width) / 2.0f;
        float y = 0.0f;
        if (scaleX > MAXIMUM_ENLARGEMENT) { //does image need centering?
            y = (contentRect.size.height - height) / 2.0f;
        }
        
        [image drawInRect:CGRectMake (x + contentRect.origin.x, y + contentRect.origin.y, width, height)];
    }
}

@end
