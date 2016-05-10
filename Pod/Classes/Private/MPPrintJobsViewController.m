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
#import "MPPrintJobsViewController.h"
#import "MPPrintJobsTableViewCell.h"
#import "MPPrintLaterQueue.h"
#import "MPPrintLaterManager.h"
#import "MPPrintItem.h"
#import "MPPageSettingsTableViewController.h"
#import "MPPageViewController.h"
#import "MPPaper.h"
#import "MPAnalyticsManager.h"
#import "MPWiFiReachability.h"
#import "MPPrintJobsActionView.h"
#import "MPPrintJobsPreviewViewController.h"
#import "UIColor+MPStyle.h"
#import "NSBundle+MPLocalizable.h"

@interface MPPrintJobsViewController ()<MPPrintDelegate, MPPrintDataSource, MPPrintJobsActionViewDelegate, MPPrintJobsTableViewCellDelegate>

@property (strong, nonatomic) MPPrintLaterJob *selectedPrintJob;
@property (strong, nonatomic) NSArray *selectedPrintJobs;
@property (strong, nonatomic) UILabel *jobsCounterLabel;
@property (strong, nonatomic) NSMutableArray *mutableCheckMarkedPrintJobs;
@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *doneBarButtonItem;
@property (strong, nonatomic) UIBarButtonItem *savedBarButton;
@property (weak, nonatomic) IBOutlet MPPrintJobsActionView *printJobsActionView;
@property (weak, nonatomic) IBOutlet UILabel *emptyPrintQueueLabel;
@property (strong, nonatomic) NSArray *allPrintLaterJobs;

@end

@implementation MPPrintJobsViewController

NSString * const kPrintJobCellIdentifier = @"PrintJobCell";
NSString * const kJobListScreenName = @"Job List Screen";

#pragma mark - Life cycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.printJobsActionView.delegate = self;
    
    MP *mp = [MP sharedInstance];
    
    self.emptyPrintQueueLabel.font = [mp.appearance.settings objectForKey:kMPJobSettingsPrimaryFont];
    self.emptyPrintQueueLabel.textColor = [mp.appearance.settings objectForKey:kMPJobSettingsPrimaryFontColor];
    self.emptyPrintQueueLabel.text = MPLocalizedString(@"Print queue is empty", nil);
    
    self.title = MPLocalizedString(@"Print Queue", nil);
    self.doneBarButtonItem.title = MPLocalizedString(@"Done", nil);
    self.savedBarButton = self.doneBarButtonItem;
    
    if (IS_OS_8_OR_LATER) {
        MPPrintLaterManager *printLaterManager = [MPPrintLaterManager sharedInstance];
        
        [printLaterManager initLocationManager];
        
        if ([printLaterManager currentLocationPermissionSet]) {
            [printLaterManager initUserNotifications];
        }
    }
    
    self.view.backgroundColor = [mp.appearance.settings objectForKey:kMPGeneralBackgroundColor];
    self.tableView.backgroundColor = [mp.appearance.settings objectForKey:kMPGeneralBackgroundColor];
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    self.tableView.separatorColor = [mp.appearance.settings objectForKey:kMPGeneralTableSeparatorColor];
    
    [self initJobsCounterLabel];
    
    NSInteger numberOfPrintLaterJobs = [[MPPrintLaterQueue sharedInstance] retrieveNumberOfPrintLaterJobs];
    
    if (numberOfPrintLaterJobs == 0) {
        self.printJobsActionView.hidden = YES;
        self.emptyPrintQueueLabel.hidden = NO;
    } else {
        self.mutableCheckMarkedPrintJobs = [NSMutableArray arrayWithCapacity:numberOfPrintLaterJobs];
        
        if (numberOfPrintLaterJobs == 1) {
            [self.mutableCheckMarkedPrintJobs addObject:[NSNumber numberWithInteger:0]];
            
            [self setJobsCounterLabel];
            
            [self.printJobsActionView.selectAllButton setTitle:MPLocalizedString(@"Unselect All", nil) forState:UIControlStateNormal];
            
            [self.printJobsActionView hideSelectAllButton];
        }
        
        if (![[MPWiFiReachability sharedInstance] isWifiConnected]) {
            [self.printJobsActionView hideNextButton];
        }
        
        [self setDeleteButtonStatus];
        [self setNextButtonStatus];
    }
}

