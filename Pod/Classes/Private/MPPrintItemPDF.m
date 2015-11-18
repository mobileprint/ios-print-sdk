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

#import "MP.h"
#import "MPPrintItemPDF.h"
#import "MPLayoutFactory.h"

@interface MPPrintItemPDF()

@property (strong, nonatomic) NSData *pdfData;
@property (assign, nonatomic) CGPDFDocumentRef pdfDocument;
@property (strong, nonatomic) NSMutableDictionary *pageImages;

@end

@implementation MPPrintItemPDF

#pragma mark - Initialization

- (id)initWithData:(NSData *)data
{
    MPPrintItemPDF *item = nil;
    CFDataRef pdfDataRef = (CFDataRef)CFBridgingRetain(data);
    CGDataProviderRef provider = CGDataProviderCreateWithCFData(pdfDataRef);
    CGPDFDocumentRef pdf = CGPDFDocumentCreateWithProvider(provider);
    
    if (pdf) {
        self = [super init];
        if (self) {
            self.pdfData = data;
            self.pdfDocument = pdf;
            self.pageImages = [NSMutableDictionary dictionary];
            self.layout = [MPLayoutFactory layoutWithType:[MPLayoutFit layoutType]];
        }
        item = self;
    } else {
        MPLogWarn(@"MPPDFPrintItem was initialized with non-PDF data.");
    }
    
    return item;
}

- (void)dealloc
{
    CGPDFDocumentRelease(self.pdfDocument);
}

- (void)setLayout:(MPLayout *)layout
{
    MPLogError(@"Cannot set layout of PDF print item (always uses centered fit layout)");
}

#pragma mark - Asset attributes

- (id)printAsset
{
    return self.pdfData;
}

- (NSString *)assetType
{
    return @"PDF";
}

- (MPPrintRenderer)renderer
{
    return DefaultPrintRenderer;
}

- (NSInteger)numberOfPages
{
    return CGPDFDocumentGetNumberOfPages(self.pdfDocument);
}

- (CGSize)sizeInUnits:(MPUnits)units
{
    CGSize size = CGSizeMake(0, 0);
    CGPDFPageRef page = CGPDFDocumentGetPage(self.pdfDocument, 1);
    CGRect pageSize = CGPDFPageGetBoxRect(page, kCGPDFMediaBox);
    if (Pixels == units) {
        size = pageSize.size;
    } else if (Inches == units) {
        size = CGSizeMake(pageSize.size.width / kMPPointsPerInch, pageSize.size.height / kMPPointsPerInch);
    }
    return size;
}

- (id)printAssetForPageRange:(MPPageRange *)pageRange
{
    id printAsset = self.printAsset;
    
    if( nil != pageRange && ![pageRange.range isEqualToString:pageRange.allPagesIndicator] ) {
        NSArray *pages = [pageRange getPages];
        
        NSTimeInterval uniqueNumber = [NSDate timeIntervalSinceReferenceDate];
        NSString *uniqueName = [NSString stringWithFormat:@"%d.pdf", (int)uniqueNumber];
        NSString *filename = [self formFilename:uniqueName];
        [self createPageRangeFile:filename pages:pages];
        
        printAsset = [NSData dataWithContentsOfFile:filename];
        [self deleteFile:filename];
    }
    
    return printAsset;
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

- (UIImage *)previewImageForPage:(NSUInteger)page paper:(MPPaper *)paper
{
    return [self previewImageForPage:page];
}

- (UIImage *)defaultPreviewImage
{
    return [self previewImageForPage:1];
}

- (UIImage *)previewImageForPaper:(MPPaper *)paper
{
    return [self defaultPreviewImage];
}

- (NSArray *)previewImagesForPaper:(MPPaper *)paper
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

#pragma mark - Page Range File

- (NSString *)formFilename:(NSString *)filename
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    
    return [NSString stringWithFormat:@"%@/%@", documentsDirectory, filename];
}

-(void) createPageRangeFile:(NSString *)filename pages:(NSArray *)pages
{
    CFStringRef path;
    CGContextRef pdfContext;
    CFURLRef url;
    CFMutableDictionaryRef myDictionary;
    
    path = CFStringCreateWithCString (NULL, [filename cStringUsingEncoding:NSASCIIStringEncoding],
                                      kCFStringEncodingUTF8);
    url = CFURLCreateWithFileSystemPath (NULL, path,
                                         kCFURLPOSIXPathStyle, 0);
    
    myDictionary = CFDictionaryCreateMutable(NULL, 0,
                                             &kCFTypeDictionaryKeyCallBacks,
                                             &kCFTypeDictionaryValueCallBacks);
    CFDictionarySetValue(myDictionary, kCGPDFContextTitle, CFSTR("Page Range"));
    CFDictionarySetValue(myDictionary, kCGPDFContextCreator, CFSTR("MobilePrintSDK"));
    
    CGRect pageRect = CGPDFPageGetBoxRect(CGPDFDocumentGetPage(self.pdfDocument, [pages[0] intValue]), kCGPDFMediaBox);
    pdfContext = CGPDFContextCreateWithURL (url, &pageRect, myDictionary);
    
    for( NSNumber *page in pages) {
        
        CFMutableDictionaryRef pageDictionary = CFDictionaryCreateMutable(NULL, 0,
                                                                          &kCFTypeDictionaryKeyCallBacks,
                                                                          &kCFTypeDictionaryValueCallBacks);
        
        CFDataRef boxData = CFDataCreate(NULL,(const UInt8 *)&pageRect, sizeof (CGRect));
        
        CFDictionarySetValue(pageDictionary, kCGPDFContextMediaBox, boxData);
        
        CGPDFContextBeginPage (pdfContext, pageDictionary);
        
        CGPDFPageRef pageRef = CGPDFDocumentGetPage(self.pdfDocument, [page intValue]);
        CGContextDrawPDFPage (pdfContext, pageRef);
        
        CGPDFContextEndPage (pdfContext);
        
        CFRelease(pageDictionary);
        CFRelease(boxData);
    }
    
    CFRelease (path);
    CGContextRelease (pdfContext);
    CFRelease(url);
    CFRelease(myDictionary);
}

- (void)deleteFile:(NSString *)filename
{
    if( filename ) {
        NSError *error;
        BOOL success = [[NSFileManager defaultManager] removeItemAtPath:filename error:&error];
        if (!success) {
            MPLogError(@"Could not delete file -:%@ ",[error localizedDescription]);
        }
    }
}

@end
