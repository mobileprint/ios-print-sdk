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

#import "HPPPAppearance.h"

@implementation HPPPAppearance

// General
NSString * const kHPPPGeneralDefaultDateFormat = @"kHPPPGeneralDefaultDateFormat";

// Background
NSString * const kHPPPBackgroundBackgroundColor = @"kHPPPBackgroundBackgroundColor";
NSString * const kHPPPBackgroundPrimaryFont = @"kHPPPBackgroundPrimaryFont";
NSString * const kHPPPBackgroundPrimaryFontColor = @"kHPPPBackgroundPrimaryFontColor";
NSString * const kHPPPBackgroundSecondaryFont = @"kHPPPBackgroundSecondaryFont";
NSString * const kHPPPBackgroundSecondaryFontColor = @"kHPPPBackgroundSecondaryFontColor";

// Selection Options
NSString * const kHPPPSelectionOptionsBackgroundColor = @"kHPPPSelectionOptionsBackgroundColor";
NSString * const kHPPPSelectionOptionsStrokeColor = @"kHPPPSelectionOptionsStrokeColor";
NSString * const kHPPPSelectionOptionsPrimaryFont = @"kHPPPSelectionOptionsPrimaryFont";
NSString * const kHPPPSelectionOptionsPrimaryFontColor = @"kHPPPSelectionOptionsPrimaryFontColor";
NSString * const kHPPPSelectionOptionsSecondaryFont = @"kHPPPSelectionOptionsSecondaryFont";
NSString * const kHPPPSelectionOptionsSecondaryFontColor = @"kHPPPSelectionOptionsSecondaryFontColor";
NSString * const kHPPPSelectionOptionsLinkFont = @"kHPPPSelectionOptionsLinkFont";
NSString * const kHPPPSelectionOptionsLinkFontColor = @"kHPPPSelectionOptionsLinkFontColor";

// Job Settings
NSString * const kHPPPJobSettingsBackgroundColor = @"kHPPPJobSettingsBackgroundColor";
NSString * const kHPPPJobSettingsStrokeColor = @"kHPPPJobSettingsStrokeColor";
NSString * const kHPPPJobSettingsPrimaryFont = @"kHPPPJobSettingsPrimaryFont";
NSString * const kHPPPJobSettingsPrimaryFontColor = @"kHPPPJobSettingsPrimaryFontColor";
NSString * const kHPPPJobSettingsSecondaryFont = @"kHPPPJobSettingsSecondaryFont";
NSString * const kHPPPJobSettingsSecondaryFontColor = @"kHPPPJobSettingsSecondaryFontColor";
NSString * const kHPPPJobSettingsSelectedPageIcon = @"kHPPPJobSettingsSelectedPageIcon";
NSString * const kHPPPJobSettingsUnselectedPageIcon = @"kHPPPJobSettingsUnselectedPageIcon";

// Main Action
NSString * const kHPPPMainActionBackgroundColor = @"kHPPPMainActionBackgroundColor";
NSString * const kHPPPMainActionStrokeColor = @"kHPPPMainActionStrokeColor";
NSString * const kHPPPMainActionLinkFont = @"kHPPPMainActionLinkFont";
NSString * const kHPPPMainActionActiveLinkFontColor = @"kHPPPMainActionActiveLinkFontColor";
NSString * const kHPPPMainActionInactiveLinkFontColor = @"kHPPPMainActionInactiveLinkFontColor";

// Queue Project Count
NSString * const kHPPPQueuePrimaryFont = @"kHPPPQueuePrimaryFont";
NSString * const kHPPPQueuePrimaryFontColor = @"kHPPPQueuePrimaryFontColor";

// Form Field
NSString * const kHPPPFormFieldBackgroundColor = @"kHPPPFormFieldBackgroundColor";
NSString * const kHPPPFormFieldStrokeColor = @"kHPPPFormFieldStrokeColor";
NSString * const kHPPPFormFieldPrimaryFont = @"kHPPPFormFieldPrimaryFont";
NSString * const kHPPPFormFieldPrimaryFontColor = @"kHPPPFormFieldPrimaryFontColor";

// Multipage Graphics
NSString * const kHPPPMultipageGraphicsStrokeColor = @"kHPPPMultipageGraphicsStrokeColor";

// Overlay
NSString * const kHPPPOverlayBackgroundColor = @"kHPPPOverlayBackgroundColor";
NSString * const kHPPPOverlayBackgroundOpacity = @"kHPPPOverlayBackgroundOpacity";
NSString * const kHPPPOverlayPrimaryFont = @"kHPPPOverlayPrimaryFont";
NSString * const kHPPPOverlayPrimaryFontColor = @"kHPPPOverlayPrimaryFontColor";
NSString * const kHPPPOverlaySecondaryFont = @"kHPPPOverlaySecondaryFont";
NSString * const kHPPPOverlaySecondaryFontColor = @"kHPPPOverlaySecondaryFontColor";
NSString * const kHPPPOverlayLinkFont = @"kHPPPOverlayLinkFont";
NSString * const kHPPPOverlayLinkFontColor = @"kHPPPOverlayLinkFontColor";

- (NSDictionary *)settings
{
    NSString *regularFont = @"HelveticaNeue";
    NSString *lightFont   = @"HelveticaNeue-Medium";
    
    _settings = @{// General
                  kHPPPGeneralDefaultDateFormat: @"MMMM d, h:mma",
                  
                  // Background
                  kHPPPBackgroundBackgroundColor:   [UIColor colorWithRed:0xEF/255.0F green:0xEF/255.0F blue:0xF4/255.0F alpha:1.0F],
                  kHPPPBackgroundPrimaryFont:       [UIFont fontWithName:regularFont size:14],
                  kHPPPBackgroundPrimaryFontColor:  [UIColor colorWithRed:0x33/255.0F green:0x33/255.0F blue:0x33/255.0F alpha:1.0F],
                  kHPPPBackgroundSecondaryFont:     [UIFont fontWithName:lightFont size:12],
                  kHPPPBackgroundSecondaryFontColor:[UIColor colorWithRed:0x33/255.0F green:0x33/255.0F blue:0x33/255.0F alpha:1.0F],
                  
                  // Selection Options
                  kHPPPSelectionOptionsBackgroundColor:   [UIColor colorWithRed:0xFF/255.0F green:0xFF/255.0F blue:0xFF/255.0F alpha:1.0F],
                  kHPPPSelectionOptionsStrokeColor:       [UIColor colorWithRed:0xC8/255.0F green:0xC7/255.0F blue:0xCC/255.0F alpha:1.0F],
                  kHPPPSelectionOptionsPrimaryFont:       [UIFont fontWithName:regularFont size:16],
                  kHPPPSelectionOptionsPrimaryFontColor:  [UIColor colorWithRed:0x00/255.0F green:0x00/255.0F blue:0x00/255.0F alpha:1.0F],
                  kHPPPSelectionOptionsSecondaryFont:     [UIFont fontWithName:regularFont size:16],
                  kHPPPSelectionOptionsSecondaryFontColor:[UIColor colorWithRed:0x8E/255.0F green:0x8E/255.0F blue:0x93/255.0F alpha:1.0F],
                  kHPPPSelectionOptionsLinkFont:          [UIFont fontWithName:regularFont size:16],
                  kHPPPSelectionOptionsLinkFontColor:     [UIColor colorWithRed:0x00/255.0F green:0x7A/255.0F blue:0xFF/255.0F alpha:1.0F],
                  
                  // Job Settings
                  kHPPPJobSettingsBackgroundColor:    [UIColor colorWithRed:0xFF/255.0F green:0xFF/255.0F blue:0xFF/255.0F alpha:1.0F],
                  kHPPPJobSettingsStrokeColor:        [UIColor colorWithRed:0xC8/255.0F green:0xC7/255.0F blue:0xCC/255.0F alpha:1.0F],
                  kHPPPJobSettingsPrimaryFont:        [UIFont fontWithName:regularFont size:16],
                  kHPPPJobSettingsPrimaryFontColor:   [UIColor colorWithRed:0x00/255.0F green:0x00/255.0F blue:0x00/255.0F alpha:1.0F],
                  kHPPPJobSettingsSecondaryFont:      [UIFont fontWithName:regularFont size:12],
                  kHPPPJobSettingsSecondaryFontColor: [UIColor colorWithRed:0x00/255.0F green:0x00/255.0F blue:0x00/255.0F alpha:1.0F],
                  kHPPPJobSettingsSelectedPageIcon:   [UIImage imageNamed:@"HPPPSelected.png"],
                  kHPPPJobSettingsUnselectedPageIcon: [UIImage imageNamed:@"HPPPUnselected.png"],
                                   
                  // Main Action
                  kHPPPMainActionBackgroundColor:       [UIColor colorWithRed:0xFF/255.0F green:0xFF/255.0F blue:0xFF/255.0F alpha:1.0F],
                  kHPPPMainActionStrokeColor:           [UIColor colorWithRed:0xC8/255.0F green:0xC7/255.0F blue:0xCC/255.0F alpha:1.0F],
                  kHPPPMainActionLinkFont:              [UIFont fontWithName:regularFont size:18],
                  kHPPPMainActionActiveLinkFontColor:   [UIColor colorWithRed:0x00/255.0F green:0x7A/255.0F blue:0xFF/255.0F alpha:1.0F],
                  kHPPPMainActionInactiveLinkFontColor: [UIColor colorWithRed:0xAA/255.0F green:0xAA/255.0F blue:0xAA/255.0F alpha:1.0F],
                  
                  // Queue Project Count
                  kHPPPQueuePrimaryFont:     [UIFont fontWithName:regularFont size:16],
                  kHPPPQueuePrimaryFontColor:[UIColor colorWithRed:0x00 green:0x00 blue:0x00 alpha:1.0F],
                  
                  // Form Field
                  kHPPPFormFieldBackgroundColor:  [UIColor colorWithRed:0xFF/255.0F green:0xFF/255.0F blue:0xFF/255.0F alpha:1.0F],
                  kHPPPFormFieldStrokeColor:      [UIColor colorWithRed:0xFF/255.0F green:0xFF/255.0F blue:0xFF/255.0F alpha:1.0F],
                  kHPPPFormFieldPrimaryFont:      [UIFont fontWithName:regularFont size:16],
                  kHPPPFormFieldPrimaryFontColor: [UIColor colorWithRed:0x00/255.0F green:0x00/255.0F blue:0x00/255.0F alpha:1.0F],
                  
                  // Multipage Graphics
                  kHPPPMultipageGraphicsStrokeColor: [UIColor colorWithRed:0xFF green:0xFF blue:0xFF alpha:1.0F],
                  
                  // Overlay
                  kHPPPOverlayBackgroundColor:    [UIColor colorWithRed:0x00/255.0F green:0x00/255.0F blue:0x00/255.0F alpha:1.0F],
                  kHPPPOverlayBackgroundOpacity:  [NSNumber numberWithFloat:.60F],
                  kHPPPOverlayPrimaryFont:        [UIFont fontWithName:regularFont size:16],
                  kHPPPOverlayPrimaryFontColor:   [UIColor colorWithRed:0xFF/255.0F green:0xFF/255.0F blue:0xFF/255.0F alpha:1.0F],
                  kHPPPOverlaySecondaryFont:      [UIFont fontWithName:regularFont size:14],
                  kHPPPOverlaySecondaryFontColor: [UIColor colorWithRed:0xFF/255.0F green:0xFF/255.0F blue:0xFF/255.0F alpha:1.0F],
                  kHPPPOverlayLinkFont:           [UIFont fontWithName:regularFont size:18],
                  kHPPPOverlayLinkFontColor:      [UIColor colorWithRed:0xFF/255.0F green:0xFF/255.0F blue:0xFF/255.0F alpha:1.0F]
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
