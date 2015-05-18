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

@interface HPPPExampleViewController () <UIPopoverPresentationControllerDelegate, HPPPPrintDelegate, HPPPPrintDataSource, UIActionSheetDelegate>

@property (strong, nonatomic) IBOutlet UIBarButtonItem *shareBarButtonItem;
@property (strong, nonatomic) UIPopoverController *popover;
@property (weak, nonatomic) IBOutlet UIImageView *lastPrintLaterJobSavedImageView;
@property (weak, nonatomic) IBOutlet UISwitch *basicMetricsSwitch;
@property (weak, nonatomic) IBOutlet UISwitch *extendedMetricsSwitch;
@property (weak, nonatomic) IBOutlet UITextField *photoSourceTextField;
@property (weak, nonatomic) IBOutlet UITextField *userIDTextField;
@property (weak, nonatomic) IBOutlet UITextField *userNameTextField;
@property (strong, nonatomic) id printingItem;
@property (assign, nonatomic) BOOL sharingInProgress;
@property (strong, nonatomic) NSDictionary *imageFiles;
@property (strong, nonatomic) NSArray *pdfFiles;

@end

@implementation HPPPExampleViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [HPPP sharedInstance].printJobName = @"Print POD Example";
    
    [HPPP sharedInstance].initialPaperSize = Size5x7;
    [HPPP sharedInstance].defaultPaperWidth = 5.0f;
    [HPPP sharedInstance].defaultPaperHeight = 7.0f;
    [HPPP sharedInstance].zoomAndCrop = YES;
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
        
        UIImage *image4x5 = self.printingItem;
        UIImage *image4x6 = self.printingItem;
        UIImage *image5x7 = self.printingItem;
        UIImage *imageLetter = self.printingItem;
        
        printLaterJobNextAvailableId = [[HPPP sharedInstance] nextPrintJobId];
        HPPPPrintLaterJob *printLaterJob = [[HPPPPrintLaterJob alloc] init];
        printLaterJob.id = printLaterJobNextAvailableId;
        printLaterJob.name = @"Add from Share";
        printLaterJob.date = [NSDate date];
        printLaterJob.printingItems = @{[HPPPPaper titleFromSize:Size4x5] : image4x5,
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
    
    NSArray *activitiesItems = @[self.printingItem];
    
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
    self.printingItem = [self randomImage];
    [self shareItem];
}

- (IBAction)printImageTapped:(id)sender 
{
    self.sharingInProgress = NO;
    [self selectImage];
}

- (IBAction)shareImageTapped:(id)sender 
{
    self.sharingInProgress = YES;
    [self selectImage];
}

- (IBAction)printPdfTapped:(id)sender 
{
    self.sharingInProgress = NO;
    [self selectPDF];
}

- (IBAction)sharePdfTapped:(id)sender 
{
    self.sharingInProgress = YES;
    [self selectPDF];
}

- (IBAction)showPrintQueueTapped:(id)sender
{
    [[HPPP sharedInstance] presentPrintQueueFromController:self animated:YES completion:nil];
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

- (void)printingItemForPaper:(HPPPPaper *)paper withCompletion:(void (^)(id))completion
{
    if (completion) {
        completion(self.printingItem);
    }
}

- (void)previewImageForPaper:(HPPPPaper *)paper withCompletion:(void (^)(UIImage *))completion
{
    if (completion) {
        if ([[HPPP sharedInstance] printingItemAsImage:self.printingItem] ){
            completion(self.printingItem);
        } else if ([[HPPP sharedInstance] printingItemAsPdf:self.printingItem]) {
            completion([[HPPP sharedInstance] imageForPDF:self.printingItem width:8.5f height:11.0f dpi:72.0f]);
        } else {
            HPPPLogError(@"Unable to determine preview image for printing item %@", self.printingItem);
        }
    }
}

- (NSInteger)numberOfPrintingItems
{
    return 1;
}

- (NSArray *)printingItemsForPaper:(HPPPPaper *)paper
{
    return @[ self.printingItem ];
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
        UIImage *image = [self randomImage];
        HPPPPrintLaterJob *job = [[HPPPPrintLaterJob alloc] init];
        job.id = jobID;
        job.name = [NSString stringWithFormat:@"Print Job #%d", idx + 1];
        job.date = [NSDate date];

        job.printingItems = @{[HPPPPaper titleFromSize:Size4x5] : image,
                              [HPPPPaper titleFromSize:Size4x6] : image,
                              [HPPPPaper titleFromSize:Size5x7] : image,
                              [HPPPPaper titleFromSize:SizeLetter] : image};
        [[HPPP sharedInstance] addJobToQueue:job];
    }
}

