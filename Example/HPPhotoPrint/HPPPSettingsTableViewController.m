//
//  HPPPSettingsViewControllerTableViewController.m
//  HPPhotoPrint
//
//  Created by James Trask on 7/7/15.
//  Copyright (c) 2015 James. All rights reserved.
//

#import "HPPPSettingsTableViewController.h"
#import "HPPPSelectPrintItemTableViewController.h"
#import <HPPP.h>
#import <HPPPLayoutFactory.h>
#import <HPPPPrintItemFactory.h>
#import <HPPPPrintManager.h>

@interface HPPPSettingsTableViewController () <UIPopoverPresentationControllerDelegate, HPPPPrintDelegate, HPPPPrintDataSource, HPPPSelectPrintItemTableViewControllerDelegate>

@property (strong, nonatomic) UIBarButtonItem *shareBarButtonItem;
@property (strong, nonatomic) UIPopoverController *popover;
@property (strong, nonatomic) HPPPPrintItem *printItem;
@property (strong, nonatomic) HPPPPrintLaterJob *printLaterJob;
@property (assign, nonatomic) BOOL sharingInProgress;
@property (assign, nonatomic) BOOL directPrintInProgress;
@property (strong, nonatomic) NSDictionary *imageFiles;
@property (strong, nonatomic) NSArray *pdfFiles;
@property (weak, nonatomic) IBOutlet UISwitch *automaticMetricsSwitch;
@property (weak, nonatomic) IBOutlet UISwitch *extendedMetricsSwitch;
@property (weak, nonatomic) IBOutlet UISegmentedControl *layoutSegmentControl;
@property (weak, nonatomic) IBOutlet UISegmentedControl *orientationSegmentControl;
@property (strong, nonatomic) IBOutletCollection(UITextField) NSArray *positionTextField;
@property (weak, nonatomic) IBOutlet UITableViewCell *showPrintQueueCell;
@property (weak, nonatomic) IBOutlet UITableViewCell *showGeoHelperCell;
@property (weak, nonatomic) IBOutlet UISegmentedControl *metricsSegmentControl;
@property (weak, nonatomic) IBOutlet UITableViewCell *automaticMetricsCell;
@property (weak, nonatomic) IBOutlet UITableViewCell *extendedMetricsCell;

@end

@implementation HPPPSettingsTableViewController

int const kLayoutDefaultIndex = 0;
int const kLayoutFitIndex = 1;
int const kLayoutFillIndex = 2;
int const kLayoutStretchIndex = 3;

int const kOrientationBest = 0;
int const kOrientationPortrait = 1;
int const kOrientationLandscape = 2;

int const kMetricsSegmentHPIndex = 0;
int const kMetricsSegmentPartnerIndex = 1;
int const kMetricsSegmentNoneIndex = 2;
int const kMetricsSegmentErrorIndex = 3;

NSString * const kMetricsOfframpKey = @"off_ramp";
NSString * const kMetricsAppTypeKey = @"app_type";
NSString * const kMetricsAppTypeHP = @"HP";

#pragma mark - Initialization

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self configureHPPP];
    
    self.shareBarButtonItem = [[UIBarButtonItem alloc]
                                    initWithBarButtonSystemItem:UIBarButtonSystemItemAction
                                    target:self
                                    action:@selector(shareTapped:)];
    self.navigationItem.rightBarButtonItem = self.shareBarButtonItem;
}

- (void)configureHPPP
{
    [HPPP sharedInstance].printJobName = @"Print POD Example";
    
    [HPPP sharedInstance].defaultPaper = [[HPPPPaper alloc] initWithPaperSize:Size5x7 paperType:Photo];
    
    [HPPP sharedInstance].handlePrintMetricsAutomatically = NO;
    
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
    
    [HPPP sharedInstance].interfaceOptions.multiPageMaximumGutter = 0;
    [HPPP sharedInstance].interfaceOptions.multiPageBleed = 40;
    [HPPP sharedInstance].interfaceOptions.multiPageBackgroundPageScale = 0.61803399;
    [HPPP sharedInstance].interfaceOptions.multiPageDoubleTapEnabled = YES;
    [HPPP sharedInstance].interfaceOptions.multiPageZoomOnSingleTap = NO;
    [HPPP sharedInstance].interfaceOptions.multiPageZoomOnDoubleTap = YES;
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"Select Print Item"] ||
        [segue.identifier isEqualToString:@"Select Share Item"] ||
        [segue.identifier isEqualToString:@"Select Direct Print Item"] ) {
        NSString *title = @"Print Item";
        self.sharingInProgress = NO;
        self.directPrintInProgress = NO;
        if ([segue.identifier isEqualToString:@"Select Share Item"]) {
            title = @"Share Item";
            self.sharingInProgress = YES;
        } else if ([segue.identifier isEqualToString:@"Select Direct Print Item"]) {
            title = @"Direct Print Item";
            self.directPrintInProgress = YES;
        }
        
        UINavigationController *navController = (UINavigationController *)segue.destinationViewController;
        HPPPSelectPrintItemTableViewController *vc = (HPPPSelectPrintItemTableViewController *)navController.topViewController;
        vc.delegate = self;
        vc.navigationItem.title = title;
    }
}

