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
#import "HPPPPageSettingsTableViewController.h"
#import "HPPPPaper.h"
#import "UIColor+Style.h"
#import "HPPPPrintPageRenderer.h"
#import "HPPPPageView.h"
#import "HPPPPaperSizeTableViewController.h"
#import "HPPPPaperTypeTableViewController.h"
#import "UITableView+Header.h"
#import "UIColor+HexString.h"
#import "UIView+Animation.h"
#import "HPPPWiFiReachability.h"
#import "UIImage+Resize.h"

#define DEFAULT_ROW_HEIGHT 44.0f

#define PAPER_SECTION 0
#define SUPPORT_SECTION 1

#define NUMBER_OF_ROWS_IN_PAPER_SECTION 4

#define PAPER_SHOW_INDEX 0
#define PAPER_SIZE_INDEX 1
#define PAPER_TYPE_INDEX 2
#define FILTER_INDEX 3

#define LAST_PRINTER_USED_SETTING @"lastPrinterUsed"
#define LAST_SIZE_USED_SETTING @"lastSizeUsed"
#define LAST_TYPE_USED_SETTING @"lastTypeUsed"
#define LAST_FILTER_USED_SETTING @"lastFilterUsed"


@interface HPPPPageSettingsTableViewController () <UIPrintInteractionControllerDelegate, UIGestureRecognizerDelegate, MCPaperSizeTableViewControllerDelegate, MCPaperTypeTableViewControllerDelegate, HPPPPageViewControllerDelegate>


@property (weak, nonatomic) HPPPPageView *pageView;
@property (strong, nonatomic) HPPPPaper *selectedPaper;
@property (strong, nonatomic) HPPPWiFiReachability *wifiReachability;
@property (weak, nonatomic) IBOutlet HPPPPageView *tableViewCellPageView;
@property (weak, nonatomic) IBOutlet UISwitch *blackAndWhiteModeSwitch;
@property (weak, nonatomic) IBOutlet UILabel *paperSizeSelectedLabel;
@property (weak, nonatomic) IBOutlet UILabel *paperTypeSelectedLabel;
@property (weak, nonatomic) IBOutlet UILabel *paperSizeLabel;
@property (weak, nonatomic) IBOutlet UILabel *paperTypeLabel;
@property (weak, nonatomic) IBOutlet UILabel *filterLabel;

@property (weak, nonatomic) IBOutlet UITableViewCell *pageViewCell;
@property (weak, nonatomic) IBOutlet UITableViewCell *paperSizeCell;
@property (weak, nonatomic) IBOutlet UITableViewCell *paperTypeCell;
@property (weak, nonatomic) IBOutlet UITableViewCell *learnMoreCell;
@property (weak, nonatomic) IBOutlet UITableViewCell *filterCell;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *printBarButtonItem;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *cancelBarButtonItem;

@property (nonatomic, strong) UIActivityIndicatorView *spinner;
@property (nonatomic, strong) HPPP *hppp;

@end

@implementation HPPPPageSettingsTableViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.hppp = [HPPP sharedInstance];
    
    self.navigationController.interactivePopGestureRecognizer.delegate = self;
    
    self.tableView.rowHeight = DEFAULT_ROW_HEIGHT;
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    
    self.paperSizeLabel.font = self.hppp.tableViewCellLabelFont;
    self.paperTypeLabel.font = self.hppp.tableViewCellLabelFont;
    self.filterLabel.font = self.hppp.tableViewCellLabelFont;
    
    self.paperSizeSelectedLabel.font = self.hppp.tableViewCellLabelFont;
    self.paperTypeSelectedLabel.font = self.hppp.tableViewCellLabelFont;
    
    self.paperSizeSelectedLabel.textColor = self.hppp.tableViewCellValueColor;
    self.paperTypeSelectedLabel.textColor = self.hppp.tableViewCellValueColor;
    
    //self.learnMoreCell.textLabel.textColor = [UIColor HPBlueColor];
    
    self.pageViewCell.backgroundColor = [UIColor HPGrayBackgroundColor];
    
    self.selectedPaper = [[HPPPPaper alloc] initWithPaperSize:Size4x6  paperType:Photo];
    
    [self loadLastUsed];
    
    if ((!self.hppp.hidePaperTypeOption) && self.selectedPaper.paperSize == SizeLetter) {
        self.paperTypeCell.hidden = NO;
    } else {
        self.paperTypeCell.hidden = YES;
    }
    
    if (self.hppp.hideBlackAndWhiteOption) {
        self.filterCell.hidden = YES;
        
    }
    if (IS_SPLIT_VIEW_CONTROLLER_IMPLEMENTATION) {
        self.navigationItem.rightBarButtonItem = nil;
        self.pageViewController.delegate = self;
    } else {
        self.pageView = self.tableViewCellPageView;
        self.pageView.image = self.image;
        
        __weak HPPPPageSettingsTableViewController *weakSelf = self;
        [self setPaperSize:self.pageView animated:YES completion:^{
            if (!weakSelf.hppp.hideBlackAndWhiteOption) {
                if (weakSelf.blackAndWhiteModeSwitch.on) {
                    weakSelf.tableView.userInteractionEnabled = NO;
                    [weakSelf.pageView setBlackAndWhiteWithCompletion:^{
                        weakSelf.tableView.userInteractionEnabled = YES;
                    }];
                }
            }
        }];
        
        self.wifiReachability = [[HPPPWiFiReachability alloc] init];
        [self.wifiReachability start:self.printBarButtonItem];
    }
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    if (IS_SPLIT_VIEW_CONTROLLER_IMPLEMENTATION) {
        self.pageView = self.pageViewController.pageView;
        __weak HPPPPageSettingsTableViewController *weakSelf = self;
        
        [self setPaperSize:self.pageView animated:NO completion:^{
            if (weakSelf.blackAndWhiteModeSwitch.on) {
                weakSelf.tableView.userInteractionEnabled = NO;
                [weakSelf.pageView setBlackAndWhiteWithCompletion:^{
                    weakSelf.tableView.userInteractionEnabled = YES;
                }];
            }
        }];
    }
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)orientation duration:(NSTimeInterval)duration
{
    if (IS_SPLIT_VIEW_CONTROLLER_IMPLEMENTATION) {
        [self setPaperSize:self.pageView animated:NO completion:nil];
    }
}


- (void)setSelectedPaper:(HPPPPaper *)selectedPaperSize
{
    _selectedPaper = selectedPaperSize;
    self.paperSizeSelectedLabel.text = [NSString stringWithFormat:@"%@ x %@", _selectedPaper.paperWidthTitle, _selectedPaper.paperHeightTitle];
    self.paperTypeSelectedLabel.text = _selectedPaper.typeTitle;
}

- (void)loadLastUsed
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    NSNumber *lastSizeUsed = [defaults objectForKey:LAST_SIZE_USED_SETTING];
    NSNumber *lastTypeUsed = [defaults objectForKey:LAST_TYPE_USED_SETTING];
    
    if (lastSizeUsed != nil) {
        self.selectedPaper = [[HPPPPaper alloc] initWithPaperSize:(PaperSize)lastSizeUsed.integerValue paperType:(PaperType)lastTypeUsed.integerValue];
    } else {
        self.selectedPaper = [[HPPPPaper alloc] initWithPaperSize:(PaperSize)self.hppp.defaultPaperSize paperType:(PaperType)self.hppp.defaultPaperType];
    }
    
    NSNumber *lastFilterUsed = [defaults objectForKey:LAST_FILTER_USED_SETTING];
    if (lastFilterUsed != nil) {
        self.blackAndWhiteModeSwitch.on = lastFilterUsed.boolValue;
    }
}

#pragma mark - Button actions

- (IBAction)cancelButtonTapped:(id)sender
{
    [HPPP sharedInstance].lastOptionsUsed = [NSDictionary dictionary];
    
    if ([self.delegate respondsToSelector:@selector(pageSettingsTableViewControllerDidCancelPrintFlow:)]) {
        [self.delegate pageSettingsTableViewControllerDidCancelPrintFlow:self];
    }
}

