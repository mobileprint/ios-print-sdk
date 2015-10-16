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

#import <UIKit/UIKit.h>
#import "HPPPPrintManager.h"
#import "HPPPPrintManager+Options.h"
#import "HPPP.h"
#import "HPPPPrintPageRenderer.h"
#import "HPPPDefaultSettingsManager.h"
#import "NSBundle+HPPPLocalizable.h"
#import "HPPPAnalyticsManager.h"
#import "HPPPPrintLaterQueue.h"
#import "HPPPPrintSettingsDelegateManager.h"

#define HPPP_DEFAULT_PRINT_JOB_NAME HPPPLocalizedString(@"Photo", @"Default job name of the print send to the printer")

@interface HPPPPrintManager() 

@property (strong, nonatomic) HPPP *hppp;

@end

@implementation HPPPPrintManager
{
    HPPPPrintSettingsDelegateManager *_settingsManager;
}

NSString * const kHPPPOfframpPrint = @"PrintFromShare";
NSString * const kHPPPOfframpQueue = @"PrintSingleFromQueue";
NSString * const kHPPPOfframpQueueMulti = @"PrintMultipleFromQueue";
NSString * const kHPPPOfframpCustom = @"PrintFromClientUI";
NSString * const kHPPPOfframpDirect = @"PrintWithNoUI";

#pragma mark - Initialization

- (id)init
{
    self = [super init];
    
    if( self ) {
        self.hppp = [HPPP sharedInstance];
        self.currentPrintSettings = [[HPPPDefaultSettingsManager sharedInstance] defaultsAsPrintSettings];
        self.currentPrintSettings.printerIsAvailable = TRUE;
        _settingsManager = [[HPPPPrintSettingsDelegateManager alloc] init];
        [_settingsManager loadLastUsed];
        self.currentPrintSettings.color = !_settingsManager.blackAndWhite;
        self.currentPrintSettings.paper = _settingsManager.paper;
        self.options = HPPPPrintManagerOriginDirect;
    }
    
    return self;
}

- (id)initWithPrintSettings:(HPPPPrintSettings *)printSettings
{
    self = [self init];
    
    if( self ) {
        if (!printSettings.paper) {
            printSettings.paper = _settingsManager.paper;
        }
        self.currentPrintSettings = printSettings;
    }
    
    return self;
}

#pragma mark - Printing

- (void)print:(HPPPPrintItem *)printItem
    pageRange:(HPPPPageRange *)pageRange
    numCopies:(NSInteger)numCopies
        error:(NSError **)errorPtr
{
    HPPPPrintManagerError error = HPPPPrintManagerErrorNone;
    
    printItem.layout.paper = self.currentPrintSettings.paper;
    
    if (IS_OS_8_OR_LATER) {
        if (self.currentPrintSettings.printerUrl == nil || self.currentPrintSettings.printerUrl.absoluteString.length == 0) {
            HPPPLogWarn(@"directPrint not completed - printer settings do not contain a printer URL");
            error = HPPPPrintManagerErrorNoPrinterUrl;
        }
        
        if (!self.currentPrintSettings.printerIsAvailable) {
            HPPPLogWarn(@"directPrint not completed - printer %@ is not available", self.currentPrintSettings.printerUrl);
            error = HPPPPrintManagerErrorPrinterNotAvailable;
        }
        
        if( !self.currentPrintSettings.paper ) {
            HPPPLogWarn(@"directPrint not completed - paper type is not selected");
            error = HPPPPrintManagerErrorNoPaperType;
        }
        
        if( HPPPPrintManagerErrorNone == error ) {
            [self doPrintWithPrintItem:printItem color:self.currentPrintSettings.color pageRange:pageRange numCopies:numCopies];
        }
    } else {
        HPPPLogWarn(@"directPrint not completed - only available on iOS 8 and later");
        error = HPPPPrintManagerErrorDirectPrintNotSupported;
    }
    
    *errorPtr = [NSError errorWithDomain:HPPP_ERROR_DOMAIN code:error userInfo:nil];
}

- (UIPrintInteractionController *)getSharedPrintInteractionController
{
    UIPrintInteractionController *controller = [UIPrintInteractionController sharedPrintController];
    
    if (nil != controller) {
        controller.delegate = self;
    }
    
    return controller;
}

