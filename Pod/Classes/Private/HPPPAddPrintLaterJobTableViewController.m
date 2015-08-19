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

#import "HPPPAddPrintLaterJobTableViewController.h"
#import "UITableView+HPPPHeader.h"
#import "HPPPPrintLaterQueue.h"
#import "HPPP.h"
#import "HPPPDefaultSettingsManager.h"
#import "UIColor+HPPPStyle.h"
#import "NSBundle+HPPPLocalizable.h"
#import "HPPPPrintLaterManager.h"
#import "HPPPPageRangeView.h"
#import "HPPPKeyboardView.h"
#import "HPPPOverlayEditView.h"
#import "HPPPMultiPageView.h"
#import "HPPPPrintItem.h"
#import "HPPPPageRange.h"

@interface HPPPAddPrintLaterJobTableViewController () <UITextViewDelegate, HPPPKeyboardViewDelegate, HPPPMultiPageViewDelegate>

@property (weak, nonatomic) IBOutlet UILabel *addToPrintQLabel;
@property (weak, nonatomic) IBOutlet HPPPMultiPageView *multiPageView;

@property (weak, nonatomic) IBOutlet UITableViewCell *jobSummaryCell;
@property (weak, nonatomic) IBOutlet UITableViewCell *addToPrintQCell;
@property (weak, nonatomic) IBOutlet UITableViewCell *jobNameCell;
@property (weak, nonatomic) IBOutlet UIStepper *numCopiesStepper;
@property (weak, nonatomic) IBOutlet UILabel *numCopiesLabel;
@property (weak, nonatomic) IBOutlet UITableViewCell *pageRangeCell;
@property (weak, nonatomic) IBOutlet UITableViewCell *blackAndWhiteCell;
@property (weak, nonatomic) IBOutlet UISwitch *blackAndWhiteSwitch;
@property (weak, nonatomic) IBOutlet UIView *footerView;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *cancelButtonItem;
@property (strong, nonatomic) UIColor *navigationBarTintColor;
@property (strong, nonatomic) UIBarButtonItem *doneButtonItem;
@property (strong, nonatomic) HPPPKeyboardView *keyboardView;
@property (strong, nonatomic) HPPPPageRangeView *pageRangeView;
@property (strong, nonatomic) HPPPOverlayEditView *editView;
@property (strong, nonatomic) UIView *smokeyView;
@property (strong, nonatomic) UIButton *smokeyCancelButton;
@property (strong, nonatomic) UIButton *pageSelectionMark;
@property (strong, nonatomic) UIImage *selectedPageImage;
@property (strong, nonatomic) UIImage *unselectedPageImage;
@property (strong, nonatomic) HPPPPrintItem *printItem;
@property (strong, nonatomic) HPPPPaper *paper;
@property (assign, nonatomic) CGRect editViewFrame;
@property (strong, nonatomic) HPPPPageRange *pageRange;
@end

@implementation HPPPAddPrintLaterJobTableViewController

NSString * const kAddJobScreenName = @"Add Job Screen";

