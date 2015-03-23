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

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "HPPPPrintLaterJob.h"

extern NSString * const kHPPPPrintJobAddedToQueueNotification;
extern NSString * const kHPPPAllPrintJobsRemovedFromQueueNotification;


@interface HPPPPrintLaterQueue : NSObject

+ (HPPPPrintLaterQueue *)sharedInstance;
- (NSString *)retrievePrintLaterJobNextAvailableId;
- (BOOL)addPrintLaterJob:(HPPPPrintLaterJob *)printLaterJob;
- (BOOL)deletePrintLaterJob:(HPPPPrintLaterJob *)printLaterJob;
- (BOOL)deleteAllPrintLaterJobs;
- (HPPPPrintLaterJob *)retrievePrintLaterJobWithID:(NSString *)id;
- (NSArray *)retrieveAllPrintLaterJobs;
- (NSInteger)retrieveNumberOfPrintLaterJobs;

@end
