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
#import "HPPPAnalyticsManager.h"
#import "HPPPPrintLaterManager.h"
#import "HPPPPrintLaterQueue.h"
#import "HPPPPrintJobsViewController.h"
#import "HPPPPageSettingsTableViewController.h"
#import "HPPPWiFiReachability.h"
#import <CoreFoundation/CoreFoundation.h>

#define DEFAULT_RULES_LABEL_FONT [UIFont fontWithName:@"Helvetica Neue" size:10]
#define DEFAULT_TABLE_VIEW_CELL_PRINT_LABEL_FONT [UIFont fontWithName:@"Helvetica Neue" size:18]
#define DEFAULT_TABLE_VIEW_CELL_PRINT_LABEL_COLOR [UIColor colorWithRed:0x02 / 255.0f green:0x7B / 255.0f blue:0xFF / 255.0f alpha:1.0f]
#define DEFAULT_TABLE_VIEW_SUPPORT_HEADER_LABEL_FONT [UIFont fontWithName:@"Helvetica Neue" size:18]
#define DEFAULT_TABLE_VIEW_SUPPORT_HEADER_LABEL_COLOR [UIColor colorWithRed:0x86 / 255.0f green:0x86 / 255.0f blue:0x86 / 255.0f alpha:1.0f]
#define DEFAULT_TABLE_VIEW_FOOTER_WARNING_LABEL_FONT [UIFont fontWithName:@"Helvetica Neue" size:12]
#define DEFAULT_TABLE_VIEW_FOOTER_WARNING_LABEL_COLOR [UIColor colorWithRed:0x33 / 255.0f green:0x33 / 255.0f blue:0x33 / 255.0f alpha:1.0f]
#define DEFAULT_TABLE_VIEW_CELL_LABEL_FONT [UIFont fontWithName:@"Helvetica Neue" size:16]
#define DEFAULT_TABLE_VIEW_CELL_LABEL_COLOR [UIColor colorWithRed:0x33 / 255.0f green:0x33 / 255.0f blue:0x33 / 255.0f alpha:1.0f]
#define DEFAULT_TABLE_VIEW_CELL_VALUE_FONT [UIFont fontWithName:@"Helvetica Neue" size:16]
#define DEFAULT_TABLE_VIEW_CELL_VALUE_COLOR [UIColor colorWithRed:0x86 / 255.0f green:0x86 / 255.0f blue:0x86 / 255.0f alpha:1.0f]
#define DEFAULT_TABLE_VIEW_SETTINGS_CELL_VALUE_FONT [UIFont fontWithName:@"Helvetica Neue" size:12]
#define DEFAULT_TABLE_VIEW_SETTINGS_CELL_VALUE_COLOR [UIColor colorWithRed:0x86 / 255.0f green:0x86 / 255.0f blue:0x86 / 255.0f alpha:1.0f]
#define DEFAULT_TABLE_VIEW_CELL_LINK_LABEL_COLOR [UIColor colorWithRed:0x02 / 255.0f green:0x7B / 255.0f blue:0xFF / 255.0f alpha:1.0f]
#define DEFAULT_DATE_FORMAT @"MMMM d, h:mma"

NSString * const kLaterActionIdentifier = @"LATER_ACTION_IDENTIFIER";
NSString * const kPrintActionIdentifier = @"PRINT_ACTION_IDENTIFIER";
NSString * const kPrintCategoryIdentifier = @"PRINT_CATEGORY_IDENTIFIER";

NSString * const kHPPPShareCompletedNotification = @"kHPPPShareCompletedNotification";

NSString * const kHPPPTrackableScreenNotification = @"kHPPPTrackableScreenNotification";
NSString * const kHPPPTrackableScreenNameKey = @"screen-name";

NSString * const kHPPPPrintQueueNotification = @"kHPPPPrintQueueNotification";
NSString * const kHPPPPrintQueueActionKey = @"kHPPPPrintQueueActionKey";
NSString * const kHPPPPrintQueueJobsKey = @"kHPPPPrintQueueJobsKey";