NSInteger const kNumberOfSectionsInTable = 4;
NSInteger const kHPPPJobSummarySection = 0;
NSInteger const kHPPPPrintSettingsSection = 3;
NSInteger const kHPPPPrintSettingsPageRangeRow = 1;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = HPPPLocalizedString(@"Add Print", @"Title of the Add Print to the Print Later Queue Screen");
    
    if (IS_OS_8_OR_LATER) {
        HPPPPrintLaterManager *printLaterManager = [HPPPPrintLaterManager sharedInstance];
        
        [printLaterManager initLocationManager];
        
        if ([printLaterManager currentLocationPermissionSet]) {
            [printLaterManager initUserNotifications];
        }
    }
    
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];

    if (IS_IPAD && IS_OS_8_OR_LATER) {
        self.tableView.tableHeaderView = [[UIView alloc] initWithFrame:CGRectZero];
    }
    
    HPPP *hppp = [HPPP sharedInstance];
    
    self.paper = [[HPPPPaper alloc] initWithPaperSize:[HPPP sharedInstance].defaultPaper.paperSize paperType:Plain];
    self.printItem = [self.printLaterJob.printItems objectForKey:self.paper.sizeTitle];

    // set appearance
    self.jobSummaryCell.textLabel.font = [hppp.appearance.settings objectForKey:kHPPPJobSettingsPrimaryFont];
    self.jobSummaryCell.textLabel.textColor = [hppp.appearance.settings objectForKey:kHPPPJobSettingsPrimaryFontColor];
    self.jobSummaryCell.detailTextLabel.font = [hppp.appearance.settings objectForKey:kHPPPJobSettingsSecondaryFont
                                                ];
    self.jobSummaryCell.detailTextLabel.textColor = [hppp.appearance.settings objectForKey:kHPPPJobSettingsSecondaryFontColor];

    self.addToPrintQLabel.font = [hppp.appearance.settings objectForKey:kHPPPMainActionLinkFont];
    self.addToPrintQLabel.textColor = [hppp.appearance.settings objectForKey:kHPPPMainActionActiveLinkFontColor];
    
    self.jobNameCell.textLabel.font = [hppp.appearance.settings objectForKey:kHPPPSelectionOptionsPrimaryFont];
    self.jobNameCell.textLabel.textColor = [hppp.appearance.settings objectForKey:kHPPPSelectionOptionsPrimaryFontColor];
    self.jobNameCell.detailTextLabel.font = [hppp.appearance.settings objectForKey:kHPPPSelectionOptionsSecondaryFont];
    self.jobNameCell.detailTextLabel.textColor = [hppp.appearance.settings objectForKey:kHPPPSelectionOptionsSecondaryFontColor];
    
    self.numCopiesLabel.font = [hppp.appearance.settings objectForKey:kHPPPSelectionOptionsPrimaryFont];
    self.numCopiesLabel.textColor = [hppp.appearance.settings objectForKey:kHPPPSelectionOptionsPrimaryFontColor];
    self.numCopiesStepper.tintColor = [hppp.appearance.settings objectForKey:kHPPPMainActionActiveLinkFontColor];
    
    self.pageRangeCell.textLabel.font = [hppp.appearance.settings objectForKey:kHPPPSelectionOptionsPrimaryFont];
    self.pageRangeCell.textLabel.textColor = [hppp.appearance.settings objectForKey:kHPPPSelectionOptionsPrimaryFontColor];
    self.pageRangeCell.detailTextLabel.font = [hppp.appearance.settings objectForKey:kHPPPSelectionOptionsSecondaryFont];
    self.pageRangeCell.detailTextLabel.textColor = [hppp.appearance.settings objectForKey:kHPPPSelectionOptionsSecondaryFontColor];
    
    self.blackAndWhiteCell.textLabel.font = [hppp.appearance.settings objectForKey:kHPPPSelectionOptionsPrimaryFont];
    self.blackAndWhiteCell.textLabel.textColor = [hppp.appearance.settings objectForKey:kHPPPSelectionOptionsPrimaryFontColor];
    
    self.selectedPageImage = [hppp.appearance.settings objectForKey:kHPPPJobSettingsSelectedPageIcon];
    self.unselectedPageImage = [hppp.appearance.settings objectForKey:kHPPPJobSettingsUnselectedPageIcon];
    self.pageSelectionMark = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.pageSelectionMark setImage:self.selectedPageImage forState:UIControlStateNormal];
    self.pageSelectionMark.backgroundColor = [UIColor clearColor];
    self.pageSelectionMark.adjustsImageWhenHighlighted = NO;
    [self.pageSelectionMark addTarget:self action:@selector(pageSelectionMarkClicked) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.pageSelectionMark];
    // Make button bigger - 32x32

    self.smokeyView = [[UIView alloc] init];
    self.smokeyView.backgroundColor = [UIColor blackColor];
    self.smokeyView.alpha = 0.0f;
    self.smokeyView.hidden = TRUE;
    self.smokeyView.userInteractionEnabled = FALSE;

    self.smokeyCancelButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [self.smokeyCancelButton setTitle:@"Cancel" forState:UIControlStateNormal];
    [self.smokeyCancelButton setTintColor:[UIColor whiteColor]];
    [self.smokeyView addSubview:self.smokeyCancelButton];

    [self.navigationController.view addSubview:self.smokeyView];

    self.pageRangeView = [[HPPPPageRangeView alloc] initWithFrame:self.view.frame];
    self.pageRangeView.delegate = self;
    self.pageRangeView.hidden = YES;
    self.pageRangeView.maxPageNum = self.printItem.numberOfPages;
    [self.navigationController.view addSubview:self.pageRangeView];

    self.keyboardView = [[HPPPKeyboardView alloc] initWithFrame:self.view.frame];
    self.keyboardView.delegate = self;
    self.keyboardView.hidden = YES;
    [self.navigationController.view addSubview:self.keyboardView];
    
    if( 1 == self.printItem.numberOfPages ) {
        self.pageRangeCell.hidden = TRUE;
        self.pageSelectionMark.hidden = TRUE;
    }
    
    self.tableView.tableFooterView = self.footerView;
    
    // set values
    self.jobSummaryCell.textLabel.text = self.printLaterJob.name;
    self.jobNameCell.detailTextLabel.text = self.printLaterJob.name;
    
    if( nil !=  self.printLaterJob.pageRange.range ) {
        [self setPageRangeLabelText:self.printLaterJob.pageRange.range];
    } else {
        [self setPageRangeLabelText:kPageRangeAllPages];
    }
    
    self.blackAndWhiteSwitch.on = self.printLaterJob.blackAndWhite;
    
    self.numCopiesStepper.minimumValue = 1;
    self.numCopiesStepper.value = self.printLaterJob.numCopies;
    [self setNumCopiesText];

    self.numCopiesStepper.tintColor = self.addToPrintQLabel.textColor;
    
    [self reloadJobSummary];
    [self configureMultiPageView];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.navigationBarTintColor = self.navigationController.navigationBar.barTintColor;
    [[NSNotificationCenter defaultCenter] postNotificationName:kHPPPTrackableScreenNotification object:nil userInfo:[NSDictionary dictionaryWithObject:kAddJobScreenName forKey:kHPPPTrackableScreenNameKey]];
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    if (IS_SPLIT_VIEW_CONTROLLER_IMPLEMENTATION) {
        self.multiPageView = self.pageViewController.multiPageView;
        self.multiPageView.delegate = self;
        [self configureMultiPageView];
    }
    
    [self.multiPageView refreshLayout];
}

- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator
{
    [super viewWillTransitionToSize:size withTransitionCoordinator:coordinator];
    
    [self.tableView reloadData];
}

- (void)viewDidLayoutSubviews
{
    [self.view layoutIfNeeded];
    [self.multiPageView refreshLayout];
    [self setEditFrames];
    if( self.editView ) {
        [self.editView refreshLayout:(CGRect)self.editViewFrame];
    }
}

- (void)setEditFrames
{
    self.editViewFrame = [self.navigationController.view convertRect:self.view.frame fromView:[self.view superview]];
    self.smokeyView.frame = [[UIScreen mainScreen] bounds];
  
    // We can't make use of hidden methods, so this position is hard-coded... at a decent risk of truncation and bad position
    //  Hidden method: self.smokeyCancelButton.frame = [self.navigationController.view convertRect:((UIView*)[self.cancelButtonItem performSelector:@selector(view)]).frame fromView:self.navigationController.navigationBar];
    if( IS_PORTRAIT ) {
        int cancelButtonWidth = 54;
        int cancelButtonRightMargin = IS_IPAD ? 20 : 8;
        int cancelButtonXOrigin = self.smokeyView.frame.size.width - (cancelButtonWidth + cancelButtonRightMargin);
        self.smokeyCancelButton.frame = CGRectMake(cancelButtonXOrigin, 27, cancelButtonWidth, 30);
    } else {
        int cancelButtonWidth = 54;
        int cancelButtonRightMargin = 20;
        int cancelButtonXOrigin = self.smokeyView.frame.size.width - (cancelButtonWidth + cancelButtonRightMargin);
        self.smokeyCancelButton.frame = CGRectMake(cancelButtonXOrigin, 7, cancelButtonWidth, 30);
    }
}

