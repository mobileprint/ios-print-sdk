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
#import "HPPPAppearance.h"
#import "UIColor+HPPPStyle.h"
#import "NSBundle+HPPPLocalizable.h"

@implementation HPPPAppearance

// Print Later Screen

NSString * const kHPPPAddPrintLaterJobScreenAddToPrintQFontAttribute = @"kHPPPAddPrintLaterJobScreenAddToPrintQFontAttribute";
NSString * const kHPPPAddPrintLaterJobScreenAddToPrintQColorAttribute = @"kHPPPAddPrintLaterJobScreenAddToPrintQColorAttribute";;
NSString * const kHPPPAddPrintLaterJobScreenJobNameFontAttribute = @"kHPPPAddPrintLaterJobScreenJobNameFontAttribute";
NSString * const kHPPPAddPrintLaterJobScreenJobNameColorActiveAttribute = @"kHPPPAddPrintLaterJobScreenJobNameColorActiveAttribute";
NSString * const kHPPPAddPrintLaterJobScreenJobNameColorInactiveAttribute = @"kHPPPAddPrintLaterJobScreenJobNameColorInactiveAttribute";
NSString * const kHPPPAddPrintLaterJobScreenSubitemTitleFontAttribute = @"kHPPPAddPrintLaterJobScreenSubitemTitleFontAttribute";
NSString * const kHPPPAddPrintLaterJobScreenSubitemTitleColorAttribute = @"kHPPPAddPrintLaterJobScreenSubitemTitleColorAttribute";
NSString * const kHPPPAddPrintLaterJobScreenSubitemFontAttribute = @"kHPPPAddPrintLaterJobScreenSubitemFontAttribute";
NSString * const kHPPPAddPrintLaterJobScreenSubitemColorAttribute = @"kHPPPAddPrintLaterJobScreenSubitemColorAttribute";
NSString * const kHPPPAddPrintLaterJobScreenDoneButtonAttribute = @"kHPPPAddPrintLaterJobScreenDoneButtonAttribute";

#define DEFAULT_ADD_TO_PRINT_Q_FONT [UIFont fontWithName:@"Helvetica Neue" size:18]
#define DEFAULT_ADD_TO_PRINT_Q_COLOR [UIColor HPPPHPBlueColor]

#define DEFAULT_JOB_NAME_FONT [UIFont fontWithName:@"Helvetica Neue" size:24]
#define DEFAULT_JOB_NAME_ACTIVE_COLOR [UIColor colorWithRed:0x33 / 255.0f green:0x33 / 255.0f blue:0x33 / 255.0f alpha:1.0f]
#define DEFAULT_JOB_NAME_INACTIVE_COLOR [UIColor colorWithRed:0x76 / 255.0f green:0x76 / 255.0f blue:0x76 / 255.0f alpha:1.0f]

#define DEFAULT_SUBITEM_TITLE_FONT [UIFont fontWithName:@"Helvetica Neue" size:18]
#define DEFAULT_SUBITEM_TITLE_COLOR [UIColor colorWithRed:0x76 / 255.0f green:0x76 / 255.0f blue:0x76 / 255.0f alpha:1.0f]

#define DEFAULT_SUBITEM_VALUE_FONT [UIFont fontWithName:@"Helvetica Neue" size:16]
#define DEFAULT_SUBITEM_VALUE_COLOR [UIColor colorWithRed:0x33 / 255.0f green:0x33 / 255.0f blue:0x33 / 255.0f alpha:1.0f]

