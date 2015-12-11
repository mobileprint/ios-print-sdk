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

@protocol MPPrintDelegate;
@protocol MPPrintDataSource;

@interface MPPrintManager (Options)

typedef NS_OPTIONS(NSUInteger, MPPrintManagerOptions) {
    MPPrintManagerOriginShare                    = 1 << 0,
    MPPrintManagerOriginQueue                    = 1 << 1,
    MPPrintManagerOriginCustom                   = 1 << 2,
    MPPrintManagerOriginDirect                   = 1 << 3,
    MPPrintManagerMultiJob                       = 1 << 4
};

@property (assign, nonatomic) MPPrintManagerOptions options;
@property (assign, nonatomic) NSInteger numberOfCopies;

- (void)saveLastOptionsForPrinter:(NSString *)printerID;
- (void)saveLastOptionsForPaper:(UIPrintPaper *)paper;

- (void)setOptionsForPrintDelegate:(id<MPPrintDelegate>)delegate dataSource:(id<MPPrintDataSource>)dataSource;

@end
