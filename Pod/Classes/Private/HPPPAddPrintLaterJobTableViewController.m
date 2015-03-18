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

@end

@implementation HPPPAddPrintLaterJobTableViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
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
    [dateFormatter setDateFormat:@"MMM dd, hh:mm"];
    self.dateLabel.text = [dateFormatter stringFromDate:self.printLaterJob.date];
    
    self.printerNameLabel.text = self.printLaterJob.printerName;
    self.printerLocationLabel.text = self.printLaterJob.printerLocation;
    
    if (IS_OS_8_OR_LATER) {
        UIMutableUserNotificationAction *laterAction = [[UIMutableUserNotificationAction alloc] init];
        laterAction.identifier = @"LATER_ACTION_IDENTIFIER";
        laterAction.activationMode = UIUserNotificationActivationModeBackground;
        laterAction.title = @"Later";
        laterAction.destructive = YES;
        
        UIMutableUserNotificationAction *printAction = [[UIMutableUserNotificationAction alloc] init];
        printAction.identifier = @"PRINT_ACTION_IDENTIFIER";
        printAction.activationMode = UIUserNotificationActivationModeBackground;
        printAction.title = @"Print";
        printAction.destructive = NO;
        
        UIMutableUserNotificationCategory *category = [[UIMutableUserNotificationCategory alloc] init];
        category.identifier = @"PRINT_CATEGORY_IDENTIFIER";
        [category setActions:@[laterAction, printAction] forContext:UIUserNotificationActionContextDefault];
        [category setActions:@[laterAction, printAction] forContext:UIUserNotificationActionContextMinimal];
        
        UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:UIUserNotificationTypeBadge|UIUserNotificationTypeAlert categories:[NSSet setWithObjects:category, nil]];
        [[UIApplication sharedApplication] registerUserNotificationSettings:settings];
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

- (IBAction)cancelButtonTapped:(id)sender
{
    if ([self.delegate respondsToSelector:@selector(addPrintLaterJobTableViewControllerDidCancelPrintFlow:)]) {
        [self.delegate addPrintLaterJobTableViewControllerDidCancelPrintFlow:self];
    }
}

@end
