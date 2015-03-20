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

@interface HPPPPrintLaterActivity : UIActivity

/*!
 * @abstract Provides the print later job
 * @description The client app must create the print later job and set it to the activity. The class HPPPPrintLaterQueue provides a method called retrievePrintLaterJobNextAvailableId to get an id, otherwise the client app can use their own ids.
 * @seealso HPPPPrintLaterJob, HPPPPrintLaterQueue
 */
@property (nonatomic, strong) HPPPPrintLaterJob *printLaterJob;

@end