- (IBAction)printButtonTapped:(id)sender
{
    [self displaySystemPrintFromBarButtonItem:self.printBarButtonItem];
}

- (void)displaySystemPrintFromBarButtonItem:(UIBarButtonItem *)barButtonItem
{
    // Obtain the shared UIPrintInteractionController
    UIPrintInteractionController *controller = [UIPrintInteractionController sharedPrintController];
    
    if (!controller) {
        NSLog(@"Couldn't get shared UIPrintInteractionController!");
        return;
    }
    
    controller.delegate = self;
    
    // Obtain a printInfo so that we can set our printing defaults.
    UIPrintInfo *printInfo = [UIPrintInfo printInfo];
    
    UIImage *image = nil;
    
    if ([self.image isPortraitImage] || (self.selectedPaper.paperSize == SizeLetter)) {
        image = self.image;
    } else {
        image = [self.image rotate];
    }
    
    // The path to the image may or may not be a good name for our print job
    // but that's all we've got.
    printInfo.jobName = @"PhotoGram";
    
    // Use the default printer if one is set
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *printer = [defaults stringForKey:LAST_PRINTER_USED_SETTING];
    printInfo.printerID = printer;
    
    // This application prints photos. UIKit will pick a paper size and print
    // quality appropriate for this content type.
    BOOL photoPaper = (self.selectedPaper.paperSize != SizeLetter) || (self.selectedPaper.paperType == Photo);
    BOOL color = !self.blackAndWhiteModeSwitch.on;
    
    if (photoPaper && color) {
        printInfo.outputType = UIPrintInfoOutputPhoto;
    } else if (photoPaper && !color) {
        printInfo.outputType = UIPrintInfoOutputPhotoGrayscale;
    } else if (!photoPaper && color) {
        printInfo.outputType = UIPrintInfoOutputGeneral;
    } else {
        printInfo.outputType = UIPrintInfoOutputGrayscale;
    }
    
    HPPPPrintPageRenderer *renderer = [[HPPPPrintPageRenderer alloc] initWithImage:image];
    controller.printPageRenderer = renderer;
    
    // Use this printInfo for this print job.
    controller.printInfo = printInfo;
    
    UIPrintInteractionCompletionHandler completionHandler = ^(UIPrintInteractionController *printController, BOOL completed, NSError *error) {
        
        [HPPP sharedInstance].lastOptionsUsed = [NSDictionary dictionary];
        
        // Set the last printer used as the default printer for the next job
        NSUserDefaults * defaults = [NSUserDefaults standardUserDefaults];
        NSString * printer = printController.printInfo.printerID;
        [defaults setObject:printer forKey:LAST_PRINTER_USED_SETTING];
        [defaults synchronize];
        
        if (error) {
            NSLog(@"FAILED! due to error in domain %@ with error code %ld", error.domain, (long)error.code);
        }
        
        if (completed) {
            NSMutableDictionary *lastOptionsUsed = [NSMutableDictionary dictionary];
            [lastOptionsUsed setValue:self.paperTypeSelectedLabel.text forKey:kHPPPPaperTypeId];
            [lastOptionsUsed setValue:self.paperSizeSelectedLabel.text forKey:kHPPPPaperSizeId];
            [lastOptionsUsed setValue:[NSNumber numberWithBool:self.blackAndWhiteModeSwitch.on] forKey:kHPPPBlackAndWhiteFilterId];
            if (printer) {
                [lastOptionsUsed setValue:printer forKey:kHPPPPrinterId];
            }
            [HPPP sharedInstance].lastOptionsUsed = [NSDictionary dictionaryWithDictionary:lastOptionsUsed];
            
            if ([self.delegate respondsToSelector:@selector(pageSettingsTableViewControllerDidFinishPrintFlow:)]) {
                [self.delegate pageSettingsTableViewControllerDidFinishPrintFlow:self];
            }
        }
        
        if (IS_IPAD) {
            self.cancelBarButtonItem.enabled = YES;
            //            [[UINavigationBar appearance] setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor whiteColor], NSFontAttributeName:[UIFont HPNavigationBarTitleFont]}];
        }
    };
    
    
    if (IS_IPAD) {
        self.cancelBarButtonItem.enabled = NO;
        //        [[UINavigationBar appearance] setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor blackColor], NSFontAttributeName:[UIFont HPNavigationBarTitleFont]}];
        [controller presentFromBarButtonItem:barButtonItem animated:YES completionHandler:completionHandler];
    } else {
        [controller presentAnimated:YES completionHandler:completionHandler];
    }
    
}

