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

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "HPPPPrintActivity.h"
#import "HPPPPageSettingsTableViewController.h"
#import "HPPPSupportAction.h"

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

/*! 
 * @abstract Main HP Photo Print manager class
 * @discussion This singleton class manages configuration settings and stored job information.
 */
@interface HPPP : NSObject

/*!
 * @abstract Used to retrieve last paper type used
 * @discussion This key works with the dictionary contained in the @link lastOptionsUsed @/link property. If the last job was successful, the value for this key will contain the paper type used.
 * @seealso lastOptionsUsed
 */
extern NSString * const kHPPPPaperTypeId;

/*!
 * @abstract Used to retrieve last paper size used
 * @discussion This key works with the dictionary contained in the @link lastOptionsUsed @/link property. If the last job was successful, the value for this key will contain the paper size used.
 * @seealso lastOptionsUsed
 */
extern NSString * const kHPPPPaperSizeId;

/*!
 * @abstract Used to retrieve last black/white setting used
 * @discussion This key works with the dictionary contained in the @link lastOptionsUsed @/link property. If the last job was successful, the value for this key will contain a true/false value indicating if black/white was chosen.
 * @seealso lastOptionsUsed
 */
extern NSString * const kHPPPBlackAndWhiteFilterId;

/*!
 * @abstract Used to retrieve ID of the printer used for the last job
 * @discussion This key works with the dictionary contained in the @link lastOptionsUsed @/link property. If the last job was successful, the value for this key will contain the ID of the printer that was used.
 * @seealso lastOptionsUsed
 */
extern NSString * const kHPPPPrinterId;

/*!
 * @abstract Indicates whether the black and white option should be hidden
 * @discussion If this value is true, the black and white filter option is hidden on the print preview page and the black and white filter is not used. The default values is false (not hidden).
 */
@property (assign, nonatomic) BOOL hideBlackAndWhiteOption;

/*!
 * @abstract Indicates whether the paper size option should be hidden
 * @discussion If this value is true, the paper size option is hidden on the print preview page and the default paper size is used. The default values is false (not hidden).
 * @seealso defaultPaperSize
 */
@property (assign, nonatomic) BOOL hidePaperSizeOption;

/*!
 * @abstract Indicates whether the paper type option should be hidden
 * @discussion If this value is true, the paper type option is hidden on the print preview page and the default paper type is used if applicable (e.g. 4x6 always uses photo paper regardless of the value of the default paper type). The default value is false (not hidden).
 * @seealso defaultPaperType
 */
@property (assign, nonatomic) BOOL hidePaperTypeOption;

/*!
 * @abstract List of supported paper sizes
 * @discussion An array of string values specifying the title of the paper sizes to display. These titles are shown in the paper size selection page and must map to known @link PaperSize @/link defined in @link HPPPPaper @/link .
 * @seealso HPPPPaper
 * @seealso PaperSize
 * @seealso titleFromSize:
 */
@property (strong, nonatomic) NSArray *paperSizes;

/*!
 * @abstract Default paper size
 * @discussion A value from the @link PaperSize @/link enum specifying the default paper size to use. This value is used to set the initial selection for paper size. It is also used as the value for paper size when the paper size selection is hidden. Default value is @link Size5x7 @/link .
 * @seealso hidePaperSizeOption
 * @seealso PaperSize
 */
@property (assign, nonatomic) PaperSize defaultPaperSize;

/*!
 * @abstract Default paper type
 * @discussion A value from the @link PaperType @/link enum specifying the default paper type to use. This value is used to set the initial selection for paper type. It is also used as the value for paper type when the paper type selection is hidden. Note that paper type does not apply to all paper sizes (e.g. 4x6 always uses photo paper regardless what paper type is specified). Default value is @link Plain @/link .
 * @seealso hidePaperTypeOption
 * @seealso PaperType
 */
@property (assign, nonatomic) PaperType defaultPaperType;

/*!
 * @abstract Font used for the ruler labels
 */
@property (strong, nonatomic) UIFont *rulesLabelFont;

/*!
 * @abstract Font used for the label of properties
 * @description Used for the name of properties on the print preview page (e.g. Paper Size, Paper Type).
 */
@property (strong, nonatomic) UIFont *tableViewCellLabelFont;

/*!
 * @abstract Font used for the value of properties
 * @description Used for the currently selected value of properties on the print preview page (e.g. 4 x 6, Plain Paper).
 */
@property (strong, nonatomic) UIColor *tableViewCellValueColor;

/*!
 * @abstract Color used for action link text
 * @description Used for one or more action links shown at the bottom of the print preview page
 */
@property (strong, nonatomic) UIColor *tableViewCellLinkLabelColor;

/*!
 * @abstract A dictionary of the most recent print options used
 * @discussion If the last print job was successful this property contains a dictionary of various options used for the job. If the last print job failed or was canceled then this property contains an empty dictionary.
 * @seealso kHPPPBlackAndWhiteFilterId
 * @seealso kHPPPPaperSizeId
 * @seealso kHPPPPaperTypeId
 * @seealso kHPPPPrinterId
 */
@property (strong, nonatomic) NSDictionary *lastOptionsUsed;

/*!
 * @property supportActions
 * @abstract An array of support actions to display on the print preview page
 * @discussion This is an array of @link HPPPSupportAction @/link objects, each describing a single support action. Support actions include an icon and a title and are displayed in a support section at the bottom of the print preview page. An action can either open a URL or present a view controller.
 * @seealso kHPPPSupportAction
 */
@property (strong, nonatomic) NSArray *supportActions;


// TODO. Implement these options:
//Layout options
//Zoom and crop?
//Center with no zoom?
//Minimum desired DPI (e.g. 300dpi)


/*!
 * @abstract Used to access the singleton instance of this class
 */
+ (HPPP *)sharedInstance;

@end
