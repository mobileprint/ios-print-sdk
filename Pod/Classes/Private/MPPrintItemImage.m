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

@property (strong, nonatomic) NSArray *printImages;

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
            self.printImages = @[ image ];
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
        self.printImages = @[ image ];
    } else {
        MPLogWarn(@"MPImagePrintItem was initialized with nil for the image.");
    }
    return self;
}

- (id)initWithImages:(NSArray *)images
{
    self = [super init];
    if (self && images && images.count > 0) {
        self.printImages = images;
    } else {
        MPLogWarn(@"MPImagePrintItem was initialized with no images.");
    }
    return self;
}

#pragma mark - Asset attributes

- (id)printAsset
{
    return self.printImages;
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
    return self.printImages.count;
}

- (CGSize)sizeInUnits:(MPUnits)units
{
    UIImage *firstImage = [self.printImages firstObject];
    CGSize size = CGSizeApplyAffineTransform(firstImage.size, CGAffineTransformMakeScale(firstImage.scale, firstImage.scale));
    if (Inches == units) {
        size = CGSizeApplyAffineTransform(size, CGAffineTransformMakeScale(1.0 / kMPPointsPerInch, 1.0 / kMPPointsPerInch));
    }
    return size;
}

- (id)printAssetForPageRange:(MPPageRange *)pageRange
{
    NSMutableArray *printImages = [NSMutableArray arrayWithArray:self.printImages];
    if( nil != pageRange && ![pageRange.range isEqualToString:pageRange.allPagesIndicator] ) {
        printImages = [NSMutableArray array];
        for (NSNumber *page in [pageRange getPages]) {
            [printImages addObject:self.printImages[[page intValue] - 1]];
        }
    }
    
    return printImages;
}

- (NSArray *)activityItems
{
    NSMutableArray *items = [NSMutableArray arrayWithArray:[super activityItems]];
    if (1 == self.printImages.count) {
        UIImage *originalImage = [self.printImages firstObject];
        UIImage *scaleOneImage = [UIImage imageWithCGImage:[originalImage CGImage] scale:1.0 orientation:[originalImage imageOrientation]];
        [items addObject:scaleOneImage];
    }
    return items;
}

#pragma mark - Preview image

- (UIImage *)defaultPreviewImage
{
    return [self.printImages firstObject];
}

- (UIImage *)previewImageForPaper:(MPPaper *)paper
{
    return [self defaultPreviewImage];
}

- (NSArray *)previewImagesForPaper:(MPPaper *)paper
{
    return self.printImages;
}

- (UIImage *)previewImageForPage:(NSUInteger)page paper:(MPPaper *)paper
{
    return self.printImages[page - 1];
}

#pragma mark - NSCoding

- (void)encodeAssetWithCoder:(NSCoder *)encoder
{
    NSMutableArray *images = [NSMutableArray array];
    for (UIImage *image in self.printImages) {
        NSData *data = UIImageJPEGRepresentation(image, [[UIScreen mainScreen] scale]);
        [images addObject:data];
    }
    [encoder encodeObject:images forKey:kMPPrintAssetKey];
}

- (id)decodeAssetWithCoder:(NSCoder *)decoder
{
    id printAsset = [decoder decodeObjectForKey:kMPPrintAssetKey];
    
    // Need this for backward compatibility.
    // Old way was to store jobs as NSData representing single image.
    if ([printAsset isKindOfClass:[NSData class]]) {
        return printAsset;
    }
    
    // New way is to story array of NSData for one or more images.
    NSArray *imagesAsData = printAsset;
    NSMutableArray *imagesAsImage = [NSMutableArray array];
    for (NSData *data in imagesAsData) {
        UIImage *image = [UIImage imageWithData:data];
        [imagesAsImage addObject:image];
    }
    NSArray *images = imagesAsImage;
    
    return images;
}

@end
