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

NSString * const kHPPPPrintLaterJobId = @"kHPPPPrintLaterJobId";
NSString * const kHPPPPrintLaterJobName = @"kHPPPPrintLaterJobName";
NSString * const kHPPPPrintLaterJobDate = @"kHPPPPrintLaterJobDate";
NSString * const kHPPPPrintLaterJobImages = @"kHPPPPrintLaterJobImages";
NSString * const kHPPPPrintLaterJobExtra = @"kHPPPPrintLaterJobExtra";

@implementation HPPPPrintLaterJob

- (void)encodeWithCoder:(NSCoder *)encoder
{
    [encoder encodeObject:self.id forKey:kHPPPPrintLaterJobId];
    [encoder encodeObject:self.name forKey:kHPPPPrintLaterJobName];
    [encoder encodeObject:self.date forKey:kHPPPPrintLaterJobDate];
    
    // UIImages don't implement the protocol necessary for serialization, so they must be change to NSDatas
    NSMutableDictionary *serializeImages = [NSMutableDictionary dictionary];
    
    for (NSString *printJobId in self.printingItems.allKeys) {
        NSData *data = [self.printingItems objectForKey:printJobId];
        if ([data isKindOfClass:[UIImage class]]) {
            data = UIImageJPEGRepresentation((UIImage *)data, [[UIScreen mainScreen] scale]);
        }
        [serializeImages setObject:data forKey:printJobId];
    }
    
    [encoder encodeObject:serializeImages.copy forKey:kHPPPPrintLaterJobImages];
    [encoder encodeObject:self.extra forKey:kHPPPPrintLaterJobExtra];
}

- (id)initWithCoder:(NSCoder *)decoder
{
    if (self = [super init]) {
        self.id = [decoder decodeObjectForKey:kHPPPPrintLaterJobId];
        self.name = [decoder decodeObjectForKey:kHPPPPrintLaterJobName];
        self.date = [decoder decodeObjectForKey:kHPPPPrintLaterJobDate];
        
        NSDictionary *decodedImages = [decoder decodeObjectForKey:kHPPPPrintLaterJobImages];
        
        NSMutableDictionary *serializeImages = [NSMutableDictionary dictionary];
        for (NSString *printJobId in decodedImages.allKeys) {
            NSData *data = [decodedImages objectForKey:printJobId];
            [serializeImages setObject:data forKey:printJobId];
        }
        
        self.printingItems = serializeImages.copy;
        self.extra = [decoder decodeObjectForKey:kHPPPPrintLaterJobExtra];
    }
    
    return self;
}

- (UIImage *)previewImage
{
    HPPPPaper *initialPaper = [[HPPPPaper alloc] initWithPaperSize:[HPPP sharedInstance].initialPaperSize paperType:Plain];
    id printingItem = [self.printingItems objectForKey:initialPaper.sizeTitle];
    
    return [[HPPP sharedInstance] previewImageForPrintingItem:printingItem andPaper:initialPaper];
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"id: %@ \nname: %@ \ndate: %@ \nextra: %@", self.id, self.name, self.date, self.extra];
}

@end
