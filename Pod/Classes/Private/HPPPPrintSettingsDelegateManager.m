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

#import "HPPPPrintSettingsDelegateManager.h"
#import "HPPPPageSettingsTableViewController.h"
#import "HPPPDefaultSettingsManager.h"
#import "NSBundle+HPPPLocalizable.h"

@implementation HPPPPrintSettingsDelegateManager

#define kPrinterDetailsNotAvailable HPPPLocalizedString(@"Not Available", @"Printer details not available")
#define kHPPPSelectPrinterPrompt HPPPLocalizedString(@"Select Printer", nil)

NSString * const kHPPPLastPrinterNameSetting = @"kHPPPLastPrinterNameSetting";
NSString * const kHPPPLastPrinterIDSetting = @"kHPPPLastPrinterIDSetting";
NSString * const kHPPPLastPrinterModelSetting = @"kHPPPLastPrinterModelSetting";
NSString * const kHPPPLastPrinterLocationSetting = @"kHPPPLastPrinterLocationSetting";
NSString * const kHPPPLastPaperSizeSetting = @"kHPPPLastPaperSizeSetting";
NSString * const kHPPPLastPaperTypeSetting = @"kHPPPLastPaperTypeSetting";
NSString * const kHPPPLastFilterSetting = @"kHPPPLastFilterSetting";

#pragma mark - HPPPPageRangeViewDelegate

- (void)didSelectPageRange:(HPPPPageRangeView *)view pageRange:(HPPPPageRange *)pageRange
{
    self.pageRange = pageRange;
    [self.pageSettingsViewController refreshData];
}

#pragma mark - HPPPPrintSettingsTableViewControllerDelegate

- (void)printSettingsTableViewController:(HPPPPrintSettingsTableViewController *)printSettingsTableViewController didChangePrintSettings:(HPPPPrintSettings *)printSettings
{
    self.printSettings.printerName = printSettings.printerName;
    self.printSettings.printerUrl = printSettings.printerUrl;
    self.printSettings.printerModel = printSettings.printerModel;
    self.printSettings.printerLocation = printSettings.printerLocation;
    self.printSettings.printerIsAvailable = printSettings.printerIsAvailable;
    
    [self savePrinterInfo];
    
    [self paperSizeTableViewController:(HPPPPaperSizeTableViewController *)printSettingsTableViewController didSelectPaper:printSettings.paper];
    
    [self paperTypeTableViewController:(HPPPPaperTypeTableViewController *)printSettingsTableViewController didSelectPaper:printSettings.paper];
    
    [self.pageSettingsViewController refreshData];
}

#pragma mark - HPPPPaperSizeTableViewControllerDelegate

- (void)paperSizeTableViewController:(HPPPPaperSizeTableViewController *)paperSizeTableViewController didSelectPaper:(HPPPPaper *)paper
{
    if (self.printSettings.paper.paperSize != SizeLetter && paper.paperSize == SizeLetter){
        paper.paperType = Plain;
        paper.typeTitle = [HPPPPaper titleFromType:Plain];
    } else if (self.printSettings.paper.paperSize == SizeLetter && paper.paperSize != SizeLetter){
        paper.paperType = Photo;
        paper.typeTitle = [HPPPPaper titleFromType:Photo];
    }
    self.printSettings.paper = paper;
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:[NSNumber numberWithInteger:self.printSettings.paper.paperSize] forKey:kHPPPLastPaperSizeSetting];
    [defaults synchronize];
    
    [self.pageSettingsViewController refreshData];
}

#pragma mark - HPPPPaperTypeTableViewControllerDelegate

- (void)paperTypeTableViewController:(HPPPPaperTypeTableViewController *)paperTypeTableViewController didSelectPaper:(HPPPPaper *)paper
{
    self.printSettings.paper = paper;
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:[NSNumber numberWithInteger:self.printSettings.paper.paperType] forKey:kHPPPLastPaperTypeSetting];
    [defaults synchronize];
 
    [self.pageSettingsViewController refreshData];
}

#pragma mark - UIPrinterPickerControllerDelegate

