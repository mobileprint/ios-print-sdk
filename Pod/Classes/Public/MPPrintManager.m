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

#import <UIKit/UIKit.h>
#import "MPPrintManager.h"
#import "MPPrintManager+Options.h"
#import "MP.h"
#import "MPPrintPageRenderer.h"
#import "MPDefaultSettingsManager.h"
#import "NSBundle+MPLocalizable.h"
#import "MPAnalyticsManager.h"
#import "MPPrintLaterQueue.h"
#import "MPPrintSettingsDelegateManager.h"
#import "MPBTSprocket.h"

#define MP_DEFAULT_PRINT_JOB_NAME MPLocalizedString(@"Photo", @"Default job name of the print send to the printer")

@interface MPPrintManager() 

@property (strong, nonatomic) MP *mp;

@end

@implementation MPPrintManager
{
    MPPrintSettingsDelegateManager *_settingsManager;
}

NSString * const kMPOfframpPrint = @"PrintFromShare";
NSString * const kMPOfframpQueue = @"PrintSingleFromQueue";
NSString * const kMPOfframpQueueMulti = @"PrintMultipleFromQueue";
NSString * const kMPOfframpCustom = @"PrintFromClientUI";
NSString * const kMPOfframpDirect = @"PrintWithNoUI";

#pragma mark - Initialization

- (id)init
{
    self = [super init];
    
    if( self ) {
        self.mp = [MP sharedInstance];
        self.currentPrintSettings = [[MPDefaultSettingsManager sharedInstance] defaultsAsPrintSettings];
        self.currentPrintSettings.printerIsAvailable = TRUE;
        _settingsManager = [[MPPrintSettingsDelegateManager alloc] init];
        [_settingsManager loadLastUsed];
        self.currentPrintSettings.color = !_settingsManager.blackAndWhite;
        self.currentPrintSettings.paper = _settingsManager.paper;
        self.options = MPPrintManagerOriginDirect;
    }
    
    return self;
}

- (id)initWithPrintSettings:(MPPrintSettings *)printSettings
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

- (void)print:(MPPrintItem *)printItem
    pageRange:(MPPageRange *)pageRange
    numCopies:(NSInteger)numCopies
        error:(NSError **)errorPtr
{
    if (MPPrintManagerOriginDirect & self.options) {
        [[MPAnalyticsManager sharedManager] trackUserFlowEventWithId:kMPMetricsEventTypePrintInitiated];
    }
    
    MPPrintManagerError error = MPPrintManagerErrorNone;
    
    printItem.layout.paper = self.currentPrintSettings.paper;
    
    if (IS_OS_8_OR_LATER) {
        if (self.currentPrintSettings.printerUrl == nil || self.currentPrintSettings.printerUrl.absoluteString.length == 0) {
            MPLogWarn(@"directPrint not completed - printer settings do not contain a printer URL");
            error = MPPrintManagerErrorNoPrinterUrl;
        }
        
        if (!self.currentPrintSettings.printerIsAvailable) {
            MPLogWarn(@"directPrint not completed - printer %@ is not available", self.currentPrintSettings.printerUrl);
            error = MPPrintManagerErrorPrinterNotAvailable;
        }
        
        if( !self.currentPrintSettings.paper ) {
            MPLogWarn(@"directPrint not completed - paper type is not selected");
            error = MPPrintManagerErrorNoPaperType;
        }
        
        if( MPPrintManagerErrorNone == error ) {
            [self doPrintWithPrintItem:printItem color:self.currentPrintSettings.color pageRange:pageRange numCopies:numCopies];
        }
    } else {
        MPLogWarn(@"directPrint not completed - only available on iOS 8 and later");
        error = MPPrintManagerErrorDirectPrintNotSupported;
    }
    
    *errorPtr = [NSError errorWithDomain:MP_ERROR_DOMAIN code:error userInfo:nil];
}

- (void)doPrintWithPrintItem:(MPPrintItem *)printItem
                       color:(BOOL)color
                   pageRange:(MPPageRange *)pageRange
                   numCopies:(NSInteger)numCopies
{
    if (self.mp.useBluetooth) {
        [((MPBTSprocket *)self.currentPrintSettings.sprocketPrinter) print:printItem numCopies:numCopies];
        
    } else {
        if (self.currentPrintSettings.printerUrl != nil) {
            
            UIPrintInteractionController *controller = [UIPrintInteractionController sharedPrintController];
            controller.delegate = self;
            
            [self prepareController:controller printItem:printItem color:color pageRange:pageRange numCopies:numCopies];
            UIPrinter *printer = [UIPrinter printerWithURL:self.currentPrintSettings.printerUrl];
            [controller printToPrinter:printer completionHandler:^(UIPrintInteractionController *printController, BOOL completed, NSError *error) {
                if (!completed) {
                    MPLogInfo(@"Print was NOT completed");
                }
                
                if (error) {
                    MPLogWarn(@"Print error:  %@", error);
                }
                
                if (completed && !error) {
                    [self saveLastOptionsForPrinter:controller.printInfo.printerID];
                    [self processMetricsForPrintItem:printItem andPageRange:pageRange];
                    if (MPPrintManagerOriginDirect & self.options) {
                        [[MPAnalyticsManager sharedManager] trackUserFlowEventWithId:kMPMetricsEventTypePrintCompleted];
                    }
                }
                
                if( self.delegate && [self.delegate respondsToSelector:@selector(didFinishPrintJob:completed:error:)] ) {
                    [self.delegate didFinishPrintJob:controller completed:completed error:error];
                }
                
            }];
        } else {
            MPLogError(@"Must have an MPPrintSettings instance in order to print");
        }
    }
}

