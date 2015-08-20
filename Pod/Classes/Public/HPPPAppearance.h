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

@interface HPPPAppearance : NSObject

// General
extern NSString * const kHPPPGeneralDefaultDateFormat;

// Background
extern NSString * const kHPPPBackgroundBackgroundColor;
extern NSString * const kHPPPBackgroundPrimaryFont;
extern NSString * const kHPPPBackgroundPrimaryFontColor;
extern NSString * const kHPPPBackgroundSecondaryFont;
extern NSString * const kHPPPBackgroundSecondaryFontColor;

// Selection Options
extern NSString * const kHPPPSelectionOptionsBackgroundColor;
extern NSString * const kHPPPSelectionOptionsStrokeColor;
extern NSString * const kHPPPSelectionOptionsPrimaryFont;
extern NSString * const kHPPPSelectionOptionsPrimaryFontColor;
extern NSString * const kHPPPSelectionOptionsSecondaryFont;
extern NSString * const kHPPPSelectionOptionsSecondaryFontColor;
extern NSString * const kHPPPSelectionOptionsLinkFont;
extern NSString * const kHPPPSelectionOptionsLinkFontColor;

// Job Settings
extern NSString * const kHPPPJobSettingsBackgroundColor;
extern NSString * const kHPPPJobSettingsStrokeColor;
extern NSString * const kHPPPJobSettingsPrimaryFont;
extern NSString * const kHPPPJobSettingsPrimaryFontColor;
extern NSString * const kHPPPJobSettingsSecondaryFont;
extern NSString * const kHPPPJobSettingsSecondaryFontColor;
extern NSString * const kHPPPJobSettingsSelectedPageIcon;
extern NSString * const kHPPPJobSettingsUnselectedPageIcon;

// Header
extern NSString * const kHPPPHeaderBackgroundColor;
extern NSString * const kHPPPHeaderPrimaryFont;
extern NSString * const kHPPPHeaderPrimaryFontColor;
extern NSString * const kHPPPHeaderLinkFont;
extern NSString * const kHPPPHeaderLinkFontColor;

// Main Action
extern NSString * const kHPPPMainActionBackgroundColor;
extern NSString * const kHPPPMainActionStrokeColor;
extern NSString * const kHPPPMainActionActiveLinkFont;
extern NSString * const kHPPPMainActionActiveLinkFontColor;
extern NSString * const kHPPPMainActionInactiveLinkFont;
extern NSString * const kHPPPMainActionInactiveLinkFontColor;

// Queue Project Count
extern NSString * const kHPPPQueuePrimaryFont;
extern NSString * const kHPPPQueuePrimaryFontColor;

// Form Field
extern NSString * const kHPPPFormFieldBackgroundColor;
extern NSString * const kHPPPFormFieldStrokeColor;
extern NSString * const kHPPPFormFieldPrimaryFont;
extern NSString * const kHPPPFormFieldPrimaryFontColor;

// Multipage Graphics
extern NSString * const kHPPPMultipageGraphicsStrokeColor;

// Overlay
extern NSString * const kHPPPOverlayBackgroundColor;
extern NSString * const kHPPPOverlayPrimaryFont;
extern NSString * const kHPPPOverlayPrimaryFontColor;
extern NSString * const kHPPPOverlaySecondaryFont;
extern NSString * const kHPPPOverlaySecondaryFontColor;
extern NSString * const kHPPPOverlayLinkFont;
extern NSString * const kHPPPOverlayLinkFontColor;
extern NSString * const kHPPPOverlayBackgroundOpacity;

@property (strong, nonatomic) NSDictionary *settings;

@end
