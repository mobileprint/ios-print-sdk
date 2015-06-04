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
#import "HPPPLayoutFactory.h"
#import "HPPPLayoutFill.h"
#import "HPPPLayoutFit.h"
#import "HPPPLayoutStretch.h"

@implementation HPPPLayoutFactory

NSString * const kHPPPLayoutTypeKey = @"kHPPPLayoutTypeKey";
NSString * const kHPPPLayoutOrientationKey = @"kHPPPLayoutOrientationKey";
NSString * const kHPPPLayoutPositionKey = @"kHPPPLayoutPositionKey";
NSString * const kHPPPLayoutAllowRotationKey = @"kHPPPLayoutAllowRotationKey";

+ (HPPPLayout *)layoutWithType:(HPPPLayoutType)layoutType
{
    return [HPPPLayoutFactory layoutWithType:layoutType orientation:HPPPLayoutOrientationBestFit assetPosition:[HPPPLayout defaultAssetPosition]];
}

+ (HPPPLayout *)layoutWithType:(HPPPLayoutType)layoutType orientation:(HPPPLayoutOrientation)orientation assetPosition:(CGRect)assetPosition
{
    HPPPLayout *layout = nil;
    
    if (HPPPLayoutTypeFill == layoutType || HPPPLayoutTypeDefault == layoutType) {
        layout = [[HPPPLayoutFill alloc] initWithOrientation:orientation andAssetPosition:assetPosition];
    } else if (HPPPLayoutTypeFit == layoutType) {
        layout = [[HPPPLayoutFit alloc] initWithOrientation:orientation andAssetPosition:assetPosition];
    } else if (HPPPLayoutTypeStretch == layoutType) {
        layout = [[HPPPLayoutStretch alloc] initWithOrientation:orientation andAssetPosition:assetPosition];
    }
    
    if (nil == layout) {
        HPPPLogWarn(@"Unable to create a layout using type %u", layoutType);
    }
    
    return layout;
}

#pragma mark - NSCoding support

+ (void)encodeLayout:(HPPPLayout *)layout WithCoder:(NSCoder *)encoder
{
    HPPPLayoutType type = [HPPPLayoutFactory layoutTypeFromLayout:layout];
    if (HPPPLayoutTypeUnknown != type) {
        [encoder encodeObject:[NSNumber numberWithInt:type] forKey:kHPPPLayoutTypeKey];
        [encoder encodeObject:[NSNumber numberWithInt:layout.orientation] forKey:kHPPPLayoutOrientationKey];
        [encoder encodeBool:layout.allowContentRotation forKey:kHPPPLayoutAllowRotationKey];
        [encoder encodeCGRect:layout.assetPosition forKey:kHPPPLayoutPositionKey];
    }
}

+ (id)initLayoutWithCoder:(NSCoder *)decoder
{
    HPPPLayoutType type = [[decoder decodeObjectForKey:kHPPPLayoutTypeKey] intValue];
    HPPPLayoutOrientation orientation = [[decoder decodeObjectForKey:kHPPPLayoutOrientationKey] intValue];
    CGRect positionRect = [decoder decodeCGRectForKey:kHPPPLayoutPositionKey];
    HPPPLayout *layout = [self layoutWithType:type orientation:orientation assetPosition:positionRect];
    layout.allowContentRotation = [decoder decodeBoolForKey:kHPPPLayoutAllowRotationKey];
    return layout;
}

+ (HPPPLayoutType)layoutTypeFromLayout:(HPPPLayout *)layout
{
    HPPPLayoutType type = HPPPLayoutTypeUnknown;
    if ([layout isKindOfClass:[HPPPLayoutStretch class]]) {
        type = HPPPLayoutTypeStretch;
    } else if ([layout isKindOfClass:[HPPPLayoutFill class]]) {
        type = HPPPLayoutTypeFill;
    } else if ([layout isKindOfClass:[HPPPLayoutFit class]]) {
        type = HPPPLayoutTypeFit;
    }
    return type;
}

@end
