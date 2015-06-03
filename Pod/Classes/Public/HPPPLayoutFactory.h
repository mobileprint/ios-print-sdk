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

@interface HPPPLayoutFactory : NSObject

/*!
 * @abstract List of supported layout types
 * @const HPPPLayoutTypeFill Specifies a layout that uses the minimum content size possible that completely fills the page and maintains the aspect ratio, i.e. fills the page with the content
 * @const HPPPLayoutTypeFit Specifies a layout that uses the maximum content size possible without cropping or changing the aspect ratio, i.e. fits the content to the page
 * @const HPPPLayoutTypeStretch Specifies a layout that exactly fills the content rectangle by reducing or enlarging the image asset and changing the aspect ration as required.
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
 * @param layoutType The type of layout to create
 * @seealso HPPPLayoutType
 */
+ (HPPPLayout *)layoutWithType:(HPPPLayoutType)layoutType;

/*!
 * @abstract Creates a layout of the given type and asset position
 * @param layoutType The type of layout to create
 * @param orientation The orientation strategy used by the layout
 * @param assetPosition A CGRect of percentage-based values that locates the layout content rectangle on the page
 * @seealso HPPPLayoutType
 */
+ (HPPPLayout *)layoutWithType:(HPPPLayoutType)layoutType orientation:(HPPPLayoutOrientation)orientation assetPosition:(CGRect)assetPosition;

// TODO: document!
+ (void)encodeLayout:(HPPPLayout *)layout WithCoder:(NSCoder *)encoder;
+ (id)initLayoutWithCoder:(NSCoder *)decoder;

@end
