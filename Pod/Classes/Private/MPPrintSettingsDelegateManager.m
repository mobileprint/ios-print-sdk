//
// HP Inc.
// All rights reserved.
//
// This file, its contents, concepts, methods, behavior, and operation
// (collectively the "Software") are protected by trade secret, patent,
// and copyright laws. The use of the Software is governed by a license
// agreement. Disclosure of the Software to third parties, in any form,
// in whole or in part, is expressly prohibited except as authorized by
// the license agreement.
//

#import "MPPrintSettingsDelegateManager.h"
#import "MPPageSettingsTableViewController.h"
#import "MPDefaultSettingsManager.h"
#import "NSBundle+MPLocalizable.h"

@implementation MPPrintSettingsDelegateManager

#define kPrinterDetailsNotAvailable MPLocalizedString(@"Not Available", @"Printer details not available")
#define kMPSelectPrinterPrompt MPLocalizedString(@"Select Printer", nil)

NSString * const kMPLastPrinterNameSetting = @"kMPLastPrinterNameSetting";
NSString * const kMPLastPrinterIDSetting = @"kMPLastPrinterIDSetting";
NSString * const kMPLastPrinterModelSetting = @"kMPLastPrinterModelSetting";
NSString * const kMPLastPrinterLocationSetting = @"kMPLastPrinterLocationSetting";
NSString * const kMPLastPaperSizeSetting = @"kMPLastPaperSizeSetting";
NSString * const kMPLastPaperTypeSetting = @"kMPLastPaperTypeSetting";
NSString * const kMPLastBlackAndWhiteFilterSetting = @"kMPLastBlackAndWhiteFilterSetting";
NSString * const kMPPrintSummarySeparatorText = @" / ";

#pragma mark - MPPageRangeViewDelegate

- (void)didSelectPageRange:(MPPageRangeKeyboardView *)view pageRange:(MPPageRange *)pageRange
{
    self.pageRange = pageRange;
    [self.pageSettingsViewController refreshData];
}

#pragma mark - MPPrintSettingsTableViewControllerDelegate

- (void)printSettingsTableViewController:(MPPrintSettingsTableViewController *)printSettingsTableViewController didChangePrintSettings:(MPPrintSettings *)printSettings
{
    self.printSettings.printerName = printSettings.printerName;
    self.printSettings.printerUrl = printSettings.printerUrl;
    self.printSettings.printerModel = printSettings.printerModel;
    self.printSettings.printerLocation = printSettings.printerLocation;
    self.printSettings.printerIsAvailable = printSettings.printerIsAvailable;
    
    [self savePrinterInfo];
    
    [self paperSizeTableViewController:(MPPaperSizeTableViewController *)printSettingsTableViewController didSelectPaper:printSettings.paper];
    
    [self paperTypeTableViewController:(MPPaperTypeTableViewController *)printSettingsTableViewController didSelectPaper:printSettings.paper];
    
    [self.pageSettingsViewController refreshData];
}

#pragma mark - MPPaperSizeTableViewControllerDelegate

- (void)paperSizeTableViewController:(MPPaperSizeTableViewController *)paperSizeTableViewController didSelectPaper:(MPPaper *)paper
{
    MPPaper *originalPaper = self.printSettings.paper;
    MPPaper *newPaper = paper;
    if (![[originalPaper supportedTypes] isEqualToArray:[newPaper supportedTypes]]) {
        NSUInteger defaultType = [[MPPaper defaultTypeForSize:paper.paperSize] unsignedIntegerValue];
        newPaper = [[MPPaper alloc] initWithPaperSize:paper.paperSize paperType:defaultType];
    }
    self.paper = newPaper;
    [self.pageSettingsViewController refreshData];
}

#pragma mark - MPPaperTypeTableViewControllerDelegate

- (void)paperTypeTableViewController:(MPPaperTypeTableViewController *)paperTypeTableViewController didSelectPaper:(MPPaper *)paper
{
    self.paper = paper;
    [self.pageSettingsViewController refreshData];
}

