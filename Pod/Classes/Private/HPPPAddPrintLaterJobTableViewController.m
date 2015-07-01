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

@interface HPPPAddPrintLaterJobTableViewController () <UITextViewDelegate, HPPPKeyboardViewDelegate>

@property (weak, nonatomic) IBOutlet UILabel *addToPrintQLabel;

@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UITextView *nameTextView;
@property (weak, nonatomic) IBOutlet UILabel *dateTitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *dateLabel;
@property (weak, nonatomic) IBOutlet UILabel *printerNameTitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *printerNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *printerLocationTitleLabel;

@property (weak, nonatomic) IBOutlet UILabel *printerLocationLabel;
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
@property (strong, nonatomic) UIView *editView;
@property (strong, nonatomic) UIView *smokeyView;
@end

@implementation HPPPAddPrintLaterJobTableViewController

NSString * const kAddJobScreenName = @"Add Job Screen";

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
    
    self.addToPrintQLabel.font = [hppp.appearance.addPrintLaterJobScreenAttributes objectForKey:kHPPPAddPrintLaterJobScreenAddToPrintQFontAttribute];
    self.addToPrintQLabel.textColor = [hppp.appearance.addPrintLaterJobScreenAttributes objectForKey:kHPPPAddPrintLaterJobScreenAddToPrintQColorAttribute];
    self.addToPrintQLabel.text = HPPPLocalizedString(@"Add to Print Queue", nil);
    
    self.nameTextView.font = [hppp.appearance.addPrintLaterJobScreenAttributes objectForKey:kHPPPAddPrintLaterJobScreenJobNameFontAttribute];
    self.nameTextView.textColor = [hppp.appearance.addPrintLaterJobScreenAttributes objectForKey:kHPPPAddPrintLaterJobScreenJobNameColorInactiveAttribute];
    
    self.dateTitleLabel.font = [hppp.appearance.addPrintLaterJobScreenAttributes objectForKey:kHPPPAddPrintLaterJobScreenSubitemTitleFontAttribute];
    self.dateTitleLabel.textColor = [hppp.appearance.addPrintLaterJobScreenAttributes objectForKey:kHPPPAddPrintLaterJobScreenSubitemTitleColorAttribute];
    self.dateTitleLabel.text = HPPPLocalizedString(@"Date", nil);
    
    self.dateLabel.font = [hppp.appearance.addPrintLaterJobScreenAttributes objectForKey:kHPPPAddPrintLaterJobScreenSubitemFontAttribute];
    self.dateLabel.textColor = [hppp.appearance.addPrintLaterJobScreenAttributes objectForKey:kHPPPAddPrintLaterJobScreenSubitemColorAttribute];
    
    self.printerNameTitleLabel.font = [hppp.appearance.addPrintLaterJobScreenAttributes objectForKey:kHPPPAddPrintLaterJobScreenSubitemTitleFontAttribute];
    self.printerNameTitleLabel.textColor = [hppp.appearance.addPrintLaterJobScreenAttributes objectForKey:kHPPPAddPrintLaterJobScreenSubitemTitleColorAttribute];
    self.printerNameTitleLabel.text = HPPPLocalizedString(@"Printer", nil);
    
    self.printerNameLabel.font = [hppp.appearance.addPrintLaterJobScreenAttributes objectForKey:kHPPPAddPrintLaterJobScreenSubitemFontAttribute];
    self.printerNameLabel.textColor = [hppp.appearance.addPrintLaterJobScreenAttributes objectForKey:kHPPPAddPrintLaterJobScreenSubitemColorAttribute];
    
    self.printerLocationTitleLabel.font = [hppp.appearance.addPrintLaterJobScreenAttributes objectForKey:kHPPPAddPrintLaterJobScreenSubitemTitleFontAttribute];
    self.printerLocationTitleLabel.textColor = [hppp.appearance.addPrintLaterJobScreenAttributes objectForKey:kHPPPAddPrintLaterJobScreenSubitemTitleColorAttribute];
    self.printerLocationTitleLabel.text = HPPPLocalizedString(@"Network", nil);
    
    self.printerLocationLabel.font = [hppp.appearance.addPrintLaterJobScreenAttributes objectForKey:kHPPPAddPrintLaterJobScreenSubitemFontAttribute];
    self.printerLocationLabel.textColor = [hppp.appearance.addPrintLaterJobScreenAttributes objectForKey:kHPPPAddPrintLaterJobScreenSubitemColorAttribute];
    
    self.nameTextView.text = self.printLaterJob.name;
    self.nameTextView.layer.borderColor = [UIColor lightGrayColor].CGColor;
    self.nameTextView.layer.borderWidth = 2.0f;
    self.nameTextView.delegate = self;
    self.nameTextView.layer.sublayerTransform = CATransform3DMakeTranslation(5, 0, 0);
    self.nameTextView.textContainer.maximumNumberOfLines = 1;
    self.nameTextView.textContainer.lineBreakMode = NSLineBreakByTruncatingTail;
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init] ;
    [dateFormatter setDateFormat:[HPPP sharedInstance].defaultDateFormat];
    self.dateLabel.text = [dateFormatter stringFromDate:self.printLaterJob.date];
    
    self.imageView.image = [self.printLaterJob previewImage];
    [self setPageRangeLabelText];
    self.blackAndWhiteSwitch.on = self.printLaterJob.blackAndWhite;
    
    self.numCopiesStepper.minimumValue = 1;
    self.numCopiesStepper.value = self.printLaterJob.numCopies;
    [self setNumCopiesText];
    
    [self preparePrinterDisplayValues];
    
    UIButton *doneButton = [hppp.appearance.addPrintLaterJobScreenAttributes objectForKey:kHPPPAddPrintLaterJobScreenDoneButtonAttribute];
    
    [doneButton removeTarget:nil action:NULL forControlEvents:UIControlEventAllEvents];
    
    [doneButton addTarget:self action:@selector(doneButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    
    self.doneButtonItem = [[UIBarButtonItem alloc] initWithCustomView:doneButton];
    self.smokeyView = [[UIView alloc] init];
    self.smokeyView.backgroundColor = [UIColor blackColor];
    self.smokeyView.alpha = 0.6f;
    self.smokeyView.hidden = TRUE;
    [self.view addSubview:self.smokeyView];
    
    self.pageRangeView = [[HPPPPageRangeView alloc] init];
    self.pageRangeView.delegate = self;
    self.pageRangeView.hidden = YES;
self.pageRangeView.maxPageNum = 50;
    [self.view addSubview:self.pageRangeView];

    self.keyboardView = [[HPPPKeyboardView alloc] init];
    self.keyboardView.delegate = self;
    self.keyboardView.hidden = YES;
    [self.view addSubview:self.keyboardView];

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

- (void)preparePrinterDisplayValues
{
    HPPPDefaultSettingsManager *settings = [HPPPDefaultSettingsManager sharedInstance];
    if (settings.isDefaultPrinterSet) {
        self.printerNameLabel.text = settings.defaultPrinterName;
        self.printerLocationLabel.text = settings.defaultPrinterNetwork;
    } else {
        self.printerNameTitleLabel.hidden = YES;
        self.printerNameLabel.hidden = YES;
        self.printerLocationTitleLabel.hidden = YES;
        self.printerLocationLabel.hidden = YES;
    }
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 4;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if( 3 == section ) {
        return 3;
    }
    
    return 1;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    cell.selected = NO;
    
    if (cell == self.addToPrintQCell) {
        
        [self.nameTextView resignFirstResponder];
        
        self.printLaterJob.name = self.nameTextView.text;
        
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
            [self.pageRangeView addButtons];
            self.editView = self.pageRangeView;
            
        } else if (cell == self.jobNameCell) {
            self.keyboardView.frame = startingFrame;
            self.editView = self.keyboardView;
        }

        if( self.editView ) {
            
            [self displaySmokeyView:TRUE];
            
            [self setNavigationBarEditing:TRUE];
            
            self.editView.hidden = NO;
            [UIView animateWithDuration:0.6f animations:^{
                self.editView.frame = desiredFrame;
            } completion:^(BOOL finished) {
                if( [self.editView isKindOfClass:[HPPPKeyboardView class]] ) {
                    [(HPPPKeyboardView *)self.editView displayKeyboard];
                } else if( [self.editView isKindOfClass:[HPPPPageRangeView class]] ) {
                    [(HPPPPageRangeView *)self.editView setCursorPosition];
                }
            }];
        }
    }
}

- (IBAction)cancelButtonTapped:(id)sender
{
    if ([self.delegate respondsToSelector:@selector(addPrintLaterJobTableViewControllerDidCancelPrintFlow:)]) {
        [self.delegate addPrintLaterJobTableViewControllerDidCancelPrintFlow:self];
    }
}

- (void)doneButtonTapped:(id)sender
{
    if( nil != self.editView ) {
        if( [self.editView isKindOfClass:[HPPPKeyboardView class]] ) {
            [(HPPPKeyboardView *)self.editView finishEditing];
        } else if( [self.editView isKindOfClass:[HPPPPageRangeView class]] ) {
            [(HPPPPageRangeView *)self.editView finishEditing];
        }
    
        [self dismissEditView];

    } else {
        [self.nameTextView resignFirstResponder];
        [self setNavigationBarEditing:NO];
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
}

- (IBAction)didToggleBlackAndWhiteMode:(id)sender {
    
    self.printLaterJob.blackAndWhite = self.blackAndWhiteSwitch.on;
}

#pragma mark - Edit View Delegates

- (void)didSelectPageRange:(HPPPPageRangeView *)view pageRange:(NSString *)pageRange
{
    self.printLaterJob.pageRange = pageRange;
    [self setPageRangeLabelText];
    [self dismissEditView];
}

- (void)didFinishEnteringText:(HPPPKeyboardView *)view text:(NSString *)text
{
    self.jobNameCell.detailTextLabel.text = text;
    [self.tableView reloadData];
    [self dismissEditView];
}

#pragma mark - Helpers

-(void)displaySmokeyView:(BOOL)display
{
    self.tableView.scrollEnabled = !display;
    
    [UIView animateWithDuration:0.6f animations:^{
        self.smokeyView.hidden = !display;
    } completion:^(BOOL finished) {
        
    }];
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
        rightBarButtonItem = self.doneButtonItem;
        nameTextFieldColor = [hppp.appearance.addPrintLaterJobScreenAttributes objectForKey:kHPPPAddPrintLaterJobScreenJobNameColorActiveAttribute];
    }
    
    self.navigationController.navigationBar.barTintColor = barTintColor;
    [self.navigationItem setRightBarButtonItem:rightBarButtonItem animated:YES];
    
    [UIView animateWithDuration:0.4f
                     animations:^{
                         self.nameTextView.textColor = nameTextFieldColor;
                         self.navigationItem.title = navigationBarTitle;
                     }];
}

- (void)setNumCopiesText
{
    NSString *copyIdentifier = @"Copies";
    
    if( 1 == self.printLaterJob.numCopies ) {
        copyIdentifier = @"Copy";
    }
    
    self.numCopiesLabel.text = [NSString stringWithFormat:@"%ld %@", self.printLaterJob.numCopies, copyIdentifier];
}

- (void)setPageRangeLabelText
{
    if( [self.printLaterJob.pageRange length] ) {
        self.pageRangeCell.detailTextLabel.text = self.printLaterJob.pageRange;
    } else {
        self.pageRangeCell.detailTextLabel.text = @"All";
    }
}

@end
