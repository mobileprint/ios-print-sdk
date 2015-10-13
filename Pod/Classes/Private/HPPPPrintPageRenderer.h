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
#import "HPPPLayout.h"
#import "HPPPPaper.h"

/*!
 * @abstract Renders the print image(s) onto the page
 * @seealso HPPPPageSettingsTableViewController
 */
@interface HPPPPrintPageRenderer : UIPrintPageRenderer

/*!
 * @abstract Initializes the renderer with an array of images to print
 */
- (id)initWithImages:(NSArray *)images layout:(HPPPLayout *)layout paper:(HPPPPaper *)paper copies:(NSInteger)copies;

@end
