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
#import "HPPPPaper.h"
#import "HPPPPrintSettingsTableViewController.h"
#import "HPPPPaperSizeTableViewController.h"
#import "HPPPPaperTypeTableViewController.h"

#define PRINTER_STATUS_INDEX 1
#define PRINTER_STATUS_ROW_HEIGHT 25.0f

@interface HPPPPrintSettingsTableViewController  () <HPPPPaperSizeTableViewControllerDelegate, HPPPPaperTypeTableViewControllerDelegate, UIPrinterPickerControllerDelegate>

@property (nonatomic, strong) HPPP *hppp;

@property (weak, nonatomic) IBOutlet UILabel *printerLabel;
@property (weak, nonatomic) IBOutlet UILabel *paperSizeLabel;
@property (weak, nonatomic) IBOutlet UILabel *paperTypeLabel;

@property (weak, nonatomic) IBOutlet UILabel *selectedPrinterLabel;
@property (weak, nonatomic) IBOutlet UILabel *selectedPaperSizeLabel;
@property (weak, nonatomic) IBOutlet UILabel *selectedPaperTypeLabel;
@property (weak, nonatomic) IBOutlet UILabel *printerStatusLabel;

@property (weak, nonatomic) IBOutlet UITableViewCell *paperTypeCell;
@property (weak, nonatomic) IBOutlet UITableViewCell *printerSelectCell;


@end

@implementation HPPPPrintSettingsTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.hppp = [HPPP sharedInstance];
    
    self.selectedPrinterLabel.text = self.printSettings.printerName;

    self.selectedPaperSizeLabel.text = self.printSettings.paper.sizeTitle;
    self.selectedPaperTypeLabel.text = self.printSettings.paper.typeTitle;
    
    self.printerLabel.font = self.hppp.tableViewCellLabelFont;
    self.printerStatusLabel.font = self.hppp.rulesLabelFont;
    self.paperSizeLabel.font = self.hppp.tableViewCellLabelFont;
    self.paperTypeLabel.font = self.hppp.tableViewCellLabelFont;
    self.selectedPrinterLabel.font = self.hppp.tableViewCellLabelFont;
    self.selectedPaperSizeLabel.font = self.hppp.tableViewCellLabelFont;
    self.selectedPaperTypeLabel.font = self.hppp.tableViewCellLabelFont;
    
    self.paperTypeCell.hidden = self.printSettings.paper.paperSize != SizeLetter;
    
    [self updatePrinterAvailability];
    
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
}