#pragma mark - UIPrinterPickerControllerDelegate

- (void)printerPickerControllerDidDismiss:(UIPrinterPickerController *)printerPickerController
{
    UIPrinter* selectedPrinter = printerPickerController.selectedPrinter;
    
    if (selectedPrinter != nil){
        MPLogInfo(@"Selected Printer: %@", selectedPrinter.URL);
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

    self.numCopiesLabelText = (self.numCopies == 1) ? MPLocalizedString(@"1 Copy", nil) : [NSString stringWithFormat:MPLocalizedString(@"%ld Copies", @"Number of copies"), (long)self.numCopies];
    
    [self.pageSettingsViewController refreshData];
    
}

#pragma mark - Black and White

- (void)setBlackAndWhite:(BOOL)blackAndWhite
{
    _blackAndWhite = blackAndWhite;
    self.printSettings.color = !blackAndWhite;
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:[NSNumber numberWithBool:blackAndWhite] forKey:kMPLastBlackAndWhiteFilterSetting];
    [defaults synchronize];
}

#pragma mark - Paper

- (void)setPaper:(MPPaper *)paper
{
    _paper = paper;
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:[NSNumber numberWithInteger:paper.paperSize] forKey:kMPLastPaperSizeSetting];
    [defaults setObject:[NSNumber numberWithInteger:paper.paperType] forKey:kMPLastPaperTypeSetting];
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
            _printJobSummaryText = [_printJobSummaryText stringByAppendingString:kMPPrintSummarySeparatorText];
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
        summaryText = [NSString stringWithFormat:MPLocalizedString(@"%ld of %ld Pages", @"page range label in job summary"), (long)[self.pageRange getUniquePages].count, (long)self.printItem.numberOfPages];
    }
    
    if( self.blackAndWhite ) {
        if( summaryText.length > 0 ) {
            summaryText = [summaryText stringByAppendingString:kMPPrintSummarySeparatorText];
        }
        summaryText = [summaryText stringByAppendingString:MPLocalizedString(@"B&W", @"Let's the user know their job will be printed in black-and-white")];
    }
    
    if( summaryText.length > 0 ) {
        summaryText = [summaryText stringByAppendingString:kMPPrintSummarySeparatorText];
    }
    
    NSString *copyText = MPLocalizedString(@"Copies", @"copies label in job summary");
    if( 1 == self.numCopies ) {
        copyText = MPLocalizedString(@"Copy", "copy label in job summary");
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
        _printLabelText = MPLocalizedString(@"Print", @"Print button label image");
    } else if( 1 == numPagesToBePrinted ) {
        _printLabelText = MPLocalizedString(@"Print 1 Page", @"Print button label single page");
    } else {
        _printLabelText = [NSString stringWithFormat:MPLocalizedString(@"Print %ld Pages", "Print button label with multiple pages"), (long)numPagesToBePrinted];
    }
    
    return _printLabelText;
}

- (NSString *)printMultipleJobsFromQueueLabelText
{
    return MPLocalizedString(@"Print All", @"Print button label for printing multiple jobs");
}

- (NSString *)printSingleJobFromQueueLabelText
{
    return MPLocalizedString(@"Print", @"Print button label for printing a single job");
}