- (void)printerPickerControllerDidDismiss:(UIPrinterPickerController *)printerPickerController
{
    UIPrinter* selectedPrinter = printerPickerController.selectedPrinter;
    
    if (selectedPrinter != nil){
        HPPPLogInfo(@"Selected Printer: %@", selectedPrinter.URL);
        self.printSettings.printerIsAvailable = YES;
        [self setPrinterDetails:selectedPrinter];
        [self savePrinterInfo];
    }
    
    [self.pageSettingsViewController refreshData];
}

#pragma mark - UIPrintInteractionControllerDelegate

- (UIViewController *)printInteractionControllerParentViewController:(UIPrintInteractionController *)printInteractionController
{
    return nil;
}

- (UIPrintPaper *)printInteractionController:(UIPrintInteractionController *)printInteractionController choosePaper:(NSArray *)paperList
{
    UIPrintPaper * paper = [UIPrintPaper bestPaperForPageSize:[self.printSettings.paper printerPaperSize] withPapersFromArray:paperList];
    return paper;
}

#pragma mark - Number of Copies

- (void)setNumCopies:(NSInteger)numCopies
{
    _numCopies = numCopies;
    
    self.numCopiesLabelText = (self.numCopies == 1) ? HPPPLocalizedString(@"1 Copy", nil) : [NSString stringWithFormat:HPPPLocalizedString(@"%ld Copies", @"Number of copies"), (long)self.numCopies];
    
    [self.pageSettingsViewController refreshData];
    
}

#pragma mark - Black and White

- (void)setBlackAndWhite:(BOOL)blackAndWhite
{
    _blackAndWhite = blackAndWhite;
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:[NSNumber numberWithInteger:blackAndWhite] forKey:kHPPPLastFilterSetting];
    [defaults synchronize];
}

#pragma mark - Special Text Generation

- (NSString *)printLaterSummaryText
{
    return nil;
}

- (NSString *)printJobSummaryText
{
    _printJobSummaryText = @"";
    if( 1 < self.printItem.numberOfPages && ![self allPagesSelected]) {
        _printJobSummaryText = [NSString stringWithFormat:@"%ld of %ld Pages Selected", (long)[self.pageRange getUniquePages].count, (long)self.printItem.numberOfPages];
    }
    
    if( _printJobSummaryText.length > 0 ) {
        _printJobSummaryText = [_printJobSummaryText stringByAppendingString:@"/"];
    }
    
    _printJobSummaryText = [_printJobSummaryText stringByAppendingString:self.printSettings.paper.sizeTitle];
    
    return _printJobSummaryText;
}

- (NSString *)printLabelText
{
    NSInteger numPagesToBePrinted = 0;
    if( ![self noPagesSelected]) {
        numPagesToBePrinted = [self.pageRange getPages].count * self.numCopies;
    }
    
    BOOL printingOneCopyOfAllPages = (1 == self.numCopies && [self allPagesSelected]);
    if( [self noPagesSelected]  ||  printingOneCopyOfAllPages ) {
        _printLabelText = @"Print";
    } else if( 1 == numPagesToBePrinted ) {
        _printLabelText = @"Print 1 Page";
    } else {
        _printLabelText = [NSString stringWithFormat:@"Print %ld Pages", (long)numPagesToBePrinted];
    }
    
    return _printLabelText;
}

- (NSString *)pageRangeText
{
    if( [self.pageRange getPages].count > 0 ) {
        _pageRangeText = self.pageRange.range;
    } else {
        _pageRangeText = kPageRangeNoPages;
    }
    
    return _pageRangeText;
}

- (NSString *)printSettingsText
{
    _printSettingsText = [NSString stringWithFormat:@"%@, %@", self.printSettings.paper.sizeTitle, self.printSettings.paper.typeTitle];
    
    if( ![self.selectedPrinterText isEqualToString:kHPPPSelectPrinterPrompt] ) {
        _printSettingsText = [_printSettingsText stringByAppendingString:[NSString stringWithFormat:@", %@", self.selectedPrinterText]];
    }
    
    return _printSettingsText;
}

- (NSString *)selectedPrinterText
{
    return self.printSettings.printerName == nil ? kHPPPSelectPrinterPrompt : self.printSettings.printerName;
}

#pragma mark - Helpers

- (BOOL)allPagesSelected
{
    return [self.pageRange.allPagesIndicator isEqualToString:self.pageRange.range];
}

