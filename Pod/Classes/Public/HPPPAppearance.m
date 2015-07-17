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

// Document Cell
NSString * const kHPPPAddPrintLaterJobScreenJobPageSelectedImageAttribute = @"kHPPPAddPrintLaterJobScreenJobPageSelectedImageAttribute";

NSString * const kHPPPAddPrintLaterJobScreenJobPageNotSelectedImageAttribute = @"kHPPPAddPrintLaterJobScreenJobPageNotSelectedImageAttribute";

// Job Summary Cell
NSString * const kHPPPAddPrintLaterJobScreenJobSummaryTitleFontAttribute = @"kHPPPAddPrintLaterJobScreenJobSummaryTitleFontAttribute";

NSString * const kHPPPAddPrintLaterJobScreenJobSummaryTitleColorAttribute = @"kHPPPAddPrintLaterJobScreenJobSummaryTitleColorAttribute";

NSString * const kHPPPAddPrintLaterJobScreenJobSummarySubtitleFontAttribute = @"kHPPPAddPrintLaterJobScreenJobSummarySubtitleFontAttribute";

NSString * const kHPPPAddPrintLaterJobScreenJobSummarySubtitleColorAttribute = @"kHPPPAddPrintLaterJobScreenJobSummarySubtitleColorAttribute";

// Add to Print Queue Button
NSString * const kHPPPAddPrintLaterJobScreenAddToPrintQFontAttribute = @"kHPPPAddPrintLaterJobScreenAddToPrintQFontAttribute";

NSString * const kHPPPAddPrintLaterJobScreenAddToPrintQActiveColorAttribute = @"kHPPPAddPrintLaterJobScreenAddToPrintQActiveColorAttribute";

NSString * const kHPPPAddPrintLaterJobScreenAddToPrintQInactiveColorAttribute = @"kHPPPAddPrintLaterJobScreenAddToPrintQInactiveColorAttribute";

// Name Cell
NSString * const kHPPPAddPrintLaterJobScreenJobNameTitleFontAttribute = @"kHPPPAddPrintLaterJobScreenJobNameTitleFontAttribute";

NSString * const kHPPPAddPrintLaterJobScreenJobNameTitleColorAttribute = @"kHPPPAddPrintLaterJobScreenJobNameTitleColorAttribute";

NSString * const kHPPPAddPrintLaterJobScreenJobNameDetailFontAttribute = @"kHPPPAddPrintLaterJobScreenJobNameDetailFontAttribute";

NSString * const kHPPPAddPrintLaterJobScreenJobNameDetailColorAttribute = @"kHPPPAddPrintLaterJobScreenJobNameDetailColorAttribute";

// Copy Cell
NSString * const kHPPPAddPrintLaterJobScreenCopyTitleFontAttribute = @"kHPPPAddPrintLaterJobScreenCopyTitleFontAttribute";

NSString * const kHPPPAddPrintLaterJobScreenCopyTitleColorAttribute = @"kHPPPAddPrintLaterJobScreenCopyTitleColorAttribute";

NSString * const kHPPPAddPrintLaterJobScreenCopyStepperColorAttribute = @"kHPPPAddPrintLaterJobScreenCopyStepperColorAttribute";

// Page Range Cell
NSString * const kHPPPAddPrintLaterJobScreenPageRangeTitleFontAttribute = @"kHPPPAddPrintLaterJobScreenPageRangeTitleFontAttribute";

NSString * const kHPPPAddPrintLaterJobScreenPageRangeTitleColorAttribute = @"kHPPPAddPrintLaterJobScreenPageRangeTitleColorAttribute";

NSString * const kHPPPAddPrintLaterJobScreenPageRangeDetailFontAttribute = @"kHPPPAddPrintLaterJobScreenPageRangeDetailFontAttribute";

NSString * const kHPPPAddPrintLaterJobScreenPageRangeDetailColorAttribute = @"kHPPPAddPrintLaterJobScreenPageRangeDetailColorAttribute";

// Black and White Cell
NSString * const kHPPPAddPrintLaterJobScreenBWTitleFontAttribute = @"kHPPPAddPrintLaterJobScreenBWTitleFontAttribute";

