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
#import <HPPPWiFiReachability.h>
#import "HPPPExampleViewController.h"
#import "HPPPWiFiReachability.h"
#import "HPPPPrintJobsTableViewController.h"

@interface HPPPExampleViewController () <UIPopoverPresentationControllerDelegate, HPPPPrintActivityDataSource>

@property (strong, nonatomic) IBOutlet UIBarButtonItem *shareBarButtonItem;
@property (strong, nonatomic) UIPopoverController *popover;
@property (weak, nonatomic) IBOutlet UIImageView *lastPrintLaterJobSavedImageView;
@property (weak, nonatomic) IBOutlet UISwitch *basicMetricsSwitch;
@property (weak, nonatomic) IBOutlet UISwitch *extendedMetricsSwitch;
@property (weak, nonatomic) IBOutlet UITextField *photoSourceTextField;
@property (weak, nonatomic) IBOutlet UITextField *userIDTextField;
@property (weak, nonatomic) IBOutlet UITextField *userNameTextField;

@end

@implementation HPPPExampleViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [HPPP sharedInstance].printJobName = @"Print POD Example";

    [HPPP sharedInstance].initialPaperSize = Size5x7;
    [HPPP sharedInstance].defaultPaperWidth = 5.0f;
    [HPPP sharedInstance].defaultPaperHeight = 7.0f;
    [HPPP sharedInstance].zoomAndCrop = NO;
    [HPPP sharedInstance].defaultPaperType = Plain;
    
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
    
    [self populatePrintQueue];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handlePrintQueueNotification:) name:kHPPPPrintQueueNotification object:nil];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (IBAction)shareBarButtonItemTap:(id)sender
{
    NSString *printLaterJobNextAvailableId = nil;
    
    [HPPP sharedInstance].handlePrintMetricsAutomatically = self.basicMetricsSwitch.on;
    
    NSString *bundlePath = [NSString stringWithFormat:@"%@/HPPhotoPrint.bundle", [NSBundle mainBundle].bundlePath];
    NSLog(@"Bundle %@", bundlePath);
    
    HPPPPrintActivity *printActivity = [[HPPPPrintActivity alloc] init];
    printActivity.dataSource = self;
    
    NSArray *applicationActivities = nil;
    if (IS_OS_8_OR_LATER) {
        HPPPPrintLaterActivity *printLaterActivity = [[HPPPPrintLaterActivity alloc] init];
        
        UIImage *image4x5 = [UIImage imageNamed:@"sample2-portrait.jpg"];
        UIImage *image4x6 = [UIImage imageNamed:@"sample2-portrait.jpg"];
        UIImage *image5x7 = [UIImage imageNamed:@"sample2-portrait.jpg"];
        UIImage *imageLetter = image4x5;

        printLaterJobNextAvailableId = [[HPPPPrintLaterQueue sharedInstance] retrievePrintLaterJobNextAvailableId];
        HPPPPrintLaterJob *printLaterJob = [[HPPPPrintLaterJob alloc] init];
        printLaterJob.id = printLaterJobNextAvailableId;
        printLaterJob.name = @"Einstein";
        printLaterJob.date = [NSDate date];
        printLaterJob.images = @{[HPPPPaper titleFromSize:Size4x5] : image4x5,
                                 [HPPPPaper titleFromSize:Size4x6] : image4x6,
                                 [HPPPPaper titleFromSize:Size5x7] : image5x7,
                                 [HPPPPaper titleFromSize:SizeLetter] : imageLetter};
        if (self.extendedMetricsSwitch.on) {
            printLaterJob.extra = [self photoSourceMetrics];
        }
        printLaterActivity.printLaterJob = printLaterJob;
        applicationActivities = @[printActivity, printLaterActivity];
    } else {
        applicationActivities = @[printActivity];
    }
    
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
            if (self.extendedMetricsSwitch.on) {
                NSMutableDictionary *metrics = [NSMutableDictionary dictionaryWithDictionary:@{ @"off_ramp":activityType }];
                [metrics addEntriesFromDictionary:[self photoSourceMetrics]];
                [[NSNotificationCenter defaultCenter] postNotificationName:kHPPPShareCompletedNotification object:self userInfo:metrics];
            }
            
            if (IS_OS_8_OR_LATER) {
                HPPPPrintLaterJob *lastPrintLaterJobSaved = [[HPPPPrintLaterQueue sharedInstance] retrievePrintLaterJobWithID:printLaterJobNextAvailableId];
                
                UIImage *image = [lastPrintLaterJobSaved.images objectForKey:@"4 x 6"];
                self.lastPrintLaterJobSavedImageView.image = image;
            }
            
            if ([activityType isEqualToString:@"HPPPPrintLaterActivity"]) {
                [HPPPPrintJobsTableViewController presentAnimated:YES usingController:self andCompletion:nil];
            }
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

- (IBAction)showPrintLaterJobsButtonTapped:(id)sender
{
    [HPPPPrintJobsTableViewController presentAnimated:YES usingController:self andCompletion:nil];
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

#pragma mark - Metrics examples

- (NSDictionary *)photoSourceMetrics
{
    return [NSDictionary dictionaryWithObjectsAndKeys:
            self.photoSourceTextField.text, @"photo_source",
            self.userIDTextField.text, @"user_id",
            self.userNameTextField.text, @"user_name", nil];
}

- (void)handlePrintQueueNotification:(NSNotification *)notification
{
    if (self.extendedMetricsSwitch.on) {
        NSArray *jobs = [notification.object objectForKey:kHPPPPrintQueueJobsKey];
        NSString *action = [notification.object objectForKey:kHPPPPrintQueueActionKey];
        for (HPPPPrintLaterJob *job in jobs) {
            NSMutableDictionary *metrics = [NSMutableDictionary dictionaryWithDictionary:@{ @"off_ramp":action }];
            [metrics addEntriesFromDictionary:job.extra];
            [[NSNotificationCenter defaultCenter] postNotificationName:kHPPPShareCompletedNotification object:self userInfo:metrics];
        }
    }
}

#pragma mark - DEBUG

- (void)populatePrintQueue
{
    [[HPPPPrintLaterQueue sharedInstance] deleteAllPrintLaterJobs];
    
    NSString *printLaterJobNextAvailableId = nil;
    HPPPPrintLaterJob *printLaterJob = nil;
    
    UIImage *image4x5 = [UIImage imageNamed:@"sample2-portrait.jpg"];
    UIImage *image4x6 = [UIImage imageNamed:@"sample2-portrait.jpg"];
    UIImage *image5x7 = [UIImage imageNamed:@"sample2-portrait.jpg"];
    UIImage *imageLetter = image4x5;

    UIImage *image4x5_2 = [UIImage imageNamed:@"sample-landscape.jpg"];
    UIImage *image4x6_2 = [UIImage imageNamed:@"sample-landscape.jpg"];
    UIImage *image5x7_2 = [UIImage imageNamed:@"sample-landscape.jpg"];
    UIImage *imageLetter_2 = image4x5_2;
    
    printLaterJobNextAvailableId = [[HPPPPrintLaterQueue sharedInstance] retrievePrintLaterJobNextAvailableId];
    printLaterJob = [[HPPPPrintLaterJob alloc] init];
    printLaterJob.id = printLaterJobNextAvailableId;
    printLaterJob.name = @"Einstein";
    printLaterJob.date = [NSDate date];
    printLaterJob.images = @{[HPPPPaper titleFromSize:Size4x5] : image4x5,
                             [HPPPPaper titleFromSize:Size4x6] : image4x6,
                             [HPPPPaper titleFromSize:Size5x7] : image5x7,
                             [HPPPPaper titleFromSize:SizeLetter] : imageLetter};
    [[HPPPPrintLaterQueue sharedInstance] addPrintLaterJob:printLaterJob];
    
    printLaterJobNextAvailableId = [[HPPPPrintLaterQueue sharedInstance] retrievePrintLaterJobNextAvailableId];
    printLaterJob = [[HPPPPrintLaterJob alloc] init];
    printLaterJob.id = printLaterJobNextAvailableId;
    printLaterJob.name = @"Dude";
    printLaterJob.date = [NSDate date];
    printLaterJob.images = @{[HPPPPaper titleFromSize:Size4x5] : image4x5_2,
                             [HPPPPaper titleFromSize:Size4x6] : image4x6_2,
                             [HPPPPaper titleFromSize:Size5x7] : image5x7_2,
                             [HPPPPaper titleFromSize:SizeLetter] : imageLetter_2};
    [[HPPPPrintLaterQueue sharedInstance] addPrintLaterJob:printLaterJob];
    
    printLaterJobNextAvailableId = [[HPPPPrintLaterQueue sharedInstance] retrievePrintLaterJobNextAvailableId];
    printLaterJob = [[HPPPPrintLaterJob alloc] init];
    printLaterJob.id = printLaterJobNextAvailableId;
    printLaterJob.name = @"Awesome";
    printLaterJob.date = [NSDate date];
    printLaterJob.images = @{[HPPPPaper titleFromSize:Size4x5] : image4x5,
                             [HPPPPaper titleFromSize:Size4x6] : image4x6,
                             [HPPPPaper titleFromSize:Size5x7] : image5x7,
                             [HPPPPaper titleFromSize:SizeLetter] : imageLetter};
    [[HPPPPrintLaterQueue sharedInstance] addPrintLaterJob:printLaterJob];
    
}

@end
