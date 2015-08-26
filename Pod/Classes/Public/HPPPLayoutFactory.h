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

@protocol HPPPLayoutFactoryDelegate;

/*!
 * @abstract Factory class for creating layouts
 */
@interface HPPPLayoutFactory : NSObject

/*!
 * @abstract List of supported layout types
 * @const HPPPLayoutTypeFill Specifies a layout that uses the minimum content size possible that completely fills the page and maintains the aspect ratio, i.e. fills the page with the content
 * @const HPPPLayoutTypeFit Specifies a layout that uses the maximum content size possible without cropping or changing the aspect ratio, i.e. fits the content to the page
 * @const HPPPLayoutTypeStretch Specifies a layout that exactly fills the content rectangle by reducing or enlarging the image asset and changing the aspect ration as required.
 * @const HPPPLayoutTypeDefault Indicates that the default layout should be used
 * @const HPPPLayoutTypeUnknown Indicates an unknown or unspecfied layout
 */
typedef enum {
    HPPPLayoutTypeFill,
    HPPPLayoutTypeFit,
    HPPPLayoutTypeStretch,
    HPPPLayoutTypeDefault,
    HPPPLayoutTypeUnknown
} HPPPLayoutType;

/*!
 * @abstract Creates a layout of the given type
 * @param layoutType The type of layout to create. See HPPPLayoutType for standard types.
 * @return The layout created or nil if not layout could be created
 * @seealso HPPPLayoutType
 */
+ (HPPPLayout *)layoutWithType:(int)layoutType;

/*!
 * @abstract Creates a layout of the given type and asset position
 * @param layoutType The type of layout to create. See HPPPLayoutType for standard types.
 * @param orientation The orientation strategy used by the layout
 * @param assetPosition A CGRect of percentage-based values that locates the layout content rectangle on the page
 * @param allowRotation A boolean specifying whether or not content is allowed to be rotated to optimize the layout
 * @return The layout created or nil if not layout could be created
 * @seealso HPPPLayoutType
 */
+ (HPPPLayout *)layoutWithType:(int)layoutType
                   orientation:(HPPPLayoutOrientation)orientation
                 assetPosition:(CGRect)assetPosition
          allowContentRotation:(BOOL)allowRotation;

/*!
 * @abstract Creates a layout of the given type and asset position
 * @param layoutType The type of layout to create. See HPPPLayoutType for standard types.
 * @param orientation The orientation strategy used by the layout
 * @param layoutOptions A dictionary of layout options.  Currently, the two supported dictionary keys are
 *  kHPPPLayoutHorizontalPositionKey and kHPPPLayoutVerticalPositionKey, and these two keys are only supported
 *  by the HPPPLayoutTypeFit layout type.
 * @param allowRotation A boolean specifying whether or not content is allowed to be rotated to optimize the layout
 * @return The layout created or nil if not layout could be created
 * @seealso HPPPLayoutType
 */
+ (HPPPLayout *)layoutWithType:(int)layoutType
                   orientation:(HPPPLayoutOrientation)orientation
                 layoutOptions:(NSDictionary *)layoutOptions
          allowContentRotation:(BOOL)allowRotation;

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

+ (void)addDelegate:(id<HPPPLayoutFactoryDelegate>)delegate;

+ (void)removeDelegate:(id<HPPPLayoutFactoryDelegate>)delegate;

@end

@protocol HPPPLayoutFactoryDelegate <NSObject>

@optional
/*!
 * @abstract Creates a layout of the given type
 * @param layoutType The type of layout to create
 * @return The layout created or nil if not layout could be created
 * @seealso HPPPLayoutType
 */
- (HPPPLayout *)layoutWithType:(int)layoutType;

/*!
 * @abstract Creates a layout of the given type and asset position
 * @param layoutType The type of layout to create
 * @param orientation The orientation strategy used by the layout
 * @param assetPosition A CGRect of percentage-based values that locates the layout content rectangle on the page
 * @param allowRotation A boolean specifying whether or not content is allowed to be rotated to optimize the layout
 * @return The layout created or nil if not layout could be created
 * @seealso HPPPLayoutType
 */
- (HPPPLayout *)layoutWithType:(int)layoutType
                   orientation:(HPPPLayoutOrientation)orientation
                 assetPosition:(CGRect)assetPosition
          allowContentRotation:(BOOL)allowRotation;

/*!
 * @abstract Creates a layout of the given type and asset position
 * @param layoutType The type of layout to create
 * @param orientation The orientation strategy used by the layout
 * @param layoutOptions A dictionary of layout options.
 * @param allowRotation A boolean specifying whether or not content is allowed to be rotated to optimize the layout
 * @return The layout created or nil if not layout could be created
 * @seealso HPPPLayoutType
 */
- (HPPPLayout *)layoutWithType:(int)layoutType
                   orientation:(HPPPLayoutOrientation)orientation
                 layoutOptions:(NSDictionary *)layoutOptions
          allowContentRotation:(BOOL)allowRotation;

@end

