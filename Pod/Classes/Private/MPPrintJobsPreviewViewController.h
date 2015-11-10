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

#import <UIKit/UIKit.h>
#import "MPPrintLaterJob.h"
#import "MPLayout.h"

/*!
 * @abstract Controller that manages the preview view of a given print job
 */
@interface MPPrintJobsPreviewViewController : UIViewController

@property (strong, nonatomic) MPPrintLaterJob *printLaterJob;

- (NSString *)dismissalNotificationName;

@end
