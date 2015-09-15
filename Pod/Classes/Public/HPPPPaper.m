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
#import "HPPPPaper.h"
#import "NSBundle+HPPPLocalizable.h"

@implementation HPPPPaper


- (id)initWithPaperSize:(NSUInteger)paperSize paperType:(NSUInteger)paperType
{
    if (nil == _supportedPaper) {
        [HPPPPaper initializePaper];
    }
    
    self = [super init];
    
    if (self) {
        
        HPPPPaper *paper = nil;
        
        for (NSDictionary *paperInfo in _supportedPaper) {
            NSUInteger supportedSize = [[paperInfo objectForKey:kHPPPPaperSizeIdKey] unsignedIntegerValue];
            NSUInteger supportedType = [[paperInfo objectForKey:kHPPPPaperTypeIdKey] unsignedIntegerValue];
            if (paperSize == supportedSize && paperType == supportedType) {
                NSDictionary *sizeInfo = [HPPPPaper sizeForId:paperSize];
                NSDictionary *typeInfo = [HPPPPaper typeForId:paperType];
                paper = self;
                paper.paperSize = paperSize;
                paper.paperType = paperType;
                paper.sizeTitle = [sizeInfo objectForKey:kHPPPPaperSizeTitleKey];
                paper.typeTitle = [typeInfo objectForKey:kHPPPPaperTypeTitleKey];
                paper.width = [[sizeInfo objectForKey:kHPPPPaperWidthKey] floatValue];
                paper.height = [[sizeInfo objectForKey:kHPPPPaperHeightKey] floatValue];
                break;
            }
        }
        
        if (!paper) {
            NSAssert(NO, @"Unknown paper size (%lul) and type (%lul)", (unsigned long)paperSize, (unsigned long)paperType);
        }
        
        self = paper;
    }
    
    return self;
}

- (id)initWithPaperSizeTitle:(NSString *)paperSizeTitle paperTypeTitle:(NSString *)paperTypeTitle;
{
    return [self initWithPaperSize:[HPPPPaper sizeFromTitle:paperSizeTitle] paperType:[HPPPPaper typeFromTitle:paperTypeTitle]];
}

+ (NSString *)titleFromSize:(NSUInteger)sizeId
{
    NSDictionary *sizeInfo = [self sizeForId:sizeId];
    if (nil == sizeInfo) {
        NSAssert(NO, @"Unknown paper size ID: %lul", (unsigned long)sizeId);
    }
    return [sizeInfo objectForKey:kHPPPPaperSizeTitleKey];
}

+ (NSUInteger)sizeFromTitle:(NSString *)title
{
    NSDictionary *sizeInfo = [self sizeForTitle:title];
    if (nil == sizeInfo) {
        NSAssert(NO, @"Unknown paper size title: %@", title);
    }
    return [[sizeInfo objectForKey:kHPPPPaperSizeIdKey] unsignedIntegerValue];
}

+ (NSString *)titleFromType:(NSUInteger)typeId
{
    NSDictionary *typeInfo = [self typeForId:typeId];
    if (nil == typeInfo) {
        NSAssert(NO, @"Unknown paper type ID: %lul", (unsigned long)typeId);
    }
    return [typeInfo objectForKey:kHPPPPaperTypeTitleKey];
}

+ (NSUInteger)typeFromTitle:(NSString *)title
{
    NSDictionary *typeInfo = [self typeForTitle:title];
    if (nil == typeInfo) {
        NSAssert(NO, @"Unknown paper type title: %@", title);
    }
    return [[typeInfo objectForKey:kHPPPPaperTypeIdKey] unsignedIntegerValue];
}

- (NSString *)paperWidthTitle
{
    return [NSNumber numberWithFloat:self.width].stringValue;
}

- (NSString *)paperHeightTitle
{
    return [NSNumber numberWithFloat:self.height].stringValue;
}

- (CGSize)printerPaperSize
{
    NSDictionary *sizeInfo = [HPPPPaper sizeForId:self.paperSize];
    NSNumber *printerWidth = [sizeInfo objectForKey:kHPPPPaperPrinterWidthKey];
    NSNumber *printerHeight = [sizeInfo objectForKey:kHPPPPaperPrinterHeightKey];
    CGFloat width = printerWidth ? [printerWidth floatValue] : self.width;
    CGFloat height = printerHeight ? [printerHeight floatValue] : self.height;
    return CGSizeMake(width, height);
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"%@, %@\nWidth %f Height %f\nPaper Size %lul\nPaper Type %lul", self.sizeTitle, self.typeTitle, self.width, self.height, (unsigned long)self.paperSize, (unsigned long)self.paperType];
}

#pragma mark - Supported paper

NSString * const kHPPPPaperSizeIdKey = @"kHPPPPaperSizeIdKey";
NSString * const kHPPPPaperSizeTitleKey = @"kHPPPPaperSizeTitleKey";
NSString * const kHPPPPaperTypeIdKey = @"kHPPPPaperTypeIdKey";
NSString * const kHPPPPaperTypeTitleKey = @"kHPPPPaperTypeTitleKey";
NSString * const kHPPPPaperWidthKey = @"kHPPPPaperWidthKey";
NSString * const kHPPPPaperHeightKey = @"kHPPPPaperHeightKey";
NSString * const kHPPPPaperPrinterWidthKey = @"kHPPPPaperPrinterWidthKey";
NSString * const kHPPPPaperPrinterHeightKey = @"kHPPPPaperPrinterHeightKey";

