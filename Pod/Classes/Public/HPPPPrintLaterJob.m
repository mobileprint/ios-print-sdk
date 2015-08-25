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
#import "HPPPPrintLaterJob.h"
#import "HPPPPrintItem.h"
#import "HPPPPrintItemFactory.h"
#import "HPPPAnalyticsManager.h"

NSString * const kHPPPPrintLaterJobId = @"kHPPPPrintLaterJobId";
NSString * const kHPPPPrintLaterJobName = @"kHPPPPrintLaterJobName";
NSString * const kHPPPPrintLaterJobDate = @"kHPPPPrintLaterJobDate";
NSString * const kHPPPPrintLaterJobImages = @"kHPPPPrintLaterJobImages";
NSString * const kHPPPPrintLaterNumCopies = @"kHPPPPrintLaterNumCopies";
NSString * const kHPPPPrintLaterPageRange = @"kHPPPPrintLaterPageRange";
NSString * const kHPPPPrintLaterBlackAndWhite = @"kHPPPPrintLaterBlackAndWhite";
NSString * const kHPPPPrintLaterJobExtra = @"kHPPPPrintLaterJobExtra";

@implementation HPPPPrintLaterJob

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
    [encoder encodeObject:self.id forKey:kHPPPPrintLaterJobId];
    [encoder encodeObject:self.name forKey:kHPPPPrintLaterJobName];
    [encoder encodeObject:self.date forKey:kHPPPPrintLaterJobDate];
    [encoder encodeObject:self.pageRange forKey:kHPPPPrintLaterPageRange];
    [encoder encodeObject:self.printItems forKey:kHPPPPrintLaterJobImages];
    [encoder encodeObject:self.extra forKey:kHPPPPrintLaterJobExtra];
    [encoder encodeObject:[NSNumber numberWithInteger:self.numCopies] forKey:kHPPPPrintLaterNumCopies];
    [encoder encodeObject:[NSNumber numberWithBool:self.blackAndWhite] forKey:kHPPPPrintLaterBlackAndWhite];
}

- (id)initWithCoder:(NSCoder *)decoder
{
    if (self = [super init]) {
        self.id = [decoder decodeObjectForKey:kHPPPPrintLaterJobId];
        self.name = [decoder decodeObjectForKey:kHPPPPrintLaterJobName];
        self.date = [decoder decodeObjectForKey:kHPPPPrintLaterJobDate];
        self.pageRange = [decoder decodeObjectForKey:kHPPPPrintLaterPageRange];
        self.printItems = [decoder decodeObjectForKey:kHPPPPrintLaterJobImages];
        self.extra = [decoder decodeObjectForKey:kHPPPPrintLaterJobExtra];
        NSNumber *numCopies = [decoder decodeObjectForKey:kHPPPPrintLaterNumCopies];
        self.numCopies = [numCopies integerValue];
        NSNumber *blackAndWhite = [decoder decodeObjectForKey:kHPPPPrintLaterBlackAndWhite];
        self.blackAndWhite = [blackAndWhite boolValue];
    }
    
    return self;
}

- (UIImage *)previewImage
{
    HPPPPaper *initialPaper = [[HPPPPaper alloc] initWithPaperSize:[HPPP sharedInstance].defaultPaper.paperSize paperType:Plain];
    HPPPPrintItem *printItem = [self printItemForPaperSize:[HPPPPaper titleFromSize:[HPPP sharedInstance].defaultPaper.paperSize]];
    
    return [printItem previewImageForPaper:initialPaper];
}

- (HPPPPrintItem *) printItemForPaperSize:(NSString *)paperSizeTitle
{
    id rawPrintItem = [self.printItems objectForKey:paperSizeTitle];
    
    HPPPPrintItem *printItem;
    if( [rawPrintItem isKindOfClass:[HPPPPrintItem class]] ) {
        printItem = rawPrintItem;
    } else {
        printItem = [HPPPPrintItemFactory printItemWithAsset:rawPrintItem];
    }
    
    if( nil == printItem ) {
        HPPPLogWarn(@"No printitem found for paper size %@", paperSizeTitle);
    }
    
    return printItem;
}

- (HPPPPrintItem *)defaultPrintItem
{
    return [self printItemForPaperSize:[HPPP sharedInstance].defaultPaper.sizeTitle];
}

- (void)prepareMetricswithOfframp:(NSString *)offramp
{
    NSInteger printPageCount = self.pageRange ? [self.pageRange getPages].count : self.defaultPrintItem.numberOfPages;
    NSMutableDictionary *jopOptions = [NSMutableDictionary dictionaryWithDictionary:self.extra];
    [jopOptions addEntriesFromDictionary:@{ kHPPPOfframpKey:offramp }];
    [jopOptions setObject:[NSNumber numberWithInteger:printPageCount] forKey:kHPPPNumberPagesPrint];
    [jopOptions setObject:[NSNumber numberWithInteger:self.defaultPrintItem.numberOfPages] forKey:kHPPPNumberPagesDocument];
    self.extra = jopOptions;
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"id: %@ \nname: %@ \ndate: %@ \npageRange: %@ \nnumCopies: %ld \nblackAndWhite: %d\nextra: %@", self.id, self.name, self.date, self.pageRange, (long)self.numCopies, self.blackAndWhite, self.extra];
}

@end
