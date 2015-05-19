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
    [encoder encodeObject:self.printItems forKey:kHPPPPrintLaterJobImages];
    [encoder encodeObject:self.extra forKey:kHPPPPrintLaterJobExtra];
}

- (id)initWithCoder:(NSCoder *)decoder
{
    if (self = [super init]) {
        self.id = [decoder decodeObjectForKey:kHPPPPrintLaterJobId];
        self.name = [decoder decodeObjectForKey:kHPPPPrintLaterJobName];
        self.date = [decoder decodeObjectForKey:kHPPPPrintLaterJobDate];
        self.printItems = [decoder decodeObjectForKey:kHPPPPrintLaterJobImages];
        self.extra = [decoder decodeObjectForKey:kHPPPPrintLaterJobExtra];
    }
    
    return self;
}

- (UIImage *)previewImage
{
    HPPPPaper *initialPaper = [[HPPPPaper alloc] initWithPaperSize:[HPPP sharedInstance].initialPaperSize paperType:Plain];
    HPPPPrintItem *printItem = [self.printItems objectForKey:initialPaper.sizeTitle];
    
    return [printItem previewImageForPaper:initialPaper];
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"id: %@ \nname: %@ \ndate: %@ \nextra: %@", self.id, self.name, self.date, self.extra];
}

@end