#pragma mark - UIPrintInteractionControllerDelegate

- (UIViewController *)printInteractionControllerParentViewController:(UIPrintInteractionController *)printInteractionController
{
    return nil;
}

- (UIPrintPaper *)printInteractionController:(UIPrintInteractionController *)printInteractionController choosePaper:(NSArray *)paperList
{
    CGSize pageSize = CGSizeMake(self.selectedPaper.width * 72.0f, self.selectedPaper.height * 72.0f);
    
    // 4x5 prints force printing on 8.5x11 paper
    //  ... fool AirPrint into printing from the 4x6 tray.
    if( Size4x5 == self.selectedPaper.paperSize )
    {
        pageSize = CGSizeMake(4.0f * 72.0f, 6.0f * 72.0f);
    }

    UIPrintPaper * paper = [UIPrintPaper bestPaperForPageSize:pageSize withPapersFromArray:paperList];
    return paper;
}

#pragma mark - Switch actions

- (IBAction)blackAndWhiteSwitchToggled:(id)sender
{
    [self applyFilter];
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:[NSNumber numberWithInteger:self.blackAndWhiteModeSwitch.on] forKey:LAST_FILTER_USED_SETTING];
    [defaults synchronize];
}

- (void)applyFilter
{
    if (self.blackAndWhiteModeSwitch.on) {
        self.tableView.userInteractionEnabled = NO;
        [self.pageView setBlackAndWhiteWithCompletion:^{
            self.tableView.userInteractionEnabled = YES;
        }];
    } else {
        [self.pageView setColorWithCompletion:nil];
    }
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if (self.hppp.supportActions.count != 0)
        return 2; // Paper Section + Support Section
    else
        return 1; // Paper Section
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == SUPPORT_SECTION) {
        return self.hppp.supportActions.count;
    } else {
        return [super tableView:tableView numberOfRowsInSection:section];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell;
    
    if (indexPath.section == PAPER_SECTION) {
        cell = [super tableView:tableView cellForRowAtIndexPath:indexPath];
        
    } else {
        cell = [tableView dequeueReusableCellWithIdentifier:@"ActionTableViewCellIdentifier"];
        
        if (!cell) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"ActionTableViewCellIdentifier"];
        }
        
        cell.textLabel.font = self.hppp.tableViewCellLabelFont;
        cell.textLabel.textColor = self.hppp.tableViewCellLinkLabelColor;
        HPPPSupportAction *action = self.hppp.supportActions[indexPath.row];
        cell.imageView.image = action.icon;
        cell.textLabel.text = action.title;
    }
    
    return cell;
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    CGFloat height = 0.0f;
    
    if (section == SUPPORT_SECTION) {
        if (self.hppp.supportActions.count != 0) {
            height = HEADER_HEIGHT;
        }
    }
    
    return height;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    cell.selected = NO;
    
    if (indexPath.section == SUPPORT_SECTION) {
        HPPPSupportAction *action = self.hppp.supportActions[indexPath.row];
        if (action.url) {
            [[UIApplication sharedApplication] openURL:action.url];
        } else {
            [self presentViewController:action.viewController animated:YES completion:nil];
        }
    }
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *header = nil;
    
    if (section == SUPPORT_SECTION) {
        if (self.hppp.supportActions.count != 0) {
            header = [tableView headerViewForSupportSection];
        }
    }
    
    return header;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat rowHeight = 0.0f;
    
    if (indexPath.section == PAPER_SECTION) {
        switch (indexPath.row) {
            case PAPER_SHOW_INDEX:
                if (!(IS_IPAD && IS_OS_8_OR_LATER)) {
                    rowHeight = self.pageViewCell.frame.size.height;
                }
                break;
                
            case PAPER_SIZE_INDEX:
                if (!self.hppp.hidePaperSizeOption) {
                    rowHeight = tableView.rowHeight;
                }
                break;
                
            case PAPER_TYPE_INDEX:
                if ((!self.hppp.hidePaperTypeOption) && (self.selectedPaper.paperSize == SizeLetter)) {
                    rowHeight = tableView.rowHeight;
                }
                break;
                
            case FILTER_INDEX:
                if (!([HPPP sharedInstance].hideBlackAndWhiteOption)) {
                    rowHeight = self.tableView.rowHeight;
                }
                break;
                
            default:
                rowHeight = self.tableView.rowHeight;
                break;
        }
    } else {
        rowHeight = tableView.rowHeight;
    }
    
    return rowHeight;
}

