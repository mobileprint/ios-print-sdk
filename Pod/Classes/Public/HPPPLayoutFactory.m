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

static NSMutableArray *factoryDelegates = nil;

+ (HPPPLayout *)layoutWithType:(int)layoutType
{
    HPPPLayout *layout = [HPPPLayoutFactory layoutWithType:layoutType orientation:HPPPLayoutOrientationBestFit assetPosition:[HPPPLayout completeFillRectangle] allowContentRotation:YES];
    
    if( nil == layout  &&  nil != factoryDelegates) {
        for (id<HPPPLayoutFactoryDelegate> delegate in factoryDelegates) {
            if( [delegate respondsToSelector:@selector(layoutWithType:)] ) {
                layout = [delegate layoutWithType:layoutType];
                if (layout) {
                    break;
                }
            }
        }
    }
    
    return layout;
}

+ (HPPPLayout *)layoutWithType:(int)layoutType
                   orientation:(HPPPLayoutOrientation)orientation
                 assetPosition:(CGRect)assetPosition
          allowContentRotation:(BOOL)allowRotation
{
    HPPPLayout *layout = nil;
    
    if (HPPPLayoutTypeFill == layoutType || HPPPLayoutTypeDefault == layoutType) {
        layout = [[HPPPLayoutFill alloc] initWithOrientation:orientation assetPosition:assetPosition allowContentRotation:allowRotation];
    } else if (HPPPLayoutTypeFit == layoutType) {
        HPPPLayoutFit *layoutFit = [[HPPPLayoutFit alloc] initWithOrientation:orientation assetPosition:assetPosition allowContentRotation:allowRotation];
        layoutFit.horizontalPosition = HPPPLayoutHorizontalPositionMiddle;
        layoutFit.verticalPosition = HPPPLayoutVerticalPositionMiddle;
        layout = layoutFit;
    } else if (HPPPLayoutTypeStretch == layoutType) {
        layout = [[HPPPLayoutStretch alloc] initWithOrientation:orientation assetPosition:assetPosition allowContentRotation:allowRotation];
    } else {
        if( nil != factoryDelegates) {
            for (id<HPPPLayoutFactoryDelegate> delegate in factoryDelegates) {
                if( [delegate respondsToSelector:@selector(layoutWithType:orientation:assetPosition:allowContentRotation:)] ) {
                    layout = [delegate layoutWithType:layoutType
                                          orientation:orientation
                                        assetPosition:assetPosition
                                 allowContentRotation:allowRotation];
                    if (layout) {
                        break;
                    }
                }
            }
        }
    }
    
    if (nil == layout) {
        HPPPLogWarn(@"Unable to create a layout using type %u", layoutType);
    }
    
    return layout;
}

+ (HPPPLayout *)layoutWithType:(int)layoutType
                   orientation:(HPPPLayoutOrientation)orientation
                 layoutOptions:(NSDictionary *)layoutOptions
          allowContentRotation:(BOOL)allowRotation
{
    HPPPLayout *layout = nil;
    
    if (HPPPLayoutTypeFit == layoutType) {
        HPPPLayoutFit *layoutFit = [[HPPPLayoutFit alloc] initWithOrientation:orientation assetPosition:[HPPPLayout completeFillRectangle] allowContentRotation:allowRotation];
        
        if( nil != layoutOptions ) {
            if( [layoutOptions objectForKey:kHPPPLayoutHorizontalPositionKey] ) {
                layoutFit.horizontalPosition = [[layoutOptions objectForKey:kHPPPLayoutHorizontalPositionKey] intValue];
            }
            
            if( [layoutOptions objectForKey:kHPPPLayoutVerticalPositionKey] ) {
                layoutFit.verticalPosition = [[layoutOptions objectForKey:kHPPPLayoutVerticalPositionKey] intValue];
            }
        }
        
        layout = layoutFit;
    } else {
        if( nil != factoryDelegates) {
            for (id<HPPPLayoutFactoryDelegate> delegate in factoryDelegates) {
                if( [delegate respondsToSelector:@selector(layoutWithType:orientation:layoutOptions:allowContentRotation:)] ) {
                    layout = [delegate layoutWithType:layoutType
                                          orientation:orientation
                                        layoutOptions:layoutOptions
                                 allowContentRotation:allowRotation];
                    if (layout) {
                        break;
                    }
                }
            }
        }

        if( nil == layout ) {
            HPPPLogWarn(@"Layout options are only supported by HPPPLayoutTypeFit");
        }
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

        if( HPPPLayoutTypeFit == type ) {
            HPPPLayoutFit *layoutFit = (HPPPLayoutFit*)layout;
            [encoder encodeObject:[NSNumber numberWithInt:layoutFit.horizontalPosition] forKey:kHPPPLayoutHorizontalPositionKey];
            [encoder encodeObject:[NSNumber numberWithInt:layoutFit.verticalPosition] forKey:kHPPPLayoutVerticalPositionKey];
        }
    }
}

+ (id)initLayoutWithCoder:(NSCoder *)decoder
{
    HPPPLayoutType type = [decoder containsValueForKey:kHPPPLayoutTypeKey] ? [[decoder decodeObjectForKey:kHPPPLayoutTypeKey] intValue] : HPPPLayoutTypeDefault;
    HPPPLayoutOrientation orientation = [decoder containsValueForKey:kHPPPLayoutOrientationKey] ? [[decoder decodeObjectForKey:kHPPPLayoutOrientationKey] intValue] : HPPPLayoutOrientationBestFit;
    CGRect positionRect = [decoder containsValueForKey:kHPPPLayoutPositionKey] ? [decoder decodeCGRectForKey:kHPPPLayoutPositionKey] : [HPPPLayout completeFillRectangle];
    BOOL allowRotation = [decoder containsValueForKey:kHPPPLayoutPositionKey] ? [decoder decodeBoolForKey:kHPPPLayoutAllowRotationKey] : YES;
    
    HPPPLayout *layout = [self layoutWithType:type orientation:orientation assetPosition:positionRect allowContentRotation:allowRotation];
 
    if( HPPPLayoutTypeFit == type ) {
        HPPPLayoutFit *layoutFit = (HPPPLayoutFit *)layout;

        HPPPLayoutHorizontalPosition horizontalPosition = [decoder containsValueForKey:kHPPPLayoutHorizontalPositionKey] ? [[decoder decodeObjectForKey:kHPPPLayoutHorizontalPositionKey] intValue] : HPPPLayoutHorizontalPositionMiddle;
        HPPPLayoutVerticalPosition verticalPosition = [decoder containsValueForKey:kHPPPLayoutVerticalPositionKey] ? [[decoder decodeObjectForKey:kHPPPLayoutVerticalPositionKey] intValue] : HPPPLayoutVerticalPositionMiddle;

        layoutFit.horizontalPosition = horizontalPosition;
        layoutFit.verticalPosition = verticalPosition;
    }
    
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

+ (void)addDelegate:(id<HPPPLayoutFactoryDelegate>)delegate
{
    if( nil == factoryDelegates ) {
        factoryDelegates = [[NSMutableArray alloc] initWithObjects:delegate, nil];
    } else {
        [factoryDelegates addObject:delegate];
    }
}

+ (void)removeDelegate:(id<HPPPLayoutFactoryDelegate>)delegate
{
    if( nil != factoryDelegates ) {
        [factoryDelegates removeObject:delegate];
    }
}

@end