NSString * const kHPPPPrintJobAddedToQueueNotification = @"kHPPPPrintJobAddedToQueueNotification";
NSString * const kHPPPPrintJobRemovedFromQueueNotification = @"kHPPPPrintJobRemovedFromQueueNotification";
NSString * const kHPPPAllPrintJobsRemovedFromQueueNotification = @"kHPPPAllPrintJobsRemovedFromQueueNotification";

NSString * const kHPPPPrinterAvailabilityNotification = @"kHPPPPrinterAvailabilityNotification";
NSString * const kHPPPPrinterAvailableKey = @"availability";
NSString * const kHPPPPrinterKey = @"printer";

NSString * const kHPPPBlackAndWhiteFilterId = @"black_and_white_filter";
NSString * const kHPPPNumberOfCopies = @"copies";
NSString * const kHPPPPaperSizeId = @"paper_size";
NSString * const kHPPPPaperTypeId = @"paper_type";
NSString * const kHPPPPrinterId = @"printer_id";
NSString * const kHPPPPrinterDisplayLocation = @"printer_location";
NSString * const kHPPPPrinterMakeAndModel = @"printer_model";
NSString * const kHPPPPrinterDisplayName = @"printer_name";

@implementation HPPP

#pragma mark - Public methods

+ (HPPP *)sharedInstance
{
    static HPPP *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[HPPP alloc] init];
    });
    
    return sharedInstance;
}

#pragma mark - Initialization

- (id)init
{
    self = [super init];
    if (self) {
        
        if ([HPPPPrintLaterManager sharedInstance].userNotificationsPermissionSet) {
            [[HPPPPrintLaterManager sharedInstance] initLocationManager];
            [[HPPPPrintLaterManager sharedInstance] initUserNotifications];
        }
        
        self.handlePrintMetricsAutomatically = YES;
        self.lastOptionsUsed = [NSMutableDictionary dictionary];
        self.initialPaperSize = Size5x7;
        self.defaultPaperWidth = 5.0f;
        self.defaultPaperHeight = 7.0f;
        self.zoomAndCrop = NO;
        self.defaultPaperType = Photo;
        self.paperSizes = @[
                            [HPPPPaper titleFromSize:Size4x6],
                            [HPPPPaper titleFromSize:Size5x7],
                            [HPPPPaper titleFromSize:SizeLetter]
                            ];
        
        self.appearance = [[HPPPAppearance alloc] init];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleShareCompletedNotification:) name:kHPPPShareCompletedNotification object:nil];
    }
    
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (BOOL)hideBlackAndWhiteOption
{
    BOOL retVal = YES;
    
    if (IS_OS_8_OR_LATER) {
        retVal = _hideBlackAndWhiteOption;
    }
    
    return retVal;
}

#pragma mark - Metrics 

- (void)handleShareCompletedNotification:(NSNotification *)notification
{
    NSString *offramp = [notification.userInfo objectForKey:kHPPPOfframpKey];
    if (([self printingOfframp:offramp] || [offramp isEqualToString:kHPPPQueueDeleteAction])  && self.handlePrintMetricsAutomatically) {
        // The client app must disable automatic print metric handling in order to post print metrics via the notification system
        return;
    }
    [[HPPPAnalyticsManager sharedManager] trackShareEventWithOptions:notification.userInfo];
}

- (BOOL)printingOfframp:(NSString *)offramp
{
    return
        [offramp isEqualToString:NSStringFromClass([HPPPPrintActivity class])] ||
        [offramp isEqualToString:NSStringFromClass([HPPPPrintLaterActivity class])] ||
        [offramp isEqualToString:kHPPPQueuePrintAction] ||
        [offramp isEqualToString:kHPPPQueuePrintAllAction];
}

#pragma mark - Getter methods

