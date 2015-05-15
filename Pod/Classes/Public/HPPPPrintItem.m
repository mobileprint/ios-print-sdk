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

#import "HPPPPrintItem.h"
#import "HPPPPrintItemFactory.h"

@implementation HPPPPrintItem

CGFloat const kHPPPPointsPerInch = 72.0f;
NSString * const kHPPPPrintAssetKey = @"kHPPPPrintAssetKey";

#pragma mark - Abstract methods

- (CGSize)sizeInUnits:(HPPPUnits)units
{
    NSAssert(NO, @"HPPPPrintItem is intended to be an abstract class");
    return CGSizeMake(0, 0);
}

- (NSInteger)numberOfPages
{
    NSAssert(NO, @"HPPPPrintItem is intended to be an abstract class");
    return 0;
}

- (UIImage *)defaultPreviewImage
{
    NSAssert(NO, @"HPPPPrintItem is intended to be an abstract class");
    return nil;
}

- (UIImage *)previewImageForPaper:(HPPPPaper *)paper
{
    NSAssert(NO, @"HPPPPrintItem is intended to be an abstract class");
    return nil;
}

#pragma mark - NSCoding

- (void)encodeWithCoder:(NSCoder *)encoder
{
    [encoder encodeObject:self.printAsset forKey:kHPPPPrintAssetKey];
}

- (id)initWithCoder:(NSCoder *)decoder
{
    id printAsset = [decoder decodeObjectForKey:kHPPPPrintAssetKey];
    return [HPPPPrintItemFactory printItemWithAsset:printAsset];
}

@end