#define DEFAULT_ADD_PRINT_LATER_JOB_SCREEN_ATTRIBUTES @{kHPPPAddPrintLaterJobScreenAddToPrintQFontAttribute:DEFAULT_ADD_TO_PRINT_Q_FONT, \
kHPPPAddPrintLaterJobScreenAddToPrintQColorAttribute:DEFAULT_ADD_TO_PRINT_Q_COLOR, \
kHPPPAddPrintLaterJobScreenJobNameFontAttribute:DEFAULT_JOB_NAME_FONT, \
kHPPPAddPrintLaterJobScreenJobNameColorActiveAttribute:DEFAULT_JOB_NAME_ACTIVE_COLOR, \
kHPPPAddPrintLaterJobScreenJobNameColorInactiveAttribute:DEFAULT_JOB_NAME_INACTIVE_COLOR, \
kHPPPAddPrintLaterJobScreenSubitemTitleFontAttribute:DEFAULT_SUBITEM_TITLE_FONT, \
kHPPPAddPrintLaterJobScreenSubitemTitleColorAttribute:DEFAULT_SUBITEM_TITLE_COLOR, \
kHPPPAddPrintLaterJobScreenSubitemFontAttribute:DEFAULT_SUBITEM_VALUE_FONT, \
kHPPPAddPrintLaterJobScreenSubitemColorAttribute:DEFAULT_SUBITEM_VALUE_COLOR, \
kHPPPAddPrintLaterJobScreenDoneButtonAttribute:[self doneButton]}

// Print Queue Screen

NSString * const kHPPPPrintQueueScreenPrintsCounterLabelFontAttribute = @"kHPPPPrintQueueScreenPrintsCounterLabelFontAttribute";
NSString * const kHPPPPrintQueueScreenPrintsCounterLabelColorAttribute = @"kHPPPPrintQueueScreenPrintsCounterLabelColorAttribute";
NSString * const kHPPPPrintQueueScreenNoWifiLabelFontAttribute = @"kHPPPPrintQueueScreenNoWifiLabelFontAttribute";
NSString * const kHPPPPrintQueueScreenNoWifiLabelColorAttribute = @"kHPPPPrintQueueScreenNoWifiLabelColorAttribute";
NSString * const kHPPPPrintQueueScreenActionButtonsFontAttribute = @"kHPPPPrintQueueScreenActionButtonsFontAttribute";
NSString * const kHPPPPrintQueueScreenActionButtonsEnableColorAttribute = @"kHPPPPrintQueueScreenActionButtonsEnableColorAttribute";
NSString * const kHPPPPrintQueueScreenActionButtonsDisableColorAttribute = @"kHPPPPrintQueueScreenActionButtonsDisableColorAttribute";
NSString * const kHPPPPrintQueueScreenActionButtonsSeparatorColorAttribute = @"kHPPPPrintQueueScreenActionButtonsSeparatorColorAttribute";
NSString * const kHPPPPrintQueueScreenJobNameFontAttribute = @"kHPPPPrintQueueScreenJobNameFontAttribute";
NSString * const kHPPPPrintQueueScreenJobNameColorAttribute = @"kHPPPPrintQueueScreenJobNameColorAttribute";
NSString * const kHPPPPrintQueueScreenJobDateFontAttribute = @"kHPPPPrintQueueScreenJobDateFontAttribute";
NSString * const kHPPPPrintQueueScreenJobDateColorAttribute = @"kHPPPPrintQueueScreenJobDateColorAttribute";
NSString * const kHPPPPrintQueueScreenEmptyQueueFontAttribute = @"kHPPPPrintQueueScreenEmptyQueueFontAttribute";
NSString * const kHPPPPrintQueueScreenEmptyQueueColorAttribute = @"kHPPPPrintQueueScreenEmptyQueueColorAttribute";
NSString * const kHPPPPrintQueueScreenPreviewJobNameFontAttribute = @"kHPPPPrintQueueScreenPreviewJobNameFontAttribute";
NSString * const kHPPPPrintQueueScreenPreviewJobNameColorAttribute = @"kHPPPPrintQueueScreenPreviewJobNameColorAttribute";
NSString * const kHPPPPrintQueueScreenPreviewJobDateFontAttribute = @"kHPPPPrintQueueScreenPreviewJobDateFontAttribute";
NSString * const kHPPPPrintQueueScreenPreviewJobDateColorAttribute = @"kHPPPPrintQueueScreenPreviewJobDateColorAttribute";
NSString * const kHPPPPrintQueueScreenPreviewDoneButtonFontAttribute = @"kHPPPPrintQueueScreenPreviewDoneButtonFontAttribute";
NSString * const kHPPPPrintQueueScreenPreviewDoneButtonColorAttribute = @"kHPPPPrintQueueScreenPreviewDoneButtonColorAttribute";

