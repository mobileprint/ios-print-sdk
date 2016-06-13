//
// HP Inc.
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
 * @discussion It maintains a dictionary of fonts, colors, icons, and other values used to customize the appearance of the user interface. Set one or more of the keys defined in this class to change the app appearance.
 * There is graphical overview available that shows where and how the print user interface can be customized. 
 * Download the style <a href="http://d3fep8xjnjngo0.cloudfront.net/ios/StyleMap.pdf" target="_blank">Map</a> and <a href="http://d3fep8xjnjngo0.cloudfront.net/ios/StyleKey.pdf" target="_blank">Key</a> for reference.
 * @seealso settings
 */
@interface MPAppearance : NSObject

/*!
 * @abstract Used as a key in the settings dictionary to store the background color for background UI elements
 * @discussion See product documentation for a map of UI elements
 * @seealso settings
 */
extern NSString * const kMPGeneralBackgroundColor;

/*!
 * @abstract Used as a key in the settings dictionary to store the primary font for background UI elements
 * @discussion See product documentation for a map of UI elements
 * @seealso settings
 */
extern NSString * const kMPGeneralBackgroundPrimaryFont;

/*!
 * @abstract Used as a key in the settings dictionary to store the primary font color for background UI elements
 * @discussion See product documentation for a map of UI elements
 * @seealso settings
 */
extern NSString * const kMPGeneralBackgroundPrimaryFontColor;

/*!
 * @abstract Used as a key in the settings dictionary to store the secondary font for background UI elements
 * @discussion See product documentation for a map of UI elements
 * @seealso settings
 */
extern NSString * const kMPGeneralBackgroundSecondaryFont;

/*!
 * @abstract Used as a key in the settings dictionary to store the secondary font color for background UI elements
 * @discussion See product documentation for a map of UI elements
 * @seealso settings
 */
extern NSString * const kMPGeneralBackgroundSecondaryFontColor;

/*!
 * @abstract Used as a key in the settings dictionary to store the separator color used in all UITableViews
 * @seealso settings
 */
extern NSString * const kMPGeneralTableSeparatorColor;


/*!
 * @abstract Used as a key in the settings dictionary to store the background color for Selection Option UI elements
 * @discussion See product documentation for a map of UI elements
 * @seealso settings
 */
extern NSString * const kMPSelectionOptionsBackgroundColor;

/*!
 * @abstract Used as a key in the settings dictionary to store the primary font for Selection Option UI elements
 * @discussion See product documentation for a map of UI elements
 * @seealso settings
 */
extern NSString * const kMPSelectionOptionsPrimaryFont;

/*!
 * @abstract Used as a key in the settings dictionary to store the primary font color for Selection Option UI elements
 * @discussion See product documentation for a map of UI elements
 * @seealso settings
 */
extern NSString * const kMPSelectionOptionsPrimaryFontColor;

/*!
 * @abstract Used as a key in the settings dictionary to store the secondary font for Selection Option UI elements
 * @discussion See product documentation for a map of UI elements
 * @seealso settings
 */
extern NSString * const kMPSelectionOptionsSecondaryFont;

/*!
 * @abstract Used as a key in the settings dictionary to store the secondary font color for Selection Option UI elements
 * @discussion See product documentation for a map of UI elements
 * @seealso settings
 */
extern NSString * const kMPSelectionOptionsSecondaryFontColor;

/*!
 * @abstract Used as a key in the settings dictionary to store the link font for Selection Option UI elements
 * @discussion See product documentation for a map of UI elements
 * @seealso settings
 */
extern NSString * const kMPSelectionOptionsLinkFont;

/*!
 * @abstract Used as a key in the settings dictionary to store the link font color for Selection Option UI elements
 * @discussion See product documentation for a map of UI elements
 * @seealso settings
 */
extern NSString * const kMPSelectionOptionsLinkFontColor;