#pragma mark - PGPaperSizeTableViewControllerDelegate

- (void)paperSizeTableViewController:(HPPPPaperSizeTableViewController *)paperSizeTableViewController didSelectPaper:(HPPPPaper *)paper
{
    self.selectedPaper = paper;
    
    if ((!self.hppp.hidePaperTypeOption) && self.selectedPaper.paperSize == SizeLetter) {
        self.paperTypeCell.hidden = NO;
    } else {
        self.paperTypeCell.hidden = YES;
    }
    
    [self.tableView reloadData];
    
    [self setPaperSize:self.pageView animated:(!IS_SPLIT_VIEW_CONTROLLER_IMPLEMENTATION) completion:nil];
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:[NSNumber numberWithInteger:self.selectedPaper.paperSize] forKey:LAST_SIZE_USED_SETTING];
    [defaults synchronize];
    
    if ([self.dataSource respondsToSelector:@selector(pageSettingsTableViewControllerRequestImageForPaper:)]) {
        self.spinner = [self.view addSpinner];
        self.spinner.activityIndicatorViewStyle = UIActivityIndicatorViewStyleGray;
        
        UIImage *image = [self.dataSource pageSettingsTableViewControllerRequestImageForPaper:paper];
        if (image) {
            self.image = image;
            self.pageView.image = self.image;
        }
        
        [self.spinner removeFromSuperview];
    }
}

- (void)setPaperSize:(HPPPPageView *)pageView animated:(BOOL)animated completion:(void (^)(void))completion
{
    self.tableView.userInteractionEnabled = NO;
    
    [pageView setPaperSize:self.selectedPaper animated:animated completion:^{
        self.tableView.userInteractionEnabled = YES;
        if (completion) {
            completion();
        }
    }];
}

#pragma mark - PGPaperTypeTableViewControllerDelegate

- (void)paperTypeTableViewController:(HPPPPaperTypeTableViewController *)paperTypeTableViewController didSelectPaper:(HPPPPaper *)paper
{
    self.selectedPaper = paper;
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:[NSNumber numberWithInteger:self.selectedPaper.paperType] forKey:LAST_TYPE_USED_SETTING];
    [defaults synchronize];
}

#pragma mark - PGPageViewControllerDelegate

- (void)pageViewController:(HPPPPageViewController *)pageViewController didTapPrintBarButtonItem:(UIBarButtonItem *)printBarButtonItem
{
    [self displaySystemPrintFromBarButtonItem:printBarButtonItem];
}

#pragma mark - UIGestureRecognizerDelegate

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer
{
    return NO;
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"PaperSizeSegue"]) {
        
        HPPPPaperSizeTableViewController *vc = (HPPPPaperSizeTableViewController *)segue.destinationViewController;
        vc.currentPaper = self.selectedPaper;
        vc.delegate = self;
    } else if ([segue.identifier isEqualToString:@"PaperTypeSegue"]) {
        
        HPPPPaperTypeTableViewController *vc = (HPPPPaperTypeTableViewController *)segue.destinationViewController;
        vc.currentPaper = self.selectedPaper;
        vc.delegate = self;
    }
}

@end
