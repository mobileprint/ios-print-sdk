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

// Print Later Screen
NSString *const HPPPAddPrintLaterJobScreenAddToPrintQFontAttribute = @"HPPPAddPrintLaterJobScreenAddToPrintQFontAttribute";
NSString *const HPPPAddPrintLaterJobScreenAddToPrintQColorAttribute = @"HPPPAddPrintLaterJobScreenAddToPrintQColorAttribute";;
NSString *const HPPPAddPrintLaterJobScreenNotificationDescriptionFontAttribute = @"HPPPAddPrintLaterJobScreenNotificationDescriptionFontAttribute";
NSString *const HPPPAddPrintLaterJobScreenNotificationDescriptionColorAttribute = @"HPPPAddPrintLaterJobScreenNotificationDescriptionColorAttribute";
NSString *const HPPPAddPrintLaterJobScreenJobNameFontAttribute = @"HPPPAddPrintLaterJobScreenJobNameFontAttribute";
NSString *const HPPPAddPrintLaterJobScreenJobNameColorAttribute = @"HPPPAddPrintLaterJobScreenJobNameColorAttribute";
NSString *const HPPPAddPrintLaterJobScreenDateFontAttribute = @"HPPPAddPrintLaterJobScreenDateFontAttribute";
NSString *const HPPPAddPrintLaterJobScreenDateColorAttribute = @"HPPPAddPrintLaterJobScreenDateColorAttribute";
NSString *const HPPPAddPrintLaterJobScreenPrinterNameTitleFontAttribute = @"HPPPAddPrintLaterJobScreenPrinterNameTitleFontAttribute";
NSString *const HPPPAddPrintLaterJobScreenPrinterNameTitleColorAttribute = @"HPPPAddPrintLaterJobScreenPrinterNameTitleColorAttribute";
NSString *const HPPPAddPrintLaterJobScreenPrinterNameFontAttribute = @"HPPPAddPrintLaterJobScreenPrinterNameFontAttribute";
NSString *const HPPPAddPrintLaterJobScreenPrinterNameColorAttribute = @"HPPPAddPrintLaterJobScreenPrinterNameColorAttribute";

#define DEFAULT_ADD_TO_PRINT_Q_FONT [UIFont fontWithName:@"Helvetica Neue" size:18]
#define DEFAULT_ADD_TO_PRINT_Q_COLOR [UIColor HPPPHPBlueColor]

#define DEFAULT_NOTIFICATION_DESCRIPTION_FONT [UIFont fontWithName:@"Helvetica Neue" size:16]
#define DEFAULT_NOTIFICATION_DESCRIPTION_COLOR [UIColor colorWithRed:0x33 / 255.0f green:0x33 / 255.0f blue:0x33 / 255.0f alpha:1.0f]

#define DEFAULT_JOB_NAME_FONT [UIFont fontWithName:@"HelveticaNeue-Bold" size:24]
#define DEFAULT_JOB_NAME_COLOR [UIColor colorWithRed:0x33 / 255.0f green:0x33 / 255.0f blue:0x33 / 255.0f alpha:1.0f]

#define DEFAULT_DATE_FONT [UIFont fontWithName:@"Helvetica Neue" size:18]
#define DEFAULT_DATE_COLOR [UIColor colorWithRed:0x33 / 255.0f green:0x33 / 255.0f blue:0x33 / 255.0f alpha:1.0f]

#define DEFAULT_PRINTER_NAME_TITLE_FONT [UIFont fontWithName:@"HelveticaNeue-Bold" size:22]
#define DEFAULT_PRINTER_NAME_TITLE_COLOR [UIColor colorWithRed:0x33 / 255.0f green:0x33 / 255.0f blue:0x33 / 255.0f alpha:1.0f]

#define DEFAULT_PRINTER_NAME_FONT [UIFont fontWithName:@"Helvetica Neue" size:18]
#define DEFAULT_PRINTER_NAME_COLOR [UIColor colorWithRed:0x33 / 255.0f green:0x33 / 255.0f blue:0x33 / 255.0f alpha:1.0f]

#define DEFAULT_ADD_PRINT_LATER_JOB_SCREEN_ATTRIBUTES @{HPPPAddPrintLaterJobScreenAddToPrintQFontAttribute:DEFAULT_ADD_TO_PRINT_Q_FONT, \
                                                        HPPPAddPrintLaterJobScreenAddToPrintQColorAttribute:DEFAULT_ADD_TO_PRINT_Q_COLOR, \
                                                        HPPPAddPrintLaterJobScreenNotificationDescriptionFontAttribute:DEFAULT_NOTIFICATION_DESCRIPTION_FONT, \
                                                        HPPPAddPrintLaterJobScreenNotificationDescriptionColorAttribute:DEFAULT_NOTIFICATION_DESCRIPTION_COLOR, \
                                                        HPPPAddPrintLaterJobScreenJobNameFontAttribute:DEFAULT_JOB_NAME_FONT, \
                                                        HPPPAddPrintLaterJobScreenJobNameColorAttribute:DEFAULT_JOB_NAME_COLOR, \
                                                        HPPPAddPrintLaterJobScreenDateFontAttribute:DEFAULT_DATE_FONT, \
                                                        HPPPAddPrintLaterJobScreenDateColorAttribute:DEFAULT_DATE_COLOR, \
                                                        HPPPAddPrintLaterJobScreenPrinterNameTitleFontAttribute:DEFAULT_PRINTER_NAME_TITLE_FONT, \
                                                        HPPPAddPrintLaterJobScreenPrinterNameTitleColorAttribute:DEFAULT_PRINTER_NAME_TITLE_COLOR, \
                                                        HPPPAddPrintLaterJobScreenPrinterNameFontAttribute:DEFAULT_PRINTER_NAME_FONT, \
                                                        HPPPAddPrintLaterJobScreenPrinterNameColorAttribute:DEFAULT_PRINTER_NAME_COLOR}


