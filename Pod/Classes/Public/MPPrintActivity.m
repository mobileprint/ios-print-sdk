
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
#import "MPPrintActivity.h"
#import "NSBundle+MPLocalizable.h"
#import "MPPrintItem.h"
#import "MPPrintItemFactory.h"

@interface MPPrintActivity () <MPPrintDelegate>

@property (strong, nonatomic) MPPrintItem *printItem;

@end

@implementation MPPrintActivity

- (NSString *)activityType
{
    return @"MPPrintActivity";
}

- (NSString *)activityTitle
{
    return MPLocalizedString(@"Print", @"Activity title of the print when the share button is tapped");
}

- (UIImage *)_activityImage
{
    return [[MP sharedInstance].appearance.settings objectForKey:kMPActivityPrintIcon];
}

- (BOOL)canPerformWithActivityItems:(NSArray *)activityItems
{
    for (id obj in activityItems) {
        if ([obj isKindOfClass:[MPPrintItem class]]) {
            self.printItem = obj;
            break;
        }
    }
    
    if (nil == self.printItem) {
        MPLogInfo(@"Unable to perform print activity on any of the items in the activity item array: %@", activityItems);
    }
    
    return (nil != self.printItem);
}


- (UIViewController *)activityViewController
{
    return [[MP sharedInstance] printViewControllerWithDelegate:self dataSource:self.dataSource printItem:self.printItem fromQueue:NO settingsOnly:NO];
}

#pragma mark - MPPrintDelegate

- (void)didFinishPrintFlow:(UIViewController *)printViewController
{
    dispatch_async(dispatch_get_main_queue(), ^ {
        [self activityDidFinish:YES];
    });
}

- (void)didCancelPrintFlow:(UIViewController *)printViewController
{
    dispatch_async(dispatch_get_main_queue(), ^ {
        [self activityDidFinish:NO];
    });
}

@end
