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

#import "MP.h"
#import "MPLayoutFactory.h"
#import "MPLayoutFill.h"
#import "MPLayoutFit.h"
#import "MPLayoutStretch.h"

@implementation MPLayoutFactory

static NSString * const kMPLayoutKey = @"kMPLayoutKey";
static NSString * const kMPLayoutTypeKey = @"kMPLayoutTypeKey";
static NSString * const kMPLayoutOrientationKey = @"kMPLayoutOrientationKey";
static NSString * const kMPLayoutPositionKey = @"kMPLayoutPositionKey";
static NSString * const kMPLayoutAllowRotationKey = @"kMPLayoutAllowRotationKey";

NSString * const kMPLayoutBorderInchesKey = @"kMPLayoutBorderInchesKey";
NSString * const kMPLayoutAssetPositionKey = @"kMPLayoutAssetPositionKey";
NSString * const kMPLayoutHorizontalPositionKey = @"kMPLayoutHorizontalPositionKey";
NSString * const kMPLayoutVerticalPositionKey = @"kMPLayoutVerticalPositionKey";
NSString * const kMPLayoutShouldRotateKey = @"kMPLayoutShouldRotateKey";

static NSMutableArray *factoryDelegates = nil;

+ (MPLayout *)layoutWithType:(NSString *)layoutType
{
    MPLayout *layout = [MPLayoutFactory layoutWithType:layoutType orientation:MPLayoutOrientationBestFit assetPosition:[MPLayout completeFillRectangle]];
    
    if( nil == layout  &&  nil != factoryDelegates) {
        for (id<MPLayoutFactoryDelegate> delegate in factoryDelegates) {
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

+ (MPLayout *)layoutWithType:(NSString *)layoutType
                   orientation:(MPLayoutOrientation)orientation
                 assetPosition:(CGRect)assetPosition
{
    return [self layoutWithType:layoutType orientation:orientation assetPosition:assetPosition shouldRotate:YES];
}

+ (MPLayout *)layoutWithType:(NSString *)layoutType
                 orientation:(MPLayoutOrientation)orientation
               assetPosition:(CGRect)assetPosition
                shouldRotate:(BOOL)shouldRotate
{
    MPLayout *layout = nil;
    
    if ([[MPLayoutFill layoutType] isEqualToString:layoutType] || nil == layoutType) {
        layout = [[MPLayoutFill alloc] initWithOrientation:orientation assetPosition:assetPosition shouldRotate:shouldRotate];
    } else if ([[MPLayoutFit layoutType] isEqualToString:layoutType]) {
        MPLayoutFit *layoutFit = [[MPLayoutFit alloc] initWithOrientation:orientation assetPosition:assetPosition shouldRotate:shouldRotate];
        layoutFit.horizontalPosition = MPLayoutHorizontalPositionMiddle;
        layoutFit.verticalPosition = MPLayoutVerticalPositionMiddle;
        layout = layoutFit;
    } else if ([[MPLayoutStretch layoutType] isEqualToString:layoutType]) {
        layout = [[MPLayoutStretch alloc] initWithOrientation:orientation assetPosition:assetPosition shouldRotate:shouldRotate];
    } else {
        if( nil != factoryDelegates) {
            for (id<MPLayoutFactoryDelegate> delegate in factoryDelegates) {
                if( [delegate respondsToSelector:@selector(layoutWithType:orientation:assetPosition:)] ) {
                    layout = [delegate layoutWithType:layoutType
                                          orientation:orientation
                                        assetPosition:assetPosition
                              ];
                    if (layout) {
                        break;
                    }
                }
            }
        }
    }
    
    if (nil == layout) {
        MPLogWarn(@"Unable to create a layout using type %@", layoutType);
    }
    
    return layout;
}

+ (MPLayout *)layoutWithType:(NSString *)layoutType
                   orientation:(MPLayoutOrientation)orientation
                 layoutOptions:(NSDictionary *)layoutOptions
{
    MPLayout *layout = nil;
    
    if ([[MPLayoutFit layoutType] isEqualToString:layoutType]) {
    
        CGRect assetPosition = [MPLayout completeFillRectangle];
        BOOL shouldRotate = YES;
        if (layoutOptions) {
            NSDictionary *assetPositionDictionary = [layoutOptions objectForKey:kMPLayoutAssetPositionKey];
            if (assetPositionDictionary) {
                CGRectMakeWithDictionaryRepresentation((__bridge CFDictionaryRef)assetPositionDictionary, &assetPosition);
            }
            
            NSNumber *shouldRotateValue = [layoutOptions objectForKey:kMPLayoutShouldRotateKey];
            if (shouldRotateValue) {
                shouldRotate = [shouldRotateValue boolValue];
            }
        }
        
        MPLayoutFit *layoutFit = [[MPLayoutFit alloc] initWithOrientation:orientation assetPosition:assetPosition shouldRotate:shouldRotate];
        
        if( nil != layoutOptions ) {
            if( [layoutOptions objectForKey:kMPLayoutHorizontalPositionKey] ) {
                layoutFit.horizontalPosition = [[layoutOptions objectForKey:kMPLayoutHorizontalPositionKey] intValue];
            }
            
            if( [layoutOptions objectForKey:kMPLayoutVerticalPositionKey] ) {
                layoutFit.verticalPosition = [[layoutOptions objectForKey:kMPLayoutVerticalPositionKey] intValue];
            }
            
            if( [layoutOptions objectForKey:kMPLayoutBorderInchesKey] ) {
                layoutFit.borderInches = [[layoutOptions objectForKey:kMPLayoutBorderInchesKey] floatValue];
            }
        }
        
        layout = layoutFit;
    } else {
        if( nil != factoryDelegates) {
            for (id<MPLayoutFactoryDelegate> delegate in factoryDelegates) {
                if( [delegate respondsToSelector:@selector(layoutWithType:orientation:layoutOptions:)] ) {
                    layout = [delegate layoutWithType:layoutType
                                          orientation:orientation
                                        layoutOptions:layoutOptions];
                    if (layout) {
                        break;
                    }
                }
            }
        }

        if( nil == layout ) {
            MPLogWarn(@"Layout options are only supported by MPLayoutTypeFit");
        }
    }
    
    if (nil == layout) {
        MPLogWarn(@"Unable to create a layout using type %@", layoutType);
    }
    
    return layout;
}

#pragma mark - NSCoding support

+ (void)encodeLayout:(MPLayout *)layout WithCoder:(NSCoder *)encoder
{
    if ([layout isKindOfClass:[MPLayoutComposite class]]) {
        [encoder encodeObject:layout forKey:kMPLayoutKey];
    } else {
        NSString *type = NSStringFromClass([layout class]);
        
        [encoder encodeObject:type forKey:kMPLayoutTypeKey];
        [encoder encodeObject:[NSNumber numberWithInt:layout.orientation] forKey:kMPLayoutOrientationKey];
        [encoder encodeCGRect:layout.assetPosition forKey:kMPLayoutPositionKey];
        [encoder encodeFloat:layout.borderInches forKey:kMPLayoutBorderInchesKey];
        
        if( [MPLayoutFit layoutType] == type ) {
            MPLayoutFit *layoutFit = (MPLayoutFit*)layout;
            [encoder encodeObject:[NSNumber numberWithInt:layoutFit.horizontalPosition] forKey:kMPLayoutHorizontalPositionKey];
            [encoder encodeObject:[NSNumber numberWithInt:layoutFit.verticalPosition] forKey:kMPLayoutVerticalPositionKey];
        }
    }

}

+ (id)initLayoutWithCoder:(NSCoder *)decoder
{
    MPLayout *layout = nil;
    NSString *layoutType;
    id rawType = [decoder containsValueForKey:kMPLayoutTypeKey] ? [decoder decodeObjectForKey:kMPLayoutTypeKey] : nil;
    
    if (nil == rawType) {
        layout = [decoder decodeObjectForKey:kMPLayoutKey];
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
            layoutType = rawType;
        }
        
        if( layoutType ) {
            MPLayoutOrientation orientation = [decoder containsValueForKey:kMPLayoutOrientationKey] ? [[decoder decodeObjectForKey:kMPLayoutOrientationKey] intValue] : MPLayoutOrientationBestFit;
            CGRect positionRect = [decoder containsValueForKey:kMPLayoutPositionKey] ? [decoder decodeCGRectForKey:kMPLayoutPositionKey] : [MPLayout completeFillRectangle];
            float borderInches = [decoder containsValueForKey:kMPLayoutTypeKey] ? [decoder decodeFloatForKey:kMPLayoutBorderInchesKey] : 0.0;
            
            layout = [self layoutWithType:layoutType orientation:orientation assetPosition:positionRect];
            layout.borderInches = borderInches;
            
            if( [MPLayoutFit layoutType] == layoutType ) {
                MPLayoutFit *layoutFit = (MPLayoutFit *)layout;
                
                MPLayoutHorizontalPosition horizontalPosition = [decoder containsValueForKey:kMPLayoutHorizontalPositionKey] ? [[decoder decodeObjectForKey:kMPLayoutHorizontalPositionKey] intValue] : MPLayoutHorizontalPositionMiddle;
                MPLayoutVerticalPosition verticalPosition = [decoder containsValueForKey:kMPLayoutVerticalPositionKey] ? [[decoder decodeObjectForKey:kMPLayoutVerticalPositionKey] intValue] : MPLayoutVerticalPositionMiddle;
                
                layoutFit.horizontalPosition = horizontalPosition;
                layoutFit.verticalPosition = verticalPosition;
            }
        } else {
            MPLogError(@"Unable to decode layout for type %@", rawType);
        }
    }
    
    return layout;
}

+ (void)addDelegate:(id<MPLayoutFactoryDelegate>)delegate
{
    if( nil == factoryDelegates ) {
        factoryDelegates = [[NSMutableArray alloc] initWithObjects:delegate, nil];
    } else {
        [factoryDelegates addObject:delegate];
    }
}

+ (void)removeDelegate:(id<MPLayoutFactoryDelegate>)delegate
{
    if( nil != factoryDelegates ) {
        [factoryDelegates removeObject:delegate];
    }
}

@end