- (UIFont *)rulesLabelFont
{
    if (nil == _rulesLabelFont) {
        return DEFAULT_RULES_LABEL_FONT;
    } else {
        return _rulesLabelFont;
    }
}

- (UIFont *)tableViewCellPrintLabelFont
{
    if (nil == _tableViewCellPrintLabelFont) {
        return DEFAULT_TABLE_VIEW_CELL_PRINT_LABEL_FONT;
    } else {
        return _tableViewCellPrintLabelFont;
    }
}

- (UIColor *)tableViewCellPrintLabelColor
{
    if (nil == _tableViewCellPrintLabelColor) {
        return DEFAULT_TABLE_VIEW_CELL_PRINT_LABEL_COLOR;
    } else {
        return _tableViewCellPrintLabelColor;
    }
}

- (UIFont *)tableViewSupportHeaderLabelFont
{
    if (nil == _tableViewSupportHeaderLabelFont) {
        return DEFAULT_TABLE_VIEW_SUPPORT_HEADER_LABEL_FONT;
    } else {
        return _tableViewSupportHeaderLabelFont;
    }
}

- (UIColor *)tableViewSupportHeaderLabelColor
{
    if (nil == _tableViewSupportHeaderLabelColor) {
        return DEFAULT_TABLE_VIEW_SUPPORT_HEADER_LABEL_COLOR;
    } else {
        return _tableViewSupportHeaderLabelColor;
    }
}

- (UIFont *)tableViewFooterWarningLabelFont
{
    if (nil == _tableViewFooterWarningLabelFont) {
        return DEFAULT_TABLE_VIEW_FOOTER_WARNING_LABEL_FONT;
    } else {
        return _tableViewFooterWarningLabelFont;
    }
}

- (UIColor *)tableViewFooterWarningLabelColor
{
    if (nil == _tableViewFooterWarningLabelColor) {
        return DEFAULT_TABLE_VIEW_FOOTER_WARNING_LABEL_COLOR;
    } else {
        return _tableViewFooterWarningLabelColor;
    }
}

- (UIFont *)tableViewCellLabelFont
{
    if (nil == _tableViewCellLabelFont) {
        return DEFAULT_TABLE_VIEW_CELL_LABEL_FONT;
    } else {
        return _tableViewCellLabelFont;
    }
}

- (UIColor *)tableViewCellLabelColor
{
    if (nil == _tableViewCellLabelColor) {
        return DEFAULT_TABLE_VIEW_CELL_LABEL_COLOR;
    } else {
        return _tableViewCellLabelColor;
    }
}

- (UIFont *)tableViewCellValueFont
{
    if (nil == _tableViewCellValueFont) {
        return DEFAULT_TABLE_VIEW_CELL_VALUE_FONT;
    } else {
        return _tableViewCellValueFont;
    }
}

- (UIColor *)tableViewCellValueColor
{
    if (nil == _tableViewCellValueColor) {
        return DEFAULT_TABLE_VIEW_CELL_VALUE_COLOR;
    } else {
        return _tableViewCellValueColor;
    }
}

- (UIFont *)tableViewSettingsCellValueFont
{
    if (nil == _tableViewSettingsCellValueFont) {
        return DEFAULT_TABLE_VIEW_SETTINGS_CELL_VALUE_FONT;
    } else {
        return _tableViewSettingsCellValueFont;
    }
}

- (UIColor *)tableViewSettingsCellValueColor
{
    if (nil == _tableViewSettingsCellValueColor) {
        return DEFAULT_TABLE_VIEW_SETTINGS_CELL_VALUE_COLOR;
    } else {
        return _tableViewSettingsCellValueColor;
    }
}

- (UIColor *)tableViewCellLinkLabelColor
{
    if (nil == _tableViewCellLinkLabelColor) {
        return DEFAULT_TABLE_VIEW_CELL_LINK_LABEL_COLOR;
    } else {
        return _tableViewCellLinkLabelColor;
    }
}