- (BOOL)noPagesSelected
{
    return [@"" isEqualToString:self.pageRange.range];
}

-(void)includePageInPageRange:(BOOL)includePage pageNumber:(NSInteger)pageNumber
{
    if( includePage ) {
        [self.pageRange addPage:[NSNumber numberWithInteger:pageNumber]];
    } else {
        [self.pageRange removePage:[NSNumber numberWithInteger:pageNumber]];
    }
    
    [self.pageSettingsViewController refreshData];
}

- (void)setPrinterDetails:(UIPrinter *)printer
{
    self.printSettings.printerUrl = printer.URL;
    self.printSettings.printerName = printer.displayName;
    self.printSettings.printerLocation = printer.displayLocation;
    self.printSettings.printerModel = printer.makeAndModel;
}

#pragma mark - Last Used Settings

- (void)savePrinterInfo
{
    NSUserDefaults * defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:self.printSettings.printerUrl.absoluteString forKey:LAST_PRINTER_USED_URL_SETTING];
    [defaults setObject:self.printSettings.printerName forKey:kHPPPLastPrinterNameSetting];
    [defaults setObject:self.printSettings.printerId forKey:kHPPPLastPrinterIDSetting];
    [defaults setObject:self.printSettings.printerModel forKey:kHPPPLastPrinterModelSetting];
    [defaults setObject:self.printSettings.printerLocation forKey:kHPPPLastPrinterLocationSetting];
    [defaults synchronize];
}

- (void)loadLastUsed
{
    self.printSettings.paper = [self lastPaperUsed];
    
    HPPPDefaultSettingsManager *settings = [HPPPDefaultSettingsManager sharedInstance];
    if( [settings isDefaultPrinterSet] ) {
        self.printSettings.printerName = settings.defaultPrinterName;
        self.printSettings.printerUrl = [NSURL URLWithString:settings.defaultPrinterUrl];
        self.printSettings.printerId = nil;
        self.printSettings.printerModel = settings.defaultPrinterModel;
        self.printSettings.printerLocation = settings.defaultPrinterLocation;
    } else {
        self.printSettings.printerName = [[NSUserDefaults standardUserDefaults] objectForKey:kHPPPLastPrinterNameSetting];
        self.printSettings.printerUrl = [NSURL URLWithString:[[NSUserDefaults standardUserDefaults] objectForKey:LAST_PRINTER_USED_URL_SETTING]];
        self.printSettings.printerId = [[NSUserDefaults standardUserDefaults] objectForKey:kHPPPLastPrinterIDSetting];
        self.printSettings.printerModel = [[NSUserDefaults standardUserDefaults] objectForKey:kHPPPLastPrinterModelSetting];
        self.printSettings.printerLocation = [[NSUserDefaults standardUserDefaults] objectForKey:kHPPPLastPrinterLocationSetting];
    }
    
    if (IS_OS_8_OR_LATER) {
        NSNumber *lastFilterUsed = [[NSUserDefaults standardUserDefaults] objectForKey:kHPPPLastFilterSetting];
        if (lastFilterUsed != nil) {
            self.blackAndWhite = lastFilterUsed.boolValue;
        }
    }
}

- (HPPPPaper *)lastPaperUsed
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    NSNumber *lastSizeUsed = [defaults objectForKey:kHPPPLastPaperSizeSetting];
    NSNumber *lastTypeUsed = [defaults objectForKey:kHPPPLastPaperTypeSetting];
    
    PaperSize paperSize = (PaperSize)[HPPP sharedInstance].defaultPaper.paperSize;
    if (lastSizeUsed) {
        paperSize = (PaperSize)[lastSizeUsed integerValue];
    }
    
    PaperType paperType = SizeLetter == paperSize ? Plain : Photo;
    if (SizeLetter == paperSize && lastTypeUsed) {
        paperType = (PaperType)[lastTypeUsed integerValue];
    }
    
    return [[HPPPPaper alloc] initWithPaperSize:paperSize paperType:paperType];
}

- (void)savePrinterId:(NSString *)printerId
{
    self.printSettings.printerId = printerId;
    NSUserDefaults * defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:self.printSettings.printerId forKey:kHPPPLastPrinterIDSetting];
    [defaults synchronize];
    
}

@end
