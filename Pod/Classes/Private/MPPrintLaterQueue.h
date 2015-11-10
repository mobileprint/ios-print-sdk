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
#import <UIKit/UIKit.h>
#import "MPPrintLaterJob.h"
#import "MPPageSettingsTableViewController.h"

/*!
 * @abstract Represents the list of queued print jobs
 */
@interface MPPrintLaterQueue : NSObject

extern NSString * const kMPOfframpAddToQueueShare;
extern NSString * const kMPOfframpAddToQueueCustom;
extern NSString * const kMPOfframpAddToQueueDirect;
extern NSString * const kMPOfframpDeleteFromQueue;

/*!
 * @abstract Used to access the singleton instance of this class
 */
+ (MPPrintLaterQueue *)sharedInstance;

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
- (BOOL)addPrintLaterJob:(MPPrintLaterJob *)printLaterJob fromController:(MPPageSettingsTableViewController *)controller;

/*!
 * @abstract Removes a job to the print queue
 * @param printLaterJob The job to remove
 */
- (BOOL)deletePrintLaterJob:(MPPrintLaterJob *)printLaterJob;

/*!
 * @abstract Removes all jobs from the print queue
 */
- (BOOL)deleteAllPrintLaterJobs;

/*!
 * @abstract Retrieves the job with the given ID
 * @param id The ID of the job to retrieve
 * @return The job with the given ID or nil if the job is not found
 */
- (MPPrintLaterJob *)retrievePrintLaterJobWithID:(NSString *)id;

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
