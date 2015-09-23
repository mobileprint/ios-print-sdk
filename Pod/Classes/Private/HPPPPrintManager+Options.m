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
#import "HPPPPrintManager.h"
#import "HPPPPrintManager+Options.h"
#import <objc/runtime.h>

// The following technique is adapted from:  http://stackoverflow.com/questions/8733104/objective-c-property-instance-variable-in-category

@implementation HPPPPrintManager (Options)

NSString * const kHPPPPrinterDetailsNotAvailable = @"Not Available";

- (void)setOptions:(HPPPPrintManagerOptions)options
{
    NSNumber *optionsAsNumber = [NSNumber numberWithUnsignedLong:options];
    objc_setAssociatedObject(self, @selector(options), optionsAsNumber, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (HPPPPrintManagerOptions)options
{
    NSNumber *optionsAsNumber = objc_getAssociatedObject(self, @selector(options));
    return [optionsAsNumber unsignedLongValue];
}

- (void)setNumberOfCopies:(NSInteger)numberOfCopies
{
    NSNumber *copiesAsNumber = [NSNumber numberWithInteger:numberOfCopies];
    objc_setAssociatedObject(self, @selector(numberOfCopies), copiesAsNumber, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSInteger)numberOfCopies
{
    NSNumber *copiesAsNumber = objc_getAssociatedObject(self, @selector(numberOfCopies));
    return [copiesAsNumber integerValue];
}

- (void)saveLastOptionsForPrinter:(NSString *)printerID;
{
    NSMutableDictionary *lastOptionsUsed = [NSMutableDictionary dictionaryWithDictionary:[HPPP sharedInstance].lastOptionsUsed];
    [lastOptionsUsed setValue:self.currentPrintSettings.paper.typeTitle forKey:kHPPPPaperTypeId];
    [lastOptionsUsed setValue:self.currentPrintSettings.paper.sizeTitle forKey:kHPPPPaperSizeId];
    [lastOptionsUsed setValue:[NSNumber numberWithBool:!self.currentPrintSettings.color] forKey:kHPPPBlackAndWhiteFilterId];
    [lastOptionsUsed setValue:[NSNumber numberWithInteger:self.numberOfCopies] forKey:kHPPPNumberOfCopies];
    
    [lastOptionsUsed setValue:kHPPPPrinterDetailsNotAvailable forKey:kHPPPPrinterDisplayName];
    [lastOptionsUsed setValue:kHPPPPrinterDetailsNotAvailable forKey:kHPPPPrinterDisplayLocation];
    [lastOptionsUsed setValue:kHPPPPrinterDetailsNotAvailable forKey:kHPPPPrinterMakeAndModel];
    
    if (printerID) {
        [lastOptionsUsed setValue:printerID forKey:kHPPPPrinterId];
        if ([printerID isEqualToString:self.currentPrintSettings.printerUrl.absoluteString]) {
            [lastOptionsUsed setValue:self.currentPrintSettings.printerName forKey:kHPPPPrinterDisplayName];
            [lastOptionsUsed setValue:self.currentPrintSettings.printerLocation forKey:kHPPPPrinterDisplayLocation];
            [lastOptionsUsed setValue:self.currentPrintSettings.printerModel forKey:kHPPPPrinterMakeAndModel];
        }
    }
    
    [HPPP sharedInstance].lastOptionsUsed = [NSDictionary dictionaryWithDictionary:lastOptionsUsed];
}

- (void)saveLastOptionsForPaper:(UIPrintPaper *)paper
{
    NSMutableDictionary *lastOptionsUsed = [NSMutableDictionary dictionaryWithDictionary:[HPPP sharedInstance].lastOptionsUsed];

    [lastOptionsUsed setValue:[NSString stringWithFormat:@"%.2f", paper.paperSize.width] forKey:kHPPPPrinterPaperWidthPoints];
    [lastOptionsUsed setValue:[NSString stringWithFormat:@"%.2f", paper.paperSize.height] forKey:kHPPPPrinterPaperHeightPoints];
    [lastOptionsUsed setValue:[NSString stringWithFormat:@"%.2f", paper.printableRect.size.width] forKey:kHPPPPrinterPaperAreaWidthPoints];
    [lastOptionsUsed setValue:[NSString stringWithFormat:@"%.2f", paper.printableRect.size.height] forKey:kHPPPPrinterPaperAreaHeightPoints];
    [lastOptionsUsed setValue:[NSString stringWithFormat:@"%.2f", paper.printableRect.origin.x] forKey:kHPPPPrinterPaperAreaXPoints];
    [lastOptionsUsed setValue:[NSString stringWithFormat:@"%.2f", paper.printableRect.origin.y] forKey:kHPPPPrinterPaperAreaYPoints];

    [HPPP sharedInstance].lastOptionsUsed = [NSDictionary dictionaryWithDictionary:lastOptionsUsed];
}

@end
