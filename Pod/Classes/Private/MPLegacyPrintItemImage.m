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

#import "MPLegacyPrintItemImage.h"
#import "MPLayoutFill.h"
#import "MPLayoutFit.h"
#import "MPLayoutStretch.h"
#import "MPLayoutFactory.h"

@implementation MPLegacyPrintItemImage

NSString * const kHPPPPrintAssetKey = @"kHPPPPrintAssetKey";

NSString * const kHPPPLayoutKey = @"kHPPPLayoutKey";
NSString * const kHPPPLayoutTypeKey = @"kHPPPLayoutTypeKey";
NSString * const kHPPPLayoutOrientationKey = @"kHPPPLayoutOrientationKey";
NSString * const kHPPPLayoutPositionKey = @"kHPPPLayoutPositionKey";
NSString * const kHPPPLayoutAllowRotationKey = @"kHPPPLayoutAllowRotationKey";

NSString * const kHPPPLayoutBorderInchesKey = @"kHPPPLayoutBorderInchesKey";
NSString * const kHPPPLayoutAssetPositionKey = @"kHPPPLayoutAssetPositionKey";
NSString * const kHPPPLayoutHorizontalPositionKey = @"kHPPPLayoutHorizontalPositionKey";
NSString * const kHPPPLayoutVerticalPositionKey = @"kHPPPLayoutVerticalPositionKey";
NSString * const kHPPPLayoutShouldRotateKey = @"kHPPPLayoutShouldRotateKey";

- (id)initWithCoder:(NSCoder *)decoder
{
    id asset = [self decodeAssetWithCoder:decoder];
    
    if ([asset isKindOfClass:[UIImage class]]) {
        self = [super initWithImage:asset];
    } else if ([asset isKindOfClass:[NSArray class]]) {
        self = [super initWithImages:asset];
    } else if ([asset isKindOfClass:[NSData class]]) {
        self = [super initWithData:asset];
    }

    if (self) {
        self.layout = [self decodeLayoutWithCoder:decoder];
    }
    
    return self;
}


- (id)decodeAssetWithCoder:(NSCoder *)decoder
{
    id printAsset = [decoder decodeObjectForKey:kHPPPPrintAssetKey];
    
    // Need this for backward compatibility.
    // Old way was to store jobs as NSData representing single image.
    if ([printAsset isKindOfClass:[NSData class]]) {
        return printAsset;
    }
    
    // New way is to story array of NSData for one or more images.
    NSArray *imagesAsData = printAsset;
    NSMutableArray *imagesAsImage = [NSMutableArray array];
    for (NSData *data in imagesAsData) {
        UIImage *image = [UIImage imageWithData:data];
        [imagesAsImage addObject:image];
    }
    NSArray *images = imagesAsImage;
    
    return images;
}

- (MPLayout *)decodeLayoutWithCoder:(NSCoder *)decoder
{
    MPLayout *layout = nil;
    NSString *layoutType;
    id rawType = [decoder containsValueForKey:kHPPPLayoutTypeKey] ? [decoder decodeObjectForKey:kHPPPLayoutTypeKey] : nil;
    
    if (nil == rawType) {
        layout = [decoder decodeObjectForKey:kHPPPLayoutKey];
    } else {
        // backward compatibility
        if( [rawType isKindOfClass:[NSNumber class]] ) {
            int type = [rawType intValue];
            switch (type) {
                case 0:
                    layoutType = [MPLayoutFill layoutType];
                    break;
                    
                case 1:
                case 3:
                    layoutType = [MPLayoutFit layoutType];
                    break;
                    
                case 2:
                    layoutType = [MPLayoutStretch layoutType];
                    break;
                    
                default:
                    MPLogError(@"Unrecognized layout type: %d", type);
                    layoutType = nil;
                    break;
            }
        } else if( [rawType isKindOfClass:[NSString class]] ) {
            layoutType = [rawType stringByReplacingOccurrencesOfString:@"HPPP" withString:@"MP"];
        }
        
        if( layoutType ) {
            MPLayoutOrientation orientation = [decoder containsValueForKey:kHPPPLayoutOrientationKey] ? [[decoder decodeObjectForKey:kHPPPLayoutOrientationKey] intValue] : MPLayoutOrientationBestFit;
            CGRect positionRect = [decoder containsValueForKey:kHPPPLayoutPositionKey] ? [decoder decodeCGRectForKey:kHPPPLayoutPositionKey] : [MPLayout completeFillRectangle];
            float borderInches = [decoder containsValueForKey:kHPPPLayoutBorderInchesKey] ? [decoder decodeFloatForKey:kHPPPLayoutBorderInchesKey] : 0.0;
            
            layout = [MPLayoutFactory layoutWithType:layoutType orientation:orientation assetPosition:positionRect];
            layout.borderInches = borderInches;
            
            if( [MPLayoutFit layoutType] == layoutType ) {
                MPLayoutFit *layoutFit = (MPLayoutFit *)layout;
                
                MPLayoutHorizontalPosition horizontalPosition = [decoder containsValueForKey:kHPPPLayoutHorizontalPositionKey] ? [[decoder decodeObjectForKey:kHPPPLayoutHorizontalPositionKey] intValue] : MPLayoutHorizontalPositionMiddle;
                MPLayoutVerticalPosition verticalPosition = [decoder containsValueForKey:kHPPPLayoutVerticalPositionKey] ? [[decoder decodeObjectForKey:kHPPPLayoutVerticalPositionKey] intValue] : MPLayoutVerticalPositionMiddle;
                
                layoutFit.horizontalPosition = horizontalPosition;
                layoutFit.verticalPosition = verticalPosition;
            }
        } else {
            MPLogError(@"Unable to decode layout for type %@", rawType);
        }
    }
    
    return layout;
}

@end
