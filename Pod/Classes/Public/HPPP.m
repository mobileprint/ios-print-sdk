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

NSString * const kHPPPTrackableScreenNameKey = @"screen-name";

NSString * const kHPPPPaperTypeId = @"kHPPPPaperTypeId";
NSString * const kHPPPPaperSizeId = @"kHPPPPaperSizeId";
NSString * const kHPPPBlackAndWhiteFilterId = @"kHPPPBlackAndWhiteFilterId";
NSString * const kHPPPPrinterId = @"kHPPPPrinterId";
NSString * const kHPPPPrinterDisplayName = @"kHPPPPrinterDisplayName";
NSString * const kHPPPPrinterDisplayLocation = @"kHPPPPrinterDisplayLocation";
NSString * const kHPPPPrinterMakeAndModel = @"kHPPPPrinterMakeAndModel";
NSString * const kHPPPNumberOfCopies = @"kHPPPNumberOfCopies";

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
        self.initialPaperSize = Size5x7;
        self.defaultPaperWidth = 5.0f;
        self.defaultPaperHeight = 7.0f;
        self.zoomAndCrop = NO;
        self.defaultPaperType = Photo;
        self.paperSizes = @[
                            [HPPPPaper titleFromSize:Size4x6],
                            [HPPPPaper titleFromSize:Size5x7],
                            [HPPPPaper titleFromSize:SizeLetter]
                            ];
    }
    
    return self;
}

- (BOOL)hideBlackAndWhiteOption
{
    BOOL retVal = YES;
    
    if (IS_OS_8_OR_LATER) {
        retVal = _hideBlackAndWhiteOption;
    }
    
    return retVal;
}

@end
