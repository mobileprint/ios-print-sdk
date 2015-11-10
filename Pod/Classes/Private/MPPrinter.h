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


/*!
 * @abstract Class used for checking printer availability
 */
@interface MPPrinter : NSObject

/*!
 * @abstract Used to access the singleton instance of this class
 */
+ (MPPrinter *)sharedInstance;

- (void)checkLastPrinterUsedAvailability;

- (void)checkDefaultPrinterAvailabilityWithCompletion:(void(^)(BOOL available))completion;

@end
