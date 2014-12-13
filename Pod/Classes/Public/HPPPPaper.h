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

@interface HPPPPaper : NSObject

typedef enum {
    Size4x5,
    Size4x6,
    Size5x7,
    SizeLetter
} PaperSize;

typedef enum {
    Plain,
    Photo
} PaperType;

@property (nonatomic, strong) NSString *sizeTitle;
@property (nonatomic, strong) NSString *typeTitle;
@property (nonatomic, assign) float width;
@property (nonatomic, assign) float height;
@property (nonatomic, assign) PaperSize paperSize;
@property (nonatomic, assign) PaperType paperType;

- (id)initWithPaperSize:(PaperSize)paperSize paperType:(PaperType)paperType;
- (id)initWithPaperSizeTitle:(NSString *)paperSizeTitle paperTypeTitle:(NSString *)paperTypeTitle;

- (NSString *)paperWidthTitle;
- (NSString *)paperHeightTitle;

+ (NSString *)titleFromSize:(PaperSize)paperSize;
+ (PaperSize)sizeFromTitle:(NSString *)paperSizeTitle;
+ (NSString *)titleFromType:(PaperType)paperType;
+ (PaperType)typeFromTitle:(NSString *)paperTypeTitle;

@end
