//
//  HPPPPrintSettingsDelegateManager.m
//  Pods
//
//  Created by Bozo on 8/11/15.
//
//

#import "HPPPPrintSettingsDelegateManager.h"
#import "HPPPPageSettingsTableViewController.h"
#import "HPPPDefaultSettingsManager.h"
#import "NSBundle+HPPPLocalizable.h"

@implementation HPPPPrintSettingsDelegateManager

#define kPrinterDetailsNotAvailable HPPPLocalizedString(@"Not Available", @"Printer details not available")

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
    [self.vc refreshData];
}

#pragma mark - HPPPPrintSettingsTableViewControllerDelegate

- (void)printSettingsTableViewController:(HPPPPrintSettingsTableViewController *)printSettingsTableViewController didChangePrintSettings:(HPPPPrintSettings *)printSettings
{
    self.currentPrintSettings.printerName = printSettings.printerName;
    self.currentPrintSettings.printerUrl = printSettings.printerUrl;
    self.currentPrintSettings.printerModel = printSettings.printerModel;
    self.currentPrintSettings.printerLocation = printSettings.printerLocation;
    self.currentPrintSettings.printerIsAvailable = printSettings.printerIsAvailable;
    
    [self savePrinterInfo];
    
    [self paperSizeTableViewController:(HPPPPaperSizeTableViewController *)printSettingsTableViewController didSelectPaper:printSettings.paper];
    
    [self paperTypeTableViewController:(HPPPPaperTypeTableViewController *)printSettingsTableViewController didSelectPaper:printSettings.paper];
    
//    [self reloadPrinterSelectionSection];
    [self.vc refreshData];
}

#pragma mark - HPPPPaperSizeTableViewControllerDelegate

- (void)paperSizeTableViewController:(HPPPPaperSizeTableViewController *)paperSizeTableViewController didSelectPaper:(HPPPPaper *)paper
{
    if (self.currentPrintSettings.paper.paperSize != SizeLetter && paper.paperSize == SizeLetter){
        paper.paperType = Plain;
        paper.typeTitle = [HPPPPaper titleFromType:Plain];
    } else if (self.currentPrintSettings.paper.paperSize == SizeLetter && paper.paperSize != SizeLetter){
        paper.paperType = Photo;
        paper.typeTitle = [HPPPPaper titleFromType:Photo];
    }
    self.currentPrintSettings.paper = paper;
    
//    [self reloadPaperSelectionSection];
//    
//    [self updatePageSettingsUI];
//    [self updatePrintSettingsUI];
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:[NSNumber numberWithInteger:self.currentPrintSettings.paper.paperSize] forKey:kHPPPLastPaperSizeSetting];
    [defaults synchronize];
    
//    [self changePaper];
    [self.vc refreshData];
}

#pragma mark - HPPPPaperTypeTableViewControllerDelegate

- (void)paperTypeTableViewController:(HPPPPaperTypeTableViewController *)paperTypeTableViewController didSelectPaper:(HPPPPaper *)paper
{
    self.currentPrintSettings.paper = paper;
//    [self updatePrintSettingsUI];
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:[NSNumber numberWithInteger:self.currentPrintSettings.paper.paperType] forKey:kHPPPLastPaperTypeSetting];
    [defaults synchronize];
 
    [self.vc refreshData];
}

#pragma mark - UIPrinterPickerControllerDelegate

- (void)printerPickerControllerDidDismiss:(UIPrinterPickerController *)printerPickerController
{
    UIPrinter* selectedPrinter = printerPickerController.selectedPrinter;
    
    if (selectedPrinter != nil){
        HPPPLogInfo(@"Selected Printer: %@", selectedPrinter.URL);
        self.currentPrintSettings.printerIsAvailable = YES;
        [self setPrinterDetails:selectedPrinter];
        [self savePrinterInfo];
    }
    
    [self.vc refreshData];
}

#pragma mark - NumCopies

