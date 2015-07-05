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
@property (weak, nonatomic) IBOutlet UISwitch *blackAndWhiteSwitch;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *cancelButtonItem;
@property (strong, nonatomic) UIColor *navigationBarTintColor;
@property (strong, nonatomic) UIBarButtonItem *doneButtonItem;
@property (strong, nonatomic) HPPPKeyboardView *keyboardView;
@property (strong, nonatomic) HPPPPageRangeView *pageRangeView;
@property (strong, nonatomic) HPPPOverlayEditView *editView;
@property (strong, nonatomic) UIView *smokeyView;
@property (strong, nonatomic) UIButton *pageSelectionMark;
@property (strong, nonatomic) UIImage *selectedPageImage;
@property (strong, nonatomic) UIImage *unselectedPageImage;
@property (strong, nonatomic) HPPPPrintItem *printItem;
@property (strong, nonatomic) HPPPPaper *paper;
@property (strong, nonatomic) UIColor *activeCellColor;

@end

@implementation HPPPAddPrintLaterJobTableViewController

NSString * const kAddJobScreenName = @"Add Job Screen";
NSString * const kPageRangeAllPages = @"All";
NSString * const kPageRangeNoPages = @"No pages selected";

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
    
    HPPP *hppp = [HPPP sharedInstance];
    
    self.paper = [[HPPPPaper alloc] initWithPaperSize:[HPPP sharedInstance].defaultPaper.paperSize paperType:Plain];
    self.printItem = [self.printLaterJob.printItems objectForKey:self.paper.sizeTitle];

    self.jobSummaryCell.textLabel.text = self.printLaterJob.name;
    self.jobNameCell.detailTextLabel.text = self.printLaterJob.name;
    
    self.addToPrintQLabel.font = [hppp.appearance.addPrintLaterJobScreenAttributes objectForKey:kHPPPAddPrintLaterJobScreenAddToPrintQFontAttribute];
    self.addToPrintQLabel.textColor = [hppp.appearance.addPrintLaterJobScreenAttributes objectForKey:kHPPPAddPrintLaterJobScreenAddToPrintQColorAttribute];
    
    [self setPageRangeLabelText];
    self.blackAndWhiteSwitch.on = self.printLaterJob.blackAndWhite;
    
    self.numCopiesStepper.minimumValue = 1;
    self.numCopiesStepper.value = self.printLaterJob.numCopies;
    [self setNumCopiesText];
    
    UIButton *doneButton = [hppp.appearance.addPrintLaterJobScreenAttributes objectForKey:kHPPPAddPrintLaterJobScreenDoneButtonAttribute];
    
    [doneButton removeTarget:nil action:NULL forControlEvents:UIControlEventAllEvents];
    
    [doneButton addTarget:self action:@selector(doneButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    
    self.doneButtonItem = [[UIBarButtonItem alloc] initWithCustomView:doneButton];
    
    self.selectedPageImage = [UIImage imageNamed:@"HPPPSelected.png"];
    self.unselectedPageImage = [UIImage imageNamed:@"HPPPUnselected.png"];
    self.pageSelectionMark = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.pageSelectionMark setImage:self.selectedPageImage forState:UIControlStateNormal];
    self.pageSelectionMark.backgroundColor = [UIColor clearColor];
    self.pageSelectionMark.adjustsImageWhenHighlighted = NO;
    [self.pageSelectionMark addTarget:self action:@selector(pageSelectionMarkClicked) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.pageSelectionMark];

    self.smokeyView = [[UIView alloc] init];
    self.smokeyView.backgroundColor = [UIColor blackColor];
    self.smokeyView.alpha = 0.6f;
    self.smokeyView.hidden = TRUE;
    [self.view addSubview:self.smokeyView];
    
    self.pageRangeView = [[HPPPPageRangeView alloc] init];
    self.pageRangeView.delegate = self;
    self.pageRangeView.hidden = YES;
    self.pageRangeView.maxPageNum = self.printItem.numberOfPages;
    [self.view addSubview:self.pageRangeView];

    self.keyboardView = [[HPPPKeyboardView alloc] init];
    self.keyboardView.delegate = self;
    self.keyboardView.hidden = YES;
    [self.view addSubview:self.keyboardView];
    
    if( 1 == self.printItem.numberOfPages ) {
        self.pageRangeCell.hidden = TRUE;
        self.pageSelectionMark.hidden = TRUE;
    }
    
    self.activeCellColor = self.addToPrintQLabel.textColor;
    
    [self reloadJobSummary];
    [self configureMultiPageView];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.navigationBarTintColor = self.navigationController.navigationBar.barTintColor;
    [[NSNotificationCenter defaultCenter] postNotificationName:kHPPPTrackableScreenNotification object:nil userInfo:[NSDictionary dictionaryWithObject:kAddJobScreenName forKey:kHPPPTrackableScreenNameKey]];

    CGRect desiredSmokeyViewFrame = self.view.frame;
    desiredSmokeyViewFrame.size.height += desiredSmokeyViewFrame.origin.y;
    desiredSmokeyViewFrame.origin.y = 0;
    
    self.smokeyView.frame = desiredSmokeyViewFrame;
}