- (void)doPrintWithPrintItem:(HPPPPrintItem *)printItem
                       color:(BOOL)color
                   pageRange:(HPPPPageRange *)pageRange
                   numCopies:(NSInteger)numCopies
{
    if (self.currentPrintSettings.printerUrl != nil) {
        UIPrintInteractionController *controller = [self getSharedPrintInteractionController];
        if (!controller) {
            HPPPLogError(@"Couldn't get shared UIPrintInteractionController!");
            return;
        }
        controller.showsNumberOfCopies = NO;
        [self prepareController:controller printItem:printItem color:color pageRange:pageRange numCopies:numCopies];
        UIPrinter *printer = [UIPrinter printerWithURL:self.currentPrintSettings.printerUrl];
        [controller printToPrinter:printer completionHandler:^(UIPrintInteractionController *printController, BOOL completed, NSError *error) {
            if (!completed) {
                HPPPLogInfo(@"Print was NOT completed");
            }
            
            if (error) {
                HPPPLogWarn(@"Print error:  %@", error);
            }
            
            if (completed && !error) {
                [self saveLastOptionsForPrinter:controller.printInfo.printerID];
                [self processMetricsForPrintItem:printItem andPageRange:pageRange];
            }
            
            if( self.delegate && [self.delegate respondsToSelector:@selector(didFinishPrintJob:completed:error:)] ) {
                [self.delegate didFinishPrintJob:controller completed:completed error:error];
            }
            
        }];
    } else {
        HPPPLogError(@"Must have an HPPPPrintSettings instance in order to print");
    }
}

- (void)prepareController:(UIPrintInteractionController *)controller
                printItem:(HPPPPrintItem *)printItem
                    color:(BOOL)color
                pageRange:(HPPPPageRange *)pageRange
                numCopies:(NSInteger)numCopies
{   
    // Obtain a printInfo so that we can set our printing defaults.
    UIPrintInfo *printInfo = [UIPrintInfo printInfo];
    
    self.numberOfCopies = numCopies;
    
    // The path to the image may or may not be a good name for our print job
    // but that's all we've got.
    if (nil != self.hppp.printJobName) {
        printInfo.jobName = self.hppp.printJobName;
    } else {
        printInfo.jobName = HPPP_DEFAULT_PRINT_JOB_NAME;
    }
    
    printInfo.printerID = self.currentPrintSettings.printerId;
    
    // This application prints photos. UIKit will pick a paper size and print
    // quality appropriate for this content type.
    BOOL photoPaper = self.currentPrintSettings.paper.photo;
    
    if (photoPaper && color) {
        printInfo.outputType = UIPrintInfoOutputPhoto;
    } else if (photoPaper && !color) {
        printInfo.outputType = UIPrintInfoOutputPhotoGrayscale;
    } else if (!photoPaper && color) {
        printInfo.outputType = UIPrintInfoOutputGeneral;
    } else {
        printInfo.outputType = UIPrintInfoOutputGrayscale;
    }
    
    if (CustomPrintRenderer == printItem.renderer) {
        if (![printItem.printAsset isKindOfClass:[UIImage class]]) {
            HPPPLogWarn(@"Using custom print renderer with non-image class:  %@", printItem.printAsset);
        }
        HPPPPrintPageRenderer *renderer = [[HPPPPrintPageRenderer alloc] initWithImages:@[[printItem printAssetForPageRange:pageRange]] layout:printItem.layout paper:self.currentPrintSettings.paper copies:numCopies];
        controller.printPageRenderer = renderer;
    } else {
        if (1 == numCopies) {
            controller.printingItem = [printItem printAssetForPageRange:pageRange];
        } else {
            NSMutableArray *items = [NSMutableArray array];
            for (int idx = 0; idx < numCopies; idx++) {
                [items addObject:[printItem printAssetForPageRange:pageRange]];
            }
            controller.printingItems = items;
        }
    }
    
    controller.printInfo = printInfo;
}

#pragma mark - UIPrintInteractionControllerDelegate

