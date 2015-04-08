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

#import "HPPPPrintJobsTableViewController.h"
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

@interface HPPPPrintJobsTableViewController ()<HPPPPageSettingsTableViewControllerDelegate, HPPPPageSettingsTableViewControllerDataSource>

@property (strong, nonatomic) HPPPPrintLaterJob *selectedPrintJob;
@property (strong, nonatomic) NSArray *selectedPrintJobs;
@property (strong, nonatomic) UILabel *defaultPrinterLabel;
@property (weak, nonatomic) UITableViewCell *printAllCell;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *settingsButton;

@end

@implementation HPPPPrintJobsTableViewController

int const kPrintAllSectionIndex = 0;
int const kPrintJobSectionIndex = 1;
NSString * const kPrintAllCellIdentifier = @"PrintAllCell";
NSString * const kPrintJobCellIdentifier = @"PrintJobCell";
CGFloat const kPrintAllTopSpace = 20.0f;
CGFloat const kPrintInfoHeight = 35.0f;
CGFloat const kPrintInfoInset = 10.0f;
CGFloat const kPrintAllHeight = 44.0f;
CGFloat const kPrintJobHeight = 60.0f;
NSString * const kNoDefaultPrinterMessage = @"No default printer";

#pragma mark - Life cycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    if (IS_OS_8_OR_LATER) {
        HPPPPrintLaterManager *printLaterManager = [HPPPPrintLaterManager sharedInstance];
        
        [printLaterManager initLocationManager];
        
        if ([printLaterManager currentLocationPermissionSet]) {
            [printLaterManager initUserNotifications];
        }
    }
    
    self.tableView.allowsMultipleSelectionDuringEditing = NO;
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateDefaultPrinterLabel:) name:kHPPPDefaultPrinterAddedNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateDefaultPrinterLabel:) name:kHPPPDefaultPrinterRemovedNotification object:nil];
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
    [self configurePrintAllCell];
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

- (IBAction)cancelButtonTapped:(id)sender
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

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (kPrintAllSectionIndex == section) {
        return 1;
    } else {
        return [[[HPPPPrintLaterQueue sharedInstance] retrieveAllPrintLaterJobs] count];
    }
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = nil;
    HPPP *hppp = [HPPP sharedInstance];
    
    if (kPrintAllSectionIndex == indexPath.section) {
        cell = [tableView dequeueReusableCellWithIdentifier:kPrintAllCellIdentifier];
        if (!cell) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kPrintAllCellIdentifier];
        }
        self.printAllCell = cell;
        [self configurePrintAllCell];
    } else if (kPrintJobSectionIndex == indexPath.section) {
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
        
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"MMMM d, h:mma"];
        
        jobCell.jobDateLabel.text = [formatter stringFromDate:job.date];
        jobCell.jobDateLabel.font = [hppp.attributedString.printQueueScreenAttributes objectForKey:HPPPPrintQueueScreenJobDateFontAttribute];
        jobCell.jobDateLabel.textColor = [hppp.attributedString.printQueueScreenAttributes objectForKey:HPPPPrintQueueScreenJobDateColorAttribute];
        
        NSString *paperSizeTitle = [HPPPPaper titleFromSize:[HPPP sharedInstance].initialPaperSize];
        jobCell.jobThumbnailImageView.image = [job.images objectForKey:paperSizeTitle];
    }
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    BOOL canEdit = NO;
    
    if( kPrintJobSectionIndex == indexPath.section ) {
        canEdit = YES;
    }
    
    return canEdit;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Must override this to enable swipe buttons. Do NOT delete!
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (kPrintJobSectionIndex == indexPath.section) {
        return kPrintJobHeight;
    } else {
        return kPrintAllHeight;
    }
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"%ld - %ld", (long)indexPath.section, (long)indexPath.row);
    
    if( indexPath.section == kPrintAllSectionIndex ) {
        if ([[HPPPWiFiReachability sharedInstance] isWifiConnected]) {
            [self printJobs:[[HPPPPrintLaterQueue sharedInstance] retrieveAllPrintLaterJobs]];
        }
    } else {
        if ([[HPPPWiFiReachability sharedInstance] isWifiConnected]) {
            HPPPPrintLaterJob *printLaterJob = [[HPPPPrintLaterQueue sharedInstance] retrieveAllPrintLaterJobs][indexPath.row];
            [self printJobs:@[printLaterJob]];
        }
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    CGFloat height = 0.0f;
    if (kPrintAllSectionIndex == section) {
        height = kPrintAllTopSpace;
    }
    return height;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    CGFloat height = 0.0f;
    if (kPrintAllSectionIndex == section) {
        height = kPrintInfoHeight;
    }
    return height;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    UIView *view = nil;
    if (kPrintAllSectionIndex == section) {
        view = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, self.tableView.frame.size.width, kPrintInfoHeight)];
        view.backgroundColor = [UIColor clearColor];
        [self configureDefaultPrinterLabel];
        [view addSubview:self.defaultPrinterLabel];
    }
    return view;
}