/*!
 * @abstract Used as a key in the settings dictionary to store the image used to show that more options will be presented
 *  when a UITableViewCell is selected.
 * @discussion See product documentation for a map of UI elements
 * @seealso settings
 */
extern NSString * const kMPSelectionOptionsDisclosureIndicatorImage;

/*!
 * @abstract Used as a key in the settings dictionary to store the image used to show that a UITableViewCell is the currently
 *  selected item within the UITableView.
 * @discussion See product documentation for a map of UI elements
 * @seealso settings
 */
extern NSString * const kMPSelectionOptionsCheckmarkImage;


/*!
 * @abstract Used as a key in the settings dictionary to store the background color for Job Settings UI elements
 * @discussion See product documentation for a map of UI elements
 * @seealso settings
 */
extern NSString * const kMPJobSettingsBackgroundColor;

/*!
 * @abstract Used as a key in the settings dictionary to store the primary font for Job Settings UI elements
 * @discussion See product documentation for a map of UI elements
 * @seealso settings
 */
extern NSString * const kMPJobSettingsPrimaryFont;

/*!
 * @abstract Used as a key in the settings dictionary to store the primary font color for Job Settings UI elements
 * @discussion See product documentation for a map of UI elements
 * @seealso settings
 */
extern NSString * const kMPJobSettingsPrimaryFontColor;

/*!
 * @abstract Used as a key in the settings dictionary to store the secondary font for Job Settings UI elements
 * @discussion See product documentation for a map of UI elements
 * @seealso settings
 */
extern NSString * const kMPJobSettingsSecondaryFont;

/*!
 * @abstract Used as a key in the settings dictionary to store the secondary font color for Job Settings UI elements
 * @discussion See product documentation for a map of UI elements
 * @seealso settings
 */
extern NSString * const kMPJobSettingsSecondaryFontColor;

/*!
 * @abstract Used as a key in the settings dictionary to store the selected page icon for Job Settings UI elements
 * @discussion See product documentation for a map of UI elements
 * @seealso settings
 */
extern NSString * const kMPJobSettingsSelectedPageIcon;

/*!
 * @abstract Used as a key in the settings dictionary to store the unselected page icon for Job Settings UI elements
 * @discussion See product documentation for a map of UI elements
 * @seealso settings
 */
extern NSString * const kMPJobSettingsUnselectedPageIcon;

/*!
 * @abstract Used as a key in the settings dictionary to store the selected job icon for Job Settings UI elements
 * @discussion See product documentation for a map of UI elements
 * @seealso settings
 */
extern NSString * const kMPJobSettingsSelectedJobIcon;

/*!
 * @abstract Used as a key in the settings dictionary to store the unselected job icon for Job Settings UI elements
 * @discussion See product documentation for a map of UI elements
 * @seealso settings
 */
extern NSString * const kMPJobSettingsUnselectedJobIcon;

/*!
 * @abstract Used as a key in the settings dictionary to store the magnifying glass icon for Job Settings UI elements
 * @discussion See product documentation for a map of UI elements
 * @seealso settings
 */
extern NSString * const kMPJobSettingsMagnifyingGlassIcon;


/*!
 * @abstract Used as a key in the settings dictionary to store the background color for Main Action UI elements
 * @discussion See product documentation for a map of UI elements
 * @seealso settings
 */
extern NSString * const kMPMainActionBackgroundColor;

/*!
 * @abstract Used as a key in the settings dictionary to store the link font for Main Action UI elements
 * @discussion See product documentation for a map of UI elements
 * @seealso settings
 */
extern NSString * const kMPMainActionLinkFont;

/*!
 * @abstract Used as a key in the settings dictionary to store the active link font color for Main Action UI elements
 * @discussion See product documentation for a map of UI elements
 * @seealso settings
 */
extern NSString * const kMPMainActionActiveLinkFontColor;

/*!
 * @abstract Used as a key in the settings dictionary to store the inactive link font color for Main Action UI elements
 * @discussion See product documentation for a map of UI elements
 * @seealso settings
 */
