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
 * @abstract This class provides access to settings which control the visual appearance of the user interface
 * @discussion The maintains a dictionary of fonts, colors, icons, and other values used to customize the appearance of the user interface. Set one or more of the keys defined in this class to change the app appearance.
 * @seealso settings
 */
@interface HPPPAppearance : NSObject

/*!
 * @abstract Used as a key in the settings dictionary to store the format used for displaying dates
 * @discussion Example value stored under this key: @"MMMM d, h:mma"
 * @seealso settings
 */
extern NSString * const kHPPPGeneralDefaultDateFormat;

/*!
 * @abstract Used as a key in the settings dictionary to store the separator color used in all UITableViews
 * @seealso settings
 */
extern NSString * const kHPPPGeneralTableSeparatorColor;

/*!
 * @abstract Used as a key in the settings dictionary to store the background color for background UI elements
 * @discussion See product documentation for a map of UI elements
 * @seealso settings
 */
extern NSString * const kHPPPBackgroundBackgroundColor;

/*!
 * @abstract Used as a key in the settings dictionary to store the primary font for background UI elements
 * @discussion See product documentation for a map of UI elements
 * @seealso settings
 */
extern NSString * const kHPPPBackgroundPrimaryFont;

/*!
 * @abstract Used as a key in the settings dictionary to store the primary font color for background UI elements
 * @discussion See product documentation for a map of UI elements
 * @seealso settings
 */
extern NSString * const kHPPPBackgroundPrimaryFontColor;

/*!
 * @abstract Used as a key in the settings dictionary to store the secondary font for background UI elements
 * @discussion See product documentation for a map of UI elements
 * @seealso settings
 */
extern NSString * const kHPPPBackgroundSecondaryFont;

/*!
 * @abstract Used as a key in the settings dictionary to store the secondary font color for background UI elements
 * @discussion See product documentation for a map of UI elements
 * @seealso settings
 */
extern NSString * const kHPPPBackgroundSecondaryFontColor;


/*!
 * @abstract Used as a key in the settings dictionary to store the background color for Selection Option UI elements
 * @discussion See product documentation for a map of UI elements
 * @seealso settings
 */
extern NSString * const kHPPPSelectionOptionsBackgroundColor;

/*!
 * @abstract Used as a key in the settings dictionary to store the primary font for Selection Option UI elements
 * @discussion See product documentation for a map of UI elements
 * @seealso settings
 */
extern NSString * const kHPPPSelectionOptionsPrimaryFont;

/*!
 * @abstract Used as a key in the settings dictionary to store the primary font color for Selection Option UI elements
 * @discussion See product documentation for a map of UI elements
 * @seealso settings
 */
extern NSString * const kHPPPSelectionOptionsPrimaryFontColor;

/*!
 * @abstract Used as a key in the settings dictionary to store the secondary font for Selection Option UI elements
 * @discussion See product documentation for a map of UI elements
 * @seealso settings
 */
extern NSString * const kHPPPSelectionOptionsSecondaryFont;

/*!
 * @abstract Used as a key in the settings dictionary to store the secondary font color for Selection Option UI elements
 * @discussion See product documentation for a map of UI elements
 * @seealso settings
 */
extern NSString * const kHPPPSelectionOptionsSecondaryFontColor;

/*!
 * @abstract Used as a key in the settings dictionary to store the link font for Selection Option UI elements
 * @discussion See product documentation for a map of UI elements
 * @seealso settings
 */
extern NSString * const kHPPPSelectionOptionsLinkFont;

/*!
 * @abstract Used as a key in the settings dictionary to store the link font color for Selection Option UI elements
 * @discussion See product documentation for a map of UI elements
 * @seealso settings
 */
extern NSString * const kHPPPSelectionOptionsLinkFontColor;


/*!
 * @abstract Used as a key in the settings dictionary to store the background color for Job Settings UI elements
 * @discussion See product documentation for a map of UI elements
 * @seealso settings
 */
extern NSString * const kHPPPJobSettingsBackgroundColor;

/*!
 * @abstract Used as a key in the settings dictionary to store the primary font for Job Settings UI elements
 * @discussion See product documentation for a map of UI elements
 * @seealso settings
 */
extern NSString * const kHPPPJobSettingsPrimaryFont;

/*!
 * @abstract Used as a key in the settings dictionary to store the primary font color for Job Settings UI elements
 * @discussion See product documentation for a map of UI elements
 * @seealso settings
 */
extern NSString * const kHPPPJobSettingsPrimaryFontColor;

/*!
 * @abstract Used as a key in the settings dictionary to store the secondary font for Job Settings UI elements
 * @discussion See product documentation for a map of UI elements
 * @seealso settings
 */
extern NSString * const kHPPPJobSettingsSecondaryFont;

/*!
 * @abstract Used as a key in the settings dictionary to store the secondary font color for Job Settings UI elements
 * @discussion See product documentation for a map of UI elements
 * @seealso settings
 */
extern NSString * const kHPPPJobSettingsSecondaryFontColor;

/*!
 * @abstract Used as a key in the settings dictionary to store the selected page icon for Job Settings UI elements
 * @discussion See product documentation for a map of UI elements
 * @seealso settings
 */
extern NSString * const kHPPPJobSettingsSelectedPageIcon;

/*!
 * @abstract Used as a key in the settings dictionary to store the unselected page icon for Job Settings UI elements
 * @discussion See product documentation for a map of UI elements
 * @seealso settings
 */
extern NSString * const kHPPPJobSettingsUnselectedPageIcon;