- (NSArray *)tableView:(UITableView *)tableView editActionsForRowAtIndexPath:(NSIndexPath *)indexPath
{
    __weak HPPPPrintJobsTableViewController *weakSelf = self;
    
    HPPPPrintLaterJob *printLaterJob = [[HPPPPrintLaterQueue sharedInstance] retrieveAllPrintLaterJobs][indexPath.row];
    
    NSMutableArray *actions = [NSMutableArray array];
    
    UITableViewRowAction *actionPrint =
    [UITableViewRowAction
     rowActionWithStyle:UITableViewRowActionStyleNormal
     title:@"Print"
     handler:^(UITableViewRowAction *action, NSIndexPath *indexPath) {
         NSLog(@"Print!");
         
         [weakSelf.tableView setEditing:NO animated:YES];
         
         [self printJobs:@[printLaterJob]];
     }];
    
    actionPrint.backgroundColor = [UIColor HPPPHPBlueColor];
    
    UITableViewRowAction *actionDelete =
    [UITableViewRowAction
     rowActionWithStyle:UITableViewRowActionStyleDestructive
     title:@"Delete"
     handler:^(UITableViewRowAction *action, NSIndexPath *indexPath) {
         NSLog(@"Delete!");
         [weakSelf.tableView setEditing:NO animated:YES];
         [[HPPPPrintLaterQueue sharedInstance] deletePrintLaterJob:printLaterJob];
         [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
         [[NSNotificationCenter defaultCenter] postNotificationName:kHPPPPrintQueueNotification object:@{ kHPPPPrintQueueActionKey:kHPPPQueueDeleteAction, kHPPPPrintQueueJobKey:job }];
         if ([HPPP sharedInstance].handlePrintMetricsAutomatically) {
             [[HPPPAnalyticsManager sharedManager] trackShareEventWithOptions:@{ kHPPPOfframpKey:kHPPPQueueDeleteAction }];
         }
     }];
    
    [actions addObject:actionDelete];
    if ([[HPPPWiFiReachability sharedInstance] isWifiConnected]) {
        [actions addObject:actionPrint];
    }
    
    return actions;
}

- (void)tableView:(UITableView *)tableView didEndDisplayingCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (kPrintJobSectionIndex == indexPath.section) {
        [self configurePrintAllCell];
    }
}

#pragma mark - HPPPPageSettingsTableViewControllerDelegate

