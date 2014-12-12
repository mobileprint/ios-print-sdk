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

#define MAXIMUM_ENLARGEMENT 1.25f

@implementation HPPPPaper

- (id)initWithPaperSize:(PaperSize)paperSize paperType:(PaperType)paperType
{
    self = [super init];
    
    if (self) {
        
        self.paperSize = paperSize;
        self.paperType = paperType;
        
        switch (paperType) {
                
            case Plain:
                self.typeTitle = @"Plain Paper";
                break;
            case Photo:
                self.typeTitle = @"Photo Paper";
                break;
            default:
                NSLog(@"Unknown paper type %i", paperSize);
                break;
        };
        
        switch (paperSize) {
                
            case Size4x5:
                
                self.sizeTitle = SIZE_4_X_5_TITLE;
                self.width = 4.0f;
                self.height = 5.0f;
                break;
                
            case Size4x6:
                
                self.sizeTitle = SIZE_4_X_6_TITLE;
                self.width = 4.0f;
                self.height = 6.0f;
                break;
                
            case Size5x7:
                
                self.sizeTitle = SIZE_5_X_7_TITLE;
                self.width = 5.0f;
                self.height = 7.0f;
                break;
                
            case SizeLetter:
                
                self.sizeTitle = SIZE_LETTER_TITLE;
                self.width = 8.5f;
                self.height = 11.0f;
                break;
                
            default:
                NSAssert(NO, @"Unknown paper size");
                NSLog(@"Unknown paper size %i", paperSize);
                break;
        };
        
    }
    
    return self;
}

- (id)initWithPaperSizeTitle:(NSString *)paperSizeTitle paperTypeTitle:(NSString *)papeTypeTitle;
{
    PaperSize paperSize = Size5x7;
    PaperType paperType = Photo;
    
    if([papeTypeTitle isEqualToString:TYPE_PLAIN_TITLE]) {
        paperType = Plain;
    }
    else if ([papeTypeTitle isEqualToString:TYPE_PHOTO_TITLE]) {
        paperType = Photo;
    } else {
        NSAssert(NO, @"Unknown paper type");
    }
    
    if ([paperSizeTitle isEqualToString:SIZE_4_X_5_TITLE]) {
        paperSize = Size4x5;
    }
    else if ([paperSizeTitle isEqualToString:SIZE_4_X_6_TITLE]) {
        paperSize = Size4x6;
    }
    else if([paperSizeTitle isEqualToString:SIZE_5_X_7_TITLE]) {
        paperSize = Size5x7;
    }
    else if([paperSizeTitle isEqualToString:SIZE_LETTER_TITLE]) {
        paperSize = SizeLetter;
    } else {
        NSAssert(NO, @"Unknown paper size");
    }
    
    return [self initWithPaperSize:paperSize paperType:paperType];
}

- (NSString *)paperWidthTitle
{
    return [NSNumber numberWithFloat:self.width].stringValue;
}

- (NSString *)paperHeightTitle
{
    return [NSNumber numberWithFloat:self.height].stringValue;
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"Width %f Height %f\nPrinter Width %f Printer Height %f\nPaper Size %d\nPaper Type %d\nScale %f", self.width, self.height, self.paperSize, self.paperType];
}

@end


