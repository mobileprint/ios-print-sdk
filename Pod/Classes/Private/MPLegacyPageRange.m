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

#import "MPLegacyPageRange.h"

@implementation MPLegacyPageRange

NSString * const kHPPPPageRangeRange = @"kHPPPPageRangeRange";
NSString * const kHPPPPageRangeAllPagesIndicator = @"kHPPPPageRangeAllPagesIndicator";
NSString * const kHPPPPageRangeMaxPageNum = @"kHPPPPageRangeMaxPageNum";
NSString * const kHPPPPageRangeSortAscending = @"kHPPPPageRangeSortAscending";

- (id)initWithCoder:(NSCoder *)decoder
{
    if (self = [super init]) {
        NSString *range = [decoder decodeObjectForKey:kHPPPPageRangeRange];
        NSString *allPagesIndicator = [decoder decodeObjectForKey:kHPPPPageRangeAllPagesIndicator];
        NSNumber *maxPageNum = [decoder decodeObjectForKey:kHPPPPageRangeMaxPageNum];
        NSNumber *sortAscending = [decoder decodeObjectForKey:kHPPPPageRangeSortAscending];
        self = [self initWithString:range allPagesIndicator:allPagesIndicator maxPageNum:[maxPageNum integerValue] sortAscending:[sortAscending boolValue]];
    }
    
    return self;
}

@end
