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

#import "MPPrintSettings.h"

@implementation MPPrintSettings

- (NSString *)description
{
    NSString *string = [NSString stringWithFormat:@"printerUrl: %@\nprinterId: %@\nprinterName: %@\nprinterLocation: %@\nprinterModel: %@\nprinterIsAvailable: %d\npaper: %@\nsprocket: %@", self.printerUrl, self.printerId, self.printerName, self.printerLocation, self.printerModel, self.printerIsAvailable, self.paper, self.sprocketPrinter];
    
    return string;
}

@end
