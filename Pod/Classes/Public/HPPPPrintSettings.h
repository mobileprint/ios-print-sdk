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
#import "HPPPPaper.h"

@interface HPPPPrintSettings : NSObject

@property (strong, nonatomic) NSURL *printerUrl;
@property (strong, nonatomic) NSString *printerId;
@property (strong, nonatomic) NSString *printerName;
@property (strong, nonatomic) NSString *printerLocation;
@property (strong, nonatomic) NSString *printerModel;
@property (assign, nonatomic) BOOL printerIsAvailable;
@property (strong, nonatomic) HPPPPaper *paper;

@end
