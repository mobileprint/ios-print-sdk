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

/*!
 * @abstract Class used to specify custom styles
 */
@interface HPPPAppearance : NSObject

/*!
 * @abstract Dictionary key used to specify add to print queue font
 */
extern NSString * const kHPPPAddPrintLaterJobScreenAddToPrintQFontAttribute;

/*!
 * @abstract Dictionary key used to specify add to print queue text color
 */
extern NSString * const kHPPPAddPrintLaterJobScreenAddToPrintQColorAttribute;

/*!
 * @abstract Dictionary key used to specify add job name font
 */
extern NSString * const kHPPPAddPrintLaterJobScreenJobNameFontAttribute;

/*!
 * @abstract Dictionary key used to specify add job name color when active
 */
extern NSString * const kHPPPAddPrintLaterJobScreenJobNameColorActiveAttribute;

/*!
 * @abstract Dictionary key used to specify add job name color when inactive
 */
extern NSString * const kHPPPAddPrintLaterJobScreenJobNameColorInactiveAttribute;

/*!
 * @abstract Dictionary key used to specify subitem title font
 */
extern NSString * const kHPPPAddPrintLaterJobScreenSubitemTitleFontAttribute;

/*!
 * @abstract Dictionary key used to specify subitem title text color
 */
extern NSString * const kHPPPAddPrintLaterJobScreenSubitemTitleColorAttribute;

/*!
 * @abstract Dictionary key used to specify subitem detail font
 */
extern NSString * const kHPPPAddPrintLaterJobScreenSubitemFontAttribute;

/*!
 * @abstract Dictionary key used to specify subitem detail text color
 */
extern NSString * const kHPPPAddPrintLaterJobScreenSubitemColorAttribute;

/*!
 * @abstract Dictionary key used to specify the done button
 * @discussion This field is used to specify the 'Done' button used to complete text editing when changing the job name. This button appears in the upper right of the screen and should be a UIButton instance.
 */
extern NSString * const kHPPPAddPrintLaterJobScreenDoneButtonAttribute;

/*!
 * @abstract Dictionary key used to specify print count font
 */
extern NSString * const kHPPPPrintQueueScreenPrintsCounterLabelFontAttribute;

/*!
 * @abstract Dictionary key used to specify print count text color
 */
extern NSString * const kHPPPPrintQueueScreenPrintsCounterLabelColorAttribute;

/*!
 * @abstract Dictionary key used to specify no Wi-Fi font
 */
extern NSString * const kHPPPPrintQueueScreenNoWifiLabelFontAttribute;

/*!
 * @abstract Dictionary key used to specify no Wi-Fi text color
 */
extern NSString * const kHPPPPrintQueueScreenNoWifiLabelColorAttribute;

/*!
 * @abstract Dictionary key used to specify action button font
 */
extern NSString * const kHPPPPrintQueueScreenActionButtonsFontAttribute;

/*!
 * @abstract Dictionary key used to specify action button text color when enabled
 */
extern NSString * const kHPPPPrintQueueScreenActionButtonsEnableColorAttribute;

/*!
 * @abstract Dictionary key used to specify action button text color when disabled
 */
extern NSString * const kHPPPPrintQueueScreenActionButtonsDisableColorAttribute;

/*!
 * @abstract Dictionary key used to specify action button separator
 */
extern NSString * const kHPPPPrintQueueScreenActionButtonsSeparatorColorAttribute;

/*!
 * @abstract Dictionary key used to specify print queue job name font
 */
extern NSString * const kHPPPPrintQueueScreenJobNameFontAttribute;

/*!
 * @abstract Dictionary key used to specify print queue job name text color
 */
extern NSString * const kHPPPPrintQueueScreenJobNameColorAttribute;

/*!
 * @abstract Dictionary key used to specify print queue job date font
 */
extern NSString * const kHPPPPrintQueueScreenJobDateFontAttribute;

/*!
 * @abstract Dictionary key used to specify print queue job date text color
 */
extern NSString * const kHPPPPrintQueueScreenJobDateColorAttribute;

/*!
 * @abstract Dictionary key used to specify empty queue font
 */
extern NSString * const kHPPPPrintQueueScreenEmptyQueueFontAttribute;

/*!
 * @abstract Dictionary key used to specify empty queue text color
 */
extern NSString * const kHPPPPrintQueueScreenEmptyQueueColorAttribute;

/*!
 * @abstract Dictionary key used to specify preview job name font
 */
extern NSString * const kHPPPPrintQueueScreenPreviewJobNameFontAttribute;

/*!
 * @abstract Dictionary key used to specify preview job name text color
 */
extern NSString * const kHPPPPrintQueueScreenPreviewJobNameColorAttribute;

/*!
 * @abstract Dictionary key used to specify preview job date font
 */
extern NSString * const kHPPPPrintQueueScreenPreviewJobDateFontAttribute;

/*!
 * @abstract Dictionary key used to specify preview job date text color
 */
extern NSString * const kHPPPPrintQueueScreenPreviewJobDateColorAttribute;

/*!
 * @abstract Dictionary key used to specify done button font
 */
extern NSString * const kHPPPPrintQueueScreenPreviewDoneButtonFontAttribute;

/*!
 * @abstract Dictionary key used to specify done button text color
 */
extern NSString * const kHPPPPrintQueueScreenPreviewDoneButtonColorAttribute;

/*!
 * @abstract Fonts and colors use in the Add Print Later Job Screen
 * @discussion Used to set the fonts and colors of the Add Print Later Job Screen
 */
@property (strong, nonatomic) NSDictionary *addPrintLaterJobScreenAttributes;

/*!
 * @abstract Fonts and colors use in the Print Queue List Screen
 * @discussion Used to set the fonts and colors of the Print Queue List Screen
 */
@property (strong, nonatomic) NSDictionary *printQueueScreenAttributes;

@end
