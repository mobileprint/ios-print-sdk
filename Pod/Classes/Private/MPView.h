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

/*!
 * @abstract Basic view class used for xib-based views
 */
@interface MPView : UIView

/*!
 * @abstract Create the view with the given xib name
 * @param xibName The name of the xib
 */
- (void)initWithXibName:(NSString *)xibName;

/*!
 * @abstract Used to retrieve the name of the xib
 * @return An NSString containing the name of the xib
 */
- (NSString *)xibName;

@end
