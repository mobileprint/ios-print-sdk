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

#import "MP.h"
#import "MPPrintItemFactory.h"
#import "MPPrintItemImage.h"
#import "MPPrintItemPDF.h"

@implementation MPPrintItemFactory

+ (MPPrintItem *)printItemWithAsset:(id)asset
{
    MPPrintItem *printItem = nil;
    
    if ([asset isKindOfClass:[UIImage class]]) {
        printItem = [[MPPrintItemImage alloc] initWithImage:asset];
    } else if ([asset isKindOfClass:[NSArray class]]) {
        printItem = [[MPPrintItemImage alloc] initWithImages:asset];
    } else if ([asset isKindOfClass:[NSData class]]) {
        printItem = [[MPPrintItemImage alloc] initWithData:asset];
        if (nil == printItem) {
            printItem = [[MPPrintItemPDF alloc] initWithData:asset];
        }
    }
    
    if (nil == printItem) {
        MPLogWarn(@"Unable to create print item using %@", asset);
    }
    
    return printItem;
}

@end