- (UIViewController *)printInteractionControllerParentViewController:(UIPrintInteractionController *)printInteractionController
{
    return nil;
}

- (UIPrintPaper *)printInteractionController:(UIPrintInteractionController *)printInteractionController choosePaper:(NSArray *)paperList
{
    
    NSMutableString *log = [NSMutableString stringWithFormat:@"\n\n\nReference: %.1f x %.1f\n\n", self.currentPrintSettings.paper.width, self.currentPrintSettings.paper.height];
    
    for (UIPrintPaper *p in paperList) {
        [log appendFormat:@"Paper: %.1f x %.1f -- x: %.1f  y: %.1f  w: %.1f  h: %.1f\n", p.paperSize.width / 72.0, p.paperSize.height  / 72.0, p.printableRect.origin.x, p.printableRect.origin.y, p.printableRect.size.width, p.printableRect.size.height];
    }
    
    UIPrintPaper *paper = nil;
    
    id<HPPPPrintPaperDelegate> paperDelegate = [HPPP sharedInstance].printPaperDelegate;
    if (paperDelegate && [paperDelegate respondsToSelector:@selector(printInteractionController:choosePaper:forPrintSettings:)]) {
        HPPPLogInfo(@"Attempting to choose paper using HPPPPrintPaperDelegate");
        paper = [paperDelegate printInteractionController:printInteractionController choosePaper:paperList forPrintSettings:self.currentPrintSettings];
    }
    
    if (!paper) {
        HPPPLogInfo(@"Attempting to choose paper using system call");
        paper = [UIPrintPaper bestPaperForPageSize:[self.currentPrintSettings.paper printerPaperSize] withPapersFromArray:paperList];
    }
        
    [log appendFormat:@"\nChosen: %.1f x %.1f -- x: %.1f  y: %.1f  w: %.1f  h: %.1f\n\n\n", paper.paperSize.width  / 72.0, paper.paperSize.height  / 72.0, paper.printableRect.origin.x, paper.printableRect.origin.y, paper.printableRect.size.width, paper.printableRect.size.height];
    HPPPLogInfo(@"%@", log);
    
    [self saveLastOptionsForPaper:paper];
    
    return paper;
}

- (CGFloat)printInteractionController:(UIPrintInteractionController *)printInteractionController cutLengthForPaper:(UIPrintPaper *)paper
{
    NSMutableString *log = [NSMutableString stringWithFormat:@"\nReference: %.1f x %.1f -- x: %.1f  y: %.1f  w: %.1f  h: %.1f\n\n\n", paper.paperSize.width  / 72.0, paper.paperSize.height  / 72.0, paper.printableRect.origin.x, paper.printableRect.origin.y, paper.printableRect.size.width, paper.printableRect.size.height];

    NSNumber *cutLength = nil;
    
    id<HPPPPrintPaperDelegate> paperDelegate = [HPPP sharedInstance].printPaperDelegate;
    if (paperDelegate && [paperDelegate respondsToSelector:@selector(printInteractionController:cutLengthForPaper:forPrintSettings:)]) {
        cutLength = [paperDelegate printInteractionController:printInteractionController cutLengthForPaper:paper forPrintSettings:self.currentPrintSettings];
    }
    
    if (!cutLength) {
        CGSize currentPaperSize = [self.currentPrintSettings.paper printerPaperSize];
        CGFloat computedLength = paper.paperSize.width * currentPaperSize.height / currentPaperSize.width;
        cutLength = [NSNumber numberWithFloat:computedLength];
    }
    
    [log appendFormat:@"\nCut length: %.1f\n\n\n", [cutLength floatValue] / 72.0];
    HPPPLogInfo(@"%@", log);
    
    return [cutLength floatValue];
}

#pragma mark - Print metrics

- (void)processMetricsForPrintItem:(HPPPPrintItem *)printItem andPageRange:(HPPPPageRange *)pageRange
{
    NSInteger printPageCount = pageRange ? [pageRange getPages].count : printItem.numberOfPages;
    NSMutableDictionary *metrics = [NSMutableDictionary dictionaryWithDictionary:printItem.extra];
    [metrics addEntriesFromDictionary:@{
                                        kHPPPOfframpKey:[self offramp],
                                        kHPPPNumberPagesPrint:[NSNumber numberWithInteger:printPageCount]
                                        }];
    printItem.extra = metrics;
    if ([HPPP sharedInstance].handlePrintMetricsAutomatically) {
        [[HPPPAnalyticsManager sharedManager] trackShareEventWithPrintItem:printItem andOptions:metrics];
    }
}