- (NSString *)printLaterLabelText
{
    NSInteger numPagesToBePrinted = 0;
    if( ![self noPagesSelected]) {
        numPagesToBePrinted = [self.pageRange getPages].count * self.numCopies;
    }
    
    BOOL printingOneCopyOfAllPages = (1 == self.numCopies && [self allPagesSelected]);
    if( [self noPagesSelected]  ||  printingOneCopyOfAllPages ) {
        _printLaterLabelText = MPLocalizedString(@"Add to Print Queue", @"Add image to print queue button label");
    } else if( 1 == numPagesToBePrinted ) {
        _printLaterLabelText = MPLocalizedString(@"Add 1 Page", @"Add single pdf doc to print queue button label");
    } else {
        _printLaterLabelText = [NSString stringWithFormat:MPLocalizedString(@"Add %ld Pages", @"Add multipage pdf to print queue button label"), (long)numPagesToBePrinted];
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
    if (![MP sharedInstance].hidePaperSizeOption) {
        [text appendFormat:@"%@, ", self.printSettings.paper.sizeTitle];
    }
    if (![MP sharedInstance].hidePaperTypeOption) {
        [text appendFormat:@"%@, ", self.printSettings.paper.typeTitle];
    }
    [text appendFormat:@"%@", self.selectedPrinterText];
    _printSettingsText = text;
    return _printSettingsText;
}

- (NSString *)selectedPrinterText
{
    return self.printSettings.printerName == nil ? kMPSelectPrinterPrompt : self.printSettings.printerName;
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
    [defaults setObject:self.printSettings.printerName forKey:kMPLastPrinterNameSetting];
    [defaults setObject:self.printSettings.printerId forKey:kMPLastPrinterIDSetting];
    [defaults setObject:self.printSettings.printerModel forKey:kMPLastPrinterModelSetting];
    [defaults setObject:self.printSettings.printerLocation forKey:kMPLastPrinterLocationSetting];
    [defaults synchronize];
}

- (void)loadLastUsed
{
    self.paper = [MPPrintSettingsDelegateManager lastPaperUsed];
    
    MPDefaultSettingsManager *settings = [MPDefaultSettingsManager sharedInstance];
    if( [settings isDefaultPrinterSet] ) {
        self.printSettings.printerName = settings.defaultPrinterName;
        self.printSettings.printerUrl = [NSURL URLWithString:settings.defaultPrinterUrl];
        self.printSettings.printerId = nil;
        self.printSettings.printerModel = settings.defaultPrinterModel;
        self.printSettings.printerLocation = settings.defaultPrinterLocation;
    } else {
        self.printSettings.printerName = [[NSUserDefaults standardUserDefaults] objectForKey:kMPLastPrinterNameSetting];
        self.printSettings.printerUrl = [NSURL URLWithString:[[NSUserDefaults standardUserDefaults] objectForKey:LAST_PRINTER_USED_URL_SETTING]];
        self.printSettings.printerId = [[NSUserDefaults standardUserDefaults] objectForKey:kMPLastPrinterIDSetting];
        self.printSettings.printerModel = [[NSUserDefaults standardUserDefaults] objectForKey:kMPLastPrinterModelSetting];
        self.printSettings.printerLocation = [[NSUserDefaults standardUserDefaults] objectForKey:kMPLastPrinterLocationSetting];
    }
    
    if (IS_OS_8_OR_LATER) {
        NSNumber *lastBlackAndWhiteUsed = [[NSUserDefaults standardUserDefaults] objectForKey:kMPLastBlackAndWhiteFilterSetting];
        if (lastBlackAndWhiteUsed != nil) {
            self.blackAndWhite = lastBlackAndWhiteUsed.boolValue;
        } else {
            self.blackAndWhite = NO;
        }
    }
}

+ (MPPaper *)lastPaperUsed
{
    MPPaper *paper = [MP sharedInstance].defaultPaper;

    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSNumber *lastSizeUsed = [defaults objectForKey:kMPLastPaperSizeSetting];
    NSNumber *lastTypeUsed = [defaults objectForKey:kMPLastPaperTypeSetting];
    if (lastSizeUsed && lastTypeUsed) {
        NSUInteger sizeId = [lastSizeUsed unsignedIntegerValue];
        NSUInteger typeId = [lastTypeUsed unsignedIntegerValue];
        if ([MPPaper supportedPaperSize:sizeId andType:typeId]) {
            paper = [[MPPaper alloc] initWithPaperSize:sizeId paperType:typeId];
        }
    }
    
    return paper;
}

- (void)savePrinterId:(NSString *)printerId
{
    self.printSettings.printerId = printerId;
    NSUserDefaults * defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:self.printSettings.printerId forKey:kMPLastPrinterIDSetting];
    [defaults synchronize];
    
}

@end