- (void)setNumCopies:(NSInteger)numCopies
{
    _numCopies = numCopies;
    
    self.numCopiesLabelText = (self.numCopies == 1) ? HPPPLocalizedString(@"1 Copy", nil) : [NSString stringWithFormat:HPPPLocalizedString(@"%ld Copies", @"Number of copies"), (long)self.numCopies];
    
//    if ([self.dataSource respondsToSelector:@selector(numberOfPrintingItems)]) {
//        NSInteger numberOfJobs = [self.dataSource numberOfPrintingItems];
//        
//        self.printLabelText = [self printLabelText:numberOfJobs copies:self.numCopies];
//    } else {
//        self.printLabelText = [self printLabelText:1 copies:self.numCopies];
//    }
    
    [self.vc refreshData];
    
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

//- (NSString *)printLabelText:(NSInteger)numberOfPrintingItems copies:(NSInteger)copies
//{
//    NSString *result = nil;
//    
//    if (numberOfPrintingItems == 1) {
//        result = HPPPLocalizedString(@"Print", @"Caption of the button for printing");
//    } else {
//        NSInteger total = numberOfPrintingItems * copies;
//        
//        if (total == 2) {
//            result = HPPPLocalizedString(@"Print both", @"Caption of the button for printing");
//        } else {
//            result = [NSString stringWithFormat:HPPPLocalizedString(@"Print all %lu", @"Caption of the button for printing"), (long)total];
//        }
//    }
//    
//    return result;
//}

- (NSString *)printLaterSummary
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
    
    _printJobSummaryText = [_printJobSummaryText stringByAppendingString:self.currentPrintSettings.paper.sizeTitle];
    
//    self.jobSummaryCell.textLabel.text = text;
//    
//    if( 0 == allPages.count  ||  printingOneCopyOfAllPages ) {
//        self.printLabelText = @"Print";
//    } else if( 1 == numPagesToBePrinted ) {
//        self.printLabelText = @"Print 1 Page";
//    } else {
//        self.printLabelText = [NSString stringWithFormat:@"Print %ld Pages", (long)numPagesToBePrinted];
//    }
    
//    HPPP *hppp = [HPPP sharedInstance];
//    if( 0 == allPages.count ) {
//        self.printCell.userInteractionEnabled = FALSE;
//        self.printLabel.textColor = [hppp.appearance.addPrintLaterJobScreenAttributes objectForKey:kHPPPAddPrintLaterJobScreenAddToPrintQInactiveColorAttribute];
//    } else {
//        self.printCell.userInteractionEnabled = TRUE;
//        self.printLabel.textColor = [hppp.appearance.addPrintLaterJobScreenAttributes objectForKey:kHPPPAddPrintLaterJobScreenAddToPrintQActiveColorAttribute];;
//    }

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
    
    [self.vc refreshData];
}

- (void)setPrinterDetails:(UIPrinter *)printer
{
    self.currentPrintSettings.printerUrl = printer.URL;
    self.currentPrintSettings.printerName = printer.displayName;
    self.currentPrintSettings.printerLocation = printer.displayLocation;
    self.currentPrintSettings.printerModel = printer.makeAndModel;
}

#pragma mark - Last Used Settings

- (void)savePrinterInfo
{
    NSUserDefaults * defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:self.currentPrintSettings.printerUrl.absoluteString forKey:LAST_PRINTER_USED_URL_SETTING];
    [defaults setObject:self.currentPrintSettings.printerName forKey:kHPPPLastPrinterNameSetting];
    [defaults setObject:self.currentPrintSettings.printerId forKey:kHPPPLastPrinterIDSetting];
    [defaults setObject:self.currentPrintSettings.printerModel forKey:kHPPPLastPrinterModelSetting];
    [defaults setObject:self.currentPrintSettings.printerLocation forKey:kHPPPLastPrinterLocationSetting];
    [defaults synchronize];
}