- (UIImage *)randomImage
{
    int numberOfSampleImages = 10;
    int picNumber = arc4random_uniform(numberOfSampleImages) + 1;
    NSString *picName = [NSString stringWithFormat:@"sample%d.jpg", picNumber];
    UIImage *image = [UIImage imageNamed:picName];
    return image;
}

#pragma mark - Image

- (void)selectImage {
    
    NSString *title = NSLocalizedString(@"Choose an Image", nil);
    NSString *cancelButtonLabel = NSLocalizedString(@"Cancel", nil);
    
    if (NSClassFromString(@"UIAlertController") != nil) {
        UIAlertControllerStyle style = UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad ? UIAlertControllerStyleAlert : UIAlertControllerStyleActionSheet;
        
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:title message:NSLocalizedString(@"Please select a sample PDF that you would like to use.", nil) preferredStyle:style];
        
        [self.imageFiles enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
            [alertController addAction:[UIAlertAction actionWithTitle:key style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
                [self doImageActivityWithFile:obj];
            }]];
        }];
        
        [alertController addAction:[UIAlertAction actionWithTitle:cancelButtonLabel style:UIAlertActionStyleCancel handler:nil]];
        [self presentViewController:alertController animated:YES completion:nil];
    }
    else {
        UIActionSheet *actionSheet = [[UIActionSheet alloc] init];
        actionSheet.title = title;
        actionSheet.delegate = self;
        [self.imageFiles enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
            [actionSheet addButtonWithTitle:key];
        }];
        actionSheet.cancelButtonIndex = [actionSheet addButtonWithTitle:cancelButtonLabel];
        [actionSheet showInView:self.view];
    }
    
}

- (void)doImageActivityWithFile:(NSString *)file
{
    NSString *filename = [NSString stringWithFormat:@"%@.jpg", file];
    UIImage *image = [UIImage imageNamed:filename];
    self.printingItem = image;
    if (self.sharingInProgress) {
        [self shareItem];
    } else {
        UIViewController *vc = [[HPPP sharedInstance] printViewControllerWithDelegate:self dataSource:self printingItem:image previewImage:image fromQueue:NO];
        [self presentViewController:vc animated:YES completion:nil];
    }
}

#pragma mark - PDF

- (void)selectPDF {
    
    NSString *title = NSLocalizedString(@"Choose a PDF", nil);
    NSString *cancelButtonLabel = NSLocalizedString(@"Cancel", nil);
    
    if (NSClassFromString(@"UIAlertController") != nil) {
        UIAlertControllerStyle style = UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad ? UIAlertControllerStyleAlert : UIAlertControllerStyleActionSheet;
        
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:title message:NSLocalizedString(@"Please select a sample PDF that you would like to use.", nil) preferredStyle:style];
        
        for (NSString *file in self.pdfFiles) {
            [alertController addAction:[UIAlertAction actionWithTitle:file style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
                [self doPdfActivityWithFile:file];
            }]];
        }
        
        [alertController addAction:[UIAlertAction actionWithTitle:cancelButtonLabel style:UIAlertActionStyleCancel handler:nil]];
        [self presentViewController:alertController animated:YES completion:nil];
    }
    else {
        UIActionSheet *actionSheet = [[UIActionSheet alloc] init];
        actionSheet.title = title;
        actionSheet.delegate = self;
        for (NSString *file in self.pdfFiles) {
            [actionSheet addButtonWithTitle:file];
        }
        actionSheet.cancelButtonIndex = [actionSheet addButtonWithTitle:cancelButtonLabel];
        [actionSheet showInView:self.view];
    }
    
}

- (void)doPdfActivityWithFile:(NSString *)file
{
    NSString *path = [[NSBundle mainBundle] pathForResource:file ofType:@"pdf"];
    NSData *pdf = [NSData dataWithContentsOfFile:path];
    if (self.sharingInProgress) {
        self.printingItem = pdf;
        [self shareItem];
    } else {
        UIImage *preview = [[HPPP sharedInstance] imageForPDF:pdf width:8.5f height:11.0f dpi:72.0f];
        UIViewController *vc = [[HPPP sharedInstance] printViewControllerWithDelegate:self dataSource:nil printingItem:pdf previewImage:preview fromQueue:NO];
        [self presentViewController:vc animated:YES completion:nil];
    }
}

#pragma mark - UIActionSheetDelegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == actionSheet.cancelButtonIndex) {
        return;
    }
    
    NSString *file = [actionSheet buttonTitleAtIndex:buttonIndex];
    if ([actionSheet.title isEqualToString:@"Choose an Image"]) {
        [self doImageActivityWithFile:[self.imageFiles objectForKey:file]];
    } else {
        [self doPdfActivityWithFile:file];
    }
}

@end
