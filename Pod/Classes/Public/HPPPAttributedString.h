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

extern NSString *const HPPPAddPrintLaterJobScreenAddToPrintQFontAttribute;
extern NSString *const HPPPAddPrintLaterJobScreenAddToPrintQColorAttribute;
extern NSString *const HPPPAddPrintLaterJobScreenJobNameFontAttribute;
extern NSString *const HPPPAddPrintLaterJobScreenJobNameColorActiveAttribute;
extern NSString *const HPPPAddPrintLaterJobScreenJobNameColorInactiveAttribute;
extern NSString *const HPPPAddPrintLaterJobScreenSubitemTitleFontAttribute;
extern NSString *const HPPPAddPrintLaterJobScreenSubitemTitleColorAttribute;
extern NSString *const HPPPAddPrintLaterJobScreenSubitemFontAttribute;
extern NSString *const HPPPAddPrintLaterJobScreenSubitemColorAttribute;
extern NSString *const HPPPAddPrintLaterJobScreenDoneButtonAttribute;

extern NSString *const HPPPPrintQueueScreenPrintsCounterLabelFontAttribute;
extern NSString *const HPPPPrintQueueScreenPrintsCounterLabelColorAttribute;
extern NSString *const HPPPPrintQueueScreenPrintAllDisabledLabelFontAttribute;
extern NSString *const HPPPPrintQueueScreenPrintAllDisabledLabelColorAttribute;
extern NSString *const HPPPPrintQueueScreenPrinterInfoFontAttribute;
extern NSString *const HPPPPrintQueueScreenPrinterInfoColorAttribute;
extern NSString *const HPPPPrintQueueScreenJobNameFontAttribute;
extern NSString *const HPPPPrintQueueScreenJobNameColorAttribute;
extern NSString *const HPPPPrintQueueScreenJobDateFontAttribute;
extern NSString *const HPPPPrintQueueScreenJobDateColorAttribute;

@interface HPPPAttributedString : NSObject

/*!
 * @abstract Fonts and colors use in the Add Print Later Job Screen
 * @description Used to set the fonts and colors of the Add Print Later Job Screen
 */
@property (strong, nonatomic) NSDictionary *addPrintLaterJobScreenAttributes;
@property (strong, nonatomic) NSDictionary *printQueueScreenAttributes;

@end