#define DEFAULT_PRINT_Q_PRINTS_COUNTER_FONT [UIFont fontWithName:@"Helvetica Neue" size:14]
#define DEFAULT_PRINT_Q_PRINTS_COUNTER_COLOR [UIColor whiteColor]

#define DEFAULT_PRINT_Q_NO_WIFI_FONT [UIFont fontWithName:@"HelveticaNeue-Light" size:18]
#define DEFAULT_PRINT_Q_NO_WIFI_COLOR [UIColor colorWithRed:0x88 / 255.0f green:0x88 / 255.0f blue:0x88 / 255.0f alpha:1.0f]

#define DEFAULT_PRINT_Q_ACTION_BUTTONS_FONT [UIFont fontWithName:@"HelveticaNeue-Light" size:12]
#define DEFAULT_PRINT_Q_ACTION_BUTTONS_ENABLE_COLOR [UIColor whiteColor]
#define DEFAULT_PRINT_Q_ACTION_BUTTONS_DISABLE_COLOR [UIColor colorWithRed:0xFF / 255.0f green:0xFF / 255.0f blue:0xFF / 255.0f alpha:0.5f]
#define DEFAULT_PRINT_Q_ACTION_BUTTONS_SEPARATOR_COLOR [UIColor colorWithRed:0xFF / 255.0f green:0xFF / 255.0f blue:0xFF / 255.0f alpha:0.5f]

#define DEFAULT_PRINT_Q_JOB_NAME_FONT [UIFont fontWithName:@"Helvetica Neue" size:14]
#define DEFAULT_PRINT_Q_JOB_NAME_COLOR [UIColor colorWithRed:0x33 / 255.0f green:0x33 / 255.0f blue:0x33 / 255.0f alpha:1.0f]

#define DEFAULT_PRINT_Q_JOB_DATE_FONT [UIFont fontWithName:@"Helvetica Neue" size:12]
#define DEFAULT_PRINT_Q_JOB_DATE_COLOR [UIColor colorWithRed:0x88 / 255.0f green:0x88 / 255.0f blue:0x88 / 255.0f alpha:1.0f]

#define DEFAULT_PRINT_Q_JOB_EMPTY_QUEUE_FONT [UIFont fontWithName:@"Helvetica Neue" size:12]
#define DEFAULT_PRINT_Q_JOB_EMPTY_QUEUE_COLOR [UIColor colorWithRed:0x88 / 255.0f green:0x88 / 255.0f blue:0x88 / 255.0f alpha:1.0f]

#define DEFAULT_PRINT_Q_PREVIEW_JOB_NAME_FONT [UIFont fontWithName:@"Helvetica Neue" size:14]
#define DEFAULT_PRINT_Q_PREVIEW_JOB_NAME_COLOR [UIColor whiteColor]

#define DEFAULT_PRINT_Q_PREVIEW_JOB_DATE_FONT [UIFont fontWithName:@"Helvetica Neue" size:12]
#define DEFAULT_PRINT_Q_PREVIEW_JOB_DATE_COLOR [UIColor whiteColor]

#define DEFAULT_PRINT_Q_PREVIEW_DONE_BUTTON_FONT [UIFont fontWithName:@"Helvetica Neue" size:16]
#define DEFAULT_PRINT_Q_PREVIEW_DONE_BUTTON_COLOR [UIColor whiteColor]


