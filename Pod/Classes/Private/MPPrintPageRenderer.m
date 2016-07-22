//
// HP Inc.
// All rights reserved.
//
// This file, its contents, concepts, methods, behavior, and operation
// (collectively the "Software") are protected by trade secret, patent,
// and copyright laws. The use of the Software is governed by a license
// agreement. Disclosure of the Software to third parties, in any form,
// in whole or in part, is expressly prohibited except as authorized by
// the license agreement.
//

#import "MPPrintPageRenderer.h"
#import "MP.h"
#import "MPPaper.h"
#import "UIImage+MPResize.h"

@interface MPPrintPageRenderer()

@property (readonly, strong, nonatomic) MPLayout *layout;
@property (readonly, strong, nonatomic) MPPaper *paper;
@property (readonly, strong, nonatomic) NSArray *images;
@property (readonly, assign, nonatomic) NSInteger numberOfCopies;

@end

@implementation MPPrintPageRenderer

- (id)initWithImages:(NSArray *)images layout:(MPLayout *)layout paper:(MPPaper *)paper copies:(NSInteger)copies
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
    
    CGSize contentPaperSize = CGSizeMake(self.paper.width * kMPPointsPerInch, self.paper.height * kMPPointsPerInch);
    CGSize printerPaperSize = [self.paper printerPaperSize];
    CGSize renderContentSize = CGSizeMake(contentRect.size.width * contentPaperSize.width / printerPaperSize.width, contentRect.size.height * contentPaperSize.height / printerPaperSize.height);
    CGRect insetContentRect = CGRectInset(CGRectMake(contentRect.origin.x, contentRect.origin.y, renderContentSize.width, renderContentSize.height), self.layout.borderInches * kMPPointsPerInch, self.layout.borderInches * kMPPointsPerInch);
    
    MPLogDebug(@"~~~~~~~~~~~~~~~~~~~~~");
    MPLogDebug(@"PRINT PAGE RENDERER");
    MPLogDebug(@"~~~~~~~~~~~~~~~~~~~~~");
    [[MPLogger sharedInstance] logSize:image.size withName:@"IMAGE"];
    [[MPLogger sharedInstance] logRect:contentRect withName:@"CONTENT"];
    [[MPLogger sharedInstance] logSize:CGSizeMake(self.paper.width, self.paper.height) withName:@"PAPER (inches)"];
    [[MPLogger sharedInstance] logSize:contentPaperSize withName:@"PAPER (points)"];
    [[MPLogger sharedInstance] logSize:printerPaperSize withName:@"PRINTER PAPER"];
    [[MPLogger sharedInstance] logSize:renderContentSize withName:@"RENDER SIZE"];
    [[MPLogger sharedInstance] logRect:insetContentRect withName:@"INSET"];
    MPLogDebug(@"~~~~~~~~~~~~~~~~~~~~~");
    
    [self.layout drawContentImage:image inRect:insetContentRect];
}

@end
