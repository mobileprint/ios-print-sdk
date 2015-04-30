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
#import "HPPPAttributedString.h"
#import "UIColor+HPPPStyle.h"
#import "NSBundle+HPPPLocalizable.h"

// Print Later Screen
NSString *const HPPPAddPrintLaterJobScreenAddToPrintQFontAttribute = @"HPPPAddPrintLaterJobScreenAddToPrintQFontAttribute";
NSString *const HPPPAddPrintLaterJobScreenAddToPrintQColorAttribute = @"HPPPAddPrintLaterJobScreenAddToPrintQColorAttribute";;
NSString *const HPPPAddPrintLaterJobScreenJobNameFontAttribute = @"HPPPAddPrintLaterJobScreenJobNameFontAttribute";
NSString *const HPPPAddPrintLaterJobScreenJobNameColorActiveAttribute = @"HPPPAddPrintLaterJobScreenJobNameColorActiveAttribute";
NSString *const HPPPAddPrintLaterJobScreenJobNameColorInactiveAttribute = @"HPPPAddPrintLaterJobScreenJobNameColorInactiveAttribute";
NSString *const HPPPAddPrintLaterJobScreenSubitemTitleFontAttribute = @"HPPPAddPrintLaterJobScreenSubitemTitleFontAttribute";
NSString *const HPPPAddPrintLaterJobScreenSubitemTitleColorAttribute = @"HPPPAddPrintLaterJobScreenSubitemTitleColorAttribute";
NSString *const HPPPAddPrintLaterJobScreenSubitemFontAttribute = @"HPPPAddPrintLaterJobScreenSubitemFontAttribute";
NSString *const HPPPAddPrintLaterJobScreenSubitemColorAttribute = @"HPPPAddPrintLaterJobScreenSubitemColorAttribute";
NSString *const HPPPAddPrintLaterJobScreenDoneButtonAttribute = @"HPPPAddPrintLaterJobScreenDoneButtonAttribute";

#define DEFAULT_ADD_TO_PRINT_Q_FONT [UIFont fontWithName:@"Helvetica Neue" size:18]
#define DEFAULT_ADD_TO_PRINT_Q_COLOR [UIColor HPPPHPBlueColor]

#define DEFAULT_JOB_NAME_FONT [UIFont fontWithName:@"Helvetica Neue" size:24]
#define DEFAULT_JOB_NAME_ACTIVE_COLOR [UIColor colorWithRed:0x33 / 255.0f green:0x33 / 255.0f blue:0x33 / 255.0f alpha:1.0f]
#define DEFAULT_JOB_NAME_INACTIVE_COLOR [UIColor colorWithRed:0x76 / 255.0f green:0x76 / 255.0f blue:0x76 / 255.0f alpha:1.0f]

#define DEFAULT_SUBITEM_TITLE_FONT [UIFont fontWithName:@"Helvetica Neue" size:18]
#define DEFAULT_SUBITEM_TITLE_COLOR [UIColor colorWithRed:0x76 / 255.0f green:0x76 / 255.0f blue:0x76 / 255.0f alpha:1.0f]

#define DEFAULT_SUBITEM_VALUE_FONT [UIFont fontWithName:@"Helvetica Neue" size:16]
#define DEFAULT_SUBITEM_VALUE_COLOR [UIColor colorWithRed:0x33 / 255.0f green:0x33 / 255.0f blue:0x33 / 255.0f alpha:1.0f]

