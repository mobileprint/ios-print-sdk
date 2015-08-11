//
// Hewlett-Packard Company
// All rights reserved.
//
// This file, its contents, concepts, methods, behavior, and operation
// (collectively the "Software") are protected by trade secret, patent,
// and copyright laws. The use of the Software is governed by a license
// agreement. Disclosure of the Software to third parties, in any form,
// in whole or in part, is expressly prohibited except as authorized by
// the

#import "HPPPDefaultSettingsTableViewController.h"
#import "HPPP.h"
#import "HPPPDefaultSettingsManager.h"
#import "HPPPSubstituteReachability.h"
#import "HPPPSubstitutePaperSizeTableViewController.h"
#import "HPPPSubstitutePaperTypeTableViewController.h"

@interface HPPPDefaultSettingsTableViewController () <UIPrinterPickerControllerDelegate,
    HPPPSubstitutePaperSizeTableViewControllerDelegate,
    HPPPSubstitutePaperTypeTableViewControllerDelegate>

@property (weak, nonatomic) IBOutlet UITableViewCell *printerNameCell;
@property (weak, nonatomic) IBOutlet UITableViewCell *printerUrlCell;
@property (weak, nonatomic) IBOutlet UITableViewCell *printerNetworkCell;
@property (weak, nonatomic) IBOutlet UITableViewCell *printerModelCell;
@property (weak, nonatomic) IBOutlet UITableViewCell *paperSizeCell;
@property (weak, nonatomic) IBOutlet UITableViewCell *paperTypeCell;

@end

@implementation HPPPDefaultSettingsTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.clearsSelectionOnViewWillAppear = NO;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return 6;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [super tableView:tableView cellForRowAtIndexPath:indexPath];
    [self updateInterfaceValues];
    return cell;
}


#pragma mark - Button handlers

- (IBAction)doneButtonTapped:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Printer selection

- (void)showPrinterSelection:(UITableView *)tableView withCompletion:(void (^)(BOOL userDidSelect))completion
{
    if ([[HPPPSubstituteReachability sharedInstance] isWifiConnected]) {
        UIPrinterPickerController *printerPicker = [UIPrinterPickerController printerPickerControllerWithInitiallySelectedPrinter:nil];
        printerPicker.delegate = self;
        
        [printerPicker presentAnimated:YES completionHandler:^(UIPrinterPickerController *printerPickerController, BOOL userDidSelect, NSError *error){
                if (completion){
                    completion(userDidSelect);
                }
        }];
    } else {
        [[HPPPSubstituteReachability sharedInstance] noPrinterSelectAlert];
    }
}

#pragma mark - UIPrinterPickerControllerDelegate

- (void)printerPickerControllerDidDismiss:(UIPrinterPickerController *)printerPickerController
{
    UIPrinter* selectedPrinter = printerPickerController.selectedPrinter;
    
    if (selectedPrinter != nil){
        NSLog(@"Selected Printer: %@", selectedPrinter.URL);
        [self setPrinterDetails:selectedPrinter];
        [self.tableView reloadData];
    }
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([tableView cellForRowAtIndexPath:indexPath] == self.printerNameCell) {
        [self showPrinterSelection:tableView withCompletion:nil];
    }
}

#pragma mark - Paper Size Delegate

- (void)paperSizeTableViewController:(HPPPSubstitutePaperSizeTableViewController *)paperSizeTableViewController didSelectPaper:(HPPPPaper *)paper
{
    [HPPP sharedInstance].defaultPaper = paper;
    [self.tableView reloadData];
}

#pragma mark - Paper Type Delegate

- (void)paperTypeTableViewController:(HPPPSubstitutePaperTypeTableViewController *)paperTypeTableViewController didSelectPaper:(HPPPPaper *)paper
{
    [HPPP sharedInstance].defaultPaper = paper;
    [self.tableView reloadData];
}

#pragma mark - Helpers

- (void)setPrinterDetails:(UIPrinter *)printer
{
    HPPPDefaultSettingsManager *defaults = [HPPPDefaultSettingsManager sharedInstance];
    defaults.defaultPrinterName = printer.displayName;
    defaults.defaultPrinterUrl = printer.URL.absoluteString;
    defaults.defaultPrinterLocation = printer.displayLocation;
    defaults.defaultPrinterModel = printer.makeAndModel;
    defaults.defaultPrinterNetwork = [[HPPPSubstituteReachability sharedInstance] wifiName];
    
}

- (void)updateInterfaceValues
{
    HPPPDefaultSettingsManager *defaults = [HPPPDefaultSettingsManager sharedInstance];
    HPPPPrintSettings *settings = defaults.defaultPrintSettings;
    
    self.printerNameCell.detailTextLabel.text = settings.printerName;
    self.printerUrlCell.detailTextLabel.text = [NSString stringWithFormat:@"%@", settings.printerUrl];
    self.printerNetworkCell.detailTextLabel.text = defaults.defaultPrinterNetwork;
    self.printerModelCell.detailTextLabel.text = settings.printerModel;
    self.paperSizeCell.detailTextLabel.text = settings.paper.sizeTitle;
    self.paperTypeCell.detailTextLabel.text = settings.paper.typeTitle;
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    HPPPDefaultSettingsManager *defaults = [HPPPDefaultSettingsManager sharedInstance];
    HPPPPrintSettings *settings = defaults.defaultPrintSettings;
    
    if ([segue.identifier isEqualToString:@"SubstitutePaperSizeSegue"]) {
        
        HPPPSubstitutePaperSizeTableViewController *vc = (HPPPSubstitutePaperSizeTableViewController *)segue.destinationViewController;
        vc.currentPaper = settings.paper;
        vc.delegate = self;
    } else if ([segue.identifier isEqualToString:@"SubstitutePaperTypeSegue"]) {
        
        HPPPSubstitutePaperTypeTableViewController *vc = (HPPPSubstitutePaperTypeTableViewController *)segue.destinationViewController;
        vc.currentPaper = settings.paper;
        vc.delegate = self;
    }
}

@end
