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

@interface HPPPAddPrintLaterJobTableViewController ()

@property (weak, nonatomic) IBOutlet UILabel *addToPrintQLabel;

@property (weak, nonatomic) IBOutlet UILabel *getNotificationLabel;

@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *dateLabel;
@property (weak, nonatomic) IBOutlet UILabel *printerNameTitleLabel;

@property (weak, nonatomic) IBOutlet UILabel *printerNameLabel;

@property (weak, nonatomic) IBOutlet UILabel *printerLocationTitleLabel;

@property (weak, nonatomic) IBOutlet UILabel *printerLocationLabel;
@property (weak, nonatomic) IBOutlet UITableViewCell *addToPrintQCell;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *getNotificationHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *nameTopConstraint;

@end

@implementation HPPPAddPrintLaterJobTableViewController

int const kJobInfoSection = 1;
CGFloat const kJobInfoNoPrinterHeight = 130.0f;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    if (IS_OS_8_OR_LATER) {
        [[HPPPPrintLaterManager sharedInstance] initLocationManager];
        [[HPPPPrintLaterManager sharedInstance] printLaterUserNotificationPermissionRequest];
    }
    
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    
    HPPP *hppp = [HPPP sharedInstance];
    
    self.addToPrintQLabel.font = [hppp.attributedString.addPrintLaterJobScreenAttributes objectForKey:HPPPAddPrintLaterJobScreenAddToPrintQFontAttribute];
    self.addToPrintQLabel.textColor = [hppp.attributedString.addPrintLaterJobScreenAttributes objectForKey:HPPPAddPrintLaterJobScreenAddToPrintQColorAttribute];
    
    self.getNotificationLabel.font = [hppp.attributedString.addPrintLaterJobScreenAttributes objectForKey:HPPPAddPrintLaterJobScreenNotificationDescriptionFontAttribute];
    self.getNotificationLabel.textColor = [hppp.attributedString.addPrintLaterJobScreenAttributes objectForKey:HPPPAddPrintLaterJobScreenNotificationDescriptionColorAttribute];
    
    self.nameLabel.font = [hppp.attributedString.addPrintLaterJobScreenAttributes objectForKey:HPPPAddPrintLaterJobScreenJobNameFontAttribute];
    self.nameLabel.textColor = [hppp.attributedString.addPrintLaterJobScreenAttributes objectForKey:HPPPAddPrintLaterJobScreenJobNameColorAttribute];
    
    self.dateLabel.font = [hppp.attributedString.addPrintLaterJobScreenAttributes objectForKey:HPPPAddPrintLaterJobScreenDateFontAttribute];
    self.dateLabel.textColor = [hppp.attributedString.addPrintLaterJobScreenAttributes objectForKey:HPPPAddPrintLaterJobScreenDateColorAttribute];
    
    self.printerNameTitleLabel.font = [hppp.attributedString.addPrintLaterJobScreenAttributes objectForKey:HPPPAddPrintLaterJobScreenPrinterNameTitleFontAttribute];
    self.printerNameTitleLabel.textColor = [hppp.attributedString.addPrintLaterJobScreenAttributes objectForKey:HPPPAddPrintLaterJobScreenPrinterNameTitleColorAttribute];
    
    self.printerNameLabel.font = [hppp.attributedString.addPrintLaterJobScreenAttributes objectForKey:HPPPAddPrintLaterJobScreenPrinterNameFontAttribute];
    self.printerNameLabel.textColor = [hppp.attributedString.addPrintLaterJobScreenAttributes objectForKey:HPPPAddPrintLaterJobScreenPrinterNameColorAttribute];
    
    self.printerLocationTitleLabel.font = [hppp.attributedString.addPrintLaterJobScreenAttributes objectForKey:HPPPAddPrintLaterJobScreenPrinterNameTitleFontAttribute];
    self.printerLocationTitleLabel.textColor = [hppp.attributedString.addPrintLaterJobScreenAttributes objectForKey:HPPPAddPrintLaterJobScreenPrinterNameTitleColorAttribute];
    
    self.printerLocationLabel.font = [hppp.attributedString.addPrintLaterJobScreenAttributes objectForKey:HPPPAddPrintLaterJobScreenPrinterNameFontAttribute];
    self.printerLocationLabel.textColor = [hppp.attributedString.addPrintLaterJobScreenAttributes objectForKey:HPPPAddPrintLaterJobScreenPrinterNameColorAttribute];
    
    self.nameLabel.text = self.printLaterJob.name;
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init] ;
    [dateFormatter setDateFormat:[HPPP sharedInstance].defaultDateFormat];
    self.dateLabel.text = [dateFormatter stringFromDate:self.printLaterJob.date];
    
    [self preparePrinterDisplayValues];
}

- (void)preparePrinterDisplayValues
{
    HPPPDefaultSettingsManager *settings = [HPPPDefaultSettingsManager sharedInstance];
    if (settings.isDefaultPrinterSet) {
        self.printerNameLabel.text = settings.defaultPrinterName;
        self.printerLocationLabel.text = settings.defaultPrinterNetwork;
    } else {
        self.getNotificationHeightConstraint.constant = 0;
        self.nameTopConstraint.constant = 0;
        self.printerNameTitleLabel.hidden = YES;
        self.printerNameLabel.hidden = YES;
        self.printerLocationTitleLabel.hidden = YES;
        self.printerLocationLabel.hidden = YES;
    }
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    cell.selected = NO;
    
    if (cell == self.addToPrintQCell) {
        
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
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat height = [super tableView:tableView heightForRowAtIndexPath:indexPath];
    if (kJobInfoSection == indexPath.section && ![HPPPDefaultSettingsManager sharedInstance].isDefaultPrinterSet) {
        height = kJobInfoNoPrinterHeight;
    }
    return height;
}

- (IBAction)cancelButtonTapped:(id)sender
{
    if ([self.delegate respondsToSelector:@selector(addPrintLaterJobTableViewControllerDidCancelPrintFlow:)]) {
        [self.delegate addPrintLaterJobTableViewControllerDidCancelPrintFlow:self];
    }
}

@end