- (void)initJobsCounterLabel
{
    self.jobsCounterLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 100.0f, 22.0f)];
    MP *mp = [MP sharedInstance];
    self.jobsCounterLabel.font = [mp.appearance.settings objectForKey:kMPQueuePrimaryFont];
    self.jobsCounterLabel.textColor = [mp.appearance.settings objectForKey:kMPQueuePrimaryFontColor];
    self.jobsCounterLabel.text = [NSString stringWithFormat:MPLocalizedString(@"%d Prints", nil), [[MPPrintLaterQueue sharedInstance] retrieveNumberOfPrintLaterJobs]];
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
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(connectionChanged:) name:kMPWiFiConnectionEstablished object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(connectionChanged:) name:kMPWiFiConnectionLost object:nil];
    [[NSNotificationCenter defaultCenter] postNotificationName:kMPTrackableScreenNotification object:nil userInfo:[NSDictionary dictionaryWithObject:kJobListScreenName forKey:kMPTrackableScreenNameKey]];
}

-  (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kMPWiFiConnectionEstablished object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kMPWiFiConnectionLost object:nil];
}

+ (void)presentAnimated:(BOOL)animated usingController:(UIViewController *)hostController andCompletion:(void(^)(void))completion
{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"MP" bundle:nil];
    UINavigationController *navigationController = (UINavigationController *)[storyboard instantiateViewControllerWithIdentifier:@"MPPrintJobsNavigationController"];
    [hostController presentViewController:navigationController animated:animated completion:^{
        if (completion) {
            completion();
        }
    }];
}

- (void)traitCollectionDidChange:(UITraitCollection *)previousTraitCollection
{
    [self.tableView reloadData];
}

#pragma mark - Button actions

- (IBAction)doneButtonTapped:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Utils

- (NSArray *)allPrintLaterJobs
{
    _allPrintLaterJobs = [[MPPrintLaterQueue sharedInstance] retrieveAllPrintLaterJobs];
    
    return _allPrintLaterJobs;
}

- (void)setSelectAllButtonStatus
{
    if (self.mutableCheckMarkedPrintJobs.count > 0) {
        self.printJobsActionView.selectAllState = NO;
    } else {
        self.printJobsActionView.selectAllState = YES;
    }
    
    if ([[MPPrintLaterQueue sharedInstance] retrieveNumberOfPrintLaterJobs] == 1) {
        [self.printJobsActionView hideSelectAllButton];
    }
}

- (void)setNextButtonStatus
{
    if (self.mutableCheckMarkedPrintJobs.count == 0) {
        self.printJobsActionView.nextButton.enabled = NO;
    } else {
        self.printJobsActionView.nextButton.enabled = YES;
    }
}

- (void)setDeleteButtonStatus
{
    if (self.mutableCheckMarkedPrintJobs.count == 0) {
        self.printJobsActionView.deleteButton.enabled = NO;
    } else {
        self.printJobsActionView.deleteButton.enabled = YES;
    }
}

- (void)setJobsCounterLabel
{
    NSInteger numberOfPrintLaterJobs = [[MPPrintLaterQueue sharedInstance] retrieveNumberOfPrintLaterJobs];
    
    if (self.mutableCheckMarkedPrintJobs.count == 0) {
        self.jobsCounterLabel.text = [NSString stringWithFormat:(numberOfPrintLaterJobs == 1) ? MPLocalizedString(@"%d Print", nil) : MPLocalizedString(@"%d Prints", nil), numberOfPrintLaterJobs];
    } else {
        self.jobsCounterLabel.text = [NSString stringWithFormat:(numberOfPrintLaterJobs == 1) ? MPLocalizedString(@"%d/%d Print", nil) : MPLocalizedString(@"%d/%d Prints", nil), self.mutableCheckMarkedPrintJobs.count, numberOfPrintLaterJobs];
    }
}

- (void)setViewControllerPageRange:(UIViewController *)vc
{
    MPPageSettingsTableViewController *previewController = nil;
    
    if ( [vc isKindOfClass:[UINavigationController class]] ) {
        vc = ((UINavigationController *)vc).topViewController;
    } else if ( [vc isKindOfClass:[UISplitViewController class]] ) {
        UINavigationController *navController = ((UISplitViewController *)vc).viewControllers[1];
        previewController = (MPPageSettingsTableViewController *)navController.topViewController;
        
        navController = ((UISplitViewController *)vc).viewControllers[0];
        vc = (MPPageSettingsTableViewController *)navController.topViewController;
    }
}

