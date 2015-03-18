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

#import "HPPPPrintLaterActivity.h"
#import "HPPPPrintLaterQueue.h"

@implementation HPPPPrintLaterActivity

- (NSString *)activityType
{
    return @"HPPPPrintLaterActivity";
}

- (NSString *)activityTitle
{
    return @"Print Later";
}

- (UIImage *)_activityImage
{
    return [UIImage imageNamed:@"HPPPPrint"]; //TODO Get icon for print later
}

- (BOOL)canPerformWithActivityItems:(NSArray *)activityItems
{
    return YES;
}

- (void)performActivity
{
    BOOL result = [[HPPPPrintLaterQueue sharedInstance] addPrintLaterJob:self.printLaterJob];
    [self activityDidFinish:result];
}

@end
