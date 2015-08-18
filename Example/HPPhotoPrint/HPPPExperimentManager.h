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

@interface HPPPExperimentManager : NSObject

@property (assign, nonatomic, readonly) BOOL showPrintIcon;

+ (HPPPExperimentManager *)sharedInstance;

- (void)updateVariationsWithDeviceID:(NSString *)deviceID;

@end