- (void)printJobs:(NSArray *)printJobs
{
    self.selectedPrintJob = printJobs[0];
    self.selectedPrintJobs = printJobs;

    UIViewController *vc = [[MP sharedInstance] printViewControllerWithDelegate:self dataSource:self printLaterJobs:printJobs fromQueue:YES settingsOnly:NO];
    if( [vc class] == [UINavigationController class] ) {
        [self setViewControllerPageRange:[(UINavigationController *)vc topViewController]];
        [self.navigationController pushViewController:[(UINavigationController *)vc topViewController] animated:YES];
    } else {
        [self setViewControllerPageRange:vc];
        [self presentViewController:vc animated:YES completion:nil];
    }
}

- (void)didDismissPreview
{
    self.navigationItem.rightBarButtonItem = self.savedBarButton;
}

- (void)setJobStatusImageView:(BOOL)isActive jobCell:(UITableViewCell *)jobCell
{
    UIImageView *imageView = nil;
    UIImage *checkMarkImage = nil;
    NSString *accessibiltyIdentifier = nil;
    if(isActive) {
        checkMarkImage = [[MP sharedInstance].appearance.settings objectForKey:kMPJobSettingsSelectedJobIcon];
        imageView = [[UIImageView alloc] initWithImage:checkMarkImage];
        accessibiltyIdentifier = @"MPActiveCircle";
    } else {
        checkMarkImage = [[MP sharedInstance].appearance.settings objectForKey:kMPJobSettingsUnselectedJobIcon];
        imageView = [[UIImageView alloc] initWithImage:checkMarkImage];
        accessibiltyIdentifier = @"MPInactiveCircle";
    }

    jobCell.accessoryView = imageView;
    jobCell.selected = isActive;

    jobCell.accessibilityIdentifier = accessibiltyIdentifier;
    jobCell.accessoryView.accessibilityIdentifier = accessibiltyIdentifier;
    jobCell.textLabel.accessibilityIdentifier = accessibiltyIdentifier;
    jobCell.detailTextLabel.accessibilityIdentifier = accessibiltyIdentifier;
    jobCell.accessibilityIdentifier = accessibiltyIdentifier;
    jobCell.imageView.accessibilityIdentifier = accessibiltyIdentifier;
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [[MPPrintLaterQueue sharedInstance] retrieveNumberOfPrintLaterJobs];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = nil;
    
    cell = [tableView dequeueReusableCellWithIdentifier:kPrintJobCellIdentifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:kPrintJobCellIdentifier];
    }
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    MPPrintJobsTableViewCell *jobCell = (MPPrintJobsTableViewCell *)cell;
    MPPrintLaterJob *job = self.allPrintLaterJobs[indexPath.row];
    
    jobCell.delegate = self;
    
    jobCell.printLaterJob = job;
    
    if ([self.mutableCheckMarkedPrintJobs containsObject:[NSNumber numberWithInteger:indexPath.row]]) {
        [self setJobStatusImageView:YES jobCell:jobCell];
    } else {
        [self setJobStatusImageView:NO jobCell:jobCell];
    }
    
    return cell;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSNumber *rowIndex = [NSNumber numberWithInteger:indexPath.row];
    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
    
    if (![self.mutableCheckMarkedPrintJobs containsObject:rowIndex]) {
        [self.mutableCheckMarkedPrintJobs addObject:rowIndex];
        [self setJobStatusImageView:YES jobCell:cell];
    } else {
        [self.mutableCheckMarkedPrintJobs removeObject:rowIndex];
        [self setJobStatusImageView:NO jobCell:cell];
    }
    
    [self setJobsCounterLabel];
    [self setDeleteButtonStatus];
    [self setNextButtonStatus];
    [self setSelectAllButtonStatus];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    CGFloat height = 0.0f;
    if (![[MPWiFiReachability sharedInstance] isWifiConnected]) {
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
    textLabel.font = [[MP sharedInstance].appearance.settings objectForKey:kMPJobSettingsPrimaryFont];
    textLabel.textColor = [[MP sharedInstance].appearance.settings objectForKey:kMPJobSettingsPrimaryFontColor];
    textLabel.backgroundColor = [[MP sharedInstance].appearance.settings objectForKey:kMPGeneralBackgroundColor];
    textLabel.layer.borderWidth = 0.5f;
    textLabel.layer.borderColor = [(UIColor *)[[MP sharedInstance].appearance.settings objectForKey:kMPGeneralBackgroundPrimaryFontColor] CGColor];
    
    NSString *text = nil;
    if (![[MPWiFiReachability sharedInstance] isWifiConnected]) {
        text = MPLocalizedString(@"No Wi-Fi connection", nil);
    }
    
    textLabel.text = text;
    
    [view addSubview:textLabel];
    
    return view;
}