- (NSString *)defaultDateFormat
{
    if (nil == _defaultDateFormat) {
        return DEFAULT_DATE_FORMAT;
    } else {
        return _defaultDateFormat;
    }
}

- (UIViewController *)printViewControllerWithDelegate:(id<HPPPPrintDelegate>)delegate dataSource:(id<HPPPPrintDataSource>)dataSource printingItem:(id)printingItem previewImage:(UIImage *)previewImage fromQueue:(BOOL)fromQueue
{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"HPPP" bundle:[NSBundle mainBundle]];
    
    
    if (IS_SPLIT_VIEW_CONTROLLER_IMPLEMENTATION) {
        UISplitViewController *pageSettingsSplitViewController = (UISplitViewController *)[storyboard instantiateViewControllerWithIdentifier:@"HPPPPageSettingsSplitViewController"];
        
        UINavigationController *detailsNavigationController = pageSettingsSplitViewController.viewControllers[1];
        detailsNavigationController.navigationBar.translucent = NO;
        HPPPPageViewController *pageViewController = (HPPPPageViewController *)detailsNavigationController.topViewController;
        pageViewController.image = previewImage;
        pageViewController.printingItem = printingItem;
        UINavigationController *masterNavigationController = pageSettingsSplitViewController.viewControllers[0];
        masterNavigationController.navigationBar.translucent = NO;
        HPPPPageSettingsTableViewController *pageSettingsTableViewController = (HPPPPageSettingsTableViewController *)masterNavigationController.topViewController;
        pageSettingsTableViewController.delegate = delegate;
        pageSettingsTableViewController.dataSource = dataSource;
        pageSettingsTableViewController.printFromQueue = fromQueue;
        
        pageSettingsTableViewController.printingItem = printingItem;
        pageSettingsTableViewController.previewImage = previewImage;
        pageSettingsTableViewController.pageViewController = pageViewController;
        pageSettingsSplitViewController.preferredDisplayMode = UISplitViewControllerDisplayModeAllVisible;
        
        return pageSettingsSplitViewController;
    } else {
        // Is not possible to use UISplitViewController in iOS 7 without been the first view controller of the app. You can however do tricky workarounds like embbeding the Split View Controller in a Container View Controller, but that can end up in difficult bugs to find.
        // From Apple Documentation (iOS 7):
        // "you must always install the view from a UISplitViewController object as the root view of your application’s window. [...] Split view controllers cannot be presented modally."
        HPPPPageSettingsTableViewController *pageSettingsTableViewController = (HPPPPageSettingsTableViewController *)[storyboard instantiateViewControllerWithIdentifier:@"HPPPPageSettingsTableViewController"];
        
        pageSettingsTableViewController.printingItem = printingItem;
        pageSettingsTableViewController.previewImage = previewImage;
        pageSettingsTableViewController.delegate = delegate;
        pageSettingsTableViewController.dataSource = dataSource;
        pageSettingsTableViewController.printFromQueue = fromQueue;
        
        UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:pageSettingsTableViewController];
        navigationController.navigationBar.translucent = NO;
        navigationController.modalPresentationStyle = UIModalPresentationFormSheet;
        
        return navigationController;
    }
}

- (UIUserNotificationCategory *)printLaterUserNotificationCategory
{
    return [[HPPPPrintLaterManager sharedInstance] printLaterUserNotificationCategory];
}

- (void)handleNotification:(UILocalNotification *)notification
{
    [[HPPPPrintLaterManager sharedInstance] handleNotification:notification];
}

- (void)handleNotification:(UILocalNotification *)notification action:(NSString *)action
{
    [[HPPPPrintLaterManager sharedInstance] handleNotification:notification action:action];
}

- (void)presentPrintQueueFromController:(UIViewController *)controller animated:(BOOL)animated completion:(void(^)(void))completion
{
    [HPPPPrintJobsViewController presentAnimated:animated usingController:controller andCompletion:completion];
}

- (NSInteger)numberOfJobsInQueue
{
    return [[HPPPPrintLaterQueue sharedInstance] retrieveNumberOfPrintLaterJobs];
}

