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

#import <stdlib.h>
#import <HPPP.h>
#import <HPPPPrintLaterHelperViewController.h>
#import "HPPPExampleViewController.h"
#import "HPPPPrintItem.h"
#import "HPPPPrintItemFactory.h"
#import "HPPPSelectPrintItemTableViewController.h"
#import "HPPPLayoutFactory.h"

@interface HPPPExampleViewController () <UIPopoverPresentationControllerDelegate, HPPPPrintDelegate, HPPPPrintDataSource, HPPPSelectPrintItemTableViewControllerDelegate>

@property (strong, nonatomic) IBOutlet UIBarButtonItem *shareBarButtonItem;
@property (strong, nonatomic) UIPopoverController *popover;
@property (weak, nonatomic) IBOutlet UIImageView *lastPrintLaterJobSavedImageView;
@property (weak, nonatomic) IBOutlet UISwitch *basicMetricsSwitch;
@property (weak, nonatomic) IBOutlet UISwitch *extendedMetricsSwitch;
@property (weak, nonatomic) IBOutlet UITextField *photoSourceTextField;
@property (weak, nonatomic) IBOutlet UITextField *userIDTextField;
@property (weak, nonatomic) IBOutlet UITextField *userNameTextField;
@property (strong, nonatomic) HPPPPrintItem *printItem;
@property (assign, nonatomic) BOOL sharingInProgress;
@property (strong, nonatomic) NSDictionary *imageFiles;
@property (strong, nonatomic) NSArray *pdfFiles;

@end

@implementation HPPPExampleViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [HPPP sharedInstance].printJobName = @"Print POD Example";
    
    [HPPP sharedInstance].defaultPaper = [[HPPPPaper alloc] initWithPaperSize:Size5x7 paperType:Photo];
    [HPPP sharedInstance].zoomAndCrop = YES;
    
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
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(printJobAddedNotification:) name:kHPPPPrintJobAddedToQueueNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handlePrintQueueNotification:) name:kHPPPPrintQueueNotification object:nil];
    
    [self populatePrintQueue];
    
    self.imageFiles = @{
                        @"Green Path":@"sample1",
                        @"Flowers":@"sample2",
                        @"Cat":@"sample6",
                        @"Dog":@"sample7",
                        @"Quality":@"sample5",
                        @"Soccer":@"sample3",
                        @"Universe":@"sample8"
                        };
    
    self.pdfFiles = @[
                      @"1 Page",
                      @"1 Page (landscape)",
                      @"2 Pages",
                      @"4 Pages",
                      @"6 Pages (landscape)",
                      @"10 Pages"
                      ];
    
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - Sharing

- (void)shareItem
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
        printLaterJobNextAvailableId = [[HPPP sharedInstance] nextPrintJobId];
        HPPPPrintLaterJob *printLaterJob = [[HPPPPrintLaterJob alloc] init];
        printLaterJob.id = printLaterJobNextAvailableId;
        printLaterJob.name = @"Add from Share";
        printLaterJob.date = [NSDate date];
        printLaterJob.printItems = @{[HPPPPaper titleFromSize:Size4x5] : self.printItem,
                                        [HPPPPaper titleFromSize:Size4x6] : self.printItem,
                                        [HPPPPaper titleFromSize:Size5x7] : self.printItem,
                                        [HPPPPaper titleFromSize:SizeLetter] : self.printItem};
        if (self.extendedMetricsSwitch.on) {
            printLaterJob.extra = [self photoSourceMetrics];
        }
        printLaterActivity.printLaterJob = printLaterJob;
        applicationActivities = @[printActivity, printLaterActivity];
    } else {
        applicationActivities = @[printActivity];
    }
    
    NSArray *activitiesItems = @[self.printItem];
    
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
            
            if ([activityType isEqualToString:@"HPPPPrintLaterActivity"]) {
                [[HPPP sharedInstance] presentPrintQueueFromController:self animated:YES completion:nil];
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

#pragma mark - Button actions

- (IBAction)showPrintLaterHelperTapped:(id)sender
{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"HPPP" bundle:[NSBundle mainBundle]];
    
    UINavigationController *nc = (UINavigationController *)[storyboard instantiateViewControllerWithIdentifier:@"HPPPPrintLaterHelperNavigationController"];
    
    [self presentViewController:nc animated:YES completion:nil];
}

- (IBAction)shareBarButtonItemTap:(id)sender
{
    self.printItem = [HPPPPrintItemFactory printItemWithAsset:[self randomImage]];
    [self shareItem];
}

- (IBAction)showPrintQueueTapped:(id)sender
{
    [[HPPP sharedInstance] presentPrintQueueFromController:self animated:YES completion:nil];
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"Print Item"] || [segue.identifier isEqualToString:@"Share Item"]) {
        NSString *title = @"Print Item";
        self.sharingInProgress = NO;
        if ([segue.identifier isEqualToString:@"Share Item"]) {
            title = @"Share Item";
            self.sharingInProgress = YES;
        }
        UINavigationController *navController = (UINavigationController *)segue.destinationViewController;
        HPPPSelectPrintItemTableViewController *vc = (HPPPSelectPrintItemTableViewController *)navController.topViewController;
        vc.delegate = self;
        vc.navigationItem.title = title;
    }
}

