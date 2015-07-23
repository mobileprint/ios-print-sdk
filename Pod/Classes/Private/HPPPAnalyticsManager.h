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

#import "HPPPPrintItem.h"

@interface HPPPAnalyticsManager : NSObject

extern NSString * const kHPPPOfframpKey;
extern NSString * const kHPPPQueuePrintAction;
extern NSString * const kHPPPQueuePrintAllAction;
extern NSString * const kHPPPQueueDeleteAction;

+ (HPPPAnalyticsManager *)sharedManager;

+ (NSString *)wifiName;
    
- (void)trackShareEventWithPrintItem:(HPPPPrintItem *)printItem andOptions:(NSDictionary *)options;
- (void)trackShareEventWithPrintLaterJob:(HPPPPrintLaterJob *)printLaterJob andOptions:(NSDictionary *)options;

@end
