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

#import "HPPPPrintJobsViewController.h"
#import "HPPPPrintJobsTableViewCell.h"
#import "HPPPPrintLaterQueue.h"
#import "HPPPPageSettingsTableViewController.h"
#import "HPPPPageViewController.h"
#import "HPPP+ViewController.h"
#import "HPPPDefaultSettingsManager.h"
#import "HPPPPaper.h"
#import "HPPPAnalyticsManager.h"
#import "HPPPWiFiReachability.h"
#import "UIColor+HPPPStyle.h"
#import "NSBundle+HPPPLocalizable.h"

@interface HPPPPrintJobsViewController ()<HPPPPageSettingsTableViewControllerDelegate, HPPPPageSettingsTableViewControllerDataSource>

@property (strong, nonatomic) HPPPPrintLaterJob *selectedPrintJob;
@property (strong, nonatomic) NSArray *selectedPrintJobs;
@property (strong, nonatomic) UILabel *jobsCounterLabel;
@property (strong, nonatomic) NSMutableArray *mutableCheckMarkedPrintJobs;
@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *doneBarButtonItem;

@end

@implementation HPPPPrintJobsViewController

NSString * const kPrintJobCellIdentifier = @"PrintJobCell";

#pragma mark - Life cycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = HPPPLocalizedString(@"Print Queue", nil);
    self.doneBarButtonItem.title = HPPPLocalizedString(@"Done", nil);
    
    if (IS_OS_8_OR_LATER) {
        HPPPPrintLaterManager *printLaterManager = [HPPPPrintLaterManager sharedInstance];
        
        [printLaterManager initLocationManager];
        
        if ([printLaterManager currentLocationPermissionSet]) {
            [printLaterManager initUserNotifications];
        }
    }
    
    self.tableView.allowsMultipleSelectionDuringEditing = NO;
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    
    [self initJobsCounterLabel];
    
    NSInteger numberOfPrintLaterJobs = [[HPPPPrintLaterQueue sharedInstance] retrieveNumberOfPrintLaterJobs];
    self.mutableCheckMarkedPrintJobs = [NSMutableArray arrayWithCapacity:numberOfPrintLaterJobs];
    
    if (numberOfPrintLaterJobs == 1) {
        [self.mutableCheckMarkedPrintJobs addObject:[NSNumber numberWithInteger:0]];
    }
}

- (void)initJobsCounterLabel
{
    self.jobsCounterLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 70.0f, 22.0f)];
    HPPP *hppp = [HPPP sharedInstance];
    self.jobsCounterLabel.font = [hppp.attributedString.printQueueScreenAttributes objectForKey:HPPPPrintQueueScreenPrintsCounterLabelFontAttribute];
    self.jobsCounterLabel.textColor = [hppp.attributedString.printQueueScreenAttributes objectForKey:HPPPPrintQueueScreenPrintsCounterLabelColorAttribute];
    self.jobsCounterLabel.text = [NSString stringWithFormat:HPPPLocalizedString(@"%d Prints", nil), [[HPPPPrintLaterQueue sharedInstance] retrieveNumberOfPrintLaterJobs]];
    UIBarButtonItem *jobsCounterBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:self.jobsCounterLabel];
    [self.navigationItem setLeftBarButtonItem:jobsCounterBarButtonItem];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(connectionChanged:) name:kHPPPWiFiConnectionEstablished object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(connectionChanged:) name:kHPPPWiFiConnectionLost object:nil];
}

-  (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kHPPPWiFiConnectionEstablished object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kHPPPWiFiConnectionLost object:nil];
}

+ (void)presentAnimated:(BOOL)animated usingController:(UIViewController *)hostController andCompletion:(void(^)(void))completion
{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"HPPP" bundle:nil];
    UINavigationController *navigationController = (UINavigationController *)[storyboard instantiateViewControllerWithIdentifier:@"HPPPPrintJobsNavigationController"];
    [hostController presentViewController:navigationController animated:animated completion:^{
        if (completion) {
            completion();
        }
    }];
}

#pragma mark - Actions

