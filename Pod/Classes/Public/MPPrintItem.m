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

#import "MPPrintItem.h"
#import "MPPrintItemFactory.h"
#import "MPLayoutFactory.h"

@implementation MPPrintItem

CGFloat const kMPPointsPerInch = 72.0f;
NSString * const kMPPrintAssetKey = @"kMPPrintAssetKey";
NSString * const kMPCustomAnalyticsKey = @"custom_data";

@synthesize customAnalytics = _customAnalytics;

#pragma mark - Abstract methods

- (CGSize)sizeInUnits:(MPUnits)units
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

- (UIImage *)previewImageForPaper:(MPPaper *)paper
{
    NSAssert(NO, @"%@ is intended to be an abstract class", NSStringFromClass(self.class));
    return nil;
}

- (NSArray *)previewImagesForPaper:(MPPaper *)paper
{
    NSAssert(NO, @"%@ is intended to be an abstract class", NSStringFromClass(self.class));
    return nil;
}

- (UIImage *)previewImageForPage:(NSUInteger)page paper:(MPPaper *)paper
{
    NSAssert(NO, @"%@ is intended to be an abstract class", NSStringFromClass(self.class));
    return nil;
}

- (id)printAssetForPageRange:(MPPageRange *)pageRange
{
    NSAssert(NO, @"%@ is intended to be an abstract class", NSStringFromClass(self.class));
    return nil;
}

- (NSArray *)activityItems
{
    return @[ self, self.printAsset ];
}

#pragma mark - NSCoding

- (void)encodeWithCoder:(NSCoder *)encoder
{
    [self encodeAssetWithCoder:encoder];
    [MPLayoutFactory encodeLayout:self.layout WithCoder:encoder];
}

- (id)initWithCoder:(NSCoder *)decoder
{
    id printAsset = [self decodeAssetWithCoder:decoder];
    MPPrintItem *printItem = [MPPrintItemFactory printItemWithAsset:printAsset];
    if (printItem) {
        printItem.layout = [MPLayoutFactory initLayoutWithCoder:decoder];
    }
    return printItem;
}


- (void)encodeAssetWithCoder:(NSCoder *)encoder
{
    [encoder encodeObject:self.printAsset forKey:kMPPrintAssetKey];
}

- (id)decodeAssetWithCoder:(NSCoder *)decoder
{
    return [decoder decodeObjectForKey:kMPPrintAssetKey];
}

#pragma mark - Layout

- (MPLayout *)layout
{
    if (!_layout) {
        _layout = [MPLayoutFactory layoutWithType:[MPLayoutFit layoutType]];
    }
    
    return _layout;
}

#pragma mark - Extra information

- (NSDictionary *)extra
{
    if (nil == _extra) {
        _extra = [NSDictionary dictionary];
    }
    return _extra;
}

- (NSDictionary *)customAnalytics
{
    _customAnalytics = [self.extra objectForKey:kMPCustomAnalyticsKey];
    
    if (nil == _customAnalytics) {
        [self setCustomAnalytics:[[NSMutableDictionary alloc] init]];
        _customAnalytics = [self.extra objectForKey:kMPCustomAnalyticsKey];
    }
    
    return _customAnalytics;
}

- (void)setCustomAnalytics:(NSDictionary *)customAnalytics
{
    _customAnalytics = customAnalytics;

    NSMutableDictionary *extras = [self.extra mutableCopy];
    [extras setObject:customAnalytics forKey:kMPCustomAnalyticsKey];
    self.extra = extras;
}

@end