#define DEFAULT_ADD_PRINT_LATER_JOB_SCREEN_ATTRIBUTES @{HPPPAddPrintLaterJobScreenAddToPrintQFontAttribute:DEFAULT_ADD_TO_PRINT_Q_FONT, \
                                                        HPPPAddPrintLaterJobScreenAddToPrintQColorAttribute:DEFAULT_ADD_TO_PRINT_Q_COLOR, \
                                                        HPPPAddPrintLaterJobScreenJobNameFontAttribute:DEFAULT_JOB_NAME_FONT, \
                                                        HPPPAddPrintLaterJobScreenJobNameColorActiveAttribute:DEFAULT_JOB_NAME_ACTIVE_COLOR, \
                                                        HPPPAddPrintLaterJobScreenJobNameColorInactiveAttribute:DEFAULT_JOB_NAME_INACTIVE_COLOR, \
                                                        HPPPAddPrintLaterJobScreenSubitemTitleFontAttribute:DEFAULT_SUBITEM_TITLE_FONT, \
                                                        HPPPAddPrintLaterJobScreenSubitemTitleColorAttribute:DEFAULT_SUBITEM_TITLE_COLOR, \
                                                        HPPPAddPrintLaterJobScreenSubitemFontAttribute:DEFAULT_SUBITEM_VALUE_FONT, \
                                                        HPPPAddPrintLaterJobScreenSubitemColorAttribute:DEFAULT_SUBITEM_VALUE_COLOR, \
                                                        HPPPAddPrintLaterJobScreenDoneButtonAttribute:[self doneButton]}


// Print Queue Screen
NSString *const HPPPPrintQueueScreenPrintsCounterLabelFontAttribute = @"HPPPPrintQueueScreenPrintsCounterLabelFontAttribute";
NSString *const HPPPPrintQueueScreenPrintsCounterLabelColorAttribute = @"HPPPPrintQueueScreenPrintsCounterLabelColorAttribute";
NSString *const HPPPPrintQueueScreenNoWifiLabelFontAttribute = @"HPPPPrintQueueScreenNoWifiLabelFontAttribute";
NSString *const HPPPPrintQueueScreenNoWifiLabelColorAttribute = @"HPPPPrintQueueScreenNoWifiLabelColorAttribute";
NSString *const HPPPPrintQueueScreenActionButtonsFontAttribute = @"HPPPPrintQueueScreenActionButtonsFontAttribute";
NSString *const HPPPPrintQueueScreenActionButtonsEnableColorAttribute = @"HPPPPrintQueueScreenActionButtonsEnableColorAttribute";
NSString *const HPPPPrintQueueScreenActionButtonsDisableColorAttribute = @"HPPPPrintQueueScreenActionButtonsDisableColorAttribute";
NSString *const HPPPPrintQueueScreenActionButtonsSeparatorColorAttribute = @"HPPPPrintQueueScreenActionButtonsSeparatorColorAttribute";
NSString *const HPPPPrintQueueScreenJobNameFontAttribute = @"HPPPPrintQueueScreenJobNameFontAttribute";
NSString *const HPPPPrintQueueScreenJobNameColorAttribute = @"HPPPPrintQueueScreenJobNameColorAttribute";
NSString *const HPPPPrintQueueScreenJobDateFontAttribute = @"HPPPPrintQueueScreenJobDateFontAttribute";
NSString *const HPPPPrintQueueScreenJobDateColorAttribute = @"HPPPPrintQueueScreenJobDateColorAttribute";
NSString *const HPPPPrintQueueScreenPreviewJobNameFontAttribute = @"HPPPPrintQueueScreenPreviewJobNameFontAttribute";
NSString *const HPPPPrintQueueScreenPreviewJobNameColorAttribute = @"HPPPPrintQueueScreenPreviewJobNameColorAttribute";
NSString *const HPPPPrintQueueScreenPreviewJobDateFontAttribute = @"HPPPPrintQueueScreenPreviewJobDateFontAttribute";
NSString *const HPPPPrintQueueScreenPreviewJobDateColorAttribute = @"HPPPPrintQueueScreenPreviewJobDateColorAttribute";
NSString *const HPPPPrintQueueScreenPreviewDoneButtonFontAttribute = @"HPPPPrintQueueScreenPreviewDoneButtonFontAttribute";
NSString *const HPPPPrintQueueScreenPreviewDoneButtonColorAttribute = @"HPPPPrintQueueScreenPreviewDoneButtonColorAttribute";

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

