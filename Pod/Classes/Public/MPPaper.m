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
#import "MPPaper.h"
#import "MPPrintItem.h"
#import "NSBundle+MPLocalizable.h"

@implementation MPPaper


- (id)initWithPaperSize:(NSUInteger)paperSize paperType:(NSUInteger)paperType
{
    if (nil == _supportedPaper) {
        [MPPaper initializePaper];
    }
    
    self = [super init];
    
    if (self) {
        
        MPPaper *paper = nil;
        
        for (NSDictionary *paperInfo in _supportedPaper) {
            NSUInteger supportedSize = [[paperInfo objectForKey:kMPPaperSizeIdKey] unsignedIntegerValue];
            NSUInteger supportedType = [[paperInfo objectForKey:kMPPaperTypeIdKey] unsignedIntegerValue];
            if (paperSize == supportedSize && paperType == supportedType) {
                NSDictionary *sizeInfo = [MPPaper sizeForId:paperSize];
                NSDictionary *typeInfo = [MPPaper typeForId:paperType];
                paper = self;
                _paperSize = paperSize;
                _paperType = paperType;
                _sizeTitle = [sizeInfo objectForKey:kMPPaperSizeTitleKey];
                _typeTitle = [typeInfo objectForKey:kMPPaperTypeTitleKey];
                _width = [[sizeInfo objectForKey:kMPPaperSizeWidthKey] floatValue];
                _height = [[sizeInfo objectForKey:kMPPaperSizeHeightKey] floatValue];
                _photo = NO;
                NSNumber *photo = [typeInfo objectForKey:kMPPaperTypePhotoKey];
                if (photo) {
                    _photo = [photo boolValue];
                }
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
    return [self initWithPaperSize:[MPPaper sizeFromTitle:paperSizeTitle] paperType:[MPPaper typeFromTitle:paperTypeTitle]];
}

+ (NSString *)titleFromSize:(NSUInteger)sizeId
{
    NSDictionary *sizeInfo = [self sizeForId:sizeId];
    if (nil == sizeInfo) {
        NSAssert(NO, @"Unknown paper size ID: %lul", (unsigned long)sizeId);
    }
    return [sizeInfo objectForKey:kMPPaperSizeTitleKey];
}

+ (NSUInteger)sizeFromTitle:(NSString *)title
{
    NSDictionary *sizeInfo = [self sizeForTitle:title];
    if (nil == sizeInfo) {
        NSAssert(NO, @"Unknown paper size title: %@", title);
    }
    return [[sizeInfo objectForKey:kMPPaperSizeIdKey] unsignedIntegerValue];
}

+ (NSString *)constantPaperSizeFromTitle:(NSString *)title
{
    NSDictionary *sizeInfo = [self sizeForTitle:title];
    if (nil == sizeInfo) {
        NSAssert(NO, @"Unknown paper size title: %@", title);
    }
    
    NSString *metricsSizeTitle = [sizeInfo objectForKey:kMPPaperSizeConstantNameKey];
    if (nil == metricsSizeTitle) {
        metricsSizeTitle = title;
    }
    
    return metricsSizeTitle;
}

+ (NSString *)titleFromType:(NSUInteger)typeId
{
    NSDictionary *typeInfo = [self typeForId:typeId];
    if (nil == typeInfo) {
        NSAssert(NO, @"Unknown paper type ID: %lul", (unsigned long)typeId);
    }
    return [typeInfo objectForKey:kMPPaperTypeTitleKey];
}

+ (NSUInteger)typeFromTitle:(NSString *)title
{
    NSDictionary *typeInfo = [self typeForTitle:title];
    if (nil == typeInfo) {
        NSAssert(NO, @"Unknown paper type title: %@", title);
    }
    return [[typeInfo objectForKey:kMPPaperTypeIdKey] unsignedIntegerValue];
}

+ (NSString *)constantPaperTypeFromTitle:(NSString *)title
{
    NSDictionary *typeInfo = [self typeForTitle:title];
    if (nil == typeInfo) {
        NSAssert(NO, @"Unknown paper type title: %@", title);
    }
    
    NSString *metricsTypeTitle = [typeInfo objectForKey:kMPPaperTypeConstantNameKey];
    if (nil == metricsTypeTitle) {
        metricsTypeTitle = title;
    }
    
    return metricsTypeTitle;
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
    NSDictionary *sizeInfo = [MPPaper sizeForId:self.paperSize];
    NSNumber *printerWidth = [sizeInfo objectForKey:kMPPaperSizePrinterWidthKey];
    NSNumber *printerHeight = [sizeInfo objectForKey:kMPPaperSizePrinterHeightKey];
    CGFloat width = printerWidth ? [printerWidth floatValue] : self.width;
    CGFloat height = printerHeight ? [printerHeight floatValue] : self.height;
    return CGSizeMake(width * kMPPointsPerInch, height * kMPPointsPerInch);
}

#pragma mark - Supported paper initialization

NSString * const kMPPaperSizeIdKey = @"kMPPaperSizeIdKey";
NSString * const kMPPaperSizeTitleKey = @"kMPPaperSizeTitleKey";
NSString * const kMPPaperTypeIdKey = @"kMPPaperTypeIdKey";
NSString * const kMPPaperTypeTitleKey = @"kMPPaperTypeTitleKey";
NSString * const kMPPaperTypeConstantNameKey = @"kMPPaperTypeConstantNameKey";
NSString * const kMPPaperSizeConstantNameKey = @"kMPPaperSizeConstantNameKey";
NSString * const kMPPaperTypePhotoKey = @"kMPPaperTypePhotoKey";
NSString * const kMPPaperSizeWidthKey = @"kMPPaperWidthKey";
NSString * const kMPPaperSizeHeightKey = @"kMPPaperHeightKey";
NSString * const kMPPaperSizePrinterWidthKey = @"kMPPaperPrinterWidthKey";
NSString * const kMPPaperSizePrinterHeightKey = @"kMPPaperPrinterHeightKey";

static NSArray *_supportedSize = nil;
static NSArray *_supportedType = nil;
static NSArray *_supportedPaper = nil;

+ (void)initializePaper
{
    if (_supportedSize && _supportedType && _supportedPaper) {
        return;
    }
    
    _supportedSize = @[];
    _supportedType = @[];
    _supportedPaper = @[];
    
    // US Paper Sizes
    
    [self registerSize:@{
                         kMPPaperSizeIdKey:[NSNumber numberWithUnsignedLong:MPPaperSize4x5],
                         kMPPaperSizeTitleKey:MPLocalizedString(@"4 x 5", @"Option for paper size"),
                         kMPPaperSizeConstantNameKey:@"4 x 5",
                         kMPPaperSizeWidthKey:[NSNumber numberWithFloat:4.0],
                         kMPPaperSizeHeightKey:[NSNumber numberWithFloat:5.0],
                         kMPPaperSizePrinterHeightKey:[NSNumber numberWithFloat:6.0]
                         }];
    [self registerSize:@{
                         kMPPaperSizeIdKey:[NSNumber numberWithUnsignedLong:MPPaperSize4x6],
                         kMPPaperSizeTitleKey:MPLocalizedString(@"4 x 6", @"Option for paper size"),
                         kMPPaperSizeConstantNameKey:@"4 x 6",
                         kMPPaperSizeWidthKey:[NSNumber numberWithFloat:4.0],
                         kMPPaperSizeHeightKey:[NSNumber numberWithFloat:6.0]
                         }];
    [self registerSize:@{
                         kMPPaperSizeIdKey:[NSNumber numberWithUnsignedLong:MPPaperSize5x7],
                         kMPPaperSizeTitleKey:MPLocalizedString(@"5 x 7", @"Option for paper size"),
                         kMPPaperSizeConstantNameKey:@"5 x 7",
                         kMPPaperSizeWidthKey:[NSNumber numberWithFloat:5.0],
                         kMPPaperSizeHeightKey:[NSNumber numberWithFloat:7.0]
                         }];
    [self registerSize:@{
                         kMPPaperSizeIdKey:[NSNumber numberWithUnsignedLong:MPPaperSizeLetter],
                         kMPPaperSizeTitleKey:MPLocalizedString(@"8.5 x 11", @"Option for paper size"),
                         kMPPaperSizeConstantNameKey:@"8.5 x 11",
                         kMPPaperSizeWidthKey:[NSNumber numberWithFloat:8.5],
                         kMPPaperSizeHeightKey:[NSNumber numberWithFloat:11.0]
                         }];
    
    [self registerSize:@{
                         kMPPaperSizeIdKey:[NSNumber numberWithUnsignedLong:MPPaperSize2x3],
                         kMPPaperSizeTitleKey:MPLocalizedString(@"2 x 3", @"Option for paper size"),
                         kMPPaperSizeConstantNameKey:@"2 x 3",
                         kMPPaperSizeWidthKey:[NSNumber numberWithFloat:2],
                         kMPPaperSizeHeightKey:[NSNumber numberWithFloat:3]
                         }];

    // International paper sizes
    
    float const kMillimetersPerInch = 25.4;
    
    [self registerSize:@{
                         kMPPaperSizeIdKey:[NSNumber numberWithUnsignedLong:MPPaperSizeA4],
                         kMPPaperSizeTitleKey:MPLocalizedString(@"A4", @"Option for paper size"),
                         kMPPaperSizeConstantNameKey:@"A4",
                         kMPPaperSizeWidthKey:[NSNumber numberWithFloat:210.0 / kMillimetersPerInch],
                         kMPPaperSizeHeightKey:[NSNumber numberWithFloat:297.0 / kMillimetersPerInch]
                         }];
    
    [self registerSize:@{
                         kMPPaperSizeIdKey:[NSNumber numberWithUnsignedLong:MPPaperSizeA5],
                         kMPPaperSizeTitleKey:MPLocalizedString(@"A5", @"Option for paper size"),
                         kMPPaperSizeConstantNameKey:@"A5",
                         kMPPaperSizeWidthKey:[NSNumber numberWithFloat:148.0 / kMillimetersPerInch],
                         kMPPaperSizeHeightKey:[NSNumber numberWithFloat:210.0 / kMillimetersPerInch]
                         }];
    
    [self registerSize:@{
                         kMPPaperSizeIdKey:[NSNumber numberWithUnsignedLong:MPPaperSizeA6],
                         kMPPaperSizeTitleKey:MPLocalizedString(@"A6", @"Option for paper size"),
                         kMPPaperSizeConstantNameKey:@"A6",
                         kMPPaperSizeWidthKey:[NSNumber numberWithFloat:105.0 / kMillimetersPerInch],
                         kMPPaperSizeHeightKey:[NSNumber numberWithFloat:148.0 / kMillimetersPerInch]
                         }];
    
    [self registerSize:@{
                         kMPPaperSizeIdKey:[NSNumber numberWithUnsignedLong:MPPaperSize10x13],
                         kMPPaperSizeTitleKey:MPLocalizedString(@"10x13cm", @"Option for paper size"),
                         kMPPaperSizeConstantNameKey:@"10x13cm",
                         kMPPaperSizeWidthKey:[NSNumber numberWithFloat:3.94],
                         kMPPaperSizeHeightKey:[NSNumber numberWithFloat:5.12],
                         kMPPaperSizePrinterHeightKey:[NSNumber numberWithFloat:5.91]
                         }];
    
    [self registerSize:@{
                         kMPPaperSizeIdKey:[NSNumber numberWithUnsignedLong:MPPaperSize10x15],
                         kMPPaperSizeTitleKey:MPLocalizedString(@"10x15cm", @"Option for paper size"),
                         kMPPaperSizeConstantNameKey:@"10x15cm",
                         kMPPaperSizeWidthKey:[NSNumber numberWithFloat:3.94],
                         kMPPaperSizeHeightKey:[NSNumber numberWithFloat:5.91]
                         }];
    
    [self registerSize:@{
                         kMPPaperSizeIdKey:[NSNumber numberWithUnsignedLong:MPPaperSize13x18],
                         kMPPaperSizeTitleKey:MPLocalizedString(@"13x18cm", @"Option for paper size"),
                         kMPPaperSizeConstantNameKey:@"13x18cm",
                         kMPPaperSizeWidthKey:[NSNumber numberWithFloat:5.12],
                         kMPPaperSizeHeightKey:[NSNumber numberWithFloat:7.09]
                         }];
    // Paper Type
    [self registerType:@{
                         kMPPaperTypeIdKey:[NSNumber numberWithUnsignedLong:MPPaperTypePlain],
                         kMPPaperTypeTitleKey:MPLocalizedString(@"Plain Paper", @"Option for paper type"),
                         kMPPaperTypeConstantNameKey:@"Plain Paper",
                         kMPPaperTypePhotoKey:[NSNumber numberWithBool:NO]
                         }];
    [self registerType:@{
                         kMPPaperTypeIdKey:[NSNumber numberWithUnsignedLong:MPPaperTypePhoto],
                         kMPPaperTypeTitleKey:MPLocalizedString(@"Photo Paper", @"Option for paper type"),
                         kMPPaperTypeConstantNameKey:@"Photo Paper",
                         kMPPaperTypePhotoKey:[NSNumber numberWithBool:YES]
                         }];
    
    // Associations
    [self associatePaperSize:MPPaperSize4x5 withType:MPPaperTypePhoto];
    [self associatePaperSize:MPPaperSize4x6 withType:MPPaperTypePhoto];
    [self associatePaperSize:MPPaperSize5x7 withType:MPPaperTypePhoto];
    [self associatePaperSize:MPPaperSizeLetter withType:MPPaperTypePlain];
    [self associatePaperSize:MPPaperSizeLetter withType:MPPaperTypePhoto];
    [self associatePaperSize:MPPaperSizeA4 withType:MPPaperTypePlain];
    [self associatePaperSize:MPPaperSizeA4 withType:MPPaperTypePhoto];
    [self associatePaperSize:MPPaperSizeA5 withType:MPPaperTypePhoto];
    [self associatePaperSize:MPPaperSizeA6 withType:MPPaperTypePhoto];
    [self associatePaperSize:MPPaperSize10x13 withType:MPPaperTypePhoto];
    [self associatePaperSize:MPPaperSize10x15 withType:MPPaperTypePhoto];
    [self associatePaperSize:MPPaperSize13x18 withType:MPPaperTypePhoto];
    [self associatePaperSize:MPPaperSize2x3 withType:MPPaperTypePhoto];
}

+ (NSArray *)supportedSize
{
    [self initializePaper];
    return _supportedSize;
}

+ (NSArray *)supportedType
{
    [self initializePaper];
    return _supportedType;
}

+ (NSArray *)supportedPaper
{
    [self initializePaper];
    return _supportedPaper;
}

+ (BOOL)registerSize:(NSDictionary *)info
{
    [self initializePaper];
    
    NSNumber *sizeId = [info objectForKey:kMPPaperSizeIdKey] ;
    NSString *title = [info objectForKey:kMPPaperSizeTitleKey];
    NSNumber *width = [info objectForKey:kMPPaperSizeWidthKey];
    NSNumber *height = [info objectForKey:kMPPaperSizeHeightKey];
    
    if (nil == sizeId || nil == title || nil == width || nil == height) {
        MPLogError(@"Attempted to register size with missing info:  %@", info);
        return NO;
    }
    
    if (nil != [self sizeForId:[sizeId unsignedIntegerValue]]) {
        MPLogError(@"Attempted to register size ID that already exists:  %lul", (unsigned long)[sizeId unsignedIntegerValue]);
        return NO;
    }
    
    if (nil != [self sizeForTitle:title]) {
        MPLogError(@"Attempted to register size title that already exists:  '%@'", title);
        return NO;
    }
    
    NSMutableArray *supportedSize = [_supportedSize mutableCopy];
    [supportedSize addObject:info];
    _supportedSize = supportedSize;
    
    return YES;
}

+ (BOOL)registerType:(NSDictionary *)info
{
    [self initializePaper];
    
    NSNumber *typeId = [info objectForKey:kMPPaperTypeIdKey] ;
    NSString *title = [info objectForKey:kMPPaperTypeTitleKey];
    
    if (nil == typeId || nil == title) {
        MPLogError(@"Attempted to register type with missing info:  %@", info);
        return NO;
    }
    
    if (nil != [self typeForId:[typeId unsignedIntegerValue]]) {
        MPLogError(@"Attempted to register type ID that already exists:  %lul", (unsigned long)[typeId unsignedIntegerValue]);
        return NO;
    }
    
    if (nil != [self typeForTitle:title]) {
        MPLogError(@"Attempted to register type title that already exists:  '%@'", title);
        return NO;
    }
    
    NSMutableArray *supportedType = [_supportedType mutableCopy];
    [supportedType addObject:info];
    _supportedType = supportedType;
    
    return YES;
}

+ (BOOL)associatePaperSize:(NSUInteger)sizeId withType:(NSUInteger)typeId
{
    [self initializePaper];
    
    if (nil != [self associationForSizeId:sizeId andTypeId:typeId]) {
        MPLogError(@"Attempted association already exists:  size (%lul) - type (%lul)", (unsigned long)sizeId, (unsigned long)typeId);
        return NO;
    }
    
    if (nil == [self sizeForId:sizeId]) {
        MPLogError(@"Attempted to associate with nonexistant size:  %lul", (unsigned long)sizeId);
        return NO;
    }
    
    if (nil == [self typeForId:typeId]) {
        MPLogError(@"Attempted to associate with nonexistant type:  %lul", (unsigned long)typeId);
        return NO;
    }
    
    NSMutableArray *supportedPaper = [_supportedPaper mutableCopy];
    [supportedPaper addObject:@{
                                kMPPaperSizeIdKey:[NSNumber numberWithUnsignedLong:sizeId],
                                kMPPaperTypeIdKey:[NSNumber numberWithUnsignedLong:typeId]
                                }];
    _supportedPaper = supportedPaper;
    
    return YES;
}

+ (void)resetPaperList
{
    _supportedSize = nil;
    _supportedType = nil;
    _supportedPaper = nil;
    [self initializePaper];
    [MP sharedInstance].supportedPapers = [self availablePapers];
    [MP sharedInstance].defaultPaper = [[self availablePapers] firstObject];
}

#pragma mark - Supported paper helpers

+ (NSArray *)availablePapers
{
    NSMutableArray *papers = [NSMutableArray array];
    for (NSDictionary *association in self.supportedPaper) {
        NSUInteger sizeId = [[association objectForKey:kMPPaperSizeIdKey] unsignedIntegerValue];
        NSUInteger typeId = [[association objectForKey:kMPPaperTypeIdKey] unsignedIntegerValue];
        MPPaper *paper = [[MPPaper alloc] initWithPaperSize:sizeId paperType:typeId];
        [papers addObject:paper];
    }
    return [self sortPapers:papers];
}

+ (MPPaper *)standardUSADefaultPaper
{
    return [[MPPaper alloc] initWithPaperSize:MPPaperSize2x3 paperType:MPPaperTypePhoto];
}

+ (NSArray *)standardUSAPapers
{
    return @[
             [[MPPaper alloc] initWithPaperSize:MPPaperSize2x3 paperType:MPPaperTypePhoto],
             [[MPPaper alloc] initWithPaperSize:MPPaperSize4x5 paperType:MPPaperTypePhoto],
             [[MPPaper alloc] initWithPaperSize:MPPaperSize4x6 paperType:MPPaperTypePhoto],
             [[MPPaper alloc] initWithPaperSize:MPPaperSize5x7 paperType:MPPaperTypePhoto],
             [[MPPaper alloc] initWithPaperSize:MPPaperSizeLetter paperType:MPPaperTypePlain],
             [[MPPaper alloc] initWithPaperSize:MPPaperSizeLetter paperType:MPPaperTypePhoto]
             ];
}

+ (MPPaper *)standardInternationalDefaultPaper
{
    return [[MPPaper alloc] initWithPaperSize:MPPaperSize10x15 paperType:MPPaperTypePhoto];
}

+ (NSArray *)standardInternationalPapers
{
    return @[
             [[MPPaper alloc] initWithPaperSize:MPPaperSizeA4 paperType:MPPaperTypePlain],
             [[MPPaper alloc] initWithPaperSize:MPPaperSizeA4 paperType:MPPaperTypePhoto],
             [[MPPaper alloc] initWithPaperSize:MPPaperSizeA5 paperType:MPPaperTypePhoto],
             [[MPPaper alloc] initWithPaperSize:MPPaperSizeA6 paperType:MPPaperTypePhoto],
             [[MPPaper alloc] initWithPaperSize:MPPaperSize10x13 paperType:MPPaperTypePhoto],
             [[MPPaper alloc] initWithPaperSize:MPPaperSize10x15 paperType:MPPaperTypePhoto],
             [[MPPaper alloc] initWithPaperSize:MPPaperSize13x18 paperType:MPPaperTypePhoto],
             ];
}

+ (BOOL)validPaperSize:(NSUInteger)paperSize andType:(NSUInteger)paperType
{
    BOOL valid = NO;
    for (MPPaper *paper in [self availablePapers]) {
        if (paper.paperSize == paperSize && paper.paperType == paperType) {
            valid = YES;
            break;
        }
    }
    return valid;
}

+ (NSDictionary *)sizeForId:(NSUInteger)sizeId
{
    NSDictionary *sizeInfo = nil;
    for (NSDictionary *info in _supportedSize) {
        NSUInteger existingId = [[info objectForKey:kMPPaperSizeIdKey] unsignedIntegerValue];
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
        NSString *existingTitle = [info objectForKey:kMPPaperSizeTitleKey];
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
        NSUInteger existingId = [[info objectForKey:kMPPaperTypeIdKey] unsignedIntegerValue];
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
        NSString *existingTitle = [info objectForKey:kMPPaperTypeTitleKey];
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
        NSUInteger existingSizeId = [[info objectForKey:kMPPaperSizeIdKey] unsignedIntegerValue];
        NSUInteger existingTypeId = [[info objectForKey:kMPPaperTypeIdKey] unsignedIntegerValue];
        if (existingSizeId == sizeId && existingTypeId == typeId) {
            associationInfo = info;
        }
    }
    return associationInfo;
}

+ (NSArray *)sortPapers:(NSArray *)papers
{
    NSMutableArray *sortedPapers = [NSMutableArray arrayWithArray:papers];
    [sortedPapers sortUsingComparator:^NSComparisonResult(id obj1, id  obj2){
        MPPaper *paper1 = obj1;
        MPPaper *paper2 = obj2;
        if (paper1.paperSize < paper2.paperSize) {
            return NSOrderedAscending;
        } else if (paper1.paperSize > paper2.paperSize) {
            return NSOrderedDescending;
        } else {
            if (paper1.paperType < paper2.paperType) {
                return NSOrderedAscending;
            } else if (paper1.paperType > paper2.paperType) {
                return NSOrderedDescending;
            }
        }
        return NSOrderedSame;
    }];
    return sortedPapers;
}

#pragma mark - Supported paper type info

+ (BOOL)supportedPaperSize:(NSUInteger)paperSize andType:(NSUInteger)paperType
{
    BOOL valid = NO;
    for (MPPaper *paper in [MP sharedInstance].supportedPapers) {
        if (paper.paperSize == paperSize && paper.paperType == paperType) {
            valid = YES;
            break;
        }
    }
    return valid;
}

- (NSArray *)supportedTypes
{
    NSMutableArray *paperTypes = [NSMutableArray array];
    for (MPPaper *supportedPaper in [MP sharedInstance].supportedPapers) {
        if (supportedPaper.paperSize == self.paperSize) {
            NSNumber *supportedType = [NSNumber numberWithUnsignedInteger:supportedPaper.paperType];
            if (![paperTypes containsObject:supportedType]) {
                [paperTypes addObject:supportedType];
            }
        }
    }
    return paperTypes;
}

- (BOOL)supportsType:(NSUInteger)paperType
{
    BOOL supported = NO;
    for (MPPaper *supportedPaper in [MP sharedInstance].supportedPapers) {
        if (supportedPaper.paperSize == self.paperSize && supportedPaper.paperType == paperType) {
            supported = YES;
            break;
        }
    }
    return supported;
}

+ (NSNumber *)defaultTypeForSize:(NSUInteger)paperSize
{
    for (MPPaper *paper in [MP sharedInstance].supportedPapers) {
        if (paperSize == paper.paperSize) {
            return [NSNumber numberWithUnsignedInteger:paper.paperType];
        }
    }
    
    for (NSDictionary *info in _supportedPaper) {
        if (paperSize == [[info objectForKey:kMPPaperSizeIdKey] unsignedIntegerValue]) {
            return [info objectForKey:kMPPaperTypeIdKey];
        }
    }
    
    return nil;
}

#pragma mark - Log description

- (NSString *)description
{
    CGSize printerSize = [self printerPaperSize];
    return [NSString stringWithFormat:@"%@, %@\nWidth %.2f Height %.2f\nPrinter Width %.2f Printer Height %.2f\nPaper Size %lul\nPaper Type %lul",
            self.sizeTitle,
            self.typeTitle,
            self.width,
            self.height,
            printerSize.width,
            printerSize.height,
            (unsigned long)self.paperSize,
            (unsigned long)self.paperType];
}

@end