-(void)pageSettingsTableViewControllerDidFinishPrintFlow:(HPPPPageSettingsTableViewController *)pageSettingsTableViewController
{
    [[NSNotificationCenter defaultCenter] postNotificationName:kHPPPPrintQueueNotification object:@{ kHPPPPrintQueueActionKey:kHPPPQueuePrintAction, kHPPPPrintQueueJobKey:self.selectedPrintJob }];
    NSLog(@"Finished Print Job!");
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

#pragma mark - Default printer label

- (void)configureDefaultPrinterLabel
{
    if (!self.defaultPrinterLabel) {
        self.defaultPrinterLabel = [[UILabel alloc] initWithFrame:CGRectMake(kPrintInfoInset, 0.0f, self.tableView.frame.size.width - (2 * kPrintInfoInset), kPrintInfoHeight)];
    }
    [self setPrinterLabelText:self.defaultPrinterLabel];
    self.defaultPrinterLabel.font = [[HPPP sharedInstance].attributedString.printQueueScreenAttributes objectForKey:HPPPPrintQueueScreenPrinterInfoFontAttribute];
    self.defaultPrinterLabel.textColor = [[HPPP sharedInstance].attributedString.printQueueScreenAttributes objectForKey:HPPPPrintQueueScreenPrinterInfoColorAttribute];
}

- (void)updateDefaultPrinterLabel:(NSNotification *)notification
{
    if (self.defaultPrinterLabel) {
        [self setPrinterLabelText:self.defaultPrinterLabel];
    }
}

- (void)setPrinterLabelText:(UILabel *)label
{
    HPPPDefaultSettingsManager *settings = [HPPPDefaultSettingsManager sharedInstance];
    if ([settings isDefaultPrinterSet]) {
        label.text = [NSString stringWithFormat:@"%@ / %@", settings.defaultPrinterName, settings.defaultPrinterNetwork];
    }
    else {
        label.text = kNoDefaultPrinterMessage;
    }
}

#pragma mark - Print all button

- (void)configurePrintAllCell
{
    self.printAllCell.textLabel.textAlignment = NSTextAlignmentCenter;
    self.printAllCell.textLabel.font = [[HPPP sharedInstance].attributedString.printQueueScreenAttributes objectForKey:HPPPPrintQueueScreenPrintAllLabelFontAttribute];
    NSString *text = @"Print queue is empty";
    BOOL enabled = NO;
    UIColor *color = [[HPPP sharedInstance].attributedString.printQueueScreenAttributes objectForKey:HPPPPrintQueueScreenPrintAllDisabledLabelColorAttribute];
    NSUInteger jobCount = [[[HPPPPrintLaterQueue sharedInstance] retrieveAllPrintLaterJobs] count];
    if (jobCount > 0) {
        text = @"No Wi-Fi connection";
        if ([[HPPPWiFiReachability sharedInstance] isWifiConnected]) {
            enabled = YES;
            color = [[HPPP sharedInstance].attributedString.printQueueScreenAttributes objectForKey:HPPPPrintQueueScreenPrintAllLabelColorAttribute];
            if (1 == jobCount) {
                text = @"Print";
            } else if (2 == jobCount) {
                text = @"Print both";
            } else {
                text = [NSString stringWithFormat:@"Print all %lu", (unsigned long)jobCount];
            }
        }
    }
    self.printAllCell.userInteractionEnabled = enabled;
    self.printAllCell.textLabel.textColor = color;
    self.printAllCell.textLabel.text = text;
}

#pragma mark - Default printer

- (IBAction)settingsButtonTapped:(id)sender
{
    if ([[HPPPWiFiReachability sharedInstance] isWifiConnected]) {
        UIPrinterPickerController *printerPicker = [UIPrinterPickerController printerPickerControllerWithInitiallySelectedPrinter:nil];
        if(IS_IPAD) {
            [printerPicker presentFromBarButtonItem:self.settingsButton animated:YES completionHandler:^(UIPrinterPickerController *printerPickerController, BOOL userDidSelect, NSError *error) {
                if (userDidSelect) {
                    [self userDidSelectPrinter:printerPickerController.selectedPrinter];
                }
            }];
        } else {
            [printerPicker presentAnimated:YES completionHandler:^(UIPrinterPickerController *printerPickerController, BOOL userDidSelect, NSError *error){
                if (userDidSelect) {
                    [self userDidSelectPrinter:printerPickerController.selectedPrinter];
                }
            }];
        }
    } else {
        [[HPPPWiFiReachability sharedInstance] noPrinterSelectAlert];
    }
}

- (void)userDidSelectPrinter:(UIPrinter *)printer
{
    [HPPPDefaultSettingsManager sharedInstance].defaultPrinterName = printer.displayName;
    [HPPPDefaultSettingsManager sharedInstance].defaultPrinterUrl = printer.URL.absoluteString;
    [HPPPDefaultSettingsManager sharedInstance].defaultPrinterNetwork = [HPPPAnalyticsManager wifiName];
    [HPPPDefaultSettingsManager sharedInstance].defaultPrinterCoordinate = [[HPPPPrintLaterManager sharedInstance] retrieveCurrentLocation];
    [[NSNotificationCenter defaultCenter] postNotificationName:kHPPPDefaultPrinterAddedNotification object:self userInfo:nil];
}

#pragma mark - HPPPWiFiReachability notification

- (void)connectionChanged:(NSNotification *)notification
{
    [self configurePrintAllCell];
    if ([self showWarning]) {
        [[HPPPWiFiReachability sharedInstance] noPrintingAlert];
    }
}

- (BOOL)showWarning
{
    BOOL warn = NO;
    NSUInteger jobCount = [[[HPPPPrintLaterQueue sharedInstance] retrieveAllPrintLaterJobs] count];
    BOOL noWiFi = ![[HPPPWiFiReachability sharedInstance] isWifiConnected];
    if (jobCount > 0 && noWiFi) {
        warn = YES;
    }
    return warn;
}

@end