- (void)configureMultiPageView
{
    self.multiPageView.blackAndWhite = self.blackAndWhiteSwitch.on;
    [self.multiPageView setInterfaceOptions:[HPPP sharedInstance].interfaceOptions];
    NSArray *images = [self.printItem previewImagesForPaper:self.paper];
    [self.multiPageView setPages:images paper:self.paper layout:self.printItem.layout];
    self.multiPageView.delegate = self;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 5;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSInteger numberOfRows = 1;
    
    if( 4 == section ) {
        numberOfRows = 3;
    }
    
    return numberOfRows;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat height = [super tableView:tableView heightForRowAtIndexPath:indexPath];
    
    if( self.pageRangeCell.hidden  &&  4 == indexPath.section  &&  1 == indexPath.row ) {
        height = 0.0F;
    }
    
    return height;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    CGFloat height = ZERO_HEIGHT;
    
    if (section > 1) {
        height = tableView.sectionHeaderHeight;
    }
    
    return height;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    CGFloat height = ZERO_HEIGHT;
    
    if( section > 0 ) {
        height = tableView.sectionFooterHeight;
    }
    
    return height;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    cell.selected = NO;
    
    if (cell == self.addToPrintQCell) {
        
        NSString *titleForInitialPaperSize = [HPPPPaper titleFromSize:[HPPP sharedInstance].defaultPaper.paperSize];
        HPPPPrintItem *printItem = [self.printLaterJob.printItems objectForKey:titleForInitialPaperSize];
        
        if (printItem == nil) {
            HPPPLogError(@"At least the printing item for the initial paper size (%@) must be provided", titleForInitialPaperSize);
        } else {
            BOOL result = [[HPPPPrintLaterQueue sharedInstance] addPrintLaterJob:self.printLaterJob];
            
            if (result) {
                if ([self.delegate respondsToSelector:@selector(addPrintLaterJobTableViewControllerDidFinishPrintFlow:)]) {
                    [self.delegate addPrintLaterJobTableViewControllerDidFinishPrintFlow:self];
                }
            } else {
                if ([self.delegate respondsToSelector:@selector(addPrintLaterJobTableViewControllerDidCancelPrintFlow:)]) {
                    [self.delegate addPrintLaterJobTableViewControllerDidCancelPrintFlow:self];
                }
            }
        }
    } else {
        
        CGRect desiredFrame = self.tableView.frame;
        desiredFrame.origin.y = 0;
        
        CGRect startingFrame = desiredFrame;
        startingFrame.origin.y = self.view.frame.origin.y + self.view.frame.size.height;
        
        if(cell == self.pageRangeCell) {
            self.pageRangeView.frame = startingFrame;
            
            NSString *pageRange = self.pageRangeCell.detailTextLabel.text;
            if( [kPageRangeNoPages isEqualToString:self.pageRangeCell.detailTextLabel.text] ) {
                pageRange = @"";
            }
            
            [self.pageRangeView prepareForDisplay:pageRange];
            self.editView = self.pageRangeView;
            
        } else if (cell == self.jobNameCell) {
            self.keyboardView.frame = startingFrame;
            [self.keyboardView prepareForDisplay:self.jobNameCell.detailTextLabel.text];
            self.editView = self.keyboardView;
        }

        if( self.editView ) {
            [self displaySmokeyView:TRUE];
            
            [self setNavigationBarEditing:TRUE];
            
            self.editView.hidden = NO;
            [UIView animateWithDuration:0.6f animations:^{
                self.editView.frame = desiredFrame;
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
        frame.origin.x = self.view.frame.size.width - 30;
        frame.origin.y = self.jobSummaryCell.frame.origin.y - 9;
        frame.size.width = 20;
        frame.size.height = 20;
        
        self.pageSelectionMark.frame = [self.jobSummaryCell.superview convertRect:frame toView:self.view];
    }
}

- (IBAction)cancelButtonTapped:(id)sender
{
    if( nil != self.editView ) {
        [self.editView cancelEditing];
        [self dismissEditView];
        
    } else if ([self.delegate respondsToSelector:@selector(addPrintLaterJobTableViewControllerDidCancelPrintFlow:)]) {
        [self.delegate addPrintLaterJobTableViewControllerDidCancelPrintFlow:self];
    }
}

- (void)doneButtonTapped:(id)sender
{
    if( nil != self.editView ) {
        [self.editView commitEditing];
        [self dismissEditView];

    }
}

#pragma mark - UITextFieldDelegate

- (void)textViewDidBeginEditing:(UITextView *)textView
{
    [self setNavigationBarEditing:YES];
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

#pragma mark - Edit View Delegates

- (void)didSelectPageRange:(HPPPPageRangeView *)view pageRange:(NSString *)pageRange
{
    self.printLaterJob.pageRange = pageRange;
    [self setPageRangeLabelText];
    [self reloadJobSummary];
    [self setPrintLaterJobPageRange];
    
    // Update the page selected icon accordingly
    BOOL pageSelected = FALSE;
    NSArray *pageNums = [HPPPPageRange getPagesFromPageRange:self.pageRangeCell.detailTextLabel.text allPagesIndicator:kPageRangeAllPages maxPageNum:self.printItem.numberOfPages];
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
    
    NSArray *pageNums = [HPPPPageRange getPagesFromPageRange:self.pageRangeCell.detailTextLabel.text allPagesIndicator:kPageRangeAllPages maxPageNum:self.printItem.numberOfPages];
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

- (void)multiPageView:(HPPPMultiPageView *)multiPageView didDoubleTapPage:(NSUInteger)pageNumber
{
    
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
    NSArray *pages = nil;
    
    NSString *pageRange = @"";
    if( ![kPageRangeNoPages isEqualToString:self.pageRangeCell.detailTextLabel.text] ) {
        pageRange = self.pageRangeCell.detailTextLabel.text;
    }
    
    if( includePage ) {
        if( pageRange.length > 0 ) {
            pageRange = [pageRange stringByAppendingString:@","];
        }
        
        self.pageRangeCell.detailTextLabel.text = [NSString stringWithFormat:@"%@%lu", pageRange, (unsigned long)self.multiPageView.currentPage];
        pages = [HPPPPageRange getPagesFromPageRange:self.pageRangeCell.detailTextLabel.text allPagesIndicator:kPageRangeAllPages maxPageNum:self.printItem.numberOfPages];
    } else {
        NSMutableArray *newPages = [[NSMutableArray alloc] init];
        
        // navigate the selected pages, removing every instance of the current page
        pages = [HPPPPageRange getPagesFromPageRange:pageRange allPagesIndicator:kPageRangeAllPages maxPageNum:self.printItem.numberOfPages];
        for( NSNumber *pageNumber in pages ) {
            if( [pageNumber integerValue] != self.multiPageView.currentPage ) {
                [newPages addObject:pageNumber];
            }
        }
        
        pages = newPages;
    }

    // since the user is clicking on pages in the multi-page view, sort the selected pages
    NSMutableArray *mutablePages = [pages mutableCopy];
    NSSortDescriptor *lowestToHighest = [NSSortDescriptor sortDescriptorWithKey:@"self" ascending:YES];
    [mutablePages sortUsingDescriptors:[NSArray arrayWithObject:lowestToHighest]];
    pages = mutablePages;
    
    if( pages.count > 0 ) {
        self.pageRangeCell.detailTextLabel.text = [HPPPPageRange formPageRangeFromPages:pages allPagesIndicator:kPageRangeAllPages maxPageNum:self.printItem.numberOfPages];
    } else {
        self.pageRangeCell.detailTextLabel.text = kPageRangeNoPages;
    }

    [self updateSelectedPageIcon:includePage];
    [self reloadJobSummary];
    [self setPrintLaterJobPageRange];
}

-(void)setPrintLaterJobPageRange
{
    if( [kPageRangeAllPages isEqualToString:self.pageRangeCell.detailTextLabel.text]  ||
        [kPageRangeNoPages isEqualToString:self.pageRangeCell.detailTextLabel.text]      ) {
        self.printLaterJob.pageRange = @"";
    } else {
        self.printLaterJob.pageRange = self.pageRangeCell.detailTextLabel.text;
    }
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
    NSArray *pages = [[NSArray alloc] init];
    if( ![kPageRangeNoPages isEqualToString:self.pageRangeCell.detailTextLabel.text] ) {
        pages = [HPPPPageRange getPagesFromPageRange:self.pageRangeCell.detailTextLabel.text allPagesIndicator:kPageRangeAllPages maxPageNum:self.printItem.numberOfPages];
    }
    
    NSString *text = @"";
    if( 1 < self.printItem.numberOfPages ) {
        text = [NSString stringWithFormat:@"%ld of %ld Pages Selected", (long)pages.count, (long)self.printItem.numberOfPages];
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
    
    if( 1 >= pages.count  ||  pages.count >= self.printItem.numberOfPages ) {
        self.addToPrintQLabel.text = @"Add to Print Queue";
    } else {
        self.addToPrintQLabel.text = [NSString stringWithFormat:@"Add %ld Pages", (long)pages.count];
    }

    if( 0 == pages.count ) {
        self.addToPrintQCell.userInteractionEnabled = FALSE;
        self.addToPrintQLabel.textColor = [UIColor lightGrayColor];
    } else {
        self.addToPrintQCell.userInteractionEnabled = TRUE;
        self.addToPrintQLabel.textColor = self.activeCellColor;
    }
    
    [self.tableView reloadData];
}

-(void)displaySmokeyView:(BOOL)display
{
    self.tableView.scrollEnabled = !display;
    
    [UIView animateWithDuration:0.6f animations:^{
        self.smokeyView.hidden = !display;
    } completion:nil];
}

- (void)dismissEditView
{
    CGRect desiredFrame = self.editView.frame;
    desiredFrame.origin.y = self.editView.frame.origin.y + self.editView.frame.size.height;
    
    [UIView animateWithDuration:0.6f animations:^{
        self.editView.frame = desiredFrame;
    } completion:^(BOOL finished) {
        self.editView.hidden = YES;
        [self displaySmokeyView:NO];
        [self setNavigationBarEditing:NO];
        self.editView = nil;
    }];
}

- (void)setNavigationBarEditing:(BOOL)editing
{
    HPPP *hppp = [HPPP sharedInstance];
    
    UIColor *barTintColor = self.navigationBarTintColor;
    NSString *navigationBarTitle = HPPPLocalizedString(@"Add Print", nil);
    UIBarButtonItem *rightBarButtonItem = self.cancelButtonItem;
    
    UIColor *nameTextFieldColor = [hppp.appearance.addPrintLaterJobScreenAttributes objectForKey:kHPPPAddPrintLaterJobScreenJobNameColorInactiveAttribute];
    
    if (editing) {
        navigationBarTitle = nil;
        barTintColor = [UIColor HPPPHPTabBarSelectedColor];
        nameTextFieldColor = [hppp.appearance.addPrintLaterJobScreenAttributes objectForKey:kHPPPAddPrintLaterJobScreenJobNameColorActiveAttribute];
    }
    
    self.navigationController.navigationBar.barTintColor = barTintColor;
    [self.navigationItem setRightBarButtonItem:rightBarButtonItem animated:YES];
    
    [UIView animateWithDuration:0.4f
                     animations:^{
                         self.navigationItem.title = navigationBarTitle;
                     }];
}

- (void)setNumCopiesText
{
    NSString *copyIdentifier = @"Copies";
    
    if( 1 == self.printLaterJob.numCopies ) {
        copyIdentifier = @"Copy";
    }
    
    self.numCopiesLabel.text = [NSString stringWithFormat:@"%ld %@", (long)self.printLaterJob.numCopies, copyIdentifier];
}

- (void)setPageRangeLabelText
{
    if( [self.printLaterJob.pageRange length] ) {
        self.pageRangeCell.detailTextLabel.text = self.printLaterJob.pageRange;
    } else {
        self.pageRangeCell.detailTextLabel.text = kPageRangeAllPages;
    }
}



@end