#pragma mark - Sharing

- (void)shareTapped:(id)sender
{
    self.sharingInProgress = YES;
    self.directPrintInProgress = NO;
    [self doActivityWithPrintItem:[HPPPPrintItemFactory printItemWithAsset:[self randomImage]]];
}

- (void)shareItem
{
    NSString *printLaterJobNextAvailableId = nil;
    
    NSString *bundlePath = [NSString stringWithFormat:@"%@/HPPhotoPrint.bundle", [NSBundle mainBundle].bundlePath];
    NSLog(@"Bundle %@", bundlePath);
    
    HPPPPrintActivity *printActivity = [[HPPPPrintActivity alloc] init];
    printActivity.dataSource = self;
    
    NSArray *applicationActivities = nil;
    if (IS_OS_8_OR_LATER) {
        HPPPPrintLaterActivity *printLaterActivity = [[HPPPPrintLaterActivity alloc] init];
        printLaterJobNextAvailableId = [[HPPP sharedInstance] nextPrintJobId];
        self.printLaterJob = [[HPPPPrintLaterJob alloc] init];
        self.printLaterJob.id = printLaterJobNextAvailableId;
        self.printLaterJob.name = @"Add from Share";
        self.printLaterJob.date = [NSDate date];
        self.printLaterJob.printItems = [self printItemsForAsset:self.printItem.printAsset];
        if (self.extendedMetricsSwitch.on) {
            NSMutableDictionary *metrics = [NSMutableDictionary dictionaryWithDictionary:@{ kMetricsAppTypeKey:kMetricsAppTypeHP }];
            [metrics addEntriesFromDictionary:[self photoSourceMetrics]];
            self.printLaterJob.extra = metrics;
        }
        printLaterActivity.printLaterJob = self.printLaterJob;
        applicationActivities = @[printActivity, printLaterActivity];
    } else {
        applicationActivities = @[printActivity];
    }
    
    NSArray *activitiesItems = @[self.printItem, self.printItem.printAsset];
    
    UIActivityViewController *activityViewController = [[UIActivityViewController alloc] initWithActivityItems:activitiesItems applicationActivities:applicationActivities];
    
    [activityViewController setValue:@"My HP Greeting Card" forKey:@"subject"];
    
    activityViewController.excludedActivityTypes = @[UIActivityTypeCopyToPasteboard,
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
                NSMutableDictionary *metrics = [NSMutableDictionary dictionaryWithDictionary:@{ kMetricsOfframpKey:activityType, kMetricsAppTypeKey:kMetricsAppTypeHP }];
                [metrics addEntriesFromDictionary:[self photoSourceMetrics]];
                if( [activityType isEqualToString:[[HPPPPrintLaterActivity alloc] init].activityType] ) {
                    [[NSNotificationCenter defaultCenter] postNotificationName:kHPPPShareCompletedNotification object:self.printLaterJob userInfo:metrics];
                } else {
                    [[NSNotificationCenter defaultCenter] postNotificationName:kHPPPShareCompletedNotification object:self.printItem userInfo:metrics];
                }
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

#pragma mark - HPPPPrintDelegate

- (void)didFinishPrintFlow:(UIViewController *)printViewController;
{
    [printViewController dismissViewControllerAnimated:YES completion:nil];
    if (self.extendedMetricsSwitch.on) {
        NSMutableDictionary *metrics = [NSMutableDictionary dictionaryWithDictionary:@{ kMetricsOfframpKey:NSStringFromClass([HPPPPrintActivity class]), kMetricsAppTypeKey:kMetricsAppTypeHP }];
        [metrics addEntriesFromDictionary:[self photoSourceMetrics]];
        [[NSNotificationCenter defaultCenter] postNotificationName:kHPPPShareCompletedNotification object:self.printItem userInfo:metrics];
    }
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
            NSLog(@"Unable to determine preview image for printing item %@", self.printItem);
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

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (!IS_OS_8_OR_LATER && (cell == self.showPrintQueueCell || cell == self.showGeoHelperCell)) {
        cell.alpha = 0.5;
        cell.userInteractionEnabled = NO;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *selectedCell = [tableView cellForRowAtIndexPath:indexPath];
    if (selectedCell == self.showPrintQueueCell) {
        [self showPrintQueue];
    } else if (selectedCell == self.showGeoHelperCell) {
        [self showGeoHelper];
    } else if (selectedCell == self.automaticMetricsCell) {
        [self toggleMetricsSwitch:self.automaticMetricsSwitch];
    } else if (selectedCell == self.extendedMetricsCell) {
        [self toggleMetricsSwitch:self.extendedMetricsSwitch];
    }
}

#pragma mark - Metrics

- (IBAction)metricsSegmentChanged:(id)sender {
    [self setSwitchesFromSegment];
}

- (IBAction)automaticMetricsChanged:(id)sender {
    [self setSegmentFromSwitches];
}

- (IBAction)extendedMetricsChanged:(id)sender {
    [self setSegmentFromSwitches];
}

- (void)toggleMetricsSwitch:(UISwitch *)metricsSwitch
{
    [metricsSwitch setOn:!metricsSwitch.on animated:true];
    [self setSegmentFromSwitches];
}

- (void)setSwitchesFromSegment
{
    BOOL automated = NO;
    BOOL extended = NO;
    
    if (kMetricsSegmentHPIndex == self.metricsSegmentControl.selectedSegmentIndex) {
        extended = YES;
    } else if (kMetricsSegmentPartnerIndex == self.metricsSegmentControl.selectedSegmentIndex) {
        automated = YES;
    } else if (kMetricsSegmentErrorIndex == self.metricsSegmentControl.selectedSegmentIndex) {
        automated = YES;
        extended = YES;
    }
    
    [self.automaticMetricsSwitch setOn:automated animated:YES];
    [self.extendedMetricsSwitch setOn:extended animated:YES];
    [HPPP sharedInstance].handlePrintMetricsAutomatically = self.automaticMetricsSwitch.on;
}

- (void)setSegmentFromSwitches
{
    if (!self.automaticMetricsSwitch.on && self.extendedMetricsSwitch.on) {
        self.metricsSegmentControl.selectedSegmentIndex = kMetricsSegmentHPIndex;
    } else if (self.automaticMetricsSwitch.on && !self.extendedMetricsSwitch.on) {
        self.metricsSegmentControl.selectedSegmentIndex = kMetricsSegmentPartnerIndex;
    } else if (!self.automaticMetricsSwitch.on && !self.extendedMetricsSwitch.on) {
        self.metricsSegmentControl.selectedSegmentIndex = kMetricsSegmentNoneIndex;
    } else if (self.automaticMetricsSwitch.on && self.extendedMetricsSwitch.on){
        self.metricsSegmentControl.selectedSegmentIndex = kMetricsSegmentErrorIndex;
    }
    
    [HPPP sharedInstance].handlePrintMetricsAutomatically = self.automaticMetricsSwitch.on;
}

- (NSDictionary *)photoSourceMetrics
{
    return [NSDictionary dictionaryWithObjectsAndKeys:
            @"facebook", @"photo_source",
            @"1234567890", @"user_id",
            @"Samply McSampleson", @"user_name", nil];
}

- (void)handlePrintQueueNotification:(NSNotification *)notification
{
    if (self.extendedMetricsSwitch.on) {
        NSString *action = [notification.object objectForKey:kHPPPPrintQueueActionKey];
        HPPPPrintLaterJob *job = [notification.object objectForKey:kHPPPPrintQueueJobKey];
        HPPPPrintItem *printItem = [notification.object objectForKey:kHPPPPrintQueuePrintItemKey];
        NSMutableDictionary *metrics = [NSMutableDictionary dictionaryWithDictionary:@{ kMetricsOfframpKey:action, kMetricsAppTypeKey:kMetricsAppTypeHP }];
        [metrics addEntriesFromDictionary:job.extra];
        [[NSNotificationCenter defaultCenter] postNotificationName:kHPPPShareCompletedNotification object:printItem userInfo:metrics];
    }
}

#pragma mark - Print Queue

- (void)showPrintQueue
{
    [[HPPP sharedInstance] presentPrintQueueFromController:self animated:YES completion:nil];
}

- (void)populatePrintQueue
{
    [[HPPP sharedInstance] clearQueue];
    
    int jobCount = 5;
    
    for (int idx = 0; idx < jobCount; idx++) {
        
        NSString *jobID = [[HPPP sharedInstance] nextPrintJobId];
        
        HPPPPrintLaterJob *job = [[HPPPPrintLaterJob alloc] init];
        job.id = jobID;
        job.name = [NSString stringWithFormat:@"Print Job #%d", idx + 1];
        job.date = [NSDate date];
        job.printItems = [self printItemsForAsset:[self randomImage]];
        
        [[HPPP sharedInstance] addJobToQueue:job];
    }
}

- (UIImage *)randomImage
{
    NSArray *sampleImages = @[
                              @"Balloons",
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

#pragma mark - Geo Helper

- (void)showGeoHelper
{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"HPPP" bundle:[NSBundle mainBundle]];
    UINavigationController *nc = (UINavigationController *)[storyboard instantiateViewControllerWithIdentifier:@"HPPPPrintLaterHelperNavigationController"];
    [self presentViewController:nc animated:YES completion:nil];
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
    } else if (self.directPrintInProgress) {
        HPPPPrintManager *printManager = [[HPPPPrintManager alloc] init];
        
        if( printManager.currentPrintSettings.paper ) {
            printItem.layout = [self layoutForPaper:printManager.currentPrintSettings.paper];
        }
        
        NSError *error;
        [printManager directPrint:printItem
                            color:TRUE
                        pageRange:nil
                        numCopies:1
                            error:&error];
        
        if (HPPPPrintManagerErrorNone != error.code) {
            NSLog(@"Print failed with error: %@", error);
        }
    } else {
        UIViewController *vc = [[HPPP sharedInstance] printViewControllerWithDelegate:self dataSource:self printItem:printItem fromQueue:NO];
        [self presentViewController:vc animated:YES completion:nil];
    }
}

#pragma mark - Layout

- (HPPPLayout *)layoutForPaper:(HPPPPaper *)paper
{
    HPPPLayout *layout = [HPPPLayoutFactory layoutWithType:HPPPLayoutTypeFit];
    if (DefaultPrintRenderer != self.printItem.renderer) {
        BOOL defaultLetter = (kLayoutDefaultIndex == self.layoutSegmentControl.selectedSegmentIndex && SizeLetter == paper.paperSize);
        
        HPPPLayoutOrientation orientation = HPPPLayoutOrientationBestFit;
        if (defaultLetter || kOrientationPortrait == self.orientationSegmentControl.selectedSegmentIndex) {
            orientation = HPPPLayoutOrientationPortrait;
        } else if (kOrientationLandscape == self.orientationSegmentControl.selectedSegmentIndex) {
            orientation = HPPPLayoutOrientationLandscape;
        }
        
        CGRect position = [HPPPLayout completeFillRectangle];
        if (defaultLetter) {
            position = [self defaultLetterPosition];
        } else {
            CGFloat x = [((UITextField *)self.positionTextField[0]).text floatValue];
            CGFloat y = [((UITextField *)self.positionTextField[1]).text floatValue];
            CGFloat width = [((UITextField *)self.positionTextField[2]).text floatValue];
            CGFloat height = [((UITextField *)self.positionTextField[3]).text floatValue];
            if (width > 0 && height > 0) {
                position = CGRectMake(x, y, width, height);
            }
        }
        
        BOOL allowRotation = !defaultLetter;
        
        HPPPLayoutType type = HPPPLayoutTypeDefault;
        if (defaultLetter || kLayoutFitIndex == self.layoutSegmentControl.selectedSegmentIndex || DefaultPrintRenderer == self.printItem.renderer) {
            type = HPPPLayoutTypeFit;
        } else if (kLayoutFillIndex == self.layoutSegmentControl.selectedSegmentIndex) {
            type = HPPPLayoutTypeFill;
        } else if (kLayoutStretchIndex == self.layoutSegmentControl.selectedSegmentIndex) {
            type = HPPPLayoutTypeStretch;
        }
        
        layout = [HPPPLayoutFactory layoutWithType:type orientation:orientation assetPosition:position allowContentRotation:allowRotation];
    }
    
    return layout;
}

- (CGRect)defaultLetterPosition
{
    HPPPPaper *letterPaper = [[HPPPPaper alloc] initWithPaperSize:SizeLetter paperType:Plain];
    HPPPPaper *defaultPaper = [HPPP sharedInstance].defaultPaper;
    CGFloat maxDimension = fmaxf(defaultPaper.width, defaultPaper.height);
    CGFloat width = maxDimension / letterPaper.width * 100.0f;
    CGFloat height = maxDimension / letterPaper.height * 100.0f;
    CGFloat x = (100.0f - width) / 2.0f;
    CGFloat y = (100.0f - height) / 2.0f;
    return CGRectMake(x, y, width, height);
}

- (NSDictionary *)printItemsForAsset:(id)asset
{
    NSArray *sizes = @[ @"4 x 5", @"4 x 6", @"5 x 7", @"8.5 x 11" ];
    NSMutableDictionary *printItems = [NSMutableDictionary dictionary];
    for (NSString *size in sizes) {
        HPPPPrintItem *printItem = [HPPPPrintItemFactory printItemWithAsset:asset];
        HPPPPaper *paper = [[HPPPPaper alloc] initWithPaperSizeTitle:size paperTypeTitle:@"Plain Paper"];
        printItem.layout = [self layoutForPaper:paper];
        [printItems addEntriesFromDictionary:@{ paper.sizeTitle: printItem }];
    }
    return printItems;
}

@end