- (IBAction)doneButtonTapped:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)printJobs:(NSArray *)printJobs
{
    self.selectedPrintJob = printJobs[0];
    self.selectedPrintJobs = printJobs;
    
    UIViewController *vc = [HPPP activityViewControllerWithOwner:self andImage:[self.selectedPrintJob.images objectForKey:[HPPPPaper titleFromSize:Size4x6]] fromQueue:YES];
    if( [vc class] == [UINavigationController class] ) {
        [self.navigationController pushViewController:[(UINavigationController *)vc topViewController] animated:YES];
    } else {
        [self presentViewController:vc animated:YES completion:nil];
    }
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [[HPPPPrintLaterQueue sharedInstance] retrieveNumberOfPrintLaterJobs];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = nil;
    HPPP *hppp = [HPPP sharedInstance];
    
    cell = [tableView dequeueReusableCellWithIdentifier:kPrintJobCellIdentifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:kPrintJobCellIdentifier];
    }
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    HPPPPrintJobsTableViewCell *jobCell = (HPPPPrintJobsTableViewCell *)cell;
    HPPPPrintLaterJob *job = [[HPPPPrintLaterQueue sharedInstance] retrieveAllPrintLaterJobs][indexPath.row];
    
    jobCell.jobNameLabel.text = job.name;
    jobCell.jobNameLabel.font = [hppp.attributedString.printQueueScreenAttributes objectForKey:HPPPPrintQueueScreenJobNameFontAttribute];
    jobCell.jobNameLabel.textColor = [hppp.attributedString.printQueueScreenAttributes objectForKey:HPPPPrintQueueScreenJobNameColorAttribute];
    
    NSString *formatString = [NSDateFormatter dateFormatFromTemplate:[HPPP sharedInstance].defaultDateFormat options:0 locale:[NSLocale currentLocale]];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:formatString];
    
    jobCell.jobDateLabel.text = [formatter stringFromDate:job.date];
    jobCell.jobDateLabel.font = [hppp.attributedString.printQueueScreenAttributes objectForKey:HPPPPrintQueueScreenJobDateFontAttribute];
    jobCell.jobDateLabel.textColor = [hppp.attributedString.printQueueScreenAttributes objectForKey:HPPPPrintQueueScreenJobDateColorAttribute];
    
    NSString *paperSizeTitle = [HPPPPaper titleFromSize:[HPPP sharedInstance].initialPaperSize];
    jobCell.jobThumbnailImageView.image = [job.images objectForKey:paperSizeTitle];
    
    UIImage *checkMarkImage = nil;
    
    if ([self.mutableCheckMarkedPrintJobs containsObject:[NSNumber numberWithInteger:0]]) {
        checkMarkImage = [UIImage imageNamed:@"Active_Circle"];
    } else {
        checkMarkImage = [UIImage imageNamed:@"Inactive_Circle"];
    }
    
    UIImageView *checkMarkImageView = [[UIImageView alloc] initWithImage:checkMarkImage];
    jobCell.accessoryView = checkMarkImageView;
    
    return cell;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSNumber *rowIndex = [NSNumber numberWithInteger:indexPath.row];
    
    UIImage *checkMarkImage = nil;
    if (![self.mutableCheckMarkedPrintJobs containsObject:rowIndex]) {
        [self.mutableCheckMarkedPrintJobs addObject:rowIndex];
        checkMarkImage = [UIImage imageNamed:@"Active_Circle"];
    } else {
        [self.mutableCheckMarkedPrintJobs removeObject:rowIndex];
        checkMarkImage = [UIImage imageNamed:@"Inactive_Circle"];
    }

    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
    UIImageView *check = [[UIImageView alloc] initWithImage:checkMarkImage];
    cell.accessoryView = check;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    CGFloat height = 0.0f;
    if (![[HPPPWiFiReachability sharedInstance] isWifiConnected] || [[HPPPPrintLaterQueue sharedInstance] retrieveNumberOfPrintLaterJobs] == 0) {
        height = 64.0f;
    }
    return height;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, self.view.frame.size.width, 64.0f)];
    view.backgroundColor = self.tableView.backgroundColor;
    
    
    UILabel *textLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0f, 10.0f, self.view.frame.size.width, 44.0f)];
    textLabel.textAlignment = NSTextAlignmentCenter;
    textLabel.font = [[HPPP sharedInstance].attributedString.printQueueScreenAttributes objectForKey:HPPPPrintQueueScreenPrintAllDisabledLabelFontAttribute];
    textLabel.textColor = [[HPPP sharedInstance].attributedString.printQueueScreenAttributes objectForKey:HPPPPrintQueueScreenPrintAllDisabledLabelColorAttribute];
    textLabel.backgroundColor = [UIColor whiteColor];
    textLabel.layer.borderWidth = 0.5f;
    textLabel.layer.borderColor = [UIColor lightGrayColor].CGColor;
    
    NSString *text = nil;
    if ([[HPPPPrintLaterQueue sharedInstance] retrieveNumberOfPrintLaterJobs] == 0) {
        text = HPPPLocalizedString(@"Print queue is empty", nil);
    } else if (![[HPPPWiFiReachability sharedInstance] isWifiConnected]) {
        text = HPPPLocalizedString(@"No Wi-Fi connection", nil);
    }
    
    textLabel.text = text;
    
    [view addSubview:textLabel];
    
    return view;
}

