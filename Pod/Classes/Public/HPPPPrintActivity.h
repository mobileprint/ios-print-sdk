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

#import <UIKit/UIKit.h>
#import "HPPPPaper.h"

@protocol HPPPPrintActivityDataSource;

/*!
 * @abstract The activity class that implements the print sharing activity
 * @description This class subclasses UIActivity to provide a custom print sharing activity. This includes print preview, page settings, and interacting with the iOS AirPrint system.
 */
@interface HPPPPrintActivity : UIActivity

/*!
 * @abstract Provides the printable image asset
 * @description The data source is used to provide an image to use for printing. A new image is requested when the sharing activity view is shown.
 * @seealso HPPPPrintActivityDataSource
 */
@property (nonatomic, weak) id<HPPPPrintActivityDataSource> dataSource;

@end

/*!
 * @abstract Defines a data source protocal for requesting the printable image
 */
@protocol HPPPPrintActivityDataSource <NSObject>

/*!
 * @abstract Called when a new printable image is needed
 * @description This method is called when initiating the print flow or whenever relevant parameters are changed (e.g. page size).
 * @param paper The HPPPPaper object that the image will be laid out on
 * @returns UIImage object for the printable image
 * @seealso HPPPaper
 */
- (UIImage *)printActivityRequestImageForPaper:(HPPPPaper *)paper;

@end