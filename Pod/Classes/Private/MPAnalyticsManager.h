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

#import "MPPrintItem.h"

@interface MPAnalyticsManager : NSObject

extern NSString * const kMPOfframpKey;

+ (MPAnalyticsManager *)sharedManager;

+ (NSString *)wifiName;

+ (NSString *)obfuscateValue:(NSString *)value;

- (void)trackShareEventWithPrintItem:(MPPrintItem *)printItem andOptions:(NSDictionary *)options;

@end