- (void)updatePrinterAvailability
{
    [self.tableView beginUpdates];
    if (self.printSettings.printerIsAvailable){
        [self.printerSelectCell.imageView setImage:nil];
        self.printerStatusLabel.hidden = YES;
    } else {
        UIImage *warningSign = [UIImage imageNamed:@"HPPPDoNoEnter"];
        [self.printerSelectCell.imageView setImage:warningSign];
        self.printerStatusLabel.hidden = NO;
    }
    [self.tableView endUpdates];
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    cell.selected = NO;
    
    if (cell == self.printerSelectCell) {
        UIPrinterPickerController* printerPicker = [UIPrinterPickerController printerPickerControllerWithInitiallySelectedPrinter:nil];
        printerPicker.delegate = self;
        
        if( IS_IPAD ) {
            [printerPicker presentFromRect:self.printerSelectCell.frame
                                    inView:tableView
                                  animated:YES
                         completionHandler:^(UIPrinterPickerController *printerPickerController, BOOL userDidSelect, NSError *error){
                             NSLog(@"closed printer picker");
                         }];
        } else {
            [printerPicker presentAnimated:YES completionHandler:^(UIPrinterPickerController *printerPickerController, BOOL userDidSelect, NSError *error){
                NSLog(@"closed printer picker");
            }];
        }
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [super tableView:tableView cellForRowAtIndexPath:indexPath];
    if (cell.hidden == YES){
        return 0.0f;
    }
    
    CGFloat rowHeight = 0.0f;
    
    switch (indexPath.row) {
        case PRINTER_STATUS_INDEX:
            rowHeight = PRINTER_STATUS_ROW_HEIGHT;
            break;
            
        default:
            rowHeight = self.tableView.rowHeight;
            break;
    }
    
    
    return rowHeight;
}

- (void)viewDidLayoutSubviews
{
    if ([self.tableView respondsToSelector:@selector(setSeparatorInset:)]) {
        [self.tableView setSeparatorInset:UIEdgeInsetsZero];
    }
    
    if ([self.tableView respondsToSelector:@selector(setLayoutMargins:)]) {
        [self.tableView setLayoutMargins:UIEdgeInsetsZero];
    }
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([cell respondsToSelector:@selector(setSeparatorInset:)]) {
        [cell setSeparatorInset:UIEdgeInsetsZero];
    }
    
    if ([cell respondsToSelector:@selector(setLayoutMargins:)]) {
        [cell setLayoutMargins:UIEdgeInsetsZero];
    }
}

#pragma mark - UIPrinterPickerControllerDelegate

- (void)printerPickerControllerDidDismiss:(UIPrinterPickerController *)printerPickerController
{
    UIPrinter* selectedPrinter = printerPickerController.selectedPrinter;
    
    if (selectedPrinter != nil){
        self.selectedPrinterLabel.text = selectedPrinter.displayName;
        self.printSettings.printerName = selectedPrinter.displayName;
        self.printSettings.printerUrl = selectedPrinter.URL;
        self.printSettings.printerIsAvailable = YES;
        
        [self updatePrinterAvailability];
        
        if ([self.delegate respondsToSelector:@selector(printSettingsTableViewController:didChangePrintSettings:)]) {
            [self.delegate printSettingsTableViewController:self didChangePrintSettings:self.printSettings];
        }
    }
}

#pragma mark - HPPPPaperSizeTableViewControllerDelegate

- (void)paperSizeTableViewController:(HPPPPaperSizeTableViewController *)paperSizeTableViewController didSelectPaper:(HPPPPaper *)paper
{
    self.printSettings.paper = paper;
    self.selectedPaperSizeLabel.text = paper.sizeTitle;
    
    // This block of beginUpdates-endUpdates is required to refresh the tableView while it is currently being displayed on screen
    [self.tableView beginUpdates];
    if (paper.paperSize == SizeLetter) {
        self.paperTypeCell.hidden = NO;
        self.printSettings.paper.paperType = Plain;
        self.printSettings.paper.typeTitle = [HPPPPaper titleFromType:Plain];
        self.selectedPaperTypeLabel.text = self.printSettings.paper.typeTitle;
        
    } else {
        self.paperTypeCell.hidden = YES;
        self.printSettings.paper.paperType = Photo;
        self.printSettings.paper.typeTitle = [HPPPPaper titleFromType:Photo];
        self.selectedPaperTypeLabel.text = self.printSettings.paper.typeTitle;
    }
    [self.tableView endUpdates];
    
    if ([self.delegate respondsToSelector:@selector(printSettingsTableViewController:didChangePrintSettings:)]) {
        [self.delegate printSettingsTableViewController:self didChangePrintSettings:self.printSettings];
    }
}

#pragma mark - HPPPPaperTypeTableViewControllerDelegate

- (void)paperTypeTableViewController:(HPPPPaperTypeTableViewController *)paperTypeTableViewController didSelectPaper:(HPPPPaper *)paper
{
    self.printSettings.paper = paper;
    self.selectedPaperTypeLabel.text = paper.typeTitle;
    
    
    if ([self.delegate respondsToSelector:@selector(printSettingsTableViewController:didChangePrintSettings:)]) {
        [self.delegate printSettingsTableViewController:self didChangePrintSettings:self.printSettings];
    }
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"PaperSizeSegue"]) {
        
        HPPPPaperSizeTableViewController *vc = (HPPPPaperSizeTableViewController *)segue.destinationViewController;
        vc.currentPaper = self.printSettings.paper;
        vc.delegate = self;
    } else if ([segue.identifier isEqualToString:@"PaperTypeSegue"]) {
        
        HPPPPaperTypeTableViewController *vc = (HPPPPaperTypeTableViewController *)segue.destinationViewController;
        vc.currentPaper = self.printSettings.paper;
        vc.delegate = self;
    }
}

@end