extern NSString * const kMPMainActionInactiveLinkFontColor;


/*!
 * @abstract Used as a key in the settings dictionary to store the primary font for queue count text
 * @discussion See product documentation for a map of UI elements
 * @seealso settings
 */
extern NSString * const kMPQueuePrimaryFont;

/*!
 * @abstract Used as a key in the settings dictionary to store the primary font color for queue count text
 * @discussion See product documentation for a map of UI elements
 * @seealso settings
 */
extern NSString * const kMPQueuePrimaryFontColor;


/*!
 * @abstract Used as a key in the settings dictionary to store the background color for Form Field UI elements
 * @discussion See product documentation for a map of UI elements
 * @seealso settings
 */
extern NSString * const kMPFormFieldBackgroundColor;

/*!
 * @abstract Used as a key in the settings dictionary to store the primary font for Form Field UI elements
 * @discussion See product documentation for a map of UI elements
 * @seealso settings
 */
extern NSString * const kMPFormFieldPrimaryFont;

/*!
 * @abstract Used as a key in the settings dictionary to store the primary font color for Form Field UI elements
 * @discussion See product documentation for a map of UI elements
 * @seealso settings
 */
extern NSString * const kMPFormFieldPrimaryFontColor;


/*!
 * @abstract Used as a key in the settings dictionary to store the background color for Overlay UI elements
 * @discussion See product documentation for a map of UI elements
 * @seealso settings
 */
extern NSString * const kMPOverlayBackgroundColor;

/*!
 * @abstract Used as a key in the settings dictionary to store the primary font for Overlay UI elements
 * @discussion See product documentation for a map of UI elements
 * @seealso settings
 */
extern NSString * const kMPOverlayPrimaryFont;

/*!
 * @abstract Used as a key in the settings dictionary to store the primary font color for Overlay UI elements
 * @discussion See product documentation for a map of UI elements
 * @seealso settings
 */
extern NSString * const kMPOverlayPrimaryFontColor;

/*!
 * @abstract Used as a key in the settings dictionary to store the secondary font for Overlay UI elements
 * @discussion See product documentation for a map of UI elements
 * @seealso settings
 */
extern NSString * const kMPOverlaySecondaryFont;

/*!
 * @abstract Used as a key in the settings dictionary to store the secondary font color for Overlay UI elements
 * @discussion See product documentation for a map of UI elements
 * @seealso settings
 */
extern NSString * const kMPOverlaySecondaryFontColor;

/*!
 * @abstract Used as a key in the settings dictionary to store the link font for Overlay UI elements
 * @discussion See product documentation for a map of UI elements
 * @seealso settings
 */
extern NSString * const kMPOverlayLinkFont;

/*!
 * @abstract Used as a key in the settings dictionary to store the link font color for Overlay UI elements
 * @discussion See product documentation for a map of UI elements
 * @seealso settings
 */
extern NSString * const kMPOverlayLinkFontColor;

/*!
 * @abstract Used as a key in the settings dictionary to store the background opacity for Overlay UI elements
 * @discussion See product documentation for a map of UI elements
 * @seealso settings
 */
extern NSString * const kMPOverlayBackgroundOpacity;


/*!
 * @abstract Used as a key in the settings dictionary to store the icon used in the Print Activity
 * @discussion See product documentation for a map of UI elements
 * @seealso settings
 */
extern NSString * const kMPActivityPrintIcon;

/*!
 * @abstract Used as a key in the settings dictionary to store the icon used in the Print Queue/Later Activity
 * @discussion See product documentation for a map of UI elements
 * @seealso settings
 */
extern NSString * const kMPActivityPrintQueueIcon;


/*!
 * @abstract A dictionary containing all customizable style settings for the MobilePrintSDK user interface
 */
@property (strong, nonatomic) NSDictionary *settings;

@property (strong, nonatomic, readonly) NSString *dateFormat;

@end
