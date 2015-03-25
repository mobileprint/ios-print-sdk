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

@interface HPPPPrintJobsTableViewController ()<HPPPPageSettingsTableViewControllerDelegate, HPPPPageSettingsTableViewControllerDataSource>

//@property (unsafe_unretained, nonatomic) IBOutlet UIView *printAllFooterView;
@property (strong, nonatomic) HPPPPrintLaterJob *selectedPrintJob;

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

#pragma mark - Life cycle

- (void)viewDidLoad {
    [super viewDidLoad];

    self.tableView.allowsMultipleSelectionDuringEditing = NO;
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
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
        
        cell.textLabel.text = @"Print all";
        cell.textLabel.textAlignment = NSTextAlignmentCenter;
        cell.textLabel.font = [hppp.attributedString.printQueueScreenAttributes objectForKey:HPPPPrintQueueScreenPrintAllLabelFontAttribute];
        cell.textLabel.textColor = [hppp.attributedString.printQueueScreenAttributes objectForKey:HPPPPrintQueueScreenPrintAllLabelColorAttribute];

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
        
        jobCell.jobThumbnailImageView.image = [job.images objectForKey:@"4 x 5"];
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
        UILabel *printerInfo = [[UILabel alloc] initWithFrame:CGRectMake(kPrintInfoInset, 0.0f, self.tableView.frame.size.width - kPrintInfoInset, kPrintInfoHeight)];
        
        HPPP *hppp = [HPPP sharedInstance];
        HPPPDefaultSettingsManager *settings = [HPPPDefaultSettingsManager sharedInstance];
        if (settings.defaultPrinterName && settings.defaultPrinterNetwork) {
            printerInfo.text = [NSString stringWithFormat:@"%@ / %@", settings.defaultPrinterName, settings.defaultPrinterNetwork];
        }
        else {
            printerInfo.text = @"No default printer";
        }
        printerInfo.font = [hppp.attributedString.printQueueScreenAttributes objectForKey:HPPPPrintQueueScreenPrinterInfoFontAttribute];
        printerInfo.textColor = [hppp.attributedString.printQueueScreenAttributes objectForKey:HPPPPrintQueueScreenPrinterInfoColorAttribute];
        [view addSubview:printerInfo];
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
    
    UITableViewRowAction *actionDelete =
    [UITableViewRowAction
     rowActionWithStyle:UITableViewRowActionStyleDestructive
     title:@"Delete"
     handler:^(UITableViewRowAction *action, NSIndexPath *indexPath) {
         NSLog(@"Delete!");
         
         [weakSelf.tableView setEditing:NO animated:YES];
         [[HPPPPrintLaterQueue sharedInstance] deletePrintLaterJob:job];
         [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationTop];
     }];
    
    return @[actionDelete, actionPrint];
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

@end