NSString * const kHPPPAddPrintLaterJobScreenBWTitleColorAttribute = @"kHPPPAddPrintLaterJobScreenBWTitleColorAttribute";

// Print Queue Description
NSString * const kHPPPAddPrintLaterJobScreenDescriptionTitleFontAttribute = @"kHPPPAddPrintLaterJobScreenDescriptionTitleFontAttribute";

NSString * const kHPPPAddPrintLaterJobScreenDescriptionTitleColorAttribute = @"kHPPPAddPrintLaterJobScreenDescriptionTitleColorAttribute";

NSString * const kHPPPAddPrintLaterJobScreenDescriptionDetailFontAttribute = @"kHPPPAddPrintLaterJobScreenDescriptionDetailFontAttribute";

NSString * const kHPPPAddPrintLaterJobScreenDescriptionDetailColorAttribute = @"kHPPPAddPrintLaterJobScreenDescriptionDetailColorAttribute";

#define DEFAULT_ADD_PRINT_LATER_PAGE_SELECTED_IMAGE      [UIImage imageNamed:@"HPPPSelected.png"]
#define DEFAULT_ADD_PRINT_LATER_PAGE_NOT_SELECTED_IMAGE  [UIImage imageNamed:@"HPPPUnselected.png"]
#define DEFAULT_ADD_PRINT_LATER_JOB_FONT                 [UIFont fontWithName:@"Helvetica Neue" size:16]
#define DEFAULT_ADD_PRINT_LATER_JOB_INFORM_COLOR         [UIColor colorWithRed:0x33 / 255.0f green:0x33 / 255.0f blue:0x33 / 255.0f alpha:1.0f]
#define DEFAULT_ADD_PRINT_LATER_JOB_ACTIVE_COLOR         [UIColor colorWithRed:0.0 green:122.0/255.0 blue:1.0 alpha:1.0]
#define DEFAULT_ADD_PRINT_LATER_JOB_INACTIVE_COLOR       [UIColor colorWithRed:0x76 / 255.0f green:0x76 / 255.0f blue:0x76 / 255.0f alpha:1.0f]

#define DEFAULT_ADD_PRINT_LATER_JOB_TITLE_FONT         DEFAULT_ADD_PRINT_LATER_JOB_FONT
#define DEFAULT_ADD_PRINT_LATER_JOB_TITLE_COLOR        DEFAULT_ADD_PRINT_LATER_JOB_INFORM_COLOR

#define DEFAULT_ADD_PRINT_LATER_JOB_DETAIL_FONT        DEFAULT_ADD_PRINT_LATER_JOB_TITLE_FONT
#define DEFAULT_ADD_PRINT_LATER_JOB_DETAIL_COLOR       DEFAULT_ADD_PRINT_LATER_JOB_INACTIVE_COLOR

#define DEFAULT_ADD_PRINT_LATER_JOB_SUBTITLE_FONT      [UIFont fontWithName:@"Helvetica Neue" size:11]
#define DEFAULT_ADD_PRINT_LATER_JOB_SUBTITLE_COLOR     DEFAULT_ADD_PRINT_LATER_JOB_TITLE_COLOR

#define DEFAULT_ADD_PRINT_LATER_JOB_TEXT_HEADING_FONT  [UIFont fontWithName:@"HelveticaNeue-Bold" size:12]
#define DEFAULT_ADD_PRINT_LATER_JOB_TEXT_HEADING_COLOR DEFAULT_ADD_PRINT_LATER_JOB_INFORM_COLOR

#define DEFAULT_ADD_PRINT_LATER_JOB_TEXT_FONT          [UIFont fontWithName:@"Helvetica Neue" size:12]
#define DEFAULT_ADD_PRINT_LATER_JOB_TEXT_COLOR         DEFAULT_ADD_PRINT_LATER_JOB_INFORM_COLOR

