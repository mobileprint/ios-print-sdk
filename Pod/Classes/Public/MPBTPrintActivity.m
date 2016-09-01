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
#import "MP.h"
#import "MPBTPrintActivity.h"
#import "NSBundle+MPLocalizable.h"

@implementation MPBTPrintActivity

- (NSString *)activityType
{
    return @"MPBTPrintActivity";
}

- (NSString *)activityTitle
{
    return MPLocalizedString(@"Print", @"Activity title of the bt print when the share button is tapped");
}

- (UIImage *)_activityImage
{
    return [[MP sharedInstance].appearance.settings objectForKey:kMPActivityPrintIcon];
}

- (BOOL)canPerformWithActivityItems:(NSArray *)activityItems
{
    return YES;
}

- (void)prepareWithActivityItems:(NSArray *)activityItems
{
}

- (UIViewController *)activityViewController
{
    return nil;
}

- (void)performActivity
{
    [[MP sharedInstance] headlessBluetoothPrintFromController:self.vc image:self.image animated:YES printCompletion:nil];
    [self activityDidFinish:YES];
}

@end