#define DEFAULT_PRINT_Q_PREVIEW_JOB_NAME_FONT [UIFont fontWithName:@"Helvetica Neue" size:14]
#define DEFAULT_PRINT_Q_PREVIEW_JOB_NAME_COLOR [UIColor whiteColor]

#define DEFAULT_PRINT_Q_PREVIEW_JOB_DATE_FONT [UIFont fontWithName:@"Helvetica Neue" size:12]
#define DEFAULT_PRINT_Q_PREVIEW_JOB_DATE_COLOR [UIColor whiteColor]

#define DEFAULT_PRINT_Q_PREVIEW_DONE_BUTTON_FONT [UIFont fontWithName:@"Helvetica Neue" size:16]
#define DEFAULT_PRINT_Q_PREVIEW_DONE_BUTTON_COLOR [UIColor whiteColor]


#define DEFAULT_PRINT_Q_SCREEN_ATTRIBUTES @{HPPPPrintQueueScreenPrintsCounterLabelFontAttribute:DEFAULT_PRINT_Q_PRINTS_COUNTER_FONT, \
                                            HPPPPrintQueueScreenPrintsCounterLabelColorAttribute:DEFAULT_PRINT_Q_PRINTS_COUNTER_COLOR, \
                                            HPPPPrintQueueScreenNoWifiLabelFontAttribute:DEFAULT_PRINT_Q_NO_WIFI_FONT, \
                                            HPPPPrintQueueScreenNoWifiLabelColorAttribute:DEFAULT_PRINT_Q_NO_WIFI_COLOR, \
                                            HPPPPrintQueueScreenActionButtonsFontAttribute:DEFAULT_PRINT_Q_ACTION_BUTTONS_FONT, \
                                            HPPPPrintQueueScreenActionButtonsEnableColorAttribute:DEFAULT_PRINT_Q_ACTION_BUTTONS_ENABLE_COLOR, \
                                            HPPPPrintQueueScreenActionButtonsDisableColorAttribute:DEFAULT_PRINT_Q_ACTION_BUTTONS_DISABLE_COLOR, \
                                            HPPPPrintQueueScreenActionButtonsSeparatorColorAttribute:DEFAULT_PRINT_Q_ACTION_BUTTONS_SEPARATOR_COLOR, \
                                            HPPPPrintQueueScreenJobNameFontAttribute:DEFAULT_PRINT_Q_JOB_NAME_FONT, \
                                            HPPPPrintQueueScreenJobNameColorAttribute:DEFAULT_PRINT_Q_JOB_NAME_COLOR, \
                                            HPPPPrintQueueScreenJobDateFontAttribute:DEFAULT_PRINT_Q_JOB_DATE_FONT, \
                                            HPPPPrintQueueScreenJobDateColorAttribute:DEFAULT_PRINT_Q_JOB_DATE_COLOR, \
                                            HPPPPrintQueueScreenPreviewJobNameFontAttribute:DEFAULT_PRINT_Q_PREVIEW_JOB_NAME_FONT, \
                                            HPPPPrintQueueScreenPreviewJobNameColorAttribute:DEFAULT_PRINT_Q_PREVIEW_JOB_NAME_COLOR, \
                                            HPPPPrintQueueScreenPreviewJobDateFontAttribute:DEFAULT_PRINT_Q_PREVIEW_JOB_DATE_FONT, \
                                            HPPPPrintQueueScreenPreviewJobDateColorAttribute:DEFAULT_PRINT_Q_PREVIEW_JOB_DATE_COLOR, \
                                            HPPPPrintQueueScreenPreviewDoneButtonFontAttribute:DEFAULT_PRINT_Q_PREVIEW_DONE_BUTTON_FONT, \
                                            HPPPPrintQueueScreenPreviewDoneButtonColorAttribute:DEFAULT_PRINT_Q_PREVIEW_DONE_BUTTON_COLOR}


@implementation HPPPAttributedString

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