#pragma mark - HPPPPrintDelegate

- (void)didFinishPrintFlow:(UIViewController *)printViewController;
{
    [printViewController dismissViewControllerAnimated:YES completion:nil];
}

- (void)didCancelPrintFlow:(UIViewController *)printViewController;
{
    [printViewController dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - HPPPPrintDataSource

- (void)printingItemForPaper:(HPPPPaper *)paper withCompletion:(void (^)(HPPPPrintItem *))completion
{
    if (completion) {
        self.printItem.layout = [self layoutForPaper:paper];
        completion(self.printItem);
    }
}

- (void)previewImageForPaper:(HPPPPaper *)paper withCompletion:(void (^)(UIImage *))completion
{
    if (completion) {
        UIImage *image = [self.printItem previewImageForPaper:paper];
        if (image) {
            completion(image);
        } else {
            HPPPLogError(@"Unable to determine preview image for printing item %@", self.printItem);
        }
    }
}

- (NSInteger)numberOfPrintingItems
{
    return 1;
}

- (NSArray *)printingItemsForPaper:(HPPPPaper *)paper
{
    self.printItem.layout = [self layoutForPaper:paper];
    return @[ self.printItem ];
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

#pragma mark - Adding and removing jobs

- (void)printJobAddedNotification:(NSNotification *)notification
{
    HPPPPrintLaterJob *job = (HPPPPrintLaterJob *)notification.object;
    dispatch_async(dispatch_get_main_queue(), ^{
        self.lastPrintLaterJobSavedImageView.image = [job previewImage];
    });
}

#pragma mark - Print queue

- (void)populatePrintQueue
{
    [[HPPP sharedInstance] clearQueue];
    
    int jobCount = 5;
    
    for (int idx = 0; idx < jobCount; idx++) {
        
        NSString *jobID = [[HPPP sharedInstance] nextPrintJobId];
        HPPPPrintItem *printItem = [HPPPPrintItemFactory printItemWithAsset:[self randomImage]];
        HPPPPrintLaterJob *job = [[HPPPPrintLaterJob alloc] init];
        job.id = jobID;
        job.name = [NSString stringWithFormat:@"Print Job #%d", idx + 1];
        job.date = [NSDate date];
        job.printItems = @{[HPPPPaper titleFromSize:Size4x5] : printItem,
                              [HPPPPaper titleFromSize:Size4x6] : printItem,
                              [HPPPPaper titleFromSize:Size5x7] : printItem,
                              [HPPPPaper titleFromSize:SizeLetter] : printItem};
        [[HPPP sharedInstance] addJobToQueue:job];
    }
}

- (UIImage *)randomImage
{
    NSArray *sampleImages = @[
                              @"Baloons",
                              @"Cat",
                              @"Dog",
                              @"Earth",
                              @"Flowers",
                              @"Focus on Quality",
                              @"Galaxy",
                              @"Garden Path",
                              @"Quality Seal",
                              @"Soccer Ball"
                              ];
    int picNumber = arc4random_uniform((unsigned int)sampleImages.count);
    NSString *picName = [NSString stringWithFormat:@"%@.jpg", [sampleImages objectAtIndex:picNumber]];
    UIImage *image = [UIImage imageNamed:picName];
    return image;
}

#pragma mark - HPPPSelectPrintItemTableViewControllerDelegate

- (void)didSelectPrintItem:(HPPPPrintItem *)printItem
{
    [self doActivityWithPrintItem:printItem];
}

#pragma mark - Activity

- (void)doActivityWithPrintItem:(HPPPPrintItem *)printItem
{
    self.printItem = printItem;
    if (self.sharingInProgress) {
        [self shareItem];
    } else {
        UIViewController *vc = [[HPPP sharedInstance] printViewControllerWithDelegate:self dataSource:self printItem:printItem fromQueue:NO];
        [self presentViewController:vc animated:YES completion:nil];
    }
}

#pragma mark - Layout

- (HPPPLayout *)layoutForPaper:(HPPPPaper *)paper
{
    HPPPLayout *layout = [HPPPLayoutFactory layoutWithType:HPPPLayoutTypeFit];
    if (SizeLetter == paper.paperSize) {
        HPPPPaper *letterPaper = [[HPPPPaper alloc] initWithPaperSize:SizeLetter paperType:Plain];
        HPPPPaper *defaultPaper = [HPPP sharedInstance].defaultPaper;
        CGFloat width = defaultPaper.width / letterPaper.width * 100.0f;
        CGFloat height = defaultPaper.height / letterPaper.height * 100.0f;
        CGFloat x = (100.0f - width) / 2.0f;
        CGFloat y = (100.0f - height) / 2.0f;
        layout = [HPPPLayoutFactory layoutWithType:HPPPLayoutTypeFit orientation:HPPPLayoutOrientationPortrait assetPosition:CGRectMake(x, y, width, height)];
    }
    return layout;
}

@end
