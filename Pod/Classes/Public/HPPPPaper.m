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

#import "HPPPPaper.h"
#import "NSBundle+Localizable.h"

#define MAXIMUM_ENLARGEMENT 1.25f
#define INVALID_PAPER -1;
#define TYPE_PLAIN_TITLE HPPPLocalizedString(@"Plain Paper", @"Option of paper type")
#define TYPE_PHOTO_TITLE HPPPLocalizedString(@"Photo Paper", @"Option of paper type")
#define SIZE_4_X_5_TITLE @"4 x 5"
#define SIZE_4_X_6_TITLE @"4 x 6"
#define SIZE_5_X_7_TITLE @"5 x 7"
#define SIZE_LETTER_TITLE @"8.5 x 11"

@implementation HPPPPaper

- (id)initWithPaperSize:(PaperSize)paperSize paperType:(PaperType)paperType
{
    self = [super init];
    
    if (self) {
        self.paperSize = paperSize;
        self.paperType = paperType;
        self.typeTitle = [HPPPPaper titleFromType:paperType];
        self.sizeTitle = [HPPPPaper titleFromSize:paperSize];
        switch (paperSize) {
            case Size4x5:
                self.width = 4.0f;
                self.height = 5.0f;
                break;
            case Size4x6:
                self.width = 4.0f;
                self.height = 6.0f;
                break;
            case Size5x7:
                self.width = 5.0f;
                self.height = 7.0f;
                break;
            case SizeLetter:
                self.width = 8.5f;
                self.height = 11.0f;
                break;
            default:
                NSAssert(NO, @"Unknown paper size (enum): %ul", paperSize);
        };
    }
    
    return self;
}

- (id)initWithPaperSizeTitle:(NSString *)paperSizeTitle paperTypeTitle:(NSString *)paperTypeTitle;
{
    return [self initWithPaperSize:[HPPPPaper sizeFromTitle:paperSizeTitle] paperType:[HPPPPaper typeFromTitle:paperTypeTitle]];
}

+ (NSString *)titleFromSize:(PaperSize)paperSize
{
    NSString * paperSizeTitle = nil;
    
    switch (paperSize) {
        case Size4x5:
            paperSizeTitle = SIZE_4_X_5_TITLE;
            break;
        case Size4x6:
            paperSizeTitle = SIZE_4_X_6_TITLE;
            break;
        case Size5x7:
            paperSizeTitle = SIZE_5_X_7_TITLE;
            break;
        case SizeLetter:
            paperSizeTitle = SIZE_LETTER_TITLE;
            break;
        default:
            NSAssert(NO, @"Unknown paper size (enum): %ul", paperSize);
    }
    
    return paperSizeTitle;
}

+ (PaperSize)sizeFromTitle:(NSString *)paperSizeTitle
{
    PaperSize paperSize = INVALID_PAPER;
    
    if ([paperSizeTitle isEqualToString:SIZE_4_X_5_TITLE]) {
        paperSize = Size4x5;
    } else if ([paperSizeTitle isEqualToString:SIZE_4_X_6_TITLE]) {
        paperSize = Size4x6;
    } else if ([paperSizeTitle isEqualToString:SIZE_5_X_7_TITLE]) {
        paperSize = Size5x7;
    } else if ([paperSizeTitle isEqualToString:SIZE_LETTER_TITLE]) {
        paperSize = SizeLetter;
    } else {
        NSAssert(NO, @"Unknown paper size: %@", paperSizeTitle);
    }
    
    return paperSize;
}

+ (NSString *)titleFromType:(PaperType)paperType
{
    NSString * paperTypeTitle = nil;
    
    switch (paperType) {
        case Plain:
            paperTypeTitle = TYPE_PLAIN_TITLE;
            break;
        case Photo:
            paperTypeTitle = TYPE_PHOTO_TITLE;
            break;
        default:
            NSAssert(NO, @"Unknown paper type (enum): %ul", paperType);
    }
    
    return paperTypeTitle;
}

+ (PaperType)typeFromTitle:(NSString *)paperTypeTitle
{
    PaperType paperType = INVALID_PAPER;
    
    if ([paperTypeTitle isEqualToString:TYPE_PLAIN_TITLE]) {
        paperType = Plain;
    } else if ([paperTypeTitle isEqualToString:TYPE_PHOTO_TITLE]) {
        paperType = Photo;
    } else {
        NSAssert(NO, @"Unknown paper type: %@", paperTypeTitle);
    }
    
    return paperType;
}

- (NSString *)paperWidthTitle
{
    return [NSNumber numberWithFloat:self.width].stringValue;
}

- (NSString *)paperHeightTitle
{
    return [NSNumber numberWithFloat:self.height].stringValue;
}

- (CGSize)printerPaperSize
{
    CGSize pageSize = CGSizeMake(self.width * 72.0f, self.height * 72.0f);
    
    // 4x5 prints force printing on 8.5x11 paper
    //  ... fool AirPrint into printing from the 4x6 tray.
    if( Size4x5 == self.paperSize )
    {
        pageSize = CGSizeMake(4.0f * 72.0f, 6.0f * 72.0f);
    }
    
    return pageSize;
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"Width %f Height %f\nPaper Size %ul\nPaper Type %ul", self.width, self.height, self.paperSize, self.paperType];
}

@end


