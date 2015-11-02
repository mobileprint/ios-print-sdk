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

#import "HPPPPrintPageRenderer.h"
#import "HPPP.h"
#import "HPPPPaper.h"
#import "UIImage+HPPPResize.h"

@interface HPPPPrintPageRenderer()

@property (readonly, strong, nonatomic) HPPPLayout *layout;
@property (readonly, strong, nonatomic) HPPPPaper *paper;
@property (readonly, strong, nonatomic) NSArray *images;
@property (readonly, assign, nonatomic) NSInteger numberOfCopies;

@end

@implementation HPPPPrintPageRenderer

- (id)initWithImages:(NSArray *)images layout:(HPPPLayout *)layout paper:(HPPPPaper *)paper copies:(NSInteger)copies
{
    self = [super init];
    
    if (self) {
        _images = images;
        _layout = layout;
        _paper = paper;
        _numberOfCopies = copies;
    }
    
    return self;
}

- (NSInteger)numberOfPages
{
    return self.numberOfCopies * self.images.count;
}

#pragma mark - UIPrintPageRenderer overrides

- (void)drawContentForPageAtIndex:(NSInteger)index inRect:(CGRect)contentRect
{
    UIImage *image = self.images[(int) (index / self.numberOfCopies)];
    
    CGSize contentPaperSize = CGSizeMake(self.paper.width * kHPPPPointsPerInch, self.paper.height * kHPPPPointsPerInch);
    CGSize printerPaperSize = [self.paper printerPaperSize];
    CGSize renderContentSize = CGSizeMake(contentRect.size.width * contentPaperSize.width / printerPaperSize.width, contentRect.size.height * contentPaperSize.height / printerPaperSize.height);
    CGRect insetContentRect = CGRectInset(CGRectMake(0, 0, renderContentSize.width, renderContentSize.height), self.layout.borderInches * kHPPPPointsPerInch, self.layout.borderInches * kHPPPPointsPerInch);
    
    if ( _layout.orientation == HPPPLayoutOrientationLandscape ) {
        
        // if the image is square
        if ( CGFLOAT_MIN >= fabs(image.size.width-image.size.height) ) {
            image = [image HPPPRotate];
        }
    }
    
    [self.layout drawContentImage:image inRect:insetContentRect];
}

@end
