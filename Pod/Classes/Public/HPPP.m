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

NSString * const kHPPPPaperTypeId = @"kHPPPPaperTypeId";
NSString * const kHPPPPaperSizeId = @"kHPPPPaperSizeId";
NSString * const kHPPPBlackAndWhiteFilterId = @"kHPPPBlackAndWhiteFilterId";
NSString * const kHPPPPrinterId = @"kHPPPPrinterId";

NSString * const kHPPPSupportIcon = @"kHPPPSupportIcon";
NSString * const kHPPPSupportTitle = @"kHPPPSupportTitle";

NSString * const kHPPPSupportUrl = @"kHPPPSupportUrl";
NSString * const kHPPPSupportVC = @"kHPPPSupportVC";


@implementation HPPP

#pragma mark - Public methods

+ (HPPP *)sharedInstance
{
    static HPPP *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[HPPP alloc] init];
    });
    
    return sharedInstance;
}

#pragma mark - Initialization

- (id)init
{
    self = [super init];
    if (self) {
        self.lastOptionsUsed = [NSMutableDictionary dictionary];
        self.defaultPaperSize = Size5x7;
        self.defaultPaperType = Plain;
        self.paperSizes = @[
                            [HPPPPaper titleFromSize:Size4x6],
                            [HPPPPaper titleFromSize:Size5x7],
                            [HPPPPaper titleFromSize:SizeLetter]
                            ];
    }
    
    return self;
}

@end
