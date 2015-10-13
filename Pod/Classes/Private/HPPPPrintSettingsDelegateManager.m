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
NSString * const kHPPPLastBlackAndWhiteFilterSetting = @"kHPPPLastBlackAndWhiteFilterSetting";
NSString * const kHPPPBlackAndWhiteIndicatorText = @"B&W";
NSString * const kHPPPPrintSummarySeparatorText = @" / ";

#pragma mark - HPPPPageRangeViewDelegate

- (void)didSelectPageRange:(HPPPPageRangeKeyboardView *)view pageRange:(HPPPPageRange *)pageRange
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
    HPPPPaper *originalPaper = self.printSettings.paper;
    HPPPPaper *newPaper = paper;
    if (![[originalPaper supportedTypes] isEqualToArray:[newPaper supportedTypes]]) {
        NSUInteger defaultType = [[HPPPPaper defaultTypeForSize:paper.paperSize] unsignedIntegerValue];
        newPaper = [[HPPPPaper alloc] initWithPaperSize:paper.paperSize paperType:defaultType];
    }
    self.paper = newPaper;
    [self.pageSettingsViewController refreshData];
}

#pragma mark - HPPPPaperTypeTableViewControllerDelegate

- (void)paperTypeTableViewController:(HPPPPaperTypeTableViewController *)paperTypeTableViewController didSelectPaper:(HPPPPaper *)paper
{
    self.paper = paper;
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
    self.printSettings.color = !blackAndWhite;
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:[NSNumber numberWithBool:blackAndWhite] forKey:kHPPPLastBlackAndWhiteFilterSetting];
    [defaults synchronize];
}

#pragma mark - Paper

- (void)setPaper:(HPPPPaper *)paper
{
    _paper = paper;
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:[NSNumber numberWithInteger:paper.paperSize] forKey:kHPPPLastPaperSizeSetting];
    [defaults setObject:[NSNumber numberWithInteger:paper.paperType] forKey:kHPPPLastPaperTypeSetting];
    [defaults synchronize];
    self.printSettings.paper = paper;
}

#pragma mark - Special Text Generation

- (NSString *)printLaterJobSummaryText
{
    _printLaterJobSummaryText = [self summaryText];
    
    return _printLaterJobSummaryText;
}

- (NSString *)printJobSummaryText
{
    _printJobSummaryText = [self summaryText];
    
    if( self.printSettings.paper ) {
        if( _printJobSummaryText.length > 0 ) {
            _printJobSummaryText = [_printJobSummaryText stringByAppendingString:kHPPPPrintSummarySeparatorText];
        }

        NSString *paperString = [NSString stringWithFormat:@"%@ %@",self.printSettings.paper.sizeTitle, self.printSettings.paper.typeTitle];
        _printJobSummaryText = [_printJobSummaryText stringByAppendingString:paperString];
    }
    
    return _printJobSummaryText;
}

- (NSString *)summaryText
{
    NSString *summaryText = @"";

    if( 1 < self.printItem.numberOfPages && ![self allPagesSelected]) {
        summaryText = [NSString stringWithFormat:@"%ld of %ld Pages", (long)[self.pageRange getUniquePages].count, (long)self.printItem.numberOfPages];
    }
    
    if( self.blackAndWhite ) {
        if( summaryText.length > 0 ) {
            summaryText = [summaryText stringByAppendingString:kHPPPPrintSummarySeparatorText];
        }
        summaryText = [summaryText stringByAppendingString:kHPPPBlackAndWhiteIndicatorText];
    }
    
    if( summaryText.length > 0 ) {
        summaryText = [summaryText stringByAppendingString:kHPPPPrintSummarySeparatorText];
    }
    
    NSString *copyText = @"Copies";
    if( 1 == self.numCopies ) {
        copyText = @"Copy";
    }
    
    summaryText = [summaryText stringByAppendingString:[NSString stringWithFormat:@"%ld %@", (long)self.numCopies, copyText]];
    
    return summaryText;
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

- (NSString *)printLaterLabelText
{
    NSInteger numPagesToBePrinted = 0;
    if( ![self noPagesSelected]) {
        numPagesToBePrinted = [self.pageRange getPages].count * self.numCopies;
    }
    
    BOOL printingOneCopyOfAllPages = (1 == self.numCopies && [self allPagesSelected]);
    if( [self noPagesSelected]  ||  printingOneCopyOfAllPages ) {
        _printLaterLabelText = @"Add to Print Queue";
    } else if( 1 == numPagesToBePrinted ) {
        _printLaterLabelText = @"Add 1 Page";
    } else {
        _printLaterLabelText = [NSString stringWithFormat:@"Add %ld Pages", (long)numPagesToBePrinted];
    }
    
    return _printLaterLabelText;
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
    NSMutableString *text = [NSMutableString stringWithString:@""];
    if (![HPPP sharedInstance].hidePaperSizeOption) {
        [text appendFormat:@"%@, ", self.printSettings.paper.sizeTitle];
    }
    if (![HPPP sharedInstance].hidePaperTypeOption) {
        [text appendFormat:@"%@, ", self.printSettings.paper.typeTitle];
    }
    [text appendFormat:@"%@", self.selectedPrinterText];
    _printSettingsText = text;
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
    self.paper = [HPPPPrintSettingsDelegateManager lastPaperUsed];
    
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
        NSNumber *lastBlackAndWhiteUsed = [[NSUserDefaults standardUserDefaults] objectForKey:kHPPPLastBlackAndWhiteFilterSetting];
        if (lastBlackAndWhiteUsed != nil) {
            self.blackAndWhite = lastBlackAndWhiteUsed.boolValue;
        }
    }
}

+ (HPPPPaper *)lastPaperUsed
{
    HPPPPaper *paper = [HPPP sharedInstance].defaultPaper;

    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSNumber *lastSizeUsed = [defaults objectForKey:kHPPPLastPaperSizeSetting];
    NSNumber *lastTypeUsed = [defaults objectForKey:kHPPPLastPaperTypeSetting];
    if (lastSizeUsed && lastTypeUsed) {
        NSUInteger sizeId = [lastSizeUsed unsignedIntegerValue];
        NSUInteger typeId = [lastTypeUsed unsignedIntegerValue];
        if ([HPPPPaper supportedPaperSize:sizeId andType:typeId]) {
            paper = [[HPPPPaper alloc] initWithPaperSize:sizeId paperType:typeId];
        }
    }
    
    return paper;
}

- (void)savePrinterId:(NSString *)printerId
{
    self.printSettings.printerId = printerId;
    NSUserDefaults * defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:self.printSettings.printerId forKey:kHPPPLastPrinterIDSetting];
    [defaults synchronize];
    
}

@end
