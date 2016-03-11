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

#import "MPAppearance.h"
#import "UIImage+MPBundle.h"

@implementation MPAppearance

// General
NSString * const kMPGeneralBackgroundColor = @"kMPBackgroundBackgroundColor";
NSString * const kMPGeneralBackgroundPrimaryFont = @"kMPBackgroundPrimaryFont";
NSString * const kMPGeneralBackgroundPrimaryFontColor = @"kMPBackgroundPrimaryFontColor";
NSString * const kMPGeneralBackgroundSecondaryFont = @"kMPBackgroundSecondaryFont";
NSString * const kMPGeneralBackgroundSecondaryFontColor = @"kMPBackgroundSecondaryFontColor";
NSString * const kMPGeneralTableSeparatorColor = @"kMPGeneralTableSeparatorColor";

// Selection Options
NSString * const kMPSelectionOptionsBackgroundColor = @"kMPSelectionOptionsBackgroundColor";
NSString * const kMPSelectionOptionsPrimaryFont = @"kMPSelectionOptionsPrimaryFont";
NSString * const kMPSelectionOptionsPrimaryFontColor = @"kMPSelectionOptionsPrimaryFontColor";
NSString * const kMPSelectionOptionsSecondaryFont = @"kMPSelectionOptionsSecondaryFont";
NSString * const kMPSelectionOptionsSecondaryFontColor = @"kMPSelectionOptionsSecondaryFontColor";
NSString * const kMPSelectionOptionsLinkFont = @"kMPSelectionOptionsLinkFont";
NSString * const kMPSelectionOptionsLinkFontColor = @"kMPSelectionOptionsLinkFontColor";
NSString * const kMPSelectionOptionsDisclosureIndicatorImage = @"kMPSelectionOptionsDisclosureIndicatorImage";
NSString * const kMPSelectionOptionsCheckmarkImage = @"kMPSelectionOptionsCheckmarkImage";

// Job Settings
NSString * const kMPJobSettingsBackgroundColor = @"kMPJobSettingsBackgroundColor";
NSString * const kMPJobSettingsPrimaryFont = @"kMPJobSettingsPrimaryFont";
NSString * const kMPJobSettingsPrimaryFontColor = @"kMPJobSettingsPrimaryFontColor";
NSString * const kMPJobSettingsSecondaryFont = @"kMPJobSettingsSecondaryFont";
NSString * const kMPJobSettingsSecondaryFontColor = @"kMPJobSettingsSecondaryFontColor";
NSString * const kMPJobSettingsSelectedPageIcon = @"kMPJobSettingsSelectedPageIcon";
NSString * const kMPJobSettingsUnselectedPageIcon = @"kMPJobSettingsUnselectedPageIcon";
NSString * const kMPJobSettingsSelectedJobIcon = @"kMPJobSettingsSelectedJobIcon";
NSString * const kMPJobSettingsUnselectedJobIcon = @"kMPJobSettingsUnselectedJobIcon";
NSString * const kMPJobSettingsMagnifyingGlassIcon = @"kMPJobSettingsMagnifyingGlassIcon";

// Main Action
NSString * const kMPMainActionBackgroundColor = @"kMPMainActionBackgroundColor";
NSString * const kMPMainActionLinkFont = @"kMPMainActionLinkFont";
NSString * const kMPMainActionActiveLinkFontColor = @"kMPMainActionActiveLinkFontColor";
NSString * const kMPMainActionInactiveLinkFontColor = @"kMPMainActionInactiveLinkFontColor";

// Queue Project Count
NSString * const kMPQueuePrimaryFont = @"kMPQueuePrimaryFont";
NSString * const kMPQueuePrimaryFontColor = @"kMPQueuePrimaryFontColor";

// Form Field
NSString * const kMPFormFieldBackgroundColor = @"kMPFormFieldBackgroundColor";
NSString * const kMPFormFieldPrimaryFont = @"kMPFormFieldPrimaryFont";
NSString * const kMPFormFieldPrimaryFontColor = @"kMPFormFieldPrimaryFontColor";

