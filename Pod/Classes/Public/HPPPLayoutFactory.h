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
 * @param allowRotation A boolean specifying whether or not content is allowed to be rotated to optimize the layout
 * @return The layout created or nil if not layout could be created
 */
+ (HPPPLayout *)layoutWithType:(NSString *)layoutType
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
 */
+ (HPPPLayout *)layoutWithType:(NSString *)layoutType
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
 */
- (HPPPLayout *)layoutWithType:(NSString *)layoutType;

/*!
 * @abstract Creates a layout of the given type and asset position
 * @param layoutType The type of layout to create
 * @param orientation The orientation strategy used by the layout
 * @param assetPosition A CGRect of percentage-based values that locates the layout content rectangle on the page
 * @param allowRotation A boolean specifying whether or not content is allowed to be rotated to optimize the layout
 * @return The layout created or nil if not layout could be created
 */
- (HPPPLayout *)layoutWithType:(NSString *)layoutType
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
 */
- (HPPPLayout *)layoutWithType:(NSString *)layoutType
                   orientation:(HPPPLayoutOrientation)orientation
                 layoutOptions:(NSDictionary *)layoutOptions
          allowContentRotation:(BOOL)allowRotation;

@end