- (void)loadLastUsed
{
    self.currentPrintSettings.paper = [self lastPaperUsed];
    
    HPPPDefaultSettingsManager *settings = [HPPPDefaultSettingsManager sharedInstance];
    if( [settings isDefaultPrinterSet] ) {
        self.currentPrintSettings.printerName = settings.defaultPrinterName;
        self.currentPrintSettings.printerUrl = [NSURL URLWithString:settings.defaultPrinterUrl];
        self.currentPrintSettings.printerId = nil;
        self.currentPrintSettings.printerModel = settings.defaultPrinterModel;
        self.currentPrintSettings.printerLocation = settings.defaultPrinterLocation;
    } else {
        self.currentPrintSettings.printerName = [[NSUserDefaults standardUserDefaults] objectForKey:kHPPPLastPrinterNameSetting];
        self.currentPrintSettings.printerUrl = [NSURL URLWithString:[[NSUserDefaults standardUserDefaults] objectForKey:LAST_PRINTER_USED_URL_SETTING]];
        self.currentPrintSettings.printerId = [[NSUserDefaults standardUserDefaults] objectForKey:kHPPPLastPrinterIDSetting];
        self.currentPrintSettings.printerModel = [[NSUserDefaults standardUserDefaults] objectForKey:kHPPPLastPrinterModelSetting];
        self.currentPrintSettings.printerLocation = [[NSUserDefaults standardUserDefaults] objectForKey:kHPPPLastPrinterLocationSetting];
    }
    
    if (IS_OS_8_OR_LATER) {
        NSNumber *lastFilterUsed = [[NSUserDefaults standardUserDefaults] objectForKey:kHPPPLastFilterSetting];
        if (lastFilterUsed != nil) {
//            self.blackAndWhiteModeSwitch.on = lastFilterUsed.boolValue;
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

- (void)setLastOptionsUsedWithPrintController:(UIPrintInteractionController *)printController
{
    NSMutableDictionary *lastOptionsUsed = [NSMutableDictionary dictionary];
    [lastOptionsUsed setValue:self.currentPrintSettings.paper.typeTitle forKey:kHPPPPaperTypeId];
    [lastOptionsUsed setValue:self.currentPrintSettings.paper.sizeTitle forKey:kHPPPPaperSizeId];
    [lastOptionsUsed setValue:[NSNumber numberWithBool:self.blackAndWhite] forKey:kHPPPBlackAndWhiteFilterId];
    [lastOptionsUsed setValue:[NSNumber numberWithInteger:self.numCopies] forKey:kHPPPNumberOfCopies];
    
    NSString * printerID = printController.printInfo.printerID;
    if (printerID) {
        [lastOptionsUsed setValue:printerID forKey:kHPPPPrinterId];
        if ([printerID isEqualToString:self.currentPrintSettings.printerUrl.absoluteString]) {
            [lastOptionsUsed setValue:self.currentPrintSettings.printerName forKey:kHPPPPrinterDisplayName];
            [lastOptionsUsed setValue:self.currentPrintSettings.printerLocation forKey:kHPPPPrinterDisplayLocation];
            [lastOptionsUsed setValue:self.currentPrintSettings.printerModel forKey:kHPPPPrinterMakeAndModel];
        } else {
            [lastOptionsUsed setValue:kPrinterDetailsNotAvailable forKey:kHPPPPrinterDisplayName];
            [lastOptionsUsed setValue:kPrinterDetailsNotAvailable forKey:kHPPPPrinterDisplayLocation];
            [lastOptionsUsed setValue:kPrinterDetailsNotAvailable forKey:kHPPPPrinterMakeAndModel];
        }
    }
    [HPPP sharedInstance].lastOptionsUsed = [NSDictionary dictionaryWithDictionary:lastOptionsUsed];
    
    self.currentPrintSettings.printerId = printerID;
    NSUserDefaults * defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:self.currentPrintSettings.printerId forKey:kHPPPLastPrinterIDSetting];
    [defaults synchronize];
    
}

@end