#pragma mark - MPPrintDelegate

- (void)didFinishPrintFlow:(UIViewController *)printViewController;
{
    MPLogInfo(@"Finished Print Job!");
    for (MPPrintLaterJob *job in self.selectedPrintJobs) {
        
        NSString *paperSize = [[MP sharedInstance].lastOptionsUsed objectForKey:kMPPaperSizeId];
        MPPrintItem *printItem = [job.printItems objectForKey:paperSize];
        if (!printItem) {
            printItem = [job.printItems objectForKey:[MP sharedInstance].defaultPaper.sizeTitle];
        }
        
        NSString *offramp = [printItem.extra objectForKey:kMPOfframpKey];
        if (!offramp) {
            MPLogError(@"Unable to obtain offramp for print later job");
        }
        
        [job prepareMetricsForOfframp:offramp];
        [job setPrintSessionForPrintItem:printItem];
        
        NSDictionary *values = @{
                                 kMPPrintQueueActionKey:offramp,
                                 kMPPrintQueueJobKey:job,
                                 kMPPrintQueuePrintItemKey:printItem };
        [[NSNotificationCenter defaultCenter] postNotificationName:kMPPrintQueueNotification object:values];
    }
    [printViewController.navigationController popViewControllerAnimated:YES];
}

- (void)didCancelPrintFlow:(UIViewController *)printViewController;
{
    MPLogInfo(@"Cancelled Print Job!");
    [printViewController dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - MPPrintDataSource

- (void)printingItemForPaper:(MPPaper *)paper withCompletion:(void (^)(MPPrintItem *printItem))completion;
{
    NSString *imageKey = [MPPaper titleFromSize:paper.paperSize];
    
    MPLogInfo(@"Retrieving image for size: %@", imageKey);
    
    if (completion) {
        MPPrintItem *printItem = [self.selectedPrintJob.printItems objectForKey:imageKey];
        printItem.extra = self.selectedPrintJob.extra;
        if (printItem == nil) {
            printItem = [self.selectedPrintJob.printItems objectForKey:[MPPaper titleFromSize:[MP sharedInstance].defaultPaper.paperSize]];
        }
        
        completion(printItem);
    }
}

- (void)previewImageForPaper:(MPPaper *)paper withCompletion:(void (^)(UIImage *))completion
{
    if (completion) {
        [self printingItemForPaper:paper withCompletion:^(MPPrintItem *printItem) {
            completion([printItem previewImageForPaper:paper]);
        }];
    }
}

- (NSInteger)numberOfPrintingItems
{
    NSInteger printJobsCount = 1;
    
    if (self.selectedPrintJobs) {
        printJobsCount = self.selectedPrintJobs.count;
    }
    
    return printJobsCount;
}

- (NSArray *)printLaterJobs
{
    return self.selectedPrintJobs;
}

#pragma mark - MPPrintJobsActionViewDelegate

- (void)printJobsActionViewDidTapSelectAllButton:(MPPrintJobsActionView *)printJobsActionView
{
    [self.mutableCheckMarkedPrintJobs removeAllObjects];
    
    if (self.printJobsActionView.selectAllState) {
        
        NSInteger numberOfPrintLaterJobs = [[MPPrintLaterQueue sharedInstance] retrieveNumberOfPrintLaterJobs];
        for (NSInteger i = 0; i < numberOfPrintLaterJobs; i++) {
            [self.mutableCheckMarkedPrintJobs addObject:[NSNumber numberWithInteger:i]];
        }
    }
    
    [self.tableView reloadData];
    
    [self setJobsCounterLabel];
    
    [self setDeleteButtonStatus];
    [self setNextButtonStatus];
    [self setSelectAllButtonStatus];
}

- (void)printJobsActionViewDidTapDeleteButton:(MPPrintJobsActionView *)printJobsActionView
{
    NSSortDescriptor *highestToLowest = [NSSortDescriptor sortDescriptorWithKey:@"self" ascending:NO];
    NSMutableArray *checkMarkedPrintJobs = self.mutableCheckMarkedPrintJobs.mutableCopy;
    [checkMarkedPrintJobs sortUsingDescriptors:@[highestToLowest]];
    
    NSString *message = (checkMarkedPrintJobs.count > 1) ? [NSString stringWithFormat:MPLocalizedString(@"Are you sure you want to delete %d Prints?", nil), checkMarkedPrintJobs.count] : MPLocalizedString(@"Are you sure you want to delete 1 Print?", nil);
    
    UIAlertControllerStyle style = UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad ? UIAlertControllerStyleAlert : UIAlertControllerStyleActionSheet;
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:MPLocalizedString(@"Delete Print from Print Queue", nil)
                                                                             message:message
                                                                      preferredStyle:style];
    
    [alertController addAction:[UIAlertAction actionWithTitle:MPLocalizedString(@"Delete", nil) style:UIAlertActionStyleDestructive handler:^(UIAlertAction *action) {
        
        for (NSNumber *index in checkMarkedPrintJobs) {
            MPPrintLaterJob *printLaterJob = self.allPrintLaterJobs[index.integerValue];
            [[MPPrintLaterQueue sharedInstance] deletePrintLaterJob:printLaterJob];
            [self.mutableCheckMarkedPrintJobs removeObject:index];
        }
        
        [self.tableView reloadData];
        
        [self setJobsCounterLabel];
        
        if ([[MPPrintLaterQueue sharedInstance] retrieveNumberOfPrintLaterJobs] == 0) {
            self.printJobsActionView.hidden = YES;
            self.emptyPrintQueueLabel.hidden = NO;
        } else {
            [self setDeleteButtonStatus];
            [self setNextButtonStatus];
            [self setSelectAllButtonStatus];
        }
    }]];
    
    [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel", nil) style:UIAlertActionStyleCancel handler:nil]];
    
    [self presentViewController:alertController animated:YES completion:nil];
}

- (void)printJobsActionViewDidTapNextButton:(MPPrintJobsActionView *)printJobsActionView
{
    NSMutableArray *jobs = [NSMutableArray arrayWithCapacity:self.mutableCheckMarkedPrintJobs.count];
    
    for (NSNumber *index in self.mutableCheckMarkedPrintJobs) {
        MPPrintLaterJob *printLaterJob = self.allPrintLaterJobs[index.integerValue];
        [jobs addObject:printLaterJob];
    }
    
    [self printJobs:jobs];
}

#pragma mark - MPPrintJobsTableViewCellDelegate

- (void)printJobsTableViewCellDidTapImage:(MPPrintJobsTableViewCell *)printJobsTableViewCell
{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"MP" bundle:nil];
    MPPrintJobsPreviewViewController *vc = (MPPrintJobsPreviewViewController *)[storyboard instantiateViewControllerWithIdentifier:@"MPPrintJobsPreviewViewController"];
    vc.modalPresentationStyle = UIModalPresentationOverCurrentContext;
    vc.printLaterJob = printJobsTableViewCell.printLaterJob;

    self.navigationItem.rightBarButtonItem = nil;
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didDismissPreview)
                                                 name:[vc dismissalNotificationName]
                                               object:nil];

    [self presentViewController:vc animated:NO completion:nil];
}

#pragma mark - MPWiFiReachability notification

- (void)connectionChanged:(NSNotification *)notification
{
    [self.tableView reloadData];
    
    if ([[MPWiFiReachability sharedInstance] isWifiConnected]) {
        [self.printJobsActionView showNextButton];
    } else {
        [self.printJobsActionView hideNextButton];
    }
    
    if ([self showWarning]) {
        [[MPWiFiReachability sharedInstance] noPrintingAlert];
    }
}

- (BOOL)showWarning
{
    BOOL warn = NO;
    NSUInteger jobCount = [[MPPrintLaterQueue sharedInstance] retrieveNumberOfPrintLaterJobs];
    BOOL noWiFi = ![[MPWiFiReachability sharedInstance] isWifiConnected];
    if (jobCount > 0 && noWiFi) {
        warn = YES;
    }
    return warn;
}

@end
