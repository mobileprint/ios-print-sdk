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
#import "HPPPLayoutFactory.h"

@implementation HPPPPrintItem

CGFloat const kHPPPPointsPerInch = 72.0f;
NSString * const kHPPPPrintAssetKey = @"kHPPPPrintAssetKey";

#pragma mark - Abstract methods

- (CGSize)sizeInUnits:(HPPPUnits)units
{
    NSAssert(NO, @"%@ is intended to be an abstract class", NSStringFromClass(self.class));
    return CGSizeMake(0, 0);
}

- (NSInteger)numberOfPages
{
    NSAssert(NO, @"%@ is intended to be an abstract class", NSStringFromClass(self.class));
    return 0;
}

- (UIImage *)defaultPreviewImage
{
    NSAssert(NO, @"%@ is intended to be an abstract class", NSStringFromClass(self.class));
    return nil;
}

- (UIImage *)previewImageForPaper:(HPPPPaper *)paper
{
    NSAssert(NO, @"%@ is intended to be an abstract class", NSStringFromClass(self.class));
    return nil;
}

#pragma mark - NSCoding

- (void)encodeWithCoder:(NSCoder *)encoder
{
    [self encodeAssetWithCoder:encoder];
    [HPPPLayoutFactory encodeLayout:self.layout WithCoder:encoder];
}

- (id)initWithCoder:(NSCoder *)decoder
{
    id printAsset = [self initAssetWithCoder:decoder];
    HPPPPrintItem *printItem = [HPPPPrintItemFactory printItemWithAsset:printAsset];
    printItem.layout = [HPPPLayoutFactory initLayoutWithCoder:decoder];
    return printItem;
}


- (void)encodeAssetWithCoder:(NSCoder *)encoder
{
    [encoder encodeObject:self.printAsset forKey:kHPPPPrintAssetKey];
}

- (id)initAssetWithCoder:(NSCoder *)decoder
{
    return [decoder decodeObjectForKey:kHPPPPrintAssetKey];
}

#pragma mark - Layout

- (HPPPLayout *)layout
{
    if (!_layout) {
        _layout = [HPPPLayoutFactory layoutWithType:kHPPPLayoutTypeDefault];
    }
    
    return _layout;
}

@end