- (void)configureMultiPageView
{
    self.multiPageView.blackAndWhite = self.blackAndWhiteSwitch.on;
    [self.multiPageView setInterfaceOptions:[HPPP sharedInstance].interfaceOptions];
    NSArray *images = [self.printItem previewImagesForPaper:self.paper];
    [self.multiPageView setPages:images paper:self.paper layout:self.printItem.layout];
    self.multiPageView.delegate = self;
}

- (HPPPPageRange *)pageRange
{
    if (nil == _pageRange) {
        _pageRange = [[HPPPPageRange alloc] initWithString:kPageRangeAllPages allPagesIndicator:kPageRangeAllPages maxPageNum:self.printItem.numberOfPages sortAscending:TRUE];
    }
    
    [_pageRange setRange:self.pageRangeCell.detailTextLabel.text];
    
    return _pageRange;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return kNumberOfSectionsInTable;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSInteger numberOfRows = 1;
    
    if( kHPPPPrintSettingsSection == section ) {
        numberOfRows = 3;
    }
    
    return numberOfRows;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat height = [super tableView:tableView heightForRowAtIndexPath:indexPath];
    
    if( self.pageRangeCell.hidden &&
       kHPPPPrintSettingsSection == indexPath.section &&
       kHPPPPrintSettingsPageRangeRow == indexPath.row ) {
        height = 0.0F;
    }
    
    return height;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    CGFloat height = ZERO_HEIGHT;
    
    if (section > kHPPPJobSummarySection) {
        height = tableView.sectionHeaderHeight;
    }
    
    return height;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    cell.selected = NO;
    
    if (cell == self.addToPrintQCell) {
        self.printLaterJob.pageRange = self.pageRange;
        
        NSString *titleForInitialPaperSize = [HPPPPaper titleFromSize:[HPPP sharedInstance].defaultPaper.paperSize];
        HPPPPrintItem *printItem = [self.printLaterJob.printItems objectForKey:titleForInitialPaperSize];
        
        if (printItem == nil) {
            HPPPLogError(@"At least the printing item for the initial paper size (%@) must be provided", titleForInitialPaperSize);
        } else {
            BOOL result = [[HPPPPrintLaterQueue sharedInstance] addPrintLaterJob:self.printLaterJob];
            
            if (result) {
                if ([self.delegate respondsToSelector:@selector(didFinishAddPrintLaterFlow:)]) {
                    [self.delegate didFinishAddPrintLaterFlow:self];
                }
            } else {
                if ([self.delegate respondsToSelector:@selector(didCancelAddPrintLaterFlow:)]) {
                    [self.delegate didCancelAddPrintLaterFlow:self];
                }
            }
        }
    } else {
        
        [self setEditFrames];
        
        if(cell == self.pageRangeCell) {
            self.pageRangeView.frame = self.editViewFrame;
            
            [self.pageRangeView prepareForDisplay:self.pageRange.range];
            
            self.editView = self.pageRangeView;
        } else if (cell == self.jobNameCell) {
            self.keyboardView.frame = self.editViewFrame;
            [self.keyboardView prepareForDisplay:self.jobNameCell.detailTextLabel.text];

            self.editView = self.keyboardView;
        }

        if( self.editView ) {
            [UIView animateWithDuration:0.6f animations:^{
                [self displaySmokeyView:TRUE];
                [self setNavigationBarEditing:TRUE];
                self.editView.hidden = NO;
            } completion:^(BOOL finished) {
                [self.editView beginEditing];
            }];
        }

    }
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if( cell == self.jobSummaryCell ) {
        CGRect frame = self.jobSummaryCell.frame;       
        frame.origin.x = self.view.frame.size.width - 55;
        frame.origin.y = self.jobSummaryCell.frame.origin.y - 12.5;
        frame.size.width = 32;
        frame.size.height = 32;
        
        self.pageSelectionMark.frame = [self.jobSummaryCell.superview convertRect:frame toView:self.view];
    }
}

#pragma mark - Selection Handlers

- (IBAction)didChangeNumCopies:(id)sender {

    self.printLaterJob.numCopies = self.numCopiesStepper.value;
    [self setNumCopiesText];
    [self reloadJobSummary];
}

