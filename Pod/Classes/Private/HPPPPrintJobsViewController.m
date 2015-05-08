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
#import "HPPPPrintJobsViewController.h"
#import "HPPPPrintJobsTableViewCell.h"
#import "HPPPPrintLaterQueue.h"
#import "HPPPPrintLaterManager.h"
#import "HPPPPageSettingsTableViewController.h"
#import "HPPPPageViewController.h"
#import "HPPPPaper.h"
#import "HPPPAnalyticsManager.h"
#import "HPPPWiFiReachability.h"
#import "HPPPPrintJobsActionView.h"
#import "HPPPPrintJobsPreviewViewController.h"
#import "UIColor+HPPPStyle.h"
#import "NSBundle+HPPPLocalizable.h"

@interface HPPPPrintJobsViewController ()<HPPPPrintDelegate, HPPPPrintDataSource, HPPPPrintJobsActionViewDelegate, HPPPPrintJobsTableViewCellDelegate>

@property (strong, nonatomic) HPPPPrintLaterJob *selectedPrintJob;
@property (strong, nonatomic) NSArray *selectedPrintJobs;
@property (strong, nonatomic) UILabel *jobsCounterLabel;
@property (strong, nonatomic) NSMutableArray *mutableCheckMarkedPrintJobs;
@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *doneBarButtonItem;
@property (weak, nonatomic) IBOutlet HPPPPrintJobsActionView *printJobsActionView;
@property (weak, nonatomic) IBOutlet UILabel *emptyPrintQueueLabel;

@end

@implementation HPPPPrintJobsViewController

NSString * const kPrintJobCellIdentifier = @"PrintJobCell";

#pragma mark - Life cycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.view.backgroundColor = self.tableView.backgroundColor;
    
    self.printJobsActionView.delegate = self;
    
    HPPP *hppp = [HPPP sharedInstance];
    
    self.emptyPrintQueueLabel.font = [hppp.appearance.printQueueScreenAttributes objectForKey:kHPPPPrintQueueScreenEmptyQueueFontAttribute];
    self.emptyPrintQueueLabel.textColor = [hppp.appearance.printQueueScreenAttributes objectForKey:kHPPPPrintQueueScreenEmptyQueueColorAttribute];
    self.emptyPrintQueueLabel.text = HPPPLocalizedString(@"Print queue is empty", nil);
    
    self.title = HPPPLocalizedString(@"Print Queue", nil);
    self.doneBarButtonItem.title = HPPPLocalizedString(@"Done", nil);
    
    if (IS_OS_8_OR_LATER) {
        HPPPPrintLaterManager *printLaterManager = [HPPPPrintLaterManager sharedInstance];
        
        [printLaterManager initLocationManager];
        
        if ([printLaterManager currentLocationPermissionSet]) {
            [printLaterManager initUserNotifications];
        }
    }
    
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    
    [self initJobsCounterLabel];
    
    NSInteger numberOfPrintLaterJobs = [[HPPPPrintLaterQueue sharedInstance] retrieveNumberOfPrintLaterJobs];
    
    if (numberOfPrintLaterJobs == 0) {
        self.printJobsActionView.hidden = YES;
        self.emptyPrintQueueLabel.hidden = NO;
    } else {
        self.mutableCheckMarkedPrintJobs = [NSMutableArray arrayWithCapacity:numberOfPrintLaterJobs];
        
        if (numberOfPrintLaterJobs == 1) {
            [self.mutableCheckMarkedPrintJobs addObject:[NSNumber numberWithInteger:0]];
            
            [self setJobsCounterLabel];
            
            [self.printJobsActionView.selectAllButton setTitle:HPPPLocalizedString(@"Unselect All", nil) forState:UIControlStateNormal];
            
            [self.printJobsActionView hideSelectAllButton];
        }
        
        if (![[HPPPWiFiReachability sharedInstance] isWifiConnected]) {
            [self.printJobsActionView hideNextButton];
        }
        
        [self setDeleteButtonStatus];
        [self setNextButtonStatus];
    }
}

- (void)initJobsCounterLabel
{
    self.jobsCounterLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 60.0f, 22.0f)];
    HPPP *hppp = [HPPP sharedInstance];
    self.jobsCounterLabel.font = [hppp.appearance.printQueueScreenAttributes objectForKey:kHPPPPrintQueueScreenPrintsCounterLabelFontAttribute];
    self.jobsCounterLabel.textColor = [hppp.appearance.printQueueScreenAttributes objectForKey:kHPPPPrintQueueScreenPrintsCounterLabelColorAttribute];
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

#pragma mark - Button actions

- (IBAction)doneButtonTapped:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Utils

