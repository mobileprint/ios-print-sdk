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
#import "HPPP.h"
#import "HPPPPrintPageRenderer.h"
#import "HPPPDefaultSettingsManager.h"
#import "NSBundle+HPPPLocalizable.h"

#define HPPP_DEFAULT_PRINT_JOB_NAME HPPPLocalizedString(@"Photo", @"Default job name of the print send to the printer")

@interface HPPPPrintManager() <UIPrintInteractionControllerDelegate>

@property (strong, nonatomic) HPPP *hppp;

@end

@implementation HPPPPrintManager

#pragma mark - Initialization

- (id)init
{
    self = [super init];
    
    if( self ) {
        self.hppp = [HPPP sharedInstance];
        self.currentPrintSettings = [[HPPPDefaultSettingsManager sharedInstance] defaultsAsPrintSettings];
        self.currentPrintSettings.printerIsAvailable = TRUE;
        [self setColorFromLastOptions];
        [self setPaperFromLastOptions];
    }
    
    return self;
}

- (id)initWithPrintSettings:(HPPPPrintSettings *)printSettings
{
    self = [self init];
    
    if( self ) {
        self.currentPrintSettings = printSettings;
        if (!self.currentPrintSettings.paper) {
            [self setPaperFromLastOptions];
        }
    }
    
    return self;
}

- (void)setColorFromLastOptions
{
    NSNumber *blackAndWhiteID = [self.hppp.lastOptionsUsed valueForKey:kHPPPBlackAndWhiteFilterId];
    if (blackAndWhiteID) {
        BOOL color = ![blackAndWhiteID boolValue];
        self.currentPrintSettings.color = color;
    } else {
        self.currentPrintSettings.color = YES;
    }
}

- (void)setPaperFromLastOptions
{
    NSString *typeTitle = [self.hppp.lastOptionsUsed valueForKey:kHPPPPaperTypeId];
    NSString *sizeTitle = [self.hppp.lastOptionsUsed valueForKey:kHPPPPaperSizeId];
    if (typeTitle && sizeTitle) {
        self.currentPrintSettings.paper = [[HPPPPaper alloc] initWithPaperSizeTitle:sizeTitle paperTypeTitle:typeTitle];
    } else {
        self.currentPrintSettings.paper = self.hppp.defaultPaper;
    }
}

#pragma mark - Printing

- (void)print:(HPPPPrintItem *)printItem
          pageRange:(HPPPPageRange *)pageRange
          numCopies:(NSInteger)numCopies
              error:(NSError **)errorPtr
{
    HPPPPrintManagerError error = HPPPPrintManagerErrorNone;
    
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
            dispatch_async(dispatch_get_main_queue(), ^{
                HPPPLogInfo(@"Print completed");
                if( [self.delegate respondsToSelector:@selector(didFinishPrintJob:completed:error:)] ) {
                    [self.delegate didFinishPrintJob:controller completed:completed error:error];
                }
            });
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
    BOOL photoPaper = (self.currentPrintSettings.paper.paperSize != SizeLetter) || (self.currentPrintSettings.paper.paperType == Photo);
    
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
        HPPPPrintPageRenderer *renderer = [[HPPPPrintPageRenderer alloc] initWithImages:@[[printItem printAssetForPageRange:pageRange]] andLayout:printItem.layout];
        renderer.numberOfCopies = numCopies;
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
    UIPrintPaper * paper = [UIPrintPaper bestPaperForPageSize:[self.currentPrintSettings.paper printerPaperSize] withPapersFromArray:paperList];
    return paper;
}

@end
