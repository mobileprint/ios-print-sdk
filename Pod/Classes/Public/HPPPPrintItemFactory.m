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
#import "HPPPPrintItemFactory.h"
#import "HPPPPrintItemImage.h"
#import "HPPPPrintItemPDF.h"

@implementation HPPPPrintItemFactory

+ (HPPPPrintItem *)printItemWithAsset:(id)asset
{
    HPPPPrintItem *printItem = nil;
    
    if ([asset isKindOfClass:[UIImage class]]) {
        printItem = [[HPPPPrintItemImage alloc] initWithImage:asset];
    } else if ([asset isKindOfClass:[NSData class]]) {
        printItem = [[HPPPPrintItemImage alloc] initWithData:asset];
        if (nil == printItem) {
            printItem = [[HPPPPrintItemPDF alloc] initWithData:asset];
        }
    }
    
    if (nil == printItem) {
        HPPPLogWarn(@"Unable to create print item using %@", asset);
    }
    
    return printItem;
}

@end
