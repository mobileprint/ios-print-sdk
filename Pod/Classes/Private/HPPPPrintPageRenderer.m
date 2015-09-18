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

@property (strong, nonatomic) HPPPLayout *layout;

@end

@implementation HPPPPrintPageRenderer

- (id)initWithImages:(NSArray *)images andLayout:(HPPPLayout *)layout;
{
    self = [super init];
    
    if (self) {
        self.images = images;
        self.layout = layout;
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
    [self.layout drawContentImage:image inRect:contentRect];
}

@end
