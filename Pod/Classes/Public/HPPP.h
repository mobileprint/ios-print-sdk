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

#import "HPPPPrintActivity.h"
#import "HPPPPageSettingsTableViewController.h"

#define IS_IPHONE (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
#define IS_IPAD (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)

#define IS_OS_8_OR_LATER ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0)

#define IS_IPHONE_4 ([[UIScreen mainScreen] bounds].size.height == 480.0f)
#define IS_IPHONE_5 ([[UIScreen mainScreen] bounds].size.height == 568.0f)
#define IS_IPHONE_6 ([[UIScreen mainScreen] bounds].size.height == 667.0f)
#define IS_IPHONE_6_PLUS ([[UIScreen mainScreen] bounds].size.height == 736.0f)

#define IS_SPLIT_VIEW_CONTROLLER_IMPLEMENTATION (IS_OS_8_OR_LATER && IS_IPAD)

#define IS_PORTRAIT UIDeviceOrientationIsPortrait([UIApplication sharedApplication].statusBarOrientation)
#define IS_LANDSCAPE UIDeviceOrientationIsLandscape([UIApplication sharedApplication].statusBarOrientation)

#define DEGREES_TO_RADIANS(x) (x * M_PI/180.0)

extern NSString * const kHPPPPaperTypeId;
extern NSString * const kHPPPPaperSizeId;
extern NSString * const kHPPPBlackAndWhiteFilterId;
extern NSString * const kHPPPPrinterId;

extern NSString * const kHPPPSupportIcon;
extern NSString * const kHPPPSupportTitle;
extern NSString * const kHPPPSupportUrl;
extern NSString * const kHPPPSupportVC;

@interface HPPP : NSObject

/*!
 If this value is true, the black & white filter option is shown together with the paper size and paper type in the page settings screen.
 
 By default, this value is false and the black & white filter option is shown.
 */
@property (assign, nonatomic) BOOL hideBlackAndWhiteOption;
@property (assign, nonatomic) BOOL hidePaperSizeOption;
@property (assign, nonatomic) BOOL hidePaperTypeOption;

@property (strong, nonatomic) NSArray *paperSizes;
@property (assign, nonatomic) NSInteger defaultPaperSize;
@property (assign, nonatomic) NSInteger defaultPaperType;

@property (strong, nonatomic) NSArray *supportActions;

@property (strong, nonatomic) UIFont *rulesLabelFont;

@property (strong, nonatomic) UIFont *tableViewCellLabelFont;
@property (strong, nonatomic) UIColor *tableViewCellValueColor;
@property (strong, nonatomic) UIColor *tableViewCellLinkLabelColor;

@property (strong, nonatomic) NSMutableDictionary *lastOptionsUsed;


// TODO. Implement these options:
//Layout options
//Zoom and crop?
//Center with no zoom?
//Minimum desired DPI (e.g. 300dpi)



+ (HPPP *)sharedInstance;

@end