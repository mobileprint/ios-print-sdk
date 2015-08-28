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

@interface HPPPPrintManager (Options)

typedef NS_OPTIONS(NSUInteger, HPPPPrintManagerOptions) {
    HPPPPrintManagerOriginShare                    = 1 << 0,
    HPPPPrintManagerOriginQueue                    = 1 << 1,
    HPPPPrintManagerOriginCustom                   = 1 << 2,
    HPPPPrintManagerOriginDirect                   = 1 << 3,
    HPPPPrintManagerMultiJob                       = 1 << 4
};

@property (assign, nonatomic) HPPPPrintManagerOptions options;
@property (assign, nonatomic) NSInteger numberOfCopies;

- (void)saveLastOptionsForPrinter:(NSString *)printerID;

@end
