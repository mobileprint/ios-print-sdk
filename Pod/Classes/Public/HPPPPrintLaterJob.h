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

/*!
 * @abstract Represents a single print job
 */
@interface HPPPPrintLaterJob : NSObject <NSCoding>

@property (strong, nonatomic) NSDictionary *images; // Dictionary with UIImages (key = the paper size title, object = UIImage)

@property (strong, nonatomic) NSString *id;
@property (strong, nonatomic) NSString *name;
@property (strong, nonatomic) NSDate *date;
@property (strong, nonatomic) NSString *printerName;
@property (strong, nonatomic) NSString *printerLocation;
@property (strong, nonatomic) NSString *printerURL;
@property (strong, nonatomic) NSDictionary *extra;

@end
