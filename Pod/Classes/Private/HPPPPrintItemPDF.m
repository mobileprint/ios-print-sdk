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

#import "HPPP.h"
#import "HPPPPrintItemPDF.h"

@interface HPPPPrintItemPDF()

@property (strong, nonatomic) NSData *pdfData;
@property (assign, nonatomic) CGPDFDocumentRef pdfDocument;
@property (strong, nonatomic) NSMutableDictionary *pageImages;

@end

@implementation HPPPPrintItemPDF

#pragma mark - Initialization

- (id)initWithData:(NSData *)data
{
    HPPPPrintItemPDF *item = nil;
    CFDataRef pdfDataRef = (CFDataRef)CFBridgingRetain(data);
    CGDataProviderRef provider = CGDataProviderCreateWithCFData(pdfDataRef);
    CGPDFDocumentRef pdf = CGPDFDocumentCreateWithProvider(provider);
    
    if (pdf) {
        self = [super init];
        if (self) {
            self.pdfData = data;
            self.pdfDocument = pdf;
            self.pageImages = [NSMutableDictionary dictionary];
        }
        item = self;
    } else {
        HPPPLogWarn(@"HPPPPDFPrintItem was initialized with non-PDF data.");
    }
    
    return item;
}

- (void)dealloc
{
    CGPDFDocumentRelease(self.pdfDocument);
}

#pragma mark - Asset attributes

- (id)printAsset
{
    return self.pdfData;
}

- (HPPPPrintRenderer)renderer
{
    return DefaultPrintRenderer;
}

- (NSInteger)numberOfPages
{
    return CGPDFDocumentGetNumberOfPages(self.pdfDocument);
}

- (CGSize)sizeInUnits:(HPPPUnits)units
{
    CGSize size = CGSizeMake(0, 0);
    CGPDFPageRef page = CGPDFDocumentGetPage(self.pdfDocument, 1);
    CGRect pageSize = CGPDFPageGetBoxRect(page, kCGPDFMediaBox);
    if (Pixels == units) {
        size = pageSize.size;
    } else if (Inches == units) {
        size = CGSizeMake(pageSize.size.width / kHPPPPointsPerInch, pageSize.size.height / kHPPPPointsPerInch);
    }
    return size;
}

#pragma mark - Preview image

// The following is adaptaed from:  http://stackoverflow.com/questions/4107850/how-can-i-programatically-generate-a-thumbnail-of-a-pdf-with-the-iphone-sdk
- (UIImage *)previewImageForPage:(NSUInteger)pageNumber
{
    CGSize sizeInPixels = [self sizeInUnits:Pixels];
    
    CGRect aRect = CGRectMake(0, 0, sizeInPixels.width, sizeInPixels.height);
    UIGraphicsBeginImageContext(aRect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSaveGState(context);
    CGContextTranslateCTM(context, 0.0, aRect.size.height);
    CGContextScaleCTM(context, 1.0, -1.0);
    
    CGContextSetGrayFillColor(context, 1.0, 1.0);
    CGContextFillRect(context, aRect);

    CGPDFPageRef page = CGPDFDocumentGetPage(self.pdfDocument, pageNumber);
    CGFloat angle = 0; //sizeInPixels.width > sizeInPixels.height ? -90 : 0;
    CGAffineTransform pdfTransform = CGPDFPageGetDrawingTransform(page, kCGPDFMediaBox, aRect, angle, true);
    
    CGContextConcatCTM(context, pdfTransform);
    
    CGContextDrawPDFPage(context, page);
    
    UIImage* previewImage = UIGraphicsGetImageFromCurrentImageContext();
    
    CGContextRestoreGState(context);
    
    UIGraphicsEndImageContext();
    
    return previewImage;
}

- (UIImage *)defaultPreviewImage
{
    return [self previewImageForPage:1];
}

- (UIImage *)previewImageForPaper:(HPPPPaper *)paper
{
    return [self defaultPreviewImage];
}

- (NSArray *)previewImagesForPaper:(HPPPPaper *)paper
{
    NSArray *imagesForPaper = [self.pageImages objectForKey:paper.sizeTitle];
    if (!imagesForPaper) {
        NSUInteger pageCount = CGPDFDocumentGetNumberOfPages(self.pdfDocument);
        NSMutableArray *images = [NSMutableArray array];
        for (int page = 1; page <= pageCount; page++) {
            [images addObject:[self previewImageForPage:page]];
        }
        imagesForPaper = images;
        [self.pageImages addEntriesFromDictionary:@{ paper.sizeTitle:imagesForPaper }];
    }
    return imagesForPaper;
}

@end
