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
#import "MPPrintLaterJob.h"
#import "MPPrintItem.h"
#import "MPPrintItemFactory.h"
#import "MPAnalyticsManager.h"

NSString * const kMPPrintLaterJobId = @"kMPPrintLaterJobId";
NSString * const kMPPrintLaterJobName = @"kMPPrintLaterJobName";
NSString * const kMPPrintLaterJobDate = @"kMPPrintLaterJobDate";
NSString * const kMPPrintLaterJobImages = @"kMPPrintLaterJobImages";
NSString * const kMPPrintLaterNumCopies = @"kMPPrintLaterNumCopies";
NSString * const kMPPrintLaterPageRange = @"kMPPrintLaterPageRange";
NSString * const kMPPrintLaterBlackAndWhite = @"kMPPrintLaterBlackAndWhite";
NSString * const kMPPrintLaterJobExtra = @"kMPPrintLaterJobExtra";

@implementation MPPrintLaterJob

@synthesize customAnalytics = _customAnalytics;

- (id) init
{
    self = [super init];
    
    if( self ) {
        self.numCopies = 1;
        self.blackAndWhite = FALSE;
        self.pageRange = nil;
    }
    
    return self;
}

- (void)encodeWithCoder:(NSCoder *)encoder
{
    [encoder encodeObject:self.id forKey:kMPPrintLaterJobId];
    [encoder encodeObject:self.name forKey:kMPPrintLaterJobName];
    [encoder encodeObject:self.date forKey:kMPPrintLaterJobDate];
    [encoder encodeObject:self.pageRange forKey:kMPPrintLaterPageRange];
    [encoder encodeObject:self.printItems forKey:kMPPrintLaterJobImages];
    [encoder encodeObject:self.extra forKey:kMPPrintLaterJobExtra];
    [encoder encodeObject:[NSNumber numberWithInteger:self.numCopies] forKey:kMPPrintLaterNumCopies];
    [encoder encodeObject:[NSNumber numberWithBool:self.blackAndWhite] forKey:kMPPrintLaterBlackAndWhite];
}

- (id)initWithCoder:(NSCoder *)decoder
{
    if (self = [super init]) {
        self.id = [decoder decodeObjectForKey:kMPPrintLaterJobId];
        self.name = [decoder decodeObjectForKey:kMPPrintLaterJobName];
        self.date = [decoder decodeObjectForKey:kMPPrintLaterJobDate];
        self.pageRange = [decoder decodeObjectForKey:kMPPrintLaterPageRange];
        self.printItems = [decoder decodeObjectForKey:kMPPrintLaterJobImages];
        self.extra = [decoder decodeObjectForKey:kMPPrintLaterJobExtra];
        NSNumber *numCopies = [decoder decodeObjectForKey:kMPPrintLaterNumCopies];
        self.numCopies = [numCopies integerValue];
        NSNumber *blackAndWhite = [decoder decodeObjectForKey:kMPPrintLaterBlackAndWhite];
        self.blackAndWhite = [blackAndWhite boolValue];
    }
    
    return self;
}

- (UIImage *)previewImage
{
    MPPaper *initialPaper = [MP sharedInstance].defaultPaper;
    MPPrintItem *printItem = [self printItemForPaperSize:[MPPaper titleFromSize:[MP sharedInstance].defaultPaper.paperSize]];
    
    return [printItem previewImageForPaper:initialPaper];
}

- (MPPrintItem *) printItemForPaperSize:(NSString *)paperSizeTitle
{
    id rawPrintItem = [self.printItems objectForKey:paperSizeTitle];
    
    MPPrintItem *printItem;
    if( [rawPrintItem isKindOfClass:[MPPrintItem class]] ) {
        printItem = rawPrintItem;
    } else {
        printItem = [MPPrintItemFactory printItemWithAsset:rawPrintItem];
    }
    
    if( nil == printItem ) {
        MPLogWarn(@"No printitem found for paper size %@", paperSizeTitle);
    }
    
    return printItem;
}

- (MPPrintItem *)defaultPrintItem
{
    return [self printItemForPaperSize:[MP sharedInstance].defaultPaper.sizeTitle];
}

- (void)setPrintSessionForPrintItem:(MPPrintItem *)printItem
{
    NSMutableDictionary *jopOptions = [NSMutableDictionary dictionaryWithDictionary:self.extra];
    [jopOptions addEntriesFromDictionary:@{ kMPMetricsPrintSessionID:[printItem.extra objectForKey:kMPMetricsPrintSessionID] }];
    self.extra = jopOptions;
}

- (void)prepareMetricsForOfframp:(NSString *)offramp
{
    NSInteger printPageCount = self.pageRange ? [self.pageRange getPages].count : self.defaultPrintItem.numberOfPages;
    NSMutableDictionary *jopOptions = [NSMutableDictionary dictionaryWithDictionary:self.extra];
    [jopOptions addEntriesFromDictionary:@{
                                           kMPOfframpKey:offramp,
                                           kMPNumberPagesPrint:[NSNumber numberWithInteger:printPageCount]}];

    self.extra = jopOptions;
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
    NSMutableDictionary *extras = [self.extra mutableCopy];
    [extras setObject:customAnalytics forKey:kMPCustomAnalyticsKey];
    self.extra = extras;
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"id: %@ \nname: %@ \ndate: %@ \npageRange: %@ \nnumCopies: %ld \nblackAndWhite: %d\nextra: %@", self.id, self.name, self.date, self.pageRange, (long)self.numCopies, self.blackAndWhite, self.extra];
}

@end
