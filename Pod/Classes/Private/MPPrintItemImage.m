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

#import "MP.h"
#import "MPPrintItemImage.h"

@interface MPPrintItemImage()

@property (strong, nonatomic) UIImage *printImage;

@end

@implementation MPPrintItemImage

#pragma mark - Initialization

- (id)initWithData:(NSData *)data
{
    MPPrintItemImage *item = nil;
    UIImage *image = [UIImage imageWithData:data];
    
    if (image) {
        self = [super init];
        if (self) {
            self.printImage = image;
        }
        item = self;
    } else {
        MPLogWarn(@"MPImagePrintItem was initialized with non-image data.");
    }
    
    return item;
}

- (id)initWithImage:(UIImage *)image
{
    self = [super init];
    if (self && image) {
        self.printImage = image;
    } else {
        MPLogWarn(@"MPImagePrintItem was initialized with nil for the image.");
    }
    return self;
}

#pragma mark - Asset attributes

- (id)printAsset
{
    return self.printImage;
}

- (NSString *)assetType
{
    return @"Image";
}

- (MPPrintRenderer)renderer
{
    return CustomPrintRenderer;
}

- (NSInteger)numberOfPages
{
    return 1;
}

- (CGSize)sizeInUnits:(MPUnits)units
{
    CGSize size = CGSizeApplyAffineTransform(self.printImage.size, CGAffineTransformMakeScale(self.printImage.scale, self.printImage.scale));
    if (Inches == units) {
        size = CGSizeApplyAffineTransform(size, CGAffineTransformMakeScale(1.0 / kMPPointsPerInch, 1.0 / kMPPointsPerInch));
    }
    return size;
}

- (id)printAssetForPageRange:(MPPageRange *)pageRange
{
    return [self printAsset];
}

#pragma mark - Preview image

- (UIImage *)defaultPreviewImage
{
    return self.printImage;
}

- (UIImage *)previewImageForPaper:(MPPaper *)paper
{
    return [self defaultPreviewImage];
}

- (NSArray *)previewImagesForPaper:(MPPaper *)paper
{
    return @[ [self defaultPreviewImage] ];
}

#pragma mark - NSCoding

- (void)encodeAssetWithCoder:(NSCoder *)encoder
{
    NSData *imageData = UIImageJPEGRepresentation(self.printImage, [[UIScreen mainScreen] scale]);
    [encoder encodeObject:imageData forKey:kMPPrintAssetKey];
}

@end