- (NSArray *)tableView:(UITableView *)tableView editActionsForRowAtIndexPath:(NSIndexPath *)indexPath
{
    __weak HPPPPrintJobsViewController *weakSelf = self;
    
    HPPPPrintLaterJob *printLaterJob = [[HPPPPrintLaterQueue sharedInstance] retrieveAllPrintLaterJobs][indexPath.row];
    
    NSMutableArray *actions = [NSMutableArray array];
    
    UITableViewRowAction *actionDelete =
    [UITableViewRowAction
     rowActionWithStyle:UITableViewRowActionStyleDestructive
     title:HPPPLocalizedString(@"Delete", @"Caption of the button for deleting a print later job")
     handler:^(UITableViewRowAction *action, NSIndexPath *indexPath) {
         NSLog(@"Delete!");
         [weakSelf.tableView setEditing:NO animated:YES];
         [[HPPPPrintLaterQueue sharedInstance] deletePrintLaterJob:printLaterJob];
         [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
         [[NSNotificationCenter defaultCenter] postNotificationName:kHPPPPrintQueueNotification object:@{ kHPPPPrintQueueActionKey:kHPPPQueueDeleteAction, kHPPPPrintQueueJobsKey:@[printLaterJob] }];
         if ([HPPP sharedInstance].handlePrintMetricsAutomatically) {
             [[HPPPAnalyticsManager sharedManager] trackShareEventWithOptions:@{ kHPPPOfframpKey:kHPPPQueueDeleteAction }];
         }
     }];
    
    [actions addObject:actionDelete];
    
    return actions;
}

#pragma mark - HPPPPageSettingsTableViewControllerDelegate

-(void)pageSettingsTableViewControllerDidFinishPrintFlow:(HPPPPageSettingsTableViewController *)pageSettingsTableViewController
{
    NSLog(@"Finished Print Job!");
    NSString *action = self.selectedPrintJobs.count > 1 ? kHPPPQueuePrintAllAction : kHPPPQueuePrintAction;
    [[NSNotificationCenter defaultCenter] postNotificationName:kHPPPPrintQueueNotification object:@{ kHPPPPrintQueueActionKey:action, kHPPPPrintQueueJobsKey:self.selectedPrintJobs }];
    
    [pageSettingsTableViewController.navigationController popViewControllerAnimated:YES];
}

-(void)pageSettingsTableViewControllerDidCancelPrintFlow:(HPPPPageSettingsTableViewController *)pageSettingsTableViewController
{
    NSLog(@"Cancelled Print Job!");
    [pageSettingsTableViewController dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - HPPPPageSettingsTableViewControllerDataSource

- (void)pageSettingsTableViewControllerRequestImageForPaper:(HPPPPaper *)paper withCompletion:(void (^)(UIImage *))completion
{
    NSString *imageKey = [HPPPPaper titleFromSize:paper.paperSize];
    
    NSLog(@"Retrieving image for size: %@", imageKey);
    
    if (completion) {
        UIImage *image = [self.selectedPrintJob.images objectForKey:imageKey];
        completion(image);
    }
}

- (NSInteger)pageSettingsTableViewControllerRequestNumberOfImagesToPrint
{
    NSInteger printJobsCount = 1;
    
    if (self.selectedPrintJobs) {
        printJobsCount = self.selectedPrintJobs.count;
    }
    
    return printJobsCount;
}

- (NSArray *)pageSettingsTableViewControllerRequestImagesForPaper:(HPPPPaper *)paper
{
    NSString *imageKey = [HPPPPaper titleFromSize:paper.paperSize];
    
    NSLog(@"Retrieving images for size: %@", imageKey);
    
    NSMutableArray *images = [NSMutableArray arrayWithCapacity:self.selectedPrintJobs.count];
    
    for (HPPPPrintLaterJob *printJob in self.selectedPrintJobs) {
        [images addObject:[printJob.images objectForKey:imageKey]];
    }
    
    return images.copy;
}

#pragma mark - Print all button


#pragma mark - HPPPWiFiReachability notification

- (void)connectionChanged:(NSNotification *)notification
{
    [self.tableView reloadData];
    
    if ([self showWarning]) {
        [[HPPPWiFiReachability sharedInstance] noPrintingAlert];
    }
}

- (BOOL)showWarning
{
    BOOL warn = NO;
    NSUInteger jobCount = [[HPPPPrintLaterQueue sharedInstance] retrieveNumberOfPrintLaterJobs];
    BOOL noWiFi = ![[HPPPWiFiReachability sharedInstance] isWifiConnected];
    if (jobCount > 0 && noWiFi) {
        warn = YES;
    }
    return warn;
}

@end


