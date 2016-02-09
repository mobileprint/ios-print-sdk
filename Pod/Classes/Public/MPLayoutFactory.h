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

#import <Foundation/Foundation.h>
#import "MPLayout.h"
#import "MPLayoutFit.h"
#import "MPLayoutFill.h"
#import "MPLayoutStretch.h"

@protocol MPLayoutFactoryDelegate;

/*!
 * @abstract Factory class for creating layouts
 */
@interface MPLayoutFactory : NSObject

/*!
 * @abstract Key used for the border inches
 * @description Key is used for options dictionary as well as en/decoding layout to file system
 */
extern NSString * const kMPLayoutBorderInchesKey;

/*!
 * @abstract Key used for the asset position
 * @description Key is used for options dictionary as well as en/decoding layout to file system
 */
extern NSString * const kMPLayoutAssetPositionKey;

/*!
 * @abstract A key for specifying the desired horizontal position of the layout
 * @discussion This key is to be used when calling the layoutWithType:orientation:layoutOptions:
 *  function on the MPLayoutFactoryClass.  Use this key as a key on the layoutOptions dictionary to specify
 *  which MPLayoutHorizontalPosition to use with the layout.
 */
extern NSString * const kMPLayoutHorizontalPositionKey;

/*!
 * @abstract A key for specifying the desired vertical position of the layout
 * @discussion This key is to be used when calling the layoutWithType:orientation:layoutOptions:
 *  function on the MPLayoutFactoryClass.  Use this key as a key on the layoutOptions dictionary to specify
 *  which MPLayoutVerticalPosition to use with the layout.
 */
extern NSString * const kMPLayoutVerticalPositionKey;

/*!
 * @abstract A key for specifying whether or not the layout should rotate content
 * @discussion This key is to be used when calling the layoutWithType:orientation:layoutOptions:
 *  function on the MPLayoutFactoryClass.  Use this key as a key on the layoutOptions dictionary to specify
 *  whether to include a rotation prep step in the layout.
 */
extern NSString * const kMPLayoutShouldRotateKey;

/*!
 * @abstract Creates a layout of the given type
 * @param layoutType The type of layout to create. See MPLayoutType for standard types.
 * @return The layout created or nil if not layout could be created
 */
+ (MPLayout *)layoutWithType:(NSString *)layoutType;

/*!
 * @abstract Creates a layout of the given type and asset position
 * @param layoutType The type of layout to create. See MPLayoutType for standard types.
 * @param orientation The orientation strategy used by the layout
 * @param assetPosition A CGRect of percentage-based values that locates the layout content rectangle on the page
 * @return The layout created or nil if not layout could be created
 */
+ (MPLayout *)layoutWithType:(NSString *)layoutType
                   orientation:(MPLayoutOrientation)orientation
                 assetPosition:(CGRect)assetPosition;

/*!
 * @abstract Creates a layout of the given type and asset position
 * @param layoutType The type of layout to create. See MPLayoutType for standard types.
 * @param orientation The orientation strategy used by the layout
 * @param assetPosition A CGRect of percentage-based values that locates the layout content rectangle on the page
 * @param shouldRotate Indicates whether to include rotation in the layout logic
 * @return The layout created or nil if not layout could be created
 */
+ (MPLayout *)layoutWithType:(NSString *)layoutType
                 orientation:(MPLayoutOrientation)orientation
               assetPosition:(CGRect)assetPosition
                shouldRotate:(BOOL)shouldRotate;

/*!
 * @abstract Creates a layout of the given type and asset position
 * @param layoutType The type of layout to create. See MPLayoutType for standard types.
 * @param orientation The orientation strategy used by the layout
 * @param layoutOptions A dictionary of layout options.  Currently, the two supported dictionary keys are
 *  kMPLayoutHorizontalPositionKey and kMPLayoutVerticalPositionKey, and these two keys are only supported
 *  by the MPLayoutTypeFit layout type.
 * @return The layout created or nil if not layout could be created
 */
+ (MPLayout *)layoutWithType:(NSString *)layoutType
                   orientation:(MPLayoutOrientation)orientation
                 layoutOptions:(NSDictionary *)layoutOptions;

/*!
 * @abstract Used to persist the layout
 * @discussion Typically this method is used with the NSCoder protocol to save the layout to the file system
 */
+ (void)encodeLayout:(MPLayout *)layout WithCoder:(NSCoder *)encoder;

/*!
 * @abstract Used to restore the layout
 * @discussion Typically this method is used with the NSCoder protocol to retrieve the layout to the file system
 */
+ (id)initLayoutWithCoder:(NSCoder *)decoder;

/*!
 * @abstract Used to add a custom layout provider
 */
+ (void)addDelegate:(id<MPLayoutFactoryDelegate>)delegate;

/*!
 * @abstract Used to remove a custom layout provider
 */
+ (void)removeDelegate:(id<MPLayoutFactoryDelegate>)delegate;

@end

/*!
 * @abstract This protocol allows for extending the layout factory with custom layout types
 * @seealso MPLayoutFactory
 */
@protocol MPLayoutFactoryDelegate <NSObject>

@optional

/*!
 * @abstract Creates a layout of the given type
 * @param layoutType The type of layout to create
 * @return The layout created or nil if not layout could be created
 */
- (MPLayout *)layoutWithType:(NSString *)layoutType;

/*!
 * @abstract Creates a layout of the given type and asset position
 * @param layoutType The type of layout to create
 * @param orientation The orientation strategy used by the layout
 * @param assetPosition A CGRect of percentage-based values that locates the layout content rectangle on the page
 * @return The layout created or nil if not layout could be created
 */
- (MPLayout *)layoutWithType:(NSString *)layoutType
                   orientation:(MPLayoutOrientation)orientation
                 assetPosition:(CGRect)assetPosition;

/*!
 * @abstract Creates a layout of the given type and asset position
 * @param layoutType The type of layout to create
 * @param orientation The orientation strategy used by the layout
 * @param assetPosition A CGRect of percentage-based values that locates the layout content rectangle on the page
 * @param shouldRotate Indicates whether the layout should include rotation step
 * @return The layout created or nil if not layout could be created
 */
- (MPLayout *)layoutWithType:(NSString *)layoutType
                 orientation:(MPLayoutOrientation)orientation
               assetPosition:(CGRect)assetPosition
                shouldRotate:(BOOL)shouldRotate;

/*!
 * @abstract Creates a layout of the given type and asset position
 * @param layoutType The type of layout to create
 * @param orientation The orientation strategy used by the layout
 * @param layoutOptions A dictionary of layout options.
 * @return The layout created or nil if not layout could be created
 */
- (MPLayout *)layoutWithType:(NSString *)layoutType
                   orientation:(MPLayoutOrientation)orientation
                 layoutOptions:(NSDictionary *)layoutOptions;

@end

