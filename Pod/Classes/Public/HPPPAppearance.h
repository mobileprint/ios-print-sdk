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
 * @abstract Dictionary key used to specify filename for the image used to denote a page that will be included in a print job
 */
extern NSString * const kHPPPAddPrintLaterJobScreenJobPageSelectedImageAttribute;

/*!
 * @abstract Dictionary key used to specify filename for the image used to denote a page that will not be included in a print job
 */
extern NSString * const kHPPPAddPrintLaterJobScreenJobPageNotSelectedImageAttribute;

/*!
 * @abstract Dictionary key used to specify title font for the job summary table view cell
 */
extern NSString * const kHPPPAddPrintLaterJobScreenJobSummaryTitleFontAttribute;

/*!
 * @abstract Dictionary key used to specify title color for the job summary table view cell
 */
extern NSString * const kHPPPAddPrintLaterJobScreenJobSummaryTitleColorAttribute;

/*!
 * @abstract Dictionary key used to specify subtitle font for the job summary table view cell
 */
extern NSString * const kHPPPAddPrintLaterJobScreenJobSummarySubtitleFontAttribute;

/*!
 * @abstract Dictionary key used to specify subtitle color for the job summary table view cell
 */
extern NSString * const kHPPPAddPrintLaterJobScreenJobSummarySubtitleColorAttribute;

/*!
 * @abstract Dictionary key used to specify 'Add to Print Queue' button font
 */
extern NSString * const kHPPPAddPrintLaterJobScreenAddToPrintQFontAttribute;

/*!
 * @abstract Dictionary key used to specify 'Add to Print Queue' button active text color
 */
extern NSString * const kHPPPAddPrintLaterJobScreenAddToPrintQActiveColorAttribute;

/*!
 * @abstract Dictionary key used to specify 'Add to Print Queue' button inactive text color
 */
extern NSString * const kHPPPAddPrintLaterJobScreenAddToPrintQInactiveColorAttribute;

/*!
 * @abstract Dictionary key used to specify title font for the job name table view cell
 */
extern NSString * const kHPPPAddPrintLaterJobScreenJobNameTitleFontAttribute;

/*!
 * @abstract Dictionary key used to specify title color for the job name table view cell
 */
extern NSString * const kHPPPAddPrintLaterJobScreenJobNameTitleColorAttribute;

/*!
 * @abstract Dictionary key used to specify detail font for the job name table view cell
 */
extern NSString * const kHPPPAddPrintLaterJobScreenJobNameDetailFontAttribute;

/*!
 * @abstract Dictionary key used to specify detail color for the job name table view cell
 */
extern NSString * const kHPPPAddPrintLaterJobScreenJobNameDetailColorAttribute;

/*!
 * @abstract Dictionary key used to specify title font for the copies table view cell
 */
extern NSString * const kHPPPAddPrintLaterJobScreenCopyTitleFontAttribute;

/*!
 * @abstract Dictionary key used to specify title color for the copies table view cell
 */
extern NSString * const kHPPPAddPrintLaterJobScreenCopyTitleColorAttribute;

/*!
 * @abstract Dictionary key used to specify stepper color for the copies table view cell
 */
extern NSString * const kHPPPAddPrintLaterJobScreenCopyStepperColorAttribute;

/*!
 * @abstract Dictionary key used to specify title font for the page range table view cell
 */
extern NSString * const kHPPPAddPrintLaterJobScreenPageRangeTitleFontAttribute;

/*!
 * @abstract Dictionary key used to specify title color for the page range table view cell
 */
extern NSString * const kHPPPAddPrintLaterJobScreenPageRangeTitleColorAttribute;

/*!
 * @abstract Dictionary key used to specify detail font for the page range table view cell
 */
extern NSString * const kHPPPAddPrintLaterJobScreenPageRangeDetailFontAttribute;

/*!
 * @abstract Dictionary key used to specify detail color for the page range table view cell
 */
extern NSString * const kHPPPAddPrintLaterJobScreenPageRangeDetailColorAttribute;

/*!
 * @abstract Dictionary key used to specify title font for the black and white table view cell
 */
extern NSString * const kHPPPAddPrintLaterJobScreenBWTitleFontAttribute;

/*!
 * @abstract Dictionary key used to specify title color for the black and white table view cell
 */
extern NSString * const kHPPPAddPrintLaterJobScreenBWTitleColorAttribute;

/*!
 * @abstract Dictionary key used to specify text font for the print queue description heading
 */
extern NSString * const kHPPPAddPrintLaterJobScreenDescriptionTitleFontAttribute;

/*!
 * @abstract Dictionary key used to specify text color for the print queue description heading
 */
extern NSString * const kHPPPAddPrintLaterJobScreenDescriptionTitleColorAttribute;

/*!
 * @abstract Dictionary key used to specify text font for the print queue description text
 */
extern NSString * const kHPPPAddPrintLaterJobScreenDescriptionDetailFontAttribute;

/*!
 * @abstract Dictionary key used to specify text color for the print queue description text
 */
extern NSString * const kHPPPAddPrintLaterJobScreenDescriptionDetailColorAttribute;

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