- (IBAction)didToggleBlackAndWhiteMode:(id)sender {
    
    self.printLaterJob.blackAndWhite = self.blackAndWhiteSwitch.on;
    self.multiPageView.blackAndWhite = self.printLaterJob.blackAndWhite;
    [self reloadJobSummary];
}

- (void)pageSelectionMarkClicked
{
    [self respondToMultiPageViewAction];
}

#pragma mark - NavBar button handlers

- (IBAction)cancelButtonTapped:(id)sender
{
    if( nil != self.editView ) {
        [self.editView cancelEditing];
        [self dismissEditView];
        
    } else if ([self.delegate respondsToSelector:@selector(didCancelAddPrintLaterFlow:)]) {
        [self.delegate didCancelAddPrintLaterFlow:self];
    }
}

- (void)doneButtonTapped:(id)sender
{
    if( nil != self.editView ) {
        [self.editView commitEditing];
        [self dismissEditView];
        
    }
}

#pragma mark - Edit View Delegates

- (void)didSelectPageRange:(HPPPPageRangeView *)view pageRange:(HPPPPageRange *)pageRange
{
    [self setPageRangeLabelText:pageRange.range];
    [self reloadJobSummary];
    
    // Update the page selected icon accordingly
    BOOL pageSelected = FALSE;
    NSArray *pageNums = [pageRange getPages];
    for( NSNumber *pageNum in pageNums ) {
        if( [pageNum integerValue] == self.multiPageView.currentPage) {
            pageSelected = TRUE;
            break;
        }
    }
    [self updateSelectedPageIcon:pageSelected];
    
    [self dismissEditView];
}

- (void)didFinishEnteringText:(HPPPKeyboardView *)view text:(NSString *)text
{
    self.jobSummaryCell.textLabel.text = text;
    self.jobNameCell.detailTextLabel.text = text;
    [self reloadJobSummary];
    [self dismissEditView];
}

#pragma mark - Multipage View Delegate

- (void)multiPageView:(HPPPMultiPageView *)multiPageView didChangeFromPage:(NSUInteger)oldPageNumber ToPage:(NSUInteger)newPageNumber
{
    BOOL pageSelected = FALSE;
    
    NSArray *pageNums = [self.pageRange getPages];
    
    for( NSNumber *pageNum in pageNums ) {
        if( [pageNum integerValue] == newPageNumber ) {
            pageSelected = TRUE;
            break;
        }
    }
    
    [self updateSelectedPageIcon:pageSelected];
}

- (void)multiPageView:(HPPPMultiPageView *)multiPageView didSingleTapPage:(NSUInteger)pageNumber
{
    [self respondToMultiPageViewAction];
}

#pragma mark - Helpers

-(void)respondToMultiPageViewAction
{
    if( self.pageSelectionMark.imageView.image == self.selectedPageImage ) {
        [self includeCurrentPageInPageRange:FALSE];
    } else {
        [self includeCurrentPageInPageRange:TRUE];
    }
}

-(void)includeCurrentPageInPageRange:(BOOL)includePage
{
    HPPPPageRange *pageRange = self.pageRange;
    
    if( includePage ) {
        [pageRange addPage:[NSNumber numberWithInteger:self.multiPageView.currentPage]];
    } else {
        [pageRange removePage:[NSNumber numberWithInteger:self.multiPageView.currentPage]];
    }
    
    if( [pageRange getPages].count > 0 ) {
        self.pageRangeCell.detailTextLabel.text = pageRange.range;
    } else {
        self.pageRangeCell.detailTextLabel.text = kPageRangeNoPages;
    }

    [self updateSelectedPageIcon:includePage];
    [self reloadJobSummary];
}

-(void)updateSelectedPageIcon:(BOOL)selectPage
{
    UIImage *image;
    
    if( selectPage ) {
        image = self.selectedPageImage;
    } else {
        image = self.unselectedPageImage;
    }
 
    [self.pageSelectionMark setImage:image forState:UIControlStateNormal];
}