// Print Queue Screen
NSString *const HPPPPrintQueueScreenPrintAllLabelFontAttribute = @"HPPPPrintQueueScreenPrintAllLabelFontAttribute";
NSString *const HPPPPrintQueueScreenPrintAllLabelColorAttribute = @"HPPPPrintQueueScreenPrintAllLabelColorAttribute";
NSString *const HPPPPrintQueueScreenPrintAllDisabledLabelFontAttribute = @"HPPPPrintQueueScreenPrintAllDisabledLabelFontAttribute";
NSString *const HPPPPrintQueueScreenPrintAllDisabledLabelColorAttribute = @"HPPPPrintQueueScreenPrintAllDisabledLabelColorAttribute";
NSString *const HPPPPrintQueueScreenPrinterInfoFontAttribute = @"HPPPPrintQueueScreenPrinterInfoFontAttribute";
NSString *const HPPPPrintQueueScreenPrinterInfoColorAttribute = @"HPPPPrintQueueScreenPrinterInfoColorAttribute";
NSString *const HPPPPrintQueueScreenJobNameFontAttribute = @"HPPPPrintQueueScreenJobNameFontAttribute";
NSString *const HPPPPrintQueueScreenJobNameColorAttribute = @"HPPPPrintQueueScreenJobNameColorAttribute";
NSString *const HPPPPrintQueueScreenJobDateFontAttribute = @"HPPPPrintQueueScreenJobDateFontAttribute";
NSString *const HPPPPrintQueueScreenJobDateColorAttribute = @"HPPPPrintQueueScreenJobDateColorAttribute";

#define DEFAULT_PRINT_Q_PRINT_ALL_FONT [UIFont fontWithName:@"Helvetica Neue" size:18]
#define DEFAULT_PRINT_Q_PRINT_ALL_COLOR [UIColor HPPPHPBlueColor]

#define DEFAULT_PRINT_Q_PRINT_ALL_DISABLED_FONT [UIFont fontWithName:@"HelveticaNeue-Light" size:18]
#define DEFAULT_PRINT_Q_PRINT_ALL_DISABLED_COLOR [UIColor colorWithRed:0x88 / 255.0f green:0x88 / 255.0f blue:0x88 / 255.0f alpha:1.0f]

#define DEFAULT_PRINT_Q_PRINTER_INFO_FONT [UIFont fontWithName:@"HelveticaNeue-Light" size:12]
#define DEFAULT_PRINT_Q_PRINTER_INFO_COLOR [UIColor colorWithRed:0x88 / 255.0f green:0x88 / 255.0f blue:0x88 / 255.0f alpha:1.0f]

#define DEFAULT_PRINT_Q_JOB_NAME_FONT [UIFont fontWithName:@"Helvetica Neue" size:14]
#define DEFAULT_PRINT_Q_JOB_NAME_COLOR [UIColor colorWithRed:0x33 / 255.0f green:0x33 / 255.0f blue:0x33 / 255.0f alpha:1.0f]

#define DEFAULT_PRINT_Q_JOB_DATE_FONT [UIFont fontWithName:@"Helvetica Neue" size:12]
#define DEFAULT_PRINT_Q_JOB_DATE_COLOR [UIColor colorWithRed:0x88 / 255.0f green:0x88 / 255.0f blue:0x88 / 255.0f alpha:1.0f]

#define DEFAULT_PRINT_Q_SCREEN_ATTRIBUTES @{HPPPPrintQueueScreenPrintAllLabelFontAttribute:DEFAULT_PRINT_Q_PRINT_ALL_FONT, \
                                            HPPPPrintQueueScreenPrintAllLabelColorAttribute:DEFAULT_PRINT_Q_PRINT_ALL_COLOR, \
                                            HPPPPrintQueueScreenPrintAllDisabledLabelFontAttribute:DEFAULT_PRINT_Q_PRINT_ALL_DISABLED_FONT, \
                                            HPPPPrintQueueScreenPrintAllDisabledLabelColorAttribute:DEFAULT_PRINT_Q_PRINT_ALL_DISABLED_COLOR, \
                                            HPPPPrintQueueScreenPrinterInfoFontAttribute:DEFAULT_PRINT_Q_PRINTER_INFO_FONT, \
                                            HPPPPrintQueueScreenPrinterInfoColorAttribute:DEFAULT_PRINT_Q_PRINTER_INFO_COLOR, \
                                            HPPPPrintQueueScreenJobNameFontAttribute:DEFAULT_PRINT_Q_JOB_NAME_FONT, \
                                            HPPPPrintQueueScreenJobNameColorAttribute:DEFAULT_PRINT_Q_JOB_NAME_COLOR, \
                                            HPPPPrintQueueScreenJobDateFontAttribute:DEFAULT_PRINT_Q_JOB_DATE_FONT, \
                                            HPPPPrintQueueScreenJobDateColorAttribute:DEFAULT_PRINT_Q_JOB_DATE_COLOR}


@implementation HPPPAttributedString

- (NSDictionary *)addPrintLaterJobScreenAttributes
{
    if (nil == _addPrintLaterJobScreenAttributes) {
        _addPrintLaterJobScreenAttributes = DEFAULT_ADD_PRINT_LATER_JOB_SCREEN_ATTRIBUTES;
    }
    
    return _addPrintLaterJobScreenAttributes;
}

- (NSDictionary *)printQueueScreenAttributes
{
    if (nil == _printQueueScreenAttributes) {
        _printQueueScreenAttributes = DEFAULT_PRINT_Q_SCREEN_ATTRIBUTES;
    }
    
    return _printQueueScreenAttributes;
}

@end
