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

#import "HPPPPrintLaterJob.h"
#import "HPPP.h"

NSString * const kHPPPPrintLaterJobId = @"kHPPPPrintLaterJobId";
NSString * const kHPPPPrintLaterJobName = @"kHPPPPrintLaterJobName";
NSString * const kHPPPPrintLaterJobDate = @"kHPPPPrintLaterJobDate";
NSString * const kHPPPPrintLaterJobPrinterName = @"kHPPPPrintLaterJobPrinterName";
NSString * const kHPPPPrintLaterJobPrinterLocation = @"kHPPPPrintLaterJobPrinterLocation";
NSString * const kHPPPPrintLaterJobPrinterURL = @"kHPPPPrintLaterJobPrinterURL";
NSString * const kHPPPPrintLaterJobImages = @"kHPPPPrintLaterJobImages";
NSString * const kHPPPPrintLaterJobExtra = @"kHPPPPrintLaterJobExtra";


@implementation HPPPPrintLaterJob

- (void)encodeWithCoder:(NSCoder *)encoder
{
    [encoder encodeObject:self.id forKey:kHPPPPrintLaterJobId];
    [encoder encodeObject:self.name forKey:kHPPPPrintLaterJobName];
    [encoder encodeObject:self.date forKey:kHPPPPrintLaterJobDate];
    [encoder encodeObject:self.printerName forKey:kHPPPPrintLaterJobPrinterName];
    [encoder encodeObject:self.printerLocation forKey:kHPPPPrintLaterJobPrinterLocation];
    [encoder encodeObject:self.printerURL forKey:kHPPPPrintLaterJobPrinterURL];
    [encoder encodeObject:self.images forKey:kHPPPPrintLaterJobImages];
    [encoder encodeObject:self.extra forKey:kHPPPPrintLaterJobExtra];
}

- (id)initWithCoder:(NSCoder *)decoder
{
    if (self = [super init]) {
        self.id = [decoder decodeObjectForKey:kHPPPPrintLaterJobId];
        self.name = [decoder decodeObjectForKey:kHPPPPrintLaterJobName];
        self.date = [decoder decodeObjectForKey:kHPPPPrintLaterJobDate];
        self.printerName = [decoder decodeObjectForKey:kHPPPPrintLaterJobPrinterName];
        self.printerLocation = [decoder decodeObjectForKey:kHPPPPrintLaterJobPrinterLocation];
        self.printerURL = [decoder decodeObjectForKey:kHPPPPrintLaterJobPrinterURL];
        self.images = [decoder decodeObjectForKey:kHPPPPrintLaterJobImages];
        self.extra = [decoder decodeObjectForKey:kHPPPPrintLaterJobExtra];
    }
    
    return self;
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"id: %@ \nname: %@ \ndate: %@ \nprinter name: %@\nprinter location: %@ \nprinter URL: %@ \n", self.id, self.name, self.date, self.printerName, self.printerLocation, self.printerURL];
}

@end