-(void)reloadJobSummary
{
    NSArray *allPages = [[NSArray alloc] init];
    NSArray *uniquePages = [[NSArray alloc] init];
    NSInteger numPagesToBePrinted = 0;
    if( ![kPageRangeNoPages isEqualToString:self.pageRangeCell.detailTextLabel.text] ) {
        allPages = [self.pageRange getPages];
        uniquePages = [self.pageRange getUniquePages];
        numPagesToBePrinted = allPages.count * self.numCopiesStepper.value;
    }
    
    BOOL printingOneCopyOfAllPages = (1 == self.numCopiesStepper.value && [kPageRangeAllPages isEqualToString:self.pageRangeCell.detailTextLabel.text]);
    
    NSString *text = @"";
    if( 1 < self.printItem.numberOfPages ) {
        text = [NSString stringWithFormat:@"%ld of %ld Pages Selected", (long)uniquePages.count, (long)self.printItem.numberOfPages];
    }
    
    if( self.blackAndWhiteSwitch.on ) {
        if( text.length > 0 ) {
            text = [text stringByAppendingString:@"/"];
        }
        text = [text stringByAppendingString:@"B&W"];
    }
    
    if( text.length > 0 ) {
        text = [text stringByAppendingString:@"/"];
    }
    
    NSString *copyText = @"Copies";
    if( 1 == self.numCopiesStepper.value ) {
        copyText = @"Copy";
    }
    
    text = [text stringByAppendingString:[NSString stringWithFormat:@"%ld %@", (long)self.numCopiesStepper.value, copyText]];
    
    self.jobSummaryCell.detailTextLabel.text = text;
    
    if( 0 == allPages.count  ||  printingOneCopyOfAllPages ) {
        self.addToPrintQLabel.text = @"Add to Print Queue";
    } else if( 1 == numPagesToBePrinted ) {
        self.addToPrintQLabel.text = @"Add 1 Page";
    } else {
        self.addToPrintQLabel.text = [NSString stringWithFormat:@"Add %ld Pages", (long)numPagesToBePrinted];
    }

    HPPP *hppp = [HPPP sharedInstance];
    if( 0 == allPages.count ) {
        self.addToPrintQCell.userInteractionEnabled = FALSE;
        self.addToPrintQLabel.textColor = [hppp.appearance.settings objectForKey:kHPPPMainActionInactiveLinkFontColor];
    } else {
        self.addToPrintQCell.userInteractionEnabled = TRUE;
        self.addToPrintQLabel.textColor = [hppp.appearance.settings objectForKey:kHPPPMainActionActiveLinkFontColor];
    }
    
    [self.tableView reloadData];
}

-(void)displaySmokeyView:(BOOL)display
{
    self.tableView.scrollEnabled = !display;
    
    if( display ) {
        self.smokeyView.hidden = FALSE;
        self.smokeyView.alpha = 0.6f;
    } else {
        self.smokeyView.alpha = 0.0f;
    }
}

- (void)dismissEditView
{
    CGRect desiredFrame = self.editView.frame;
    desiredFrame.origin.y = self.editView.frame.origin.y + self.editView.frame.size.height;
    
    [UIView animateWithDuration:0.6f animations:^{
        [self displaySmokeyView:NO];
        self.editView.frame = desiredFrame;
        [self setNavigationBarEditing:FALSE];
    } completion:^(BOOL finished) {
        self.editView.hidden = YES;
        self.smokeyView.hidden = YES;
        self.editView = nil;
    }];
}

- (void)setNavigationBarEditing:(BOOL)editing
{
    UIColor *buttonColor = nil;
    
    if (editing) {
        buttonColor = [UIColor clearColor];
    }
    
    self.cancelButtonItem.tintColor = buttonColor;
}

- (void)setNumCopiesText
{
    NSString *copyIdentifier = @"Copies";
    
    if( 1 == self.printLaterJob.numCopies ) {
        copyIdentifier = @"Copy";
    }
    
    self.numCopiesLabel.text = [NSString stringWithFormat:@"%ld %@", (long)self.printLaterJob.numCopies, copyIdentifier];
}

- (void)setPageRangeLabelText:(NSString *)pageRange
{
    if( pageRange.length ) {
        self.pageRangeCell.detailTextLabel.text = pageRange;
    } else {
        self.pageRangeCell.detailTextLabel.text = kPageRangeAllPages;
    }
}




@end