- (void)setSelectAllButtonStatus
{
    if (self.mutableCheckMarkedPrintJobs.count > 0) {
        self.printJobsActionView.selectAllState = NO;
    } else {
        self.printJobsActionView.selectAllState = YES;
    }
    
    if ([[HPPPPrintLaterQueue sharedInstance] retrieveNumberOfPrintLaterJobs] == 1) {
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
    NSInteger numberOfPrintLaterJobs = [[HPPPPrintLaterQueue sharedInstance] retrieveNumberOfPrintLaterJobs];
    
    if (self.mutableCheckMarkedPrintJobs.count == 0) {
        self.jobsCounterLabel.text = [NSString stringWithFormat:(numberOfPrintLaterJobs == 1) ? HPPPLocalizedString(@"%d Print", nil) : HPPPLocalizedString(@"%d Prints", nil), numberOfPrintLaterJobs];
    } else {
        self.jobsCounterLabel.text = [NSString stringWithFormat:(numberOfPrintLaterJobs == 1) ? HPPPLocalizedString(@"%d/%d Print", nil) : HPPPLocalizedString(@"%d/%d Prints", nil), self.mutableCheckMarkedPrintJobs.count, numberOfPrintLaterJobs];
    }
}

- (void)printJobs:(NSArray *)printJobs
{
    self.selectedPrintJob = printJobs[0];
    self.selectedPrintJobs = printJobs;
    
    UIViewController *vc = [[HPPP sharedInstance] printViewControllerWithDelegate:self dataSource:self image:[self.selectedPrintJob.images objectForKey:[HPPPPaper titleFromSize:Size4x6]] fromQueue:YES];
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
    
    cell = [tableView dequeueReusableCellWithIdentifier:kPrintJobCellIdentifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:kPrintJobCellIdentifier];
    }
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    HPPPPrintJobsTableViewCell *jobCell = (HPPPPrintJobsTableViewCell *)cell;
    HPPPPrintLaterJob *job = [[HPPPPrintLaterQueue sharedInstance] retrieveAllPrintLaterJobs][indexPath.row];
    
    jobCell.delegate = self;
    
    jobCell.printLaterJob = job;
    
    UIImage *checkMarkImage = nil;
    
    if ([self.mutableCheckMarkedPrintJobs containsObject:[NSNumber numberWithInteger:0]]) {
        checkMarkImage = [UIImage imageNamed:@"HPPPActiveCircle"];
    } else {
        checkMarkImage = [UIImage imageNamed:@"HPPPInactiveCircle"];
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
        checkMarkImage = [UIImage imageNamed:@"HPPPActiveCircle"];
        
        [self setJobsCounterLabel];
    } else {
        [self.mutableCheckMarkedPrintJobs removeObject:rowIndex];
        checkMarkImage = [UIImage imageNamed:@"HPPPInactiveCircle"];
        
        [self setJobsCounterLabel];
    }
    
    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
    UIImageView *check = [[UIImageView alloc] initWithImage:checkMarkImage];
    cell.accessoryView = check;
    
    [self setDeleteButtonStatus];
    [self setNextButtonStatus];
    [self setSelectAllButtonStatus];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    CGFloat height = 0.0f;
    if (![[HPPPWiFiReachability sharedInstance] isWifiConnected]) {
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
    textLabel.font = [[HPPP sharedInstance].appearance.printQueueScreenAttributes objectForKey:kHPPPPrintQueueScreenNoWifiLabelFontAttribute];
    textLabel.textColor = [[HPPP sharedInstance].appearance.printQueueScreenAttributes objectForKey:kHPPPPrintQueueScreenNoWifiLabelColorAttribute];
    textLabel.backgroundColor = [UIColor whiteColor];
    textLabel.layer.borderWidth = 0.5f;
    textLabel.layer.borderColor = [UIColor lightGrayColor].CGColor;
    
    NSString *text = nil;
    if (![[HPPPWiFiReachability sharedInstance] isWifiConnected]) {
        text = HPPPLocalizedString(@"No Wi-Fi connection", nil);
    }
    
    textLabel.text = text;
    
    [view addSubview:textLabel];
    
    return view;
}

#pragma mark - HPPPPrintDelegate

- (void)didFinishPrintFlow:(UIViewController *)printViewController;
{
    HPPPLogInfo(@"Finished Print Job!");
    NSString *action = self.selectedPrintJobs.count > 1 ? kHPPPQueuePrintAllAction : kHPPPQueuePrintAction;
    [[NSNotificationCenter defaultCenter] postNotificationName:kHPPPPrintQueueNotification object:@{ kHPPPPrintQueueActionKey:action, kHPPPPrintQueueJobsKey:self.selectedPrintJobs }];
    
    [printViewController.navigationController popViewControllerAnimated:YES];
}

- (void)didCancelPrintFlow:(UIViewController *)printViewController;
{
    HPPPLogInfo(@"Cancelled Print Job!");
    [printViewController dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - HPPPPrintDataSource

- (void)imageForPaper:(HPPPPaper *)paper withCompletion:(void (^)(UIImage *))completion;
{
    NSString *imageKey = [HPPPPaper titleFromSize:paper.paperSize];
    
    HPPPLogInfo(@"Retrieving image for size: %@", imageKey);
    
    if (completion) {
        UIImage *image = [self.selectedPrintJob.images objectForKey:imageKey];
        completion(image);
    }
}

- (NSInteger)numberOfImages
{
    NSInteger printJobsCount = 1;
    
    if (self.selectedPrintJobs) {
        printJobsCount = self.selectedPrintJobs.count;
    }
    
    return printJobsCount;
}

- (NSArray *)imagesForPaper:(HPPPPaper *)paper
{
    NSString *imageKey = [HPPPPaper titleFromSize:paper.paperSize];
    
    HPPPLogInfo(@"Retrieving images for size: %@", imageKey);
    
    NSMutableArray *images = [NSMutableArray arrayWithCapacity:self.selectedPrintJobs.count];
    
    for (HPPPPrintLaterJob *printJob in self.selectedPrintJobs) {
        [images addObject:[printJob.images objectForKey:imageKey]];
    }
    
    return images.copy;
}

#pragma mark - HPPPPrintJobsActionViewDelegate

- (void)printJobsActionViewDidTapSelectAllButton:(HPPPPrintJobsActionView *)printJobsActionView
{
    [self.mutableCheckMarkedPrintJobs removeAllObjects];
    
    if (self.printJobsActionView.selectAllState) {
        
        NSInteger numberOfPrintLaterJobs = [[HPPPPrintLaterQueue sharedInstance] retrieveNumberOfPrintLaterJobs];
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

- (void)printJobsActionViewDidTapDeleteButton:(HPPPPrintJobsActionView *)printJobsActionView
{
    NSArray *checkMarkedPrintJobs = self.mutableCheckMarkedPrintJobs.copy;
    
    NSString *message = (checkMarkedPrintJobs.count > 1) ? [NSString stringWithFormat:HPPPLocalizedString(@"Are you sure you want to delete %d Prints?", nil), checkMarkedPrintJobs.count] : HPPPLocalizedString(@"Are you sure you want to delete 1 Print?", nil);
    
    UIAlertControllerStyle style = UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad ? UIAlertControllerStyleAlert : UIAlertControllerStyleActionSheet;
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:HPPPLocalizedString(@"Delete Print from Print Queue", nil)
                                                                             message:message
                                                                      preferredStyle:style];
    
    [alertController addAction:[UIAlertAction actionWithTitle:HPPPLocalizedString(@"Delete", nil) style:UIAlertActionStyleDestructive handler:^(UIAlertAction *action) {
        NSArray *allPrintLaterJobs = [[HPPPPrintLaterQueue sharedInstance] retrieveAllPrintLaterJobs];
        
        for (NSNumber *index in checkMarkedPrintJobs) {
            HPPPPrintLaterJob *printLaterJob = allPrintLaterJobs[index.integerValue];
            [[HPPPPrintLaterQueue sharedInstance] deletePrintLaterJob:printLaterJob];
            [self.mutableCheckMarkedPrintJobs removeObject:index];
        }
        
        [self.tableView reloadData];
        
        [self setJobsCounterLabel];
        
        if ([[HPPPPrintLaterQueue sharedInstance] retrieveNumberOfPrintLaterJobs] == 0) {
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

- (void)printJobsActionViewDidTapNextButton:(HPPPPrintJobsActionView *)printJobsActionView
{
    NSMutableArray *jobs = [NSMutableArray arrayWithCapacity:self.mutableCheckMarkedPrintJobs.count];
    
    NSArray *allPrintLaterJobs = [[HPPPPrintLaterQueue sharedInstance] retrieveAllPrintLaterJobs];
    
    for (NSNumber *index in self.mutableCheckMarkedPrintJobs) {
        HPPPPrintLaterJob *printLaterJob = allPrintLaterJobs[index.integerValue];
        [jobs addObject:printLaterJob];
    }
    
    [self printJobs:jobs];
}

#pragma mark - HPPPPrintJobsTableViewCellDelegate

- (void)printJobsTableViewCellDidTapImage:(HPPPPrintJobsTableViewCell *)printJobsTableViewCell
{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"HPPP" bundle:nil];
    HPPPPrintJobsPreviewViewController *vc = (HPPPPrintJobsPreviewViewController *)[storyboard instantiateViewControllerWithIdentifier:@"HPPPPrintJobsPreviewViewController"];
    
    vc.modalPresentationStyle = UIModalPresentationOverCurrentContext;
    
    vc.printLaterJob = printJobsTableViewCell.printLaterJob;
    
    [self presentViewController:vc animated:NO completion:nil];
}

#pragma mark - HPPPWiFiReachability notification

- (void)connectionChanged:(NSNotification *)notification
{
    [self.tableView reloadData];
    
    if ([[HPPPWiFiReachability sharedInstance] isWifiConnected]) {
        [self.printJobsActionView showNextButton];
    } else {
        [self.printJobsActionView hideNextButton];
    }
    
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
