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

#import "HPPP.h"
#import "HPPPPrintItemImage.h"

@interface HPPPPrintItemImage()

@property (strong, nonatomic) UIImage *printImage;

@end

@implementation HPPPPrintItemImage

#pragma mark - Initialization

- (id)initWithData:(NSData *)data
{
    HPPPPrintItemImage *item = nil;
    UIImage *image = [UIImage imageWithData:data];
    
    if (image) {
        self = [super init];
        if (self) {
            self.printImage = image;
        }
        item = self;
    } else {
        HPPPLogWarn(@"HPPPImagePrintItem was initialized with non-image data.");
    }
    
    return item;
}

- (id)initWithImage:(UIImage *)image
{
    self = [super init];
    if (self && image) {
        self.printImage = image;
    } else {
        HPPPLogWarn(@"HPPPImagePrintItem was initialized with nil for the image.");
    }
    return self;
}

#pragma mark - Asset attributes

- (id)printAsset
{
    return self.printImage;
}

- (HPPPPrintRenderer)renderer
{
    return CustomPrintRenderer;
}

- (NSInteger)numberOfPages
{
    return 1;
}

- (CGSize)sizeInUnits:(HPPPUnits)units
{
    CGSize size = CGSizeMake(0, 0);
    if (Pixels == units) {
        size = self.printImage.size;
    } else if (Inches == units) {
        
        size = CGSizeMake(self.printImage.size.width / kHPPPPointsPerInch, self.printImage.size.height / kHPPPPointsPerInch);
    }
    return size;
}

#pragma mark - Preview image

- (UIImage *)defaultPreviewImage
{
    return self.printImage;
}

- (UIImage *)previewImageForPaper:(HPPPPaper *)paper
{
    return [self defaultPreviewImage];
}

- (NSArray *)previewImagesForPaper:(HPPPPaper *)paper
{
    return @[ [self defaultPreviewImage] ];
}

#pragma mark - NSCoding

- (void)encodeAssetWithCoder:(NSCoder *)encoder
{
    NSData *imageData = UIImageJPEGRepresentation(self.printImage, [[UIScreen mainScreen] scale]);
    [encoder encodeObject:imageData forKey:kHPPPPrintAssetKey];
}

@end
