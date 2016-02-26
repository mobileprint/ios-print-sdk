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

#import "MPLegacyPrintLaterJob.h"

@implementation MPLegacyPrintLaterJob

NSString * const kHPPPPrintLaterJobId = @"kHPPPPrintLaterJobId";
NSString * const kHPPPPrintLaterJobName = @"kHPPPPrintLaterJobName";
NSString * const kHPPPPrintLaterJobDate = @"kHPPPPrintLaterJobDate";
NSString * const kHPPPPrintLaterJobImages = @"kHPPPPrintLaterJobImages";
NSString * const kHPPPPrintLaterNumCopies = @"kHPPPPrintLaterNumCopies";
NSString * const kHPPPPrintLaterPageRange = @"kHPPPPrintLaterPageRange";
NSString * const kHPPPPrintLaterBlackAndWhite = @"kHPPPPrintLaterBlackAndWhite";
NSString * const kHPPPPrintLaterJobExtra = @"kHPPPPrintLaterJobExtra";

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

@end
