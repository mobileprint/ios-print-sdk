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

#import "HPPP.h"
#import "UIFont+Style.h"

#define FONT_PLIST_FILENAME @"Fonts"
#define FAMILY_NAME_KEY @"FamilyName"
#define MIN_FONT_SIZE_KEY @"MinFontSize"
#define DEFAULT_MIN_FONT_SIZE 1.0f

@implementation UIFont (Style)

+ (UIFont *)HPSimplifiedRegularFontWithSize:(CGFloat)size
{
    return [UIFont fontWithName:@"HPSimplified-Regular" size:size];
}

+ (UIFont *)HPSimplifiedLightFontWithSize:(CGFloat)size
{
    return [UIFont fontWithName:@"HPSimplified-Light" size:size];
}

+ (UIFont *)HPSimplifiedBoldFontWithSize:(CGFloat)size
{
    return [UIFont fontWithName:@"HPSimplified-Bold" size:size];
}

+ (CGFloat)HPDefaultCardFontSize
{
    return 12;
}

+ (UIFont *)HPPaperSizeLabelFont
{
    return [UIFont HPSimplifiedRegularFontWithSize:18.0f];
}

+ (UIFont *)HPNavigationBarTitleFont
{
    return [self HPSimplifiedRegularFontWithSize:18.0f];
}

+ (UIFont *)HPCategoryTitleFont
{
    if (IS_IPHONE) {
        return [self HPIphoneCategoryTitleFont];
    } else {
        return [self HPIpadCategoryTitleFont];
    }
}

+ (UIFont *)HPIphoneCategoryTitleFont
{
    return [UIFont HPSimplifiedLightFontWithSize:15.0f];
}

+ (UIFont *)HPIpadCategoryTitleFont
{
    return [UIFont HPSimplifiedLightFontWithSize:24.0f];
}

+ (NSArray *)HPTextFonts
{
    NSMutableArray *fonts = [NSMutableArray array];
	
	NSString *pathToPlist = [[NSBundle mainBundle] pathForResource:FONT_PLIST_FILENAME ofType:@"plist"];
	
	NSArray *fontsPlist = [NSArray arrayWithContentsOfFile:pathToPlist];
	
    for (NSDictionary *fontDict in fontsPlist) {
        [fonts addObject:[UIFont fontWithName:[fontDict objectForKey:FAMILY_NAME_KEY] size:[UIFont HPDefaultCardFontSize]]];
    }
    
	return fonts.copy;
}

- (float)minFontSize
{
    NSString *pathToPlist = [[NSBundle mainBundle] pathForResource:FONT_PLIST_FILENAME ofType:@"plist"];
    
    NSArray *fontsPlist = [NSArray arrayWithContentsOfFile:pathToPlist];
    
    for (NSDictionary *fontDict in fontsPlist) {
        NSString *familyName = [fontDict objectForKey: FAMILY_NAME_KEY];
        
        if ([self.familyName isEqualToString:familyName]) {
            NSNumber *minFontSize = [fontDict objectForKey:MIN_FONT_SIZE_KEY];
            return [minFontSize floatValue];
        }
        
    }
    
    NSLog(@"Unknown font family (%@), setting minimum font size to default (%f)", self.familyName, DEFAULT_MIN_FONT_SIZE);
    return DEFAULT_MIN_FONT_SIZE;
}


@end