#define DEFAULT_PRINT_Q_SCREEN_ATTRIBUTES @{kHPPPPrintQueueScreenPrintsCounterLabelFontAttribute:DEFAULT_PRINT_Q_PRINTS_COUNTER_FONT, \
kHPPPPrintQueueScreenPrintsCounterLabelColorAttribute:DEFAULT_PRINT_Q_PRINTS_COUNTER_COLOR, \
kHPPPPrintQueueScreenNoWifiLabelFontAttribute:DEFAULT_PRINT_Q_NO_WIFI_FONT, \
kHPPPPrintQueueScreenNoWifiLabelColorAttribute:DEFAULT_PRINT_Q_NO_WIFI_COLOR, \
kHPPPPrintQueueScreenActionButtonsFontAttribute:DEFAULT_PRINT_Q_ACTION_BUTTONS_FONT, \
kHPPPPrintQueueScreenActionButtonsEnableColorAttribute:DEFAULT_PRINT_Q_ACTION_BUTTONS_ENABLE_COLOR, \
kHPPPPrintQueueScreenActionButtonsDisableColorAttribute:DEFAULT_PRINT_Q_ACTION_BUTTONS_DISABLE_COLOR, \
kHPPPPrintQueueScreenActionButtonsSeparatorColorAttribute:DEFAULT_PRINT_Q_ACTION_BUTTONS_SEPARATOR_COLOR, \
kHPPPPrintQueueScreenJobNameFontAttribute:DEFAULT_PRINT_Q_JOB_NAME_FONT, \
kHPPPPrintQueueScreenJobNameColorAttribute:DEFAULT_PRINT_Q_JOB_NAME_COLOR, \
kHPPPPrintQueueScreenJobDateFontAttribute:DEFAULT_PRINT_Q_JOB_DATE_FONT, \
kHPPPPrintQueueScreenJobDateColorAttribute:DEFAULT_PRINT_Q_JOB_DATE_COLOR, \
kHPPPPrintQueueScreenEmptyQueueFontAttribute:DEFAULT_PRINT_Q_JOB_EMPTY_QUEUE_FONT, \
kHPPPPrintQueueScreenEmptyQueueColorAttribute:DEFAULT_PRINT_Q_JOB_EMPTY_QUEUE_COLOR, \
kHPPPPrintQueueScreenPreviewJobNameFontAttribute:DEFAULT_PRINT_Q_PREVIEW_JOB_NAME_FONT, \
kHPPPPrintQueueScreenPreviewJobNameColorAttribute:DEFAULT_PRINT_Q_PREVIEW_JOB_NAME_COLOR, \
kHPPPPrintQueueScreenPreviewJobDateFontAttribute:DEFAULT_PRINT_Q_PREVIEW_JOB_DATE_FONT, \
kHPPPPrintQueueScreenPreviewJobDateColorAttribute:DEFAULT_PRINT_Q_PREVIEW_JOB_DATE_COLOR, \
kHPPPPrintQueueScreenPreviewDoneButtonFontAttribute:DEFAULT_PRINT_Q_PREVIEW_DONE_BUTTON_FONT, \
kHPPPPrintQueueScreenPreviewDoneButtonColorAttribute:DEFAULT_PRINT_Q_PREVIEW_DONE_BUTTON_COLOR}

- (NSDictionary *)addPrintLaterJobScreenAttributes
{
    if (nil == _addPrintLaterJobScreenAttributes) {
        _addPrintLaterJobScreenAttributes = DEFAULT_ADD_PRINT_LATER_JOB_SCREEN_ATTRIBUTES;
    }
    
    return _addPrintLaterJobScreenAttributes;
}

- (UIButton *)doneButton
{
    UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 64, 34)];
    [button setTitle:HPPPLocalizedString(@"Done", nil) forState:UIControlStateNormal];
    button.titleLabel.font = [UIFont fontWithName:@"System" size:18];
    button.titleLabel.textAlignment = NSTextAlignmentRight;
    [button setTitleColor:[UIColor HPPPHPBlueColor] forState:UIControlStateNormal];
    
    return button;
}

- (NSDictionary *)printQueueScreenAttributes
{
    if (nil == _printQueueScreenAttributes) {
        _printQueueScreenAttributes = DEFAULT_PRINT_Q_SCREEN_ATTRIBUTES;
    }
    
    return _printQueueScreenAttributes;
}

@end