- (NSString *)nextPrintJobId
{
    return [[HPPPPrintLaterQueue sharedInstance] retrievePrintLaterJobNextAvailableId];
}

- (void)clearQueue
{
    [[HPPPPrintLaterQueue sharedInstance] deleteAllPrintLaterJobs];
}

- (void)addJobToQueue:(HPPPPrintLaterJob *)job
{
    [[HPPPPrintLaterQueue sharedInstance] addPrintLaterJob:job];
}

- (BOOL)isWifiConnected
{
    return [[HPPPWiFiReachability sharedInstance] isWifiConnected];
}

// The following is adaptaed from:  http://stackoverflow.com/questions/4107850/how-can-i-programatically-generate-a-thumbnail-of-a-pdf-with-the-iphone-sdk
- (UIImage *)imageForPDF:(NSData *)pdfData width:(CGFloat)width height:(CGFloat)height dpi:(CGFloat)dpi
{
    CGPDFDocumentRef pdf = [self printingItemAsPdf:pdfData];
    
    if (!pdf) {
        return nil;
    }
    
    CGPDFPageRef page;
    
    CGRect aRect = CGRectMake(0, 0, width * dpi, height * dpi);
    UIGraphicsBeginImageContext(aRect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    UIImage* previewImage;
    
    
    CGContextSaveGState(context);
    CGContextTranslateCTM(context, 0.0, aRect.size.height);
    CGContextScaleCTM(context, 1.0, -1.0);
    
    CGContextSetGrayFillColor(context, 1.0, 1.0);
    CGContextFillRect(context, aRect);
    
    
    // Grab the first PDF page
    page = CGPDFDocumentGetPage(pdf, 1);
    CGRect pageSize = CGPDFPageGetBoxRect(page, kCGPDFMediaBox);
    CGFloat angle = pageSize.size.width > pageSize.size.height ? -90 : 0;
    CGAffineTransform pdfTransform = CGPDFPageGetDrawingTransform(page, kCGPDFMediaBox, aRect, angle, true); // future page layout... check kCGPDFCropBox size
    // And apply the transform.
    CGContextConcatCTM(context, pdfTransform);
    
    CGContextDrawPDFPage(context, page);
    
    // Create the new UIImage from the context
    previewImage = UIGraphicsGetImageFromCurrentImageContext();
    
    CGContextRestoreGState(context);
    
    UIGraphicsEndImageContext();
    CGPDFDocumentRelease(pdf);
    
    return previewImage;
}

- (UIImage *)printingItemAsImage:(id)printingItem;
{
    UIImage *image = nil;

    if ( [printingItem isKindOfClass:[UIImage class]]) {
        image = printingItem;
    } else if ([printingItem isKindOfClass:[NSData class]]) {
        image = [UIImage imageWithData:printingItem scale:[[UIScreen mainScreen] scale]];
    } else {
        HPPPLogWarn(@"Unkown data type for printing item: %@", printingItem);
    }
    
    return image;
}

- (CGPDFDocumentRef)printingItemAsPdf:(id)printingItem;
{
    CGPDFDocumentRef pdf = nil;
    if ([printingItem isKindOfClass:[NSData class]]) {
        CFDataRef pdfDataRef = (CFDataRef)CFBridgingRetain(printingItem);
        CGDataProviderRef provider = CGDataProviderCreateWithCFData(pdfDataRef);
        pdf = CGPDFDocumentCreateWithProvider(provider);
    }
    return pdf;
}

- (UIImage *)previewImageForPrintingItem:(id)printingItem andPaper:(HPPPPaper *)paper
{
    UIImage *previewImage = [[HPPP sharedInstance] printingItemAsImage:printingItem];
    if (nil == previewImage) {
        previewImage = [[HPPP sharedInstance] imageForPDF:printingItem width:paper.width height:paper.height dpi:72.0f];
    }
    return previewImage;
}

@end