#define DEFAULT_ADD_PRINT_LATER_JOB_SCREEN_ATTRIBUTES @{kHPPPAddPrintLaterJobScreenJobPageSelectedImageAttribute:DEFAULT_ADD_PRINT_LATER_PAGE_SELECTED_IMAGE, \
kHPPPAddPrintLaterJobScreenJobPageNotSelectedImageAttribute:DEFAULT_ADD_PRINT_LATER_PAGE_NOT_SELECTED_IMAGE, \
kHPPPAddPrintLaterJobScreenJobSummaryTitleFontAttribute:DEFAULT_ADD_PRINT_LATER_JOB_TITLE_FONT, \
kHPPPAddPrintLaterJobScreenJobSummaryTitleColorAttribute:DEFAULT_ADD_PRINT_LATER_JOB_TITLE_COLOR, \
kHPPPAddPrintLaterJobScreenJobSummarySubtitleFontAttribute:DEFAULT_ADD_PRINT_LATER_JOB_SUBTITLE_FONT, \
kHPPPAddPrintLaterJobScreenJobSummarySubtitleColorAttribute:DEFAULT_ADD_PRINT_LATER_JOB_SUBTITLE_COLOR, \
kHPPPAddPrintLaterJobScreenAddToPrintQFontAttribute:DEFAULT_ADD_PRINT_LATER_JOB_FONT, \
kHPPPAddPrintLaterJobScreenAddToPrintQActiveColorAttribute:DEFAULT_ADD_PRINT_LATER_JOB_ACTIVE_COLOR, \
kHPPPAddPrintLaterJobScreenAddToPrintQInactiveColorAttribute:DEFAULT_ADD_PRINT_LATER_JOB_INACTIVE_COLOR, \
kHPPPAddPrintLaterJobScreenJobNameTitleFontAttribute:DEFAULT_ADD_PRINT_LATER_JOB_TITLE_FONT, \
kHPPPAddPrintLaterJobScreenJobNameTitleColorAttribute:DEFAULT_ADD_PRINT_LATER_JOB_TITLE_COLOR, \
kHPPPAddPrintLaterJobScreenJobNameDetailFontAttribute:DEFAULT_ADD_PRINT_LATER_JOB_DETAIL_FONT, \
kHPPPAddPrintLaterJobScreenJobNameDetailColorAttribute:DEFAULT_ADD_PRINT_LATER_JOB_DETAIL_COLOR, \
kHPPPAddPrintLaterJobScreenCopyTitleFontAttribute:DEFAULT_ADD_PRINT_LATER_JOB_TITLE_FONT, \
kHPPPAddPrintLaterJobScreenCopyTitleColorAttribute:DEFAULT_ADD_PRINT_LATER_JOB_TITLE_COLOR, \
kHPPPAddPrintLaterJobScreenCopyStepperColorAttribute:DEFAULT_ADD_PRINT_LATER_JOB_ACTIVE_COLOR, \
kHPPPAddPrintLaterJobScreenPageRangeTitleFontAttribute:DEFAULT_ADD_PRINT_LATER_JOB_TITLE_FONT, \
kHPPPAddPrintLaterJobScreenPageRangeTitleColorAttribute:DEFAULT_ADD_PRINT_LATER_JOB_TITLE_COLOR, \
kHPPPAddPrintLaterJobScreenPageRangeDetailFontAttribute:DEFAULT_ADD_PRINT_LATER_JOB_DETAIL_FONT, \
kHPPPAddPrintLaterJobScreenPageRangeDetailColorAttribute:DEFAULT_ADD_PRINT_LATER_JOB_DETAIL_COLOR, \
kHPPPAddPrintLaterJobScreenBWTitleFontAttribute:DEFAULT_ADD_PRINT_LATER_JOB_TITLE_FONT, \
kHPPPAddPrintLaterJobScreenBWTitleColorAttribute:DEFAULT_ADD_PRINT_LATER_JOB_TITLE_COLOR, \
kHPPPAddPrintLaterJobScreenDescriptionTitleFontAttribute:DEFAULT_ADD_PRINT_LATER_JOB_TEXT_HEADING_FONT, \
kHPPPAddPrintLaterJobScreenDescriptionTitleColorAttribute:DEFAULT_ADD_PRINT_LATER_JOB_TEXT_HEADING_COLOR, \
kHPPPAddPrintLaterJobScreenDescriptionDetailFontAttribute:DEFAULT_ADD_PRINT_LATER_JOB_TEXT_FONT, \
kHPPPAddPrintLaterJobScreenDescriptionDetailColorAttribute:DEFAULT_ADD_PRINT_LATER_JOB_TEXT_COLOR}

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