/*!
 * @abstract Used as a key in the settings dictionary to store the selected job icon for Job Settings UI elements
 * @discussion See product documentation for a map of UI elements
 * @seealso settings
 */
extern NSString * const kHPPPJobSettingsSelectedJobIcon;

/*!
 * @abstract Used as a key in the settings dictionary to store the unselected job icon for Job Settings UI elements
 * @discussion See product documentation for a map of UI elements
 * @seealso settings
 */
extern NSString * const kHPPPJobSettingsUnselectedJobIcon;

/*!
 * @abstract Used as a key in the settings dictionary to store the magnifying glass icon for Job Settings UI elements
 * @discussion See product documentation for a map of UI elements
 * @seealso settings
 */
extern NSString * const kHPPPJobSettingsMagnifyingGlassIcon;


/*!
 * @abstract Used as a key in the settings dictionary to store the background color for Main Action UI elements
 * @discussion See product documentation for a map of UI elements
 * @seealso settings
 */
extern NSString * const kHPPPMainActionBackgroundColor;

/*!
 * @abstract Used as a key in the settings dictionary to store the link font for Main Action UI elements
 * @discussion See product documentation for a map of UI elements
 * @seealso settings
 */
extern NSString * const kHPPPMainActionLinkFont;

/*!
 * @abstract Used as a key in the settings dictionary to store the active link font color for Main Action UI elements
 * @discussion See product documentation for a map of UI elements
 * @seealso settings
 */
extern NSString * const kHPPPMainActionActiveLinkFontColor;

/*!
 * @abstract Used as a key in the settings dictionary to store the inactive link font color for Main Action UI elements
 * @discussion See product documentation for a map of UI elements
 * @seealso settings
 */
extern NSString * const kHPPPMainActionInactiveLinkFontColor;


/*!
 * @abstract Used as a key in the settings dictionary to store the primary font for queue count text
 * @discussion See product documentation for a map of UI elements
 * @seealso settings
 */
extern NSString * const kHPPPQueuePrimaryFont;

/*!
 * @abstract Used as a key in the settings dictionary to store the primary font color for queue count text
 * @discussion See product documentation for a map of UI elements
 * @seealso settings
 */
extern NSString * const kHPPPQueuePrimaryFontColor;


/*!
 * @abstract Used as a key in the settings dictionary to store the background color for Form Field UI elements
 * @discussion See product documentation for a map of UI elements
 * @seealso settings
 */
extern NSString * const kHPPPFormFieldBackgroundColor;

/*!
 * @abstract Used as a key in the settings dictionary to store the primary font for Form Field UI elements
 * @discussion See product documentation for a map of UI elements
 * @seealso settings
 */
extern NSString * const kHPPPFormFieldPrimaryFont;

/*!
 * @abstract Used as a key in the settings dictionary to store the primary font color for Form Field UI elements
 * @discussion See product documentation for a map of UI elements
 * @seealso settings
 */
extern NSString * const kHPPPFormFieldPrimaryFontColor;


/*!
 * @abstract Used as a key in the settings dictionary to store the background color for Overlay UI elements
 * @discussion See product documentation for a map of UI elements
 * @seealso settings
 */
extern NSString * const kHPPPOverlayBackgroundColor;

/*!
 * @abstract Used as a key in the settings dictionary to store the primary font for Overlay UI elements
 * @discussion See product documentation for a map of UI elements
 * @seealso settings
 */
extern NSString * const kHPPPOverlayPrimaryFont;

/*!
 * @abstract Used as a key in the settings dictionary to store the primary font color for Overlay UI elements
 * @discussion See product documentation for a map of UI elements
 * @seealso settings
 */
extern NSString * const kHPPPOverlayPrimaryFontColor;

/*!
 * @abstract Used as a key in the settings dictionary to store the secondary font for Overlay UI elements
 * @discussion See product documentation for a map of UI elements
 * @seealso settings
 */
extern NSString * const kHPPPOverlaySecondaryFont;

/*!
 * @abstract Used as a key in the settings dictionary to store the secondary font color for Overlay UI elements
 * @discussion See product documentation for a map of UI elements
 * @seealso settings
 */
extern NSString * const kHPPPOverlaySecondaryFontColor;

/*!
 * @abstract Used as a key in the settings dictionary to store the link font for Overlay UI elements
 * @discussion See product documentation for a map of UI elements
 * @seealso settings
 */
extern NSString * const kHPPPOverlayLinkFont;

/*!
 * @abstract Used as a key in the settings dictionary to store the link font color for Overlay UI elements
 * @discussion See product documentation for a map of UI elements
 * @seealso settings
 */
extern NSString * const kHPPPOverlayLinkFontColor;

/*!
 * @abstract Used as a key in the settings dictionary to store the background opacity for Overlay UI elements
 * @discussion See product documentation for a map of UI elements
 * @seealso settings
 */
extern NSString * const kHPPPOverlayBackgroundOpacity;


/*!
 * @abstract Used as a key in the settings dictionary to store the icon used in the Print Activity
 * @discussion See product documentation for a map of UI elements
 * @seealso settings
 */
extern NSString * const kHPPPActivityPrintIcon;

/*!
 * @abstract Used as a key in the settings dictionary to store the icon used in the Print Queue/Later Activity
 * @discussion See product documentation for a map of UI elements
 * @seealso settings
 */
extern NSString * const kHPPPActivityPrintQueueIcon;


/*!
 * @abstract A dictionary containing all customizable style settings for the HPPhotoPrint user interface
 */
@property (strong, nonatomic) NSDictionary *settings;

@end
