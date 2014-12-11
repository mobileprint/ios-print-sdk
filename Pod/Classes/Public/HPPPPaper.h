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

#define TYPE_PLAIN_TITLE @"Plain Paper"
#define TYPE_PHOTO_TITLE @"Photo Paper"

#define SIZE_4_X_5_TITLE @"4 x 5"
#define SIZE_4_X_6_TITLE @"4 x 6"
#define SIZE_5_X_7_TITLE @"5 x 7"
#define SIZE_LETTER_TITLE @"8.5 x 11"

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

@interface HPPPPaper : NSObject

@property (nonatomic, strong) NSString *sizeTitle;
@property (nonatomic, strong) NSString *typeTitle;
@property (nonatomic, assign) float width;
@property (nonatomic, assign) float height;
@property (nonatomic, assign) PaperSize paperSize;
@property (nonatomic, assign) PaperType paperType;

- (id)initWithPaperSize:(PaperSize)paperSize paperType:(PaperType)paperType;

- (id)initWithPaperSizeTitle:(NSString *)paperSizeTitle paperTypeTitle:(NSString *)papeTypeTitle;

- (NSString *)paperWidthTitle;
- (NSString *)paperHeightTitle;

@end