static NSArray *_supportedSize = nil;
static NSArray *_supportedType = nil;
static NSArray *_supportedPaper = nil;

+ (void)initializePaper
{
    _supportedSize = @[];
    _supportedType = @[];
    _supportedPaper = @[];
    
    // Paper Size
    [self registerSize:@{
                         kHPPPPaperSizeIdKey:[NSNumber numberWithUnsignedLong:HPPPPaperSize4x5],
                         kHPPPPaperSizeTitleKey:HPPPLocalizedString(@"4 x 5", @"Option for paper size"),
                         kHPPPPaperWidthKey:[NSNumber numberWithFloat:4.0],
                         kHPPPPaperHeightKey:[NSNumber numberWithFloat:5.0],
                         kHPPPPaperPrinterHeightKey:[NSNumber numberWithFloat:6.0]
                         }];
    [self registerSize:@{
                         kHPPPPaperSizeIdKey:[NSNumber numberWithUnsignedLong:HPPPPaperSize4x6],
                         kHPPPPaperSizeTitleKey:HPPPLocalizedString(@"4 x 6", @"Option for paper size"),
                         kHPPPPaperWidthKey:[NSNumber numberWithFloat:4.0],
                         kHPPPPaperHeightKey:[NSNumber numberWithFloat:6.0]
                         }];
    [self registerSize:@{
                         kHPPPPaperSizeIdKey:[NSNumber numberWithUnsignedLong:HPPPPaperSize5x7],
                         kHPPPPaperSizeTitleKey:HPPPLocalizedString(@"5 x 7", @"Option for paper size"),
                         kHPPPPaperWidthKey:[NSNumber numberWithFloat:5.0],
                         kHPPPPaperHeightKey:[NSNumber numberWithFloat:7.0]
                         }];
    [self registerSize:@{
                         kHPPPPaperSizeIdKey:[NSNumber numberWithUnsignedLong:HPPPPaperSizeLetter],
                         kHPPPPaperSizeTitleKey:HPPPLocalizedString(@"8.5 x 11", @"Option for paper size"),
                         kHPPPPaperWidthKey:[NSNumber numberWithFloat:8.5],
                         kHPPPPaperHeightKey:[NSNumber numberWithFloat:11.0]
                         }];
    
    // Paper Type
    [self registerType:@{
                         kHPPPPaperTypeIdKey:[NSNumber numberWithUnsignedLong:HPPPPaperTypePlain],
                         kHPPPPaperTypeTitleKey:HPPPLocalizedString(@"Plain Paper", @"Option for paper type")
                         }];
    [self registerType:@{
                         kHPPPPaperTypeIdKey:[NSNumber numberWithUnsignedLong:HPPPPaperTypePhoto],
                         kHPPPPaperTypeTitleKey:HPPPLocalizedString(@"Photo Paper", @"Option for paper type")
                         }];

    // Associations
    [self associatePaperSize:HPPPPaperSize4x5 withType:HPPPPaperTypePhoto];
    [self associatePaperSize:HPPPPaperSize4x6 withType:HPPPPaperTypePhoto];
    [self associatePaperSize:HPPPPaperSize5x7 withType:HPPPPaperTypePhoto];
    [self associatePaperSize:HPPPPaperSizeLetter withType:HPPPPaperTypePhoto];
    [self associatePaperSize:HPPPPaperSizeLetter withType:HPPPPaperTypePlain];
}

+ (NSArray *)supportedSize
{
    if (!_supportedSize) {
        [self initializePaper];
    }
    return _supportedSize;
}

+ (NSArray *)supportedType
{
    if (!_supportedType) {
        [self initializePaper];
    }
    return _supportedType;
}

+ (NSArray *)supportedPaper
{
    if (!_supportedPaper) {
        [self initializePaper];
    }
    return _supportedPaper;
}

+ (NSArray *)availablePapers
{
    NSMutableArray *papers = [NSMutableArray array];
    for (NSDictionary *association in self.supportedPaper) {
        NSUInteger sizeId = [[association objectForKey:kHPPPPaperSizeIdKey] unsignedIntegerValue];
        NSUInteger typeId = [[association objectForKey:kHPPPPaperTypeIdKey] unsignedIntegerValue];
        HPPPPaper *paper = [[HPPPPaper alloc] initWithPaperSize:sizeId paperType:typeId];
        [papers addObject:paper];
    }
    return papers;
}

