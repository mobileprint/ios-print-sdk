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

@protocol MPPrintDataSource;

/*!
 * @abstract The activity class that implements the print sharing activity
 * @discussion This class subclasses UIActivity to provide a custom print sharing activity. This includes print preview, page settings, and interacting with the iOS AirPrint system.
 */
@interface MPPrintActivity : UIActivity

/*!
 * @abstract Storess the print data source to be used during the activity
 * @discussion Set this property to an object implementing the MPPrintDataSource protocol. This will be used to provide custom images for each paper size.
 */
@property (weak, nonatomic) id<MPPrintDataSource>dataSource;

@end