// Overlay
NSString * const kMPOverlayBackgroundColor = @"kMPOverlayBackgroundColor";
NSString * const kMPOverlayBackgroundOpacity = @"kMPOverlayBackgroundOpacity";
NSString * const kMPOverlayPrimaryFont = @"kMPOverlayPrimaryFont";
NSString * const kMPOverlayPrimaryFontColor = @"kMPOverlayPrimaryFontColor";
NSString * const kMPOverlaySecondaryFont = @"kMPOverlaySecondaryFont";
NSString * const kMPOverlaySecondaryFontColor = @"kMPOverlaySecondaryFontColor";
NSString * const kMPOverlayLinkFont = @"kMPOverlayLinkFont";
NSString * const kMPOverlayLinkFontColor = @"kMPOverlayLinkFontColor";

// Activity
NSString * const kMPActivityPrintIcon = @"kMPActivityPrintIcon";
NSString * const kMPActivityPrintQueueIcon = @"kMPActivityPrintQueueIcon";

- (NSDictionary *)settings
{
    if (nil == _settings) {
        _settings = [self defaultSettings];
    }
    
    return _settings;
}

- (NSString *)dateFormat
{
  return @"MMMM d, h:mma";
}

- (NSDictionary *)defaultSettings
{
    NSString *regularFont = @"HelveticaNeue";
    NSString *lightFont   = @"HelveticaNeue-Medium";
    
    _settings = @{// General
                  kMPGeneralBackgroundColor:             [UIColor colorWithRed:0xEF/255.0F green:0xEF/255.0F blue:0xF4/255.0F alpha:1.0F],
                  kMPGeneralBackgroundPrimaryFont:       [UIFont fontWithName:regularFont size:14],
                  kMPGeneralBackgroundPrimaryFontColor:  [UIColor colorWithRed:0x33/255.0F green:0x33/255.0F blue:0x33/255.0F alpha:1.0F],
                  kMPGeneralBackgroundSecondaryFont:     [UIFont fontWithName:lightFont size:12],
                  kMPGeneralBackgroundSecondaryFontColor:[UIColor colorWithRed:0x33/255.0F green:0x33/255.0F blue:0x33/255.0F alpha:1.0F],
                  kMPGeneralTableSeparatorColor:         [UIColor colorWithRed:0xC8/255.0F green:0xC7/255.0F blue:0xCC/255.0F alpha:1.0F],
                  
                  // Selection Options
                  kMPSelectionOptionsBackgroundColor:         [UIColor colorWithRed:0xFF/255.0F green:0xFF/255.0F blue:0xFF/255.0F alpha:1.0F],
                  kMPSelectionOptionsPrimaryFont:             [UIFont fontWithName:regularFont size:16],
                  kMPSelectionOptionsPrimaryFontColor:        [UIColor colorWithRed:0x00/255.0F green:0x00/255.0F blue:0x00/255.0F alpha:1.0F],
                  kMPSelectionOptionsSecondaryFont:           [UIFont fontWithName:regularFont size:16],
                  kMPSelectionOptionsSecondaryFontColor:      [UIColor colorWithRed:0x8E/255.0F green:0x8E/255.0F blue:0x93/255.0F alpha:1.0F],
                  kMPSelectionOptionsLinkFont:                [UIFont fontWithName:regularFont size:16],
                  kMPSelectionOptionsLinkFontColor:           [UIColor colorWithRed:0x00/255.0F green:0x7A/255.0F blue:0xFF/255.0F alpha:1.0F],
                  kMPSelectionOptionsDisclosureIndicatorImage:[UIImage imageResource:@"MPArrow" ofType:@"png"],
                  kMPSelectionOptionsCheckmarkImage:          [UIImage imageResource:@"MPCheck" ofType:@"png"],
                  
                  // Job Settings
                  kMPJobSettingsBackgroundColor:    [UIColor colorWithRed:0xFF/255.0F green:0xFF/255.0F blue:0xFF/255.0F alpha:1.0F],
                  kMPJobSettingsPrimaryFont:        [UIFont fontWithName:regularFont size:16],
                  kMPJobSettingsPrimaryFontColor:   [UIColor colorWithRed:0x00/255.0F green:0x00/255.0F blue:0x00/255.0F alpha:1.0F],
                  kMPJobSettingsSecondaryFont:      [UIFont fontWithName:regularFont size:12],
                  kMPJobSettingsSecondaryFontColor: [UIColor colorWithRed:0x00/255.0F green:0x00/255.0F blue:0x00/255.0F alpha:1.0F],
                  kMPJobSettingsSelectedPageIcon:   [UIImage imageResource:@"MPSelected" ofType:@"png"],
                  kMPJobSettingsUnselectedPageIcon: [UIImage imageResource:@"MPUnselected" ofType:@"png"],
                  kMPJobSettingsSelectedJobIcon:    [UIImage imageResource:@"MPActiveCircle" ofType:@"png"],
                  kMPJobSettingsUnselectedJobIcon:  [UIImage imageResource:@"MPInactiveCircle" ofType:@"png"],
                  kMPJobSettingsMagnifyingGlassIcon:[UIImage imageResource:@"MPMagnify" ofType:@"png"],
                  
                  // Main Action
                  kMPMainActionBackgroundColor:       [UIColor colorWithRed:0xFF/255.0F green:0xFF/255.0F blue:0xFF/255.0F alpha:1.0F],
                  kMPMainActionLinkFont:              [UIFont fontWithName:regularFont size:18],
                  kMPMainActionActiveLinkFontColor:   [UIColor colorWithRed:0x00/255.0F green:0x7A/255.0F blue:0xFF/255.0F alpha:1.0F],
                  kMPMainActionInactiveLinkFontColor: [UIColor colorWithRed:0xAA/255.0F green:0xAA/255.0F blue:0xAA/255.0F alpha:1.0F],
                  
                  // Queue Project Count
                  kMPQueuePrimaryFont:     [UIFont fontWithName:regularFont size:16],
                  kMPQueuePrimaryFontColor:[UIColor colorWithRed:0x00 green:0x00 blue:0x00 alpha:1.0F],
                  
                  // Form Field
                  kMPFormFieldBackgroundColor:  [UIColor colorWithRed:0xFF/255.0F green:0xFF/255.0F blue:0xFF/255.0F alpha:1.0F],
                  kMPFormFieldPrimaryFont:      [UIFont fontWithName:regularFont size:16],
                  kMPFormFieldPrimaryFontColor: [UIColor colorWithRed:0x00/255.0F green:0x00/255.0F blue:0x00/255.0F alpha:1.0F],
                  
                  // Overlay
                  kMPOverlayBackgroundColor:    [UIColor colorWithRed:0x00/255.0F green:0x00/255.0F blue:0x00/255.0F alpha:1.0F],
                  kMPOverlayBackgroundOpacity:  [NSNumber numberWithFloat:.80F],
                  kMPOverlayPrimaryFont:        [UIFont fontWithName:regularFont size:16],
                  kMPOverlayPrimaryFontColor:   [UIColor colorWithRed:0xFF/255.0F green:0xFF/255.0F blue:0xFF/255.0F alpha:1.0F],
                  kMPOverlaySecondaryFont:      [UIFont fontWithName:regularFont size:14],
                  kMPOverlaySecondaryFontColor: [UIColor colorWithRed:0xFF/255.0F green:0xFF/255.0F blue:0xFF/255.0F alpha:1.0F],
                  kMPOverlayLinkFont:           [UIFont fontWithName:regularFont size:18],
                  kMPOverlayLinkFontColor:      [UIColor colorWithRed:0xFF/255.0F green:0xFF/255.0F blue:0xFF/255.0F alpha:1.0F],
                  
                  // Activity
                  kMPActivityPrintIcon:      [UIImage imageResource:@"MPPrint" ofType:@"png"],
                  kMPActivityPrintQueueIcon: [UIImage imageResource:@"MPPrintLater" ofType:@"png"],
                  };
    
    return _settings;
}

// This function is helpful in finding desired font names
- (void)listAllFonts
{
    NSArray *familyNames = [[NSArray alloc] initWithArray:[UIFont familyNames]];
    NSArray *fontNames;
    NSInteger indFamily, indFont;
    for (indFamily=0; indFamily<[familyNames count]; ++indFamily)
    {
        NSLog(@"Family name: %@", [familyNames objectAtIndex:indFamily]);
        fontNames = [[NSArray alloc] initWithArray:
                     [UIFont fontNamesForFamilyName:
                      [familyNames objectAtIndex:indFamily]]];
        for (indFont=0; indFont<[fontNames count]; ++indFont)
        {
            NSLog(@"    Font name: %@", [fontNames objectAtIndex:indFont]);
        }
    }
}

@end