- (NSString *)offramp
{
    NSString *offramp = kHPPPOfframpDirect;
    if (self.options & HPPPPrintManagerOriginShare) {
        offramp = kHPPPOfframpPrint;
    } else if (self.options & HPPPPrintManagerOriginCustom) {
        offramp = kHPPPOfframpCustom;
    } else if (self.options & HPPPPrintManagerOriginQueue) {
        if (self.options & HPPPPrintManagerMultiJob) {
            offramp = kHPPPOfframpQueueMulti;
        } else {
            offramp = kHPPPOfframpQueue;
        }
    }
    return offramp;
}

+ (BOOL)printingOfframp:(NSString *)offramp
{
    return [self printNowOfframp:offramp] || [self printLaterOfframp:offramp];
}

+ (BOOL)printNowOfframp:(NSString *)offramp
{
    NSArray *offramps = @[
                          kHPPPOfframpPrint,
                          kHPPPOfframpQueue,
                          kHPPPOfframpQueueMulti,
                          kHPPPOfframpCustom,
                          kHPPPOfframpDirect ];
    
    return [offramps containsObject:offramp];
}

+ (BOOL)printLaterOfframp:(NSString *)offramp
{
    NSArray *offramps = @[
                          kHPPPOfframpAddToQueueShare,
                          kHPPPOfframpAddToQueueCustom,
                          kHPPPOfframpAddToQueueDirect,
                          kHPPPOfframpDeleteFromQueue ];
    
    return [offramps containsObject:offramp];
}

#pragma mark - Print settings

- (void)setCurrentPrintSettings:(HPPPPrintSettings *)currentPrintSettings
{
    _currentPrintSettings = currentPrintSettings;
    
    id<HPPPPrintPaperDelegate> paperDelegate = [HPPP sharedInstance].printPaperDelegate;
    
    if (paperDelegate && [paperDelegate respondsToSelector:@selector(hidePaperSizeForPrintSettings:)]) {
        [HPPP sharedInstance].hidePaperSizeOption = [paperDelegate hidePaperSizeForPrintSettings:currentPrintSettings];
    }
    
    if (paperDelegate && [paperDelegate respondsToSelector:@selector(hidePaperTypeForPrintSettings:)]) {
        [HPPP sharedInstance].hidePaperTypeOption = [paperDelegate hidePaperTypeForPrintSettings:currentPrintSettings];
    }
    
    if (paperDelegate && [paperDelegate respondsToSelector:@selector(supportedPapersForPrintSettings:)]) {
        NSArray *papers = [paperDelegate supportedPapersForPrintSettings:currentPrintSettings];
        if ([papers count] > 0) {
            [HPPP sharedInstance].supportedPapers = papers;
        } else {
            HPPPLogError(@"Paper delegate must specify at least one supported paper");
        }
    }
    
    [HPPP sharedInstance].defaultPaper = [[HPPP sharedInstance].supportedPapers firstObject];
    if (paperDelegate && [paperDelegate respondsToSelector:@selector(defaultPaperForPrintSettings:)]) {
        HPPPPaper *paper = [paperDelegate defaultPaperForPrintSettings:currentPrintSettings];
        if ([HPPPPaper supportedPaperSize:paper.paperSize andType:paper.paperType]) {
            [HPPP sharedInstance].defaultPaper = paper;
        } else {
            HPPPLogError(@"Default paper specified is not in supported paper list: size (%lul) - type (%lul)", (unsigned long)paper.paperSize, (unsigned long)paper.paperType);
        }
    }
    
    if (!currentPrintSettings.paper || ![HPPPPaper supportedPaperSize:currentPrintSettings.paper.paperSize andType:currentPrintSettings.paper.paperType]) {
        _currentPrintSettings.paper = [HPPP sharedInstance].defaultPaper;
    }
}

@end
