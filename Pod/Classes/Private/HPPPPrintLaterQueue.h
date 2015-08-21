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
#import "HPPPAddPrintLaterJobTableViewController.h"

/*!
 * @abstract Represents the list of queued print jobs
 */
@interface HPPPPrintLaterQueue : NSObject

extern NSString * const kHPPPOfframpAddToQueueShare;
extern NSString * const kHPPPOfframpAddToQueueCustom;
extern NSString * const kHPPPOfframpAddToQueueDirect;

/*!
 * @abstract Used to access the singleton instance of this class
 */
+ (HPPPPrintLaterQueue *)sharedInstance;

/*!
 * @abstract Used to get the next available job ID
 * @return The next available job ID
 */
- (NSString *)retrievePrintLaterJobNextAvailableId;

/*!
 * @abstract Adds a job to the print queue
 * @param printLaterJob The job to add
 * @param controller The controller (if any) used to add the job
 */
- (BOOL)addPrintLaterJob:(HPPPPrintLaterJob *)printLaterJob fromController:(HPPPAddPrintLaterJobTableViewController *)controller;

/*!
 * @abstract Removes a job to the print queue
 * @param printLaterJob The job to remove
 */
- (BOOL)deletePrintLaterJob:(HPPPPrintLaterJob *)printLaterJob;

/*!
 * @abstract Removes all jobs from the print queue
 */
- (BOOL)deleteAllPrintLaterJobs;

/*!
 * @abstract Retrieves the job with the given ID
 * @param id The ID of the job to retrieve
 * @return The job with the given ID or nil if the job is not found
 */
- (HPPPPrintLaterJob *)retrievePrintLaterJobWithID:(NSString *)id;

/*!
 * @abstract Retrieves all jobs in the print queue
 * @return An array containing all print jobs currently in the queue
 */
- (NSArray *)retrieveAllPrintLaterJobs;

/*!
 * @abstract Retrieves the total number of jobs currently in the print queue
 * @return An integer representing the number of jobs
 */
- (NSInteger)retrieveNumberOfPrintLaterJobs;

@end
