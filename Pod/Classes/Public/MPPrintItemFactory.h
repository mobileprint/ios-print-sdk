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

#import <Foundation/Foundation.h>
#import "MPPrintItem.h"

/*!
 * @abstract Factory class for creating print items
 */
@interface MPPrintItemFactory : NSObject

/*!
 * @abstract Creates a print item instance for a given asset
 * @param asset The printable asset used to create the print item
 * @return The print item or nil if no print item could be created with the asset given
 */
+ (MPPrintItem *)printItemWithAsset:(id)asset;

@end
