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

#import <HPPP.h>
#import "HPPPExampleViewController.h"

@interface HPPPExampleViewController () <UIPopoverPresentationControllerDelegate, HPPPPrintActivityDataSource>

@property (strong, nonatomic) IBOutlet UIBarButtonItem *shareBarButtonItem;
@property (strong, nonatomic) UIPopoverController *popover;

@end

@implementation HPPPExampleViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [HPPP sharedInstance].initialPaperSize = Size5x7;
    [HPPP sharedInstance].defaultPaperWidth = 5.0f;
    [HPPP sharedInstance].defaultPaperHeight = 7.0f;
    [HPPP sharedInstance].zoomAndCrop = NO;
    [HPPP sharedInstance].defaultPaperType = Plain;
    
    [HPPP sharedInstance].tableViewCellLinkLabelColor = [UIColor colorWithRed:0x00 / 255.0f green:0x96 / 255.0f blue:0xD6 / 255.0f alpha:1.0f];

    [HPPP sharedInstance].tableViewFooterWarningLabelFont = [UIFont fontWithName:@"Helvetica Neue" size:12];
    [HPPP sharedInstance].tableViewFooterWarningLabelColor = [UIColor colorWithRed:0x33 / 255.0f green:0x33 / 255.0f blue:0x33 / 255.0f alpha:1.0f];
    
    [HPPP sharedInstance].tableViewCellPrintLabelFont = [UIFont fontWithName:@"Helvetica Neue" size:18];
    [HPPP sharedInstance].tableViewCellPrintLabelColor = [UIColor colorWithRed:0x00 / 255.0f green:0x96 / 255.0f blue:0xD6 / 255.0f alpha:1.0f];

    [HPPP sharedInstance].tableViewCellLabelFont = [UIFont fontWithName:@"Helvetica Neue" size:16];
    [HPPP sharedInstance].tableViewCellLabelColor = [UIColor colorWithRed:0x33 / 255.0f green:0x33 / 255.0f blue:0x33 / 255.0f alpha:1.0f];

    [HPPP sharedInstance].tableViewCellValueFont = [UIFont fontWithName:@"Helvetica Neue" size:12];
    [HPPP sharedInstance].tableViewCellValueColor = [UIColor colorWithRed:0x86 / 255.0f green:0x86 / 255.0f blue:0x86 / 255.0f alpha:1.0f];
    
    [HPPP sharedInstance].rulesLabelFont = [UIFont fontWithName:@"Helvetica Neue" size:10];
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    UINavigationController *navigationController = (UINavigationController *)[storyboard instantiateViewControllerWithIdentifier:@"PrintInstructions"];
    
    HPPPSupportAction *action1 = [[HPPPSupportAction alloc] initWithIcon:[UIImage imageNamed:@"print-instructions"] title:@"Print Instructions" url:[NSURL URLWithString:@"http://hp.com"]];
    HPPPSupportAction *action2 = [[HPPPSupportAction alloc] initWithIcon:[UIImage imageNamed:@"print-instructions"] title:@"Print Instructions VC" viewController:navigationController];
    
    [HPPP sharedInstance].supportActions =  @[action1, action2];
    
    [HPPP sharedInstance].paperSizes = @[
                                         [HPPPPaper titleFromSize:Size4x5],
                                         [HPPPPaper titleFromSize:Size4x6],
                                         [HPPPPaper titleFromSize:Size5x7],
                                         [HPPPPaper titleFromSize:SizeLetter]
                                         ];
}

- (IBAction)shareBarButtonItemTap:(id)sender
{
    NSString *bundlePath = [NSString stringWithFormat:@"%@/HPPhotoPrint.bundle", [NSBundle mainBundle].bundlePath];
    NSLog(@"Bundle %@", bundlePath);
    
    HPPPPrintActivity *printActivity = [[HPPPPrintActivity alloc] init];
    printActivity.dataSource = self;
    
    NSArray *applicationActivities = @[printActivity];
    
    UIImage *card = [UIImage imageNamed:@"sample-portrait.jpg"];
    NSArray *activitiesItems = @[card];
    
    UIActivityViewController *activityViewController = [[UIActivityViewController alloc] initWithActivityItems:activitiesItems applicationActivities:applicationActivities];
    
    [activityViewController setValue:@"My HP Greeting Card" forKey:@"subject"];
    
    activityViewController.excludedActivityTypes = @[UIActivityTypeCopyToPasteboard,
                                                     UIActivityTypeSaveToCameraRoll,
                                                     UIActivityTypePostToWeibo,
                                                     UIActivityTypePostToTencentWeibo,
                                                     UIActivityTypeAddToReadingList,
                                                     UIActivityTypePrint,
                                                     UIActivityTypeAssignToContact,
                                                     UIActivityTypePostToVimeo];
    
    activityViewController.completionHandler = ^(NSString *activityType, BOOL completed) {
        NSLog(@"completed dialog - activity: %@ - finished flag: %d", activityType, completed);
        if (completed) {
            NSLog(@"completionHandler - Succeed");
            HPPP *hppp = [HPPP sharedInstance];
            NSLog(@"Paper Size used: %@", [hppp.lastOptionsUsed valueForKey:kHPPPPaperSizeId]);
            
        } else {
            NSLog(@"completionHandler - didn't succeed.");
        }
    };
    
    if (IS_IPAD && !IS_OS_8_OR_LATER) {
        self.popover = [[UIPopoverController alloc] initWithContentViewController:activityViewController];
        [self.popover presentPopoverFromBarButtonItem:self.shareBarButtonItem permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
    } else {
        if (IS_OS_8_OR_LATER) {
            activityViewController.popoverPresentationController.barButtonItem = self.shareBarButtonItem;
            activityViewController.popoverPresentationController.delegate = self;
        }
        
        [self presentViewController:activityViewController animated:YES completion:nil];
    }
    
}

#pragma mark - HPPPPrintActivityDataSource

- (void)printActivityRequestImageForPaper:(HPPPPaper *)paper withCompletion:(void (^)(UIImage *))completion
{
    if (completion) {
        completion([UIImage imageNamed:@"sample2-portrait.jpg"]);
    }
}

#pragma mark - UIPopoverPresentationControllerDelegate

// NOTE: The implementation of this delegate with the default value is a workaround to compensate an error in the new popover presentation controller of the SDK 8. This fix correct the case where if the user keep tapping repeatedly the share button in an iPad iOS 8, the app goes back to the first screen.
- (BOOL)popoverPresentationControllerShouldDismissPopover:(UIPopoverPresentationController *)popoverPresentationController
{
    return YES;
}

@end
