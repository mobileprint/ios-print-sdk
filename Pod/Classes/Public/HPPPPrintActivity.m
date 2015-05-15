
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

#import "HPPP.h"
#import "HPPPPrintActivity.h"
#import "NSBundle+HPPPLocalizable.h"

@interface HPPPPrintActivity () <HPPPPrintDelegate>

@property (strong, nonatomic) id printingItem;
@property (strong, nonatomic) UIImage *previewImage;

@end

@implementation HPPPPrintActivity

- (NSString *)activityType
{
    return @"HPPPPrintActivity";
}

- (NSString *)activityTitle
{
    return HPPPLocalizedString(@"Print", @"Activity title of the print when the share button is tapped");
}

- (UIImage *)_activityImage
{
    return [UIImage imageNamed:@"HPPPPrint"];
}

- (BOOL)canPerformWithActivityItems:(NSArray *)activityItems
{
    for (id obj in activityItems) {
        if ([[HPPP sharedInstance] printingItemAsImage:obj]) {
            self.printingItem = obj;
            self.previewImage = obj;
            break;
        } else if ([[HPPP sharedInstance] printingItemAsPdf:obj]) {
            HPPPPaper *initialPaper = [[HPPPPaper alloc] initWithPaperSize:[HPPP sharedInstance].initialPaperSize paperType:Plain];
            self.printingItem = obj;
            self.previewImage = [[HPPP sharedInstance] imageForPDF:obj width:initialPaper.width height:initialPaper.height dpi:72.0f];
            break;
        }
    }
    
    if (!self.printingItem) {
        HPPPLogInfo(@"Unable to perform print activity on any of the items in the activity item array: %@", activityItems);
    }
    
    return (nil != self.printingItem);
}


- (UIViewController *)activityViewController
{
    return [[HPPP sharedInstance] printViewControllerWithDelegate:self dataSource:self.dataSource printingItem:self.printingItem previewImage:self.previewImage fromQueue:NO];
}

#pragma mark - HPPPPrintDelegate

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
