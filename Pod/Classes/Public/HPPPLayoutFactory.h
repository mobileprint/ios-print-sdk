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
#import "HPPPLayout.h"
#import "HPPPLayoutFit.h"
#import "HPPPLayoutFill.h"
#import "HPPPLayoutStretch.h"

@protocol HPPPLayoutFactoryDelegate;

/*!
 * @abstract Factory class for creating layouts
 */
@interface HPPPLayoutFactory : NSObject

/*!
 * @abstract Key used for the border inches
 * @description Key is used for options dictionary as well as en/decoding layout to file system
 */
extern NSString * const kHPPPLayoutBorderInchesKey;

/*!
 * @abstract Key used for the asset position
 * @description Key is used for options dictionary as well as en/decoding layout to file system
 */
extern NSString * const kHPPPLayoutAssetPositionKey;

/*!
 * @abstract Creates a layout of the given type
 * @param layoutType The type of layout to create. See HPPPLayoutType for standard types.
 * @return The layout created or nil if not layout could be created
 */
+ (HPPPLayout *)layoutWithType:(NSString *)layoutType;

/*!
 * @abstract Creates a layout of the given type and asset position
 * @param layoutType The type of layout to create. See HPPPLayoutType for standard types.
 * @param orientation The orientation strategy used by the layout
 * @param assetPosition A CGRect of percentage-based values that locates the layout content rectangle on the page
 * @return The layout created or nil if not layout could be created
 */
+ (HPPPLayout *)layoutWithType:(NSString *)layoutType
                   orientation:(HPPPLayoutOrientation)orientation
                 assetPosition:(CGRect)assetPosition;

/*!
 * @abstract Creates a layout of the given type and asset position
 * @param layoutType The type of layout to create. See HPPPLayoutType for standard types.
 * @param orientation The orientation strategy used by the layout
 * @param layoutOptions A dictionary of layout options.  Currently, the two supported dictionary keys are
 *  kHPPPLayoutHorizontalPositionKey and kHPPPLayoutVerticalPositionKey, and these two keys are only supported
 *  by the HPPPLayoutTypeFit layout type.
 * @return The layout created or nil if not layout could be created
 */
+ (HPPPLayout *)layoutWithType:(NSString *)layoutType
                   orientation:(HPPPLayoutOrientation)orientation
                 layoutOptions:(NSDictionary *)layoutOptions;

/*!
 * @abstract Used to persist the layout
 * @discussion Typically this method is used with the NSCoder protocol to save the layout to the file system
 */
+ (void)encodeLayout:(HPPPLayout *)layout WithCoder:(NSCoder *)encoder;

/*!
 * @abstract Used to restore the layout
 * @discussion Typically this method is used with the NSCoder protocol to retrieve the layout to the file system
 */
+ (id)initLayoutWithCoder:(NSCoder *)decoder;

/*!
 * @abstract Used to add a custom layout provider
 */
+ (void)addDelegate:(id<HPPPLayoutFactoryDelegate>)delegate;

/*!
 * @abstract Used to remove a custom layout provider
 */
+ (void)removeDelegate:(id<HPPPLayoutFactoryDelegate>)delegate;

@end

/*!
 * @abstract This protocol allows for extending the layout factory with custom layout types
 * @seealso HPPPLayoutFactory
 */
@protocol HPPPLayoutFactoryDelegate <NSObject>

@optional
/*!
 * @abstract Creates a layout of the given type
 * @param layoutType The type of layout to create
 * @return The layout created or nil if not layout could be created
 */
- (HPPPLayout *)layoutWithType:(NSString *)layoutType;

/*!
 * @abstract Creates a layout of the given type and asset position
 * @param layoutType The type of layout to create
 * @param orientation The orientation strategy used by the layout
 * @param assetPosition A CGRect of percentage-based values that locates the layout content rectangle on the page
 * @return The layout created or nil if not layout could be created
 */
- (HPPPLayout *)layoutWithType:(NSString *)layoutType
                   orientation:(HPPPLayoutOrientation)orientation
                 assetPosition:(CGRect)assetPosition;

/*!
 * @abstract Creates a layout of the given type and asset position
 * @param layoutType The type of layout to create
 * @param orientation The orientation strategy used by the layout
 * @param layoutOptions A dictionary of layout options.
 * @return The layout created or nil if not layout could be created
 */
- (HPPPLayout *)layoutWithType:(NSString *)layoutType
                   orientation:(HPPPLayoutOrientation)orientation
                 layoutOptions:(NSDictionary *)layoutOptions;

@end

