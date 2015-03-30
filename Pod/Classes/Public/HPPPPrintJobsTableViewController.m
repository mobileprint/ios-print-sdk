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
#import "UIColor+HPPPStyle.h"

@interface HPPPPrintJobsTableViewController ()<HPPPPageSettingsTableViewControllerDelegate, HPPPPageSettingsTableViewControllerDataSource>

//@property (unsafe_unretained, nonatomic) IBOutlet UIView *printAllFooterView;
@property (strong, nonatomic) HPPPPrintLaterJob *selectedPrintJob;
@property (strong, nonatomic) UILabel *defaultPrinterLabel;

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

- (IBAction)cancelButtonTapped:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)printJob:(HPPPPrintLaterJob *)printJob
{
    self.selectedPrintJob = printJob;
    
    UIViewController *vc = [HPPP activityViewControllerWithOwner:self andImage:[self.selectedPrintJob.images objectForKey:[HPPPPaper titleFromSize:Size4x6]] useDefaultPrinter:YES];
    if( [vc class] == [UINavigationController class] ) {
        [self.navigationController pushViewController:[(UINavigationController *)vc topViewController] animated:YES];
    } else {
        [self presentViewController:vc animated:YES completion:nil];
    }
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (kPrintAllSectionIndex == section) {
        return 1;
    } else {
        return [[[HPPPPrintLaterQueue sharedInstance] retrieveAllPrintLaterJobs] count];
    }
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = nil;
    HPPP *hppp = [HPPP sharedInstance];
    
    if (kPrintAllSectionIndex == indexPath.section) {
        cell = [tableView dequeueReusableCellWithIdentifier:kPrintAllCellIdentifier];
        if (!cell) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kPrintAllCellIdentifier];
        }
        if ([[[HPPPPrintLaterQueue sharedInstance] retrieveAllPrintLaterJobs] count] == 0) {
            cell.textLabel.text = @"Print queue is empty";
            cell.userInteractionEnabled = NO;
            cell.textLabel.textColor = [hppp.attributedString.printQueueScreenAttributes objectForKey:HPPPPrintQueueScreenPrintAllDisabledLabelColorAttribute];
        } else {
            cell.textLabel.text = @"Print all";
            cell.userInteractionEnabled = YES;
            cell.textLabel.textColor = [hppp.attributedString.printQueueScreenAttributes objectForKey:HPPPPrintQueueScreenPrintAllLabelColorAttribute];
        }
        cell.textLabel.textAlignment = NSTextAlignmentCenter;
        cell.textLabel.font = [hppp.attributedString.printQueueScreenAttributes objectForKey:HPPPPrintQueueScreenPrintAllLabelFontAttribute];
        
    } else if (kPrintJobSectionIndex == indexPath.section) {
        cell = [tableView dequeueReusableCellWithIdentifier:kPrintJobCellIdentifier];
        if (!cell) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:kPrintJobCellIdentifier];
        }
        
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

// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    
    BOOL canEdit = NO;
    
    if( kPrintJobSectionIndex == indexPath.section ) {
        canEdit = YES;
    }
    
    return canEdit;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
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
        [[[UIAlertView alloc] initWithTitle:@"Print Dreams" message:@"You can dream about printing all of your jobs at once, but when you wake up you're going to be bummed!!" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil] show];
    }
    else {
        [self printJob:[[HPPPPrintLaterQueue sharedInstance] retrieveAllPrintLaterJobs][indexPath.row]];
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

- (NSArray *)tableView:(UITableView *)tableView editActionsForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    __weak HPPPPrintJobsTableViewController *weakSelf = self;
    
    HPPPPrintLaterJob *job = [[HPPPPrintLaterQueue sharedInstance] retrieveAllPrintLaterJobs][indexPath.row];
    
    UITableViewRowAction *actionPrint =
    [UITableViewRowAction
     rowActionWithStyle:UITableViewRowActionStyleNormal
     title:@"Print"
     handler:^(UITableViewRowAction *action, NSIndexPath *indexPath) {
         NSLog(@"Print!");
         
         [weakSelf.tableView setEditing:NO animated:YES];
         
         [self printJob:job];
     }];
    
    actionPrint.backgroundColor = [UIColor HPPPHPBlueColor];
    
    UITableViewRowAction *actionDelete =
    [UITableViewRowAction
     rowActionWithStyle:UITableViewRowActionStyleDestructive
     title:@"Delete"
     handler:^(UITableViewRowAction *action, NSIndexPath *indexPath) {
         NSLog(@"Delete!");
         [weakSelf.tableView setEditing:NO animated:YES];
         [[HPPPPrintLaterQueue sharedInstance] deletePrintLaterJob:job];
         [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
     }];
    
    return @[actionDelete, actionPrint];
}

- (void)tableView:(UITableView *)tableView didEndDisplayingCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (kPrintJobSectionIndex == indexPath.section && 0 == [[[HPPPPrintLaterQueue sharedInstance] retrieveAllPrintLaterJobs] count]) {
        [tableView reloadData];
    }
}

#pragma mark - HPPPPageSettingsTableViewControllerDelegate

-(void)pageSettingsTableViewControllerDidFinishPrintFlow:(HPPPPageSettingsTableViewController *)pageSettingsTableViewController
{
    NSLog(@"Finished Print Job!");
}

-(void)pageSettingsTableViewControllerDidCancelPrintFlow:(HPPPPageSettingsTableViewController *)pageSettingsTableViewController
{
    NSLog(@"Cancelled Print Job!");
    [pageSettingsTableViewController dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - HPPPPageSettingsTableViewControllerDataSource

-(void)pageSettingsTableViewControllerRequestImageForPaper:(HPPPPaper *)paper withCompletion:(void (^)(UIImage *))completion
{
    NSString* imageKey = [HPPPPaper titleFromSize:paper.paperSize];
    
    NSLog(@"Retrieving image for size: %@", imageKey);
    
    if( completion ) {
        UIImage *image = [self.selectedPrintJob.images objectForKey:imageKey];
        completion(image);
    }
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

@end