- (void)prepareController:(UIPrintInteractionController *)controller
                printItem:(MPPrintItem *)printItem
                    color:(BOOL)color
                pageRange:(MPPageRange *)pageRange
                numCopies:(NSInteger)numCopies
{   
    // Obtain a printInfo so that we can set our printing defaults.
    UIPrintInfo *printInfo = [UIPrintInfo printInfo];

    self.numberOfCopies = IS_OS_8_OR_LATER ? numCopies : 1;
    
    // The path to the image may or may not be a good name for our print job
    // but that's all we've got.
    if (nil != self.mp.printJobName) {
        printInfo.jobName = self.mp.printJobName;
    } else {
        printInfo.jobName = MP_DEFAULT_PRINT_JOB_NAME;
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
            MPLogWarn(@"Using custom print renderer with non-image class:  %@", printItem.printAsset);
        }
        MPPrintPageRenderer *renderer = [[MPPrintPageRenderer alloc] initWithImages:[printItem printAssetForPageRange:pageRange] layout:printItem.layout paper:self.currentPrintSettings.paper copies:self.numberOfCopies];
        controller.printPageRenderer = renderer;
    } else {
        if (1 == self.numberOfCopies) {
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
    CGSize referencePaperPointSize = [self.currentPrintSettings.paper printerPaperSize];
    NSMutableString *log = [NSMutableString stringWithFormat:@"\n\n\nReference: %.1f x %.1f\n\n", referencePaperPointSize.width / kMPPointsPerInch, referencePaperPointSize.height / kMPPointsPerInch];
    
    for (UIPrintPaper *p in paperList) {
        [log appendFormat:@"Paper: %.1f x %.1f -- x: %.1f  y: %.1f  w: %.1f  h: %.1f\n", p.paperSize.width / kMPPointsPerInch, p.paperSize.height  / kMPPointsPerInch, p.printableRect.origin.x, p.printableRect.origin.y, p.printableRect.size.width, p.printableRect.size.height];
    }
    
    UIPrintPaper *paper = nil;
    
    id<MPPrintPaperDelegate> paperDelegate = [MP sharedInstance].printPaperDelegate;
    if (paperDelegate && [paperDelegate respondsToSelector:@selector(printInteractionController:choosePaper:forPrintSettings:)]) {
        MPLogInfo(@"Attempting to choose paper using MPPrintPaperDelegate");
        paper = [paperDelegate printInteractionController:printInteractionController choosePaper:paperList forPrintSettings:self.currentPrintSettings];
    }
    
    if (!paper) {
        MPLogInfo(@"Attempting to choose paper using system call");
        paper = [UIPrintPaper bestPaperForPageSize:referencePaperPointSize withPapersFromArray:paperList];
    }
        
    [log appendFormat:@"\nChosen: %.1f x %.1f -- x: %.1f  y: %.1f  w: %.1f  h: %.1f\n\n\n", paper.paperSize.width  / kMPPointsPerInch, paper.paperSize.height  / kMPPointsPerInch, paper.printableRect.origin.x, paper.printableRect.origin.y, paper.printableRect.size.width, paper.printableRect.size.height];
    MPLogInfo(@"%@", log);
    
    [self saveLastOptionsForPaper:paper];
    
    return paper;
}

- (CGFloat)printInteractionController:(UIPrintInteractionController *)printInteractionController cutLengthForPaper:(UIPrintPaper *)paper
{
    NSMutableString *log = [NSMutableString stringWithFormat:@"\nReference: %.1f x %.1f -- x: %.1f  y: %.1f  w: %.1f  h: %.1f\n\n\n", paper.paperSize.width  / kMPPointsPerInch, paper.paperSize.height  / kMPPointsPerInch, paper.printableRect.origin.x, paper.printableRect.origin.y, paper.printableRect.size.width, paper.printableRect.size.height];

    NSNumber *cutLength = nil;
    
    id<MPPrintPaperDelegate> paperDelegate = [MP sharedInstance].printPaperDelegate;
    if (paperDelegate && [paperDelegate respondsToSelector:@selector(printInteractionController:cutLengthForPaper:forPrintSettings:)]) {
        cutLength = [paperDelegate printInteractionController:printInteractionController cutLengthForPaper:paper forPrintSettings:self.currentPrintSettings];
    }
    
    if (!cutLength) {
        CGSize currentPaperSize = [self.currentPrintSettings.paper printerPaperSize];
        CGFloat computedLength = paper.paperSize.width * currentPaperSize.height / currentPaperSize.width;
        cutLength = [NSNumber numberWithFloat:computedLength];
    }
    
    [log appendFormat:@"\nCut length: %.1f\n\n\n", [cutLength floatValue] / kMPPointsPerInch];
    MPLogInfo(@"%@", log);
    
    return [cutLength floatValue];
}

#pragma mark - Print metrics

- (void)processMetricsForPrintItem:(MPPrintItem *)printItem andPageRange:(MPPageRange *)pageRange
{
    NSInteger printPageCount = pageRange ? [pageRange getPages].count : printItem.numberOfPages;
    NSMutableDictionary *metrics = [NSMutableDictionary dictionaryWithDictionary:printItem.extra];
    [metrics addEntriesFromDictionary:@{
                                        kMPOfframpKey:[self offramp],
                                        kMPNumberPagesPrint:[NSNumber numberWithInteger:printPageCount],
                                        kMPMetricsPrintSessionID:[MPAnalyticsManager sharedManager].printSessionId
                                        }];
    printItem.extra = metrics;
    
    if ([MP sharedInstance].handlePrintMetricsAutomatically) {
        [[MPAnalyticsManager sharedManager] trackShareEventWithPrintItem:printItem andOptions:metrics];
    }
}

- (NSString *)offramp
{
    NSString *offramp = kMPOfframpDirect;
    if (self.options & MPPrintManagerOriginShare) {
        offramp = kMPOfframpPrint;
    } else if (self.options & MPPrintManagerOriginCustom) {
        offramp = kMPOfframpCustom;
    } else if (self.options & MPPrintManagerOriginQueue) {
        if (self.options & MPPrintManagerMultiJob) {
            offramp = kMPOfframpQueueMulti;
        } else {
            offramp = kMPOfframpQueue;
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
                          kMPOfframpPrint,
                          kMPOfframpQueue,
                          kMPOfframpQueueMulti,
                          kMPOfframpCustom,
                          kMPOfframpDirect ];
    
    return [offramps containsObject:offramp];
}

+ (BOOL)printLaterOfframp:(NSString *)offramp
{
    NSArray *offramps = @[
                          kMPOfframpAddToQueueShare,
                          kMPOfframpAddToQueueCustom,
                          kMPOfframpAddToQueueDirect,
                          kMPOfframpDeleteFromQueue ];
    
    return [offramps containsObject:offramp];
}

#pragma mark - Print settings

- (void)setCurrentPrintSettings:(MPPrintSettings *)currentPrintSettings
{
    _currentPrintSettings = currentPrintSettings;
    
    id<MPPrintPaperDelegate> paperDelegate = [MP sharedInstance].printPaperDelegate;
    
    if (paperDelegate && [paperDelegate respondsToSelector:@selector(hidePaperSizeForPrintSettings:)]) {
        [MP sharedInstance].hidePaperSizeOption = [paperDelegate hidePaperSizeForPrintSettings:currentPrintSettings];
    }
    
    if (paperDelegate && [paperDelegate respondsToSelector:@selector(hidePaperTypeForPrintSettings:)]) {
        [MP sharedInstance].hidePaperTypeOption = [paperDelegate hidePaperTypeForPrintSettings:currentPrintSettings];
    }
    
    if (paperDelegate && [paperDelegate respondsToSelector:@selector(supportedPapersForPrintSettings:)]) {
        NSArray *papers = [paperDelegate supportedPapersForPrintSettings:currentPrintSettings];
        if ([papers count] > 0) {
            [MP sharedInstance].supportedPapers = papers;
        } else {
            MPLogError(@"Paper delegate must specify at least one supported paper");
        }
    }
    
    [MP sharedInstance].defaultPaper = [[MP sharedInstance].supportedPapers firstObject];
    if (paperDelegate && [paperDelegate respondsToSelector:@selector(defaultPaperForPrintSettings:)]) {
        MPPaper *paper = [paperDelegate defaultPaperForPrintSettings:currentPrintSettings];
        if ([MPPaper supportedPaperSize:paper.paperSize andType:paper.paperType]) {
            [MP sharedInstance].defaultPaper = paper;
        } else {
            MPLogError(@"Default paper specified is not in supported paper list: size (%lul) - type (%lul)", (unsigned long)paper.paperSize, (unsigned long)paper.paperType);
        }
    }
    
    if (!currentPrintSettings.paper || ![MPPaper supportedPaperSize:currentPrintSettings.paper.paperSize andType:currentPrintSettings.paper.paperType]) {
        _currentPrintSettings.paper = [MP sharedInstance].defaultPaper;
    }
}

@end
