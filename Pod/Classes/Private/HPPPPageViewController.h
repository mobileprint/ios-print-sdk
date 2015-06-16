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
#import "HPPPPageView.h"
#import "HPPPMultiPageView.h"

/*!
 * @abstract Controls the graphical preview portion of the print preview
 */
@interface HPPPPageViewController : UIViewController

/*!
 * @abstract The HPPPPageView that this controller owns
 */
@property (weak, nonatomic) IBOutlet HPPPPageView *pageView;
@property (weak, nonatomic) IBOutlet HPPPMultiPageView *multiPageView;

/*!
 * @abstract The actual data to be printed (e.g. image, PDF, etc.)
 */
@property (strong, nonatomic) HPPPPrintItem *printItem;

@end