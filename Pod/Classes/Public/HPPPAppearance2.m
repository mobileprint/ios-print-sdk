//
//  HPPPAppearance2.m
//  Pods
//
//  Created by Bozo on 8/18/15.
//
//

#import "HPPPAppearance2.h"

@implementation HPPPAppearance2

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

// Header
NSString * const kHPPPHeaderBackgroundColor = @"kHPPPHeaderBackgroundColor";
NSString * const kHPPPHeaderPrimaryFont = @"kHPPPHeaderPrimaryFont";
NSString * const kHPPPHeaderPrimaryFontColor = @"kHPPPHeaderPrimaryFontColor";
NSString * const kHPPPHeaderLinkFont = @"kHPPPHeaderLinkFont";
NSString * const kHPPPHeaderLinkFontColor = @"kHPPPHeaderLinkFontColor";

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
NSString * const kHPPPOverlayPrimaryFont = @"kHPPPOverlayPrimaryFont";
NSString * const kHPPPOverlayPrimaryFontColor = @"kHPPPOverlayPrimaryFontColor";
NSString * const kHPPPOverlaySecondaryFont = @"kHPPPOverlaySecondaryFont";
NSString * const kHPPPOverlaySecondaryFontColor = @"kHPPPOverlaySecondaryFontColor";
NSString * const kHPPPOverlayLinkFont = @"kHPPPOverlayLinkFont";
NSString * const kHPPPOverlayLinkFontColor = @"kHPPPOverlayLinkFontColor";

- (NSDictionary *)settings
{
    NSString *regularFont = @"HelveticaNeue";//@"HPSimplified-Regular";
    NSString *lightFont   = @"HelveticaNeue-Light";//@"HPSimplified-Light";
    
    _settings = @{// Background
                  kHPPPBackgroundBackgroundColor:   [UIColor colorWithRed:0xEF/255.0F green:0xEF/255.0F blue:0xF4/255.0F alpha:1.0F],
                  kHPPPBackgroundPrimaryFont:       [UIFont fontWithName:regularFont size:13],
                  kHPPPBackgroundPrimaryFontColor:  [UIColor colorWithRed:0x33/255.0F green:0x33/255.0F blue:0x33/255.0F alpha:1.0F],
                  kHPPPBackgroundSecondaryFont:     [UIFont fontWithName:lightFont size:12],
                  kHPPPBackgroundSecondaryFontColor:[UIColor colorWithRed:0x33/255.0F green:0x33/255.0F blue:0x33/255.0F alpha:1.0F],
                  
                  // Selection Options
                  kHPPPSelectionOptionsBackgroundColor:   [UIColor colorWithRed:0xFF/255.0F green:0xFF/255.0F blue:0xFF/255.0F alpha:1.0F],
                  kHPPPSelectionOptionsStrokeColor:       [UIColor colorWithRed:0xC8/255.0F green:0xC7/255.0F blue:0xCC/255.0F alpha:1.0F],
                  kHPPPSelectionOptionsPrimaryFont:       [UIFont fontWithName:lightFont size:16],
                  kHPPPSelectionOptionsPrimaryFontColor:  [UIColor colorWithRed:0x33/255.0F green:0x33/255.0F blue:0x33/255.0F alpha:1.0F],
                  kHPPPSelectionOptionsSecondaryFont:     [UIFont fontWithName:lightFont size:16],
                  kHPPPSelectionOptionsSecondaryFontColor:[UIColor colorWithRed:0x8F/255.0F green:0x8F/255.0F blue:0x95/255.0F alpha:1.0F],
                  kHPPPSelectionOptionsLinkFont:          [UIFont fontWithName:lightFont size:16],
                  kHPPPSelectionOptionsLinkFontColor:     [UIColor colorWithRed:0x00/255.0F green:0x96/255.0F blue:0xD6/255.0F alpha:1.0F],
                  
                  // Job Settings
                  kHPPPJobSettingsBackgroundColor:    [UIColor colorWithRed:0xFF/255.0F green:0xFF/255.0F blue:0xFF/255.0F alpha:1.0F],
                  kHPPPJobSettingsStrokeColor:        [UIColor colorWithRed:0xC8/255.0F green:0xC7/255.0F blue:0xCC/255.0F alpha:1.0F],
                  kHPPPJobSettingsPrimaryFont:        [UIFont fontWithName:lightFont size:18],
                  kHPPPJobSettingsPrimaryFontColor:   [UIColor colorWithRed:0x33/255.0F green:0x33/255.0F blue:0x33/255.0F alpha:1.0F],
                  kHPPPJobSettingsSecondaryFont:      [UIFont fontWithName:lightFont size:12],
                  kHPPPJobSettingsSecondaryFontColor: [UIColor colorWithRed:0x33/255.0F green:0x33/255.0F blue:0x33/255.0F alpha:1.0F],
                  kHPPPJobSettingsSelectedPageIcon:   [UIImage imageNamed:@"HPPPSelected.png"],
                  kHPPPJobSettingsUnselectedPageIcon: [UIImage imageNamed:@"HPPPUnselected.png"],
                  
                  // Header
                  kHPPPHeaderBackgroundColor:  [UIColor colorWithRed:0xEF/255.0F green:0xEF/255.0F blue:0xF4/255.0F alpha:1.0F],
                  kHPPPHeaderPrimaryFont:      [UIFont fontWithName:lightFont size:20],
                  kHPPPHeaderPrimaryFontColor: [UIColor colorWithRed:0xFF/255.0F green:0xFF/255.0F blue:0xFF/255.0F alpha:1.0F],
                  kHPPPHeaderLinkFont:         [UIFont fontWithName:regularFont size:18],
                  kHPPPHeaderLinkFontColor:    [UIColor colorWithRed:0xFF/255.0F green:0xFF/255.0F blue:0xFF/255.0F alpha:1.0F],
                  
                  // Main Action
                  kHPPPMainActionBackgroundColor:     [UIColor colorWithRed:0xFF/255.0F green:0xFF/255.0F blue:0xFF/255.0F alpha:1.0F],
                  kHPPPMainActionStrokeColor:         [UIColor colorWithRed:0xC8/255.0F green:0xC7/255.0F blue:0xCC/255.0F alpha:1.0F],
                  kHPPPMainActionLinkFont:            [UIFont fontWithName:regularFont size:18],
                  kHPPPMainActionActiveLinkFontColor: [UIColor colorWithRed:0x00/255.0F green:0x96/255.0F blue:0xD6/255.0F alpha:1.0F],
kHPPPMainActionInactiveLinkFontColor: [UIColor grayColor],
                  
                  // Queue Project Count
                  kHPPPQueuePrimaryFont:     [UIFont fontWithName:lightFont size:14],
                  kHPPPQueuePrimaryFontColor:[UIColor colorWithRed:0xFF green:0xFF blue:0xFF alpha:1.0F],
                  
                  // Form Field
                  kHPPPFormFieldBackgroundColor:  [UIColor colorWithRed:0xFF/255.0F green:0xFF/255.0F blue:0xFF/255.0F alpha:1.0F],
                  kHPPPFormFieldStrokeColor:      [UIColor colorWithRed:0xCC/255.0F green:0xCC/255.0F blue:0xCC/255.0F alpha:1.0F],
                  kHPPPFormFieldPrimaryFont:      [UIFont fontWithName:lightFont size:14],
                  kHPPPFormFieldPrimaryFontColor: [UIColor colorWithRed:0x33/255.0F green:0x33/255.0F blue:0x33/255.0F alpha:1.0F],
                  
                  // Multipage Graphics
                  kHPPPMultipageGraphicsStrokeColor: [UIColor colorWithRed:0xCC green:0xCC blue:0xCC alpha:1.0F],
                  
                  // Overlay
                  kHPPPOverlayBackgroundColor:    [UIColor colorWithRed:0x00/255.0F green:0x00/255.0F blue:0x00/255.0F alpha:1.0F],
                  kHPPPOverlayPrimaryFont:        [UIFont fontWithName:lightFont size:20],
                  kHPPPOverlayPrimaryFontColor:   [UIColor colorWithRed:0xFF/255.0F green:0xFF/255.0F blue:0xFF/255.0F alpha:1.0F],
                  kHPPPOverlaySecondaryFont:      [UIFont fontWithName:lightFont size:10],
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
