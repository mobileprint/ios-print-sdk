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
#import <UIKit/UIKit.h>

/*!
 * @abstract Represents the paper used to print
 * @discussion This class represents the paper used by the printer. It includes both the size of the media (e.g. 4 x 6 inch paper) as well as the type (e.g. photo paper).
 */
@interface HPPPPaper : NSObject

/*!
 * @abstract List of default supported paper sizes
 * @const HPPPPaperSize4x5 4" by 5" photo sticker media
 * @const HPPPPaperSize4x6 4" by 6" photo paper
 * @const HPPPPaperSize5x7 5" by 7" photo paper
 * @const HPPPPaperSizeLetter Standard 8.5" x 11" letter paper
 * @const HPPPPaperSizeA4 Standard 210mm x 297mm letter paper
 * @const HPPPPaperSizeA5 Standard 148mm x 210mm
 * @const HPPPPaperSizeA6 Standard 105mm x 148mm
 * @const HPPPPaperSizeCustom Used to indicate last enum value used by the print library. Apps can register custom paper size ID using any value greater than HPPPPaperSizeCustom
 */
typedef enum {
    HPPPPaperSize4x5,
    HPPPPaperSize4x6,
    HPPPPaperSize5x7,
    HPPPPaperSizeLetter,
    HPPPPaperSizeA4,
    HPPPPaperSizeA5,
    HPPPPaperSizeA6,
    HPPPPaperSize10x13,
    HPPPPaperSize10x15,
    HPPPPaperSize13x18,
    HPPPPaperSizeCustom
} HPPPPaperSize;

/*!
 * @abstract List of default supported paper types
 * @const HPPPPaperTypePlain Plain paper
 * @const HPPPPaperTypePhoto Photo paper
 */
typedef enum {
    HPPPPaperTypePlain,
    HPPPPaperTypePhoto
} HPPPPaperType;

extern NSString * const kHPPPPaperSizeIdKey;
extern NSString * const kHPPPPaperSizeTitleKey;
extern NSString * const kHPPPPaperTypeIdKey;
extern NSString * const kHPPPPaperWidthKey;
extern NSString * const kHPPPPaperHeightKey;
extern NSString * const kHPPPPaperPrinterWidthKey;
extern NSString * const kHPPPPaperPrinterHeightKey;

/*!
 * @abstract Label to display for the paper size
 */
@property (nonatomic, strong) NSString *sizeTitle;

/*!
 * @abstract Label to display for the paper type
 */
@property (nonatomic, strong) NSString *typeTitle;

/*!
 * @abstract Physical width of the paper in inches
 */
@property (nonatomic, assign) float width;

/*!
 * @abstract Physical height of the paper in inches
 */
@property (nonatomic, assign) float height;

/*!
 * @abstract @link PaperSize @/link used by this paper
 * @seealso PaperSize
 */
@property (nonatomic, assign) NSUInteger paperSize;

/*!
 * @abstract @link PaperType @/link used by this paper
 * @seealso PaperType
 */
@property (nonatomic, assign) NSUInteger paperType;

/*!
 * @abstract Initializer using enums
 * @param paperSize The size of the paper
 * @param paperType The type of the paper
 * @seealso PaperSize
 * @seealso PaperType
 * @returns The initialized HPPPPaper object
 */
- (id)initWithPaperSize:(NSUInteger)paperSize paperType:(NSUInteger)paperType;


/*!
 * @abstract Initializer using string titles
 * @param paperSize The title of the paper size
 * @param paperType The title of the paper type
 * @seealso titleFromSize:
 * @seealso titleFromType:
 * @returns The initialized HPPPPaper object
 */
- (id)initWithPaperSizeTitle:(NSString *)paperSizeTitle paperTypeTitle:(NSString *)paperTypeTitle;

/*!
 * @abstract Creates a string for the paper width
 * @returns Paper width as a string suitable for display
 */
- (NSString *)paperWidthTitle;

/*!
 * @abstract Creates a string for the paper height
 * @returns Paper height as a string suitable for display
 */
- (NSString *)paperHeightTitle;

/*!
 * @abstract Creates the paper size to be used by AirPrint
 * @returns A reference paper size to be used during the paper size selection process
 */
- (CGSize)printerPaperSize;

/*!
 * @abstract Retrieves the title for a given paper size
 * @discussion This method asserts that the size given is a valid paper size. An exception is raised if an invalid size is passed.
 * @returns Display title for the paper size
 * @seealso PaperSize
 * @seealso sizeFromTitle:
 */
+ (NSString *)titleFromSize:(NSUInteger)paperSize;

/*!
 * @abstract Retrieves the paper size for a given size title
 * @description This method asserts that the string given is a valid paper size. An exception is raised if an invalid string is passed.
 * @returns @link PaperSize @/link for the size title
 * @seealso PaperSize
 * @seealso titleFromSize:
 */
+ (NSUInteger)sizeFromTitle:(NSString *)paperSizeTitle;

/*!
 * @abstract Retrieves the title for a given paper type
 * @description This method asserts that the type given is a valid paper type. An exception is raised if an invalid type is passed.
 * @returns Display title for the paper type
 * @seealso PaperType
 * @seealso typeFromTitle:
 */
+ (NSString *)titleFromType:(NSUInteger)paperType;

/*!
 * @abstract Retrieves the paper type for a given type title
 * @description This method asserts that the string given is a valid paper type. An exception is raised if an invalid string is passed.
 * @returns @link PaperType @/link for the type title
 * @seealso PaperType
 * @seealso titleFromType:
 */
+ (NSUInteger)typeFromTitle:(NSString *)paperTypeTitle;

+ (NSArray *)availablePapers;
+ (BOOL)registerSize:(NSDictionary *)info;
+ (BOOL)registerType:(NSDictionary *)info;
+ (BOOL)associatePaperSize:(NSUInteger)sizeId withType:(NSUInteger)typeId;

@end