+ (BOOL)registerSize:(NSDictionary *)info
{
    NSNumber *sizeId = [info objectForKey:kHPPPPaperSizeIdKey] ;
    NSString *title = [info objectForKey:kHPPPPaperSizeTitleKey];
    NSNumber *width = [info objectForKey:kHPPPPaperWidthKey];
    NSNumber *height = [info objectForKey:kHPPPPaperHeightKey];
    
    if (nil == sizeId || nil == title || nil == width || nil == height) {
        HPPPLogError(@"Attempted to register size with missing info:  %@", info);
        return NO;
    }
    
    if (nil != [self sizeForId:[sizeId unsignedIntegerValue]]) {
        HPPPLogError(@"Attempted to register size ID that already exists:  %lul", [sizeId unsignedIntegerValue]);
        return NO;
    }
    
    if (nil != [self sizeForTitle:title]) {
        HPPPLogError(@"Attempted to register size title that already exists:  '%@'", title);
        return NO;
    }
    
    NSMutableArray *supportedSize = [_supportedSize mutableCopy];
    [supportedSize addObject:info];
    _supportedSize = supportedSize;
    
    return YES;
}

+ (BOOL)registerType:(NSDictionary *)info
{
    NSNumber *typeId = [info objectForKey:kHPPPPaperTypeIdKey] ;
    NSString *title = [info objectForKey:kHPPPPaperTypeTitleKey];
    
    if (nil == typeId || nil == title) {
        HPPPLogError(@"Attempted to register type with missing info:  %@", info);
        return NO;
    }
    
    if (nil != [self typeForId:[typeId unsignedIntegerValue]]) {
        HPPPLogError(@"Attempted to register type ID that already exists:  %lul", [typeId unsignedIntegerValue]);
        return NO;
    }
    
    if (nil != [self typeForTitle:title]) {
        HPPPLogError(@"Attempted to register type title that already exists:  '%@'", title);
        return NO;
    }
    
    NSMutableArray *supportedType = [_supportedType mutableCopy];
    [supportedType addObject:info];
    _supportedType = supportedType;
    
    return YES;
}

+ (BOOL)associatePaperSize:(NSUInteger)sizeId withType:(NSUInteger)typeId
{
    if (nil != [self associationForSizeId:sizeId andTypeId:typeId]) {
        HPPPLogError(@"Attempted association already exists:  size (%lul) - type (%lul)", sizeId, typeId);
        return NO;
    }
    
    if (nil == [self sizeForId:sizeId]) {
        HPPPLogError(@"Attempted to associate with nonexistant size:  %lul", sizeId);
        return NO;
    }
    
    if (nil == [self typeForId:typeId]) {
        HPPPLogError(@"Attempted to associate with nonexistant type:  %lul", typeId);
        return NO;
    }
    
    NSMutableArray *supportedPaper = [_supportedPaper mutableCopy];
    [supportedPaper addObject:@{
                                kHPPPPaperSizeIdKey:[NSNumber numberWithUnsignedLong:sizeId],
                                kHPPPPaperTypeIdKey:[NSNumber numberWithUnsignedLong:typeId]
                                }];
    _supportedPaper = supportedPaper;
    
    return YES;
}


+ (NSDictionary *)sizeForId:(NSUInteger)sizeId
{
    NSDictionary *sizeInfo = nil;
    for (NSDictionary *info in _supportedSize) {
        NSUInteger existingId = [[info objectForKey:kHPPPPaperSizeIdKey] unsignedIntegerValue];
        if (existingId == sizeId) {
            sizeInfo = info;
            break;
        }
    }
    return sizeInfo;
}

+ (NSDictionary *)sizeForTitle:(NSString *)title
{
    NSDictionary *sizeInfo = nil;
    for (NSDictionary *info in _supportedSize) {
        NSString *existingTitle = [info objectForKey:kHPPPPaperSizeTitleKey];
        if ([existingTitle isEqualToString:title]) {
            sizeInfo = info;
            break;
        }
    }
    return sizeInfo;
}

+ (NSDictionary *)typeForId:(NSUInteger)typeId
{
    NSDictionary *typeInfo = nil;
    for (NSDictionary *info in _supportedType) {
        NSUInteger existingId = [[info objectForKey:kHPPPPaperTypeIdKey] unsignedIntegerValue];
        if (existingId == typeId) {
            typeInfo = info;
            break;
        }
    }
    return typeInfo;
}

+ (NSDictionary *)typeForTitle:(NSString *)title
{
    NSDictionary *typeInfo = nil;
    for (NSDictionary *info in _supportedType) {
        NSString *existingTitle = [info objectForKey:kHPPPPaperTypeTitleKey];
        if ([existingTitle isEqualToString:title]) {
            typeInfo = info;
            break;
        }
    }
    return typeInfo;
}

+ (NSDictionary *)associationForSizeId:(NSUInteger)sizeId andTypeId:(NSUInteger)typeId
{
    NSDictionary *associationInfo = nil;
    for (NSDictionary *info in _supportedPaper) {
        NSUInteger existingSizeId = [[info objectForKey:kHPPPPaperSizeIdKey] unsignedIntegerValue];
        NSUInteger existingTypeId = [[info objectForKey:kHPPPPaperTypeIdKey] unsignedIntegerValue];
        if (existingSizeId == sizeId && existingTypeId == typeId) {
            associationInfo = info;
        }
    }
    return associationInfo;
}

@end


