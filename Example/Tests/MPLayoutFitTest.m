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

#import "UIImage+MPResize.h"
#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import "MPLayoutFactory.h"
#import "MPLayoutAlgorithmFit.h"
#import "MPLogger.h"
#import <OCMock/OCMock.h>

@interface MPLayoutFit (private)

@property (strong, nonatomic) MPLayoutAlgorithm *algorithm;

@end

@interface MPLayoutFitTest : XCTestCase

@end

@implementation MPLayoutFitTest
{
    id _loggerMock;
}

#pragma mark - Setup tests

- (void)setUp
{
    [super setUp];
    _loggerMock = OCMPartialMock([MPLogger sharedInstance]);
}

- (void)tearDown
{
    [super tearDown];
    [_loggerMock stopMocking];
}

#pragma mark - Test draw in rect

- (UIImage *)sampleImage:(CGSize)size
{
    UIGraphicsBeginImageContext(size);
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

- (void)verifyImagePosition:(MPLayout *)layout imageSize:(CGSize)imageSize containerSize:(CGSize)containerSize expectedRect:(CGRect)expectedRect
{
    CGRect containerRect = CGRectMake(0, 0, containerSize.width, containerSize.height);
    UIImage *image = [self sampleImage:imageSize];
    CGRect imageLocation = [layout contentImageLocation:image inRect:containerRect];
    XCTAssertTrue(CGRectEqualToRect(imageLocation, expectedRect),
                  @"contentImageLocation returned an unexpected CGRect");
}

- (void)verifyDrawContentImage:(MPLayout *)layout imageSize:(CGSize)imageSize containerSize:(CGSize)containerSize expectedRect:(CGRect)expectedRect
{
    CGRect containerRect = CGRectMake(0, 0, containerSize.width, containerSize.height);
    UIImage *image = [self sampleImage:imageSize];
    UIImage *rotatedImage = [image MPRotate];
    id imageMock = OCMPartialMock(image);
    id rotatedMock = OCMPartialMock(rotatedImage);
    __block id checkMock = imageMock;
    OCMStub([imageMock MPRotate]).andReturn(rotatedImage).andDo(^(NSInvocation *invocation) {
        checkMock = rotatedMock;
    });
    [layout drawContentImage:image inRect:containerRect];
    OCMVerify([checkMock drawInRect:expectedRect]);
}

- (void)verifyLayout:(MPLayout *)layout imageSize:(CGSize)imageSize containerSize:(CGSize)containerSize expectedRect:(CGRect)expectedRect
{
    [self verifyImagePosition:layout imageSize:imageSize containerSize:containerSize expectedRect:expectedRect];
    [self verifyDrawContentImage:layout imageSize:imageSize containerSize:containerSize expectedRect:expectedRect];
}

- (void)testdrawContentNarrowPortrait
{
    CGFloat reduction = 10;
    CGSize containerSize = CGSizeMake(100, 200);
    CGSize imageSize = CGSizeMake(containerSize.width - reduction, containerSize.height);
    [self verifyLayout:[MPLayoutFactory layoutWithType:[MPLayoutFit layoutType]]
             imageSize:imageSize
         containerSize:containerSize
          expectedRect:CGRectMake(reduction / 2.0, 0, imageSize.width, imageSize.height)];
}

- (void)testdrawContentWidePortrait
{
    CGFloat reduction = 10;
    CGSize containerSize = CGSizeMake(100, 200);
    CGSize imageSize = CGSizeMake(containerSize.width, containerSize.height - reduction);
    [self verifyLayout:[MPLayoutFactory layoutWithType:[MPLayoutFit layoutType]]
             imageSize:imageSize
         containerSize:containerSize
          expectedRect:CGRectMake(0, reduction / 2.0, imageSize.width, imageSize.height)];
}

- (void)testdrawContentNarrowLandscape
{
    CGFloat reduction = 10;
    CGSize containerSize = CGSizeMake(200, 100);
    CGSize imageSize = CGSizeMake(containerSize.width - reduction, containerSize.height);
    [self verifyLayout:[MPLayoutFactory layoutWithType:[MPLayoutFit layoutType]]
             imageSize:imageSize
         containerSize:containerSize
          expectedRect:CGRectMake(reduction / 2.0, 0, imageSize.width, imageSize.height)];
}

- (void)testdrawContentWideLandscape
{
    CGFloat reduction = 10;
    CGSize containerSize = CGSizeMake(200, 100);
    CGSize imageSize = CGSizeMake(containerSize.width, containerSize.height - reduction);
    [self verifyLayout:[MPLayoutFactory layoutWithType:[MPLayoutFit layoutType]]
             imageSize:imageSize
         containerSize:containerSize
          expectedRect:CGRectMake(0, reduction / 2.0, imageSize.width, imageSize.height)];
}

- (void)testdrawContentSmall
{
    CGFloat scale = 0.5;
    CGSize containerSize = CGSizeMake(200, 100);
    CGSize imageSize = CGSizeMake(containerSize.width * scale, containerSize.height * scale);
    [self verifyLayout:[MPLayoutFactory layoutWithType:[MPLayoutFit layoutType]]
             imageSize:imageSize
         containerSize:containerSize
          expectedRect:CGRectMake(0, 0, containerSize.width, containerSize.height)];
}

- (void)testdrawContentBig
{
    CGFloat scale = 2.0;
    CGSize containerSize = CGSizeMake(200, 100);
    CGSize imageSize = CGSizeMake(containerSize.width * scale, containerSize.height * scale);
    [self verifyLayout:[MPLayoutFactory layoutWithType:[MPLayoutFit layoutType]]
             imageSize:imageSize
         containerSize:containerSize
          expectedRect:CGRectMake(0, 0, containerSize.width, containerSize.height)];
}

- (void)testRotatePortrait
{
    CGFloat reduction = 10;
    CGSize containerSize = CGSizeMake(200, 100);
    CGSize imageSize = CGSizeMake(containerSize.height - reduction, containerSize.width);
    [self verifyLayout:[MPLayoutFactory layoutWithType:[MPLayoutFit layoutType]]
             imageSize:imageSize
         containerSize:containerSize
          expectedRect:CGRectMake(0, reduction / 2.0, imageSize.height, imageSize.width)]; 
}

- (void)testRotateLandscape
{
    CGFloat reduction = 10;
    CGSize containerSize = CGSizeMake(100, 200);
    CGSize imageSize = CGSizeMake(containerSize.height, containerSize.width - reduction);
    [self verifyLayout:[MPLayoutFactory layoutWithType:[MPLayoutFit layoutType]]
             imageSize:imageSize
         containerSize:containerSize
          expectedRect:CGRectMake(reduction / 2.0, 0, imageSize.height, imageSize.width)];
}

- (void)testRotateLandscapeTop
{
    CGFloat reduction = 10;
    CGSize containerSize = CGSizeMake(100, 200);
    CGSize imageSize = CGSizeMake(containerSize.height, containerSize.width - reduction);
    MPLayoutFit *layout = (MPLayoutFit *)[MPLayoutFactory layoutWithType:[MPLayoutFit layoutType]];
    layout.verticalPosition = MPLayoutVerticalPositionTop;
    [self verifyLayout:layout
             imageSize:imageSize
         containerSize:containerSize
          expectedRect:CGRectMake(0, 0, imageSize.height, imageSize.width)];
}


- (void)testRotateLandscapeLeft
{
    CGSize containerSize = CGSizeMake(100, 200);
    CGSize imageSize = CGSizeMake(containerSize.width / 2.0, containerSize.width);
    MPLayoutFit *layout = (MPLayoutFit *)[MPLayoutFactory layoutWithType:[MPLayoutFit layoutType] orientation:MPLayoutOrientationLandscape assetPosition:[MPLayout completeFillRectangle]];
    layout.horizontalPosition = MPLayoutHorizontalPositionLeft;
    [self verifyLayout:layout
             imageSize:imageSize
         containerSize:containerSize
          expectedRect:CGRectMake(0, containerSize.height - imageSize.width, imageSize.height, imageSize.width)];
}

- (void)testArchiving
{
    MPLayoutOrientation orientation = MPLayoutOrientationPortrait;
    CGRect assetPosition = CGRectMake(arc4random_uniform(100), arc4random_uniform(100), arc4random_uniform(100), arc4random_uniform(100));
    MPLayoutHorizontalPosition horizontalPosition = MPLayoutHorizontalPositionRight;
    MPLayoutVerticalPosition verticalPosition = MPLayoutVerticalPositionTop;
    
    MPLayoutFit *originalLayout = (MPLayoutFit *)[MPLayoutFactory layoutWithType:[MPLayoutFit layoutType] orientation:orientation assetPosition:assetPosition];
    originalLayout.horizontalPosition = horizontalPosition;
    originalLayout.verticalPosition = verticalPosition;
    
    NSString *filename = @"FitLayoutTest";
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths firstObject];
    NSString *archivePath = [documentsDirectory stringByAppendingPathComponent:filename];
    BOOL success = [NSKeyedArchiver archiveRootObject:originalLayout toFile:archivePath];
    
    XCTAssert(success, @"Expected layout to be archived successfully");
    
    MPLayoutFit *restoredLayout = (MPLayoutFit *)[NSKeyedUnarchiver unarchiveObjectWithFile:archivePath];
    
    XCTAssert(nil != restoredLayout, @"Expected layout to be unarchived successfully");
    XCTAssert(restoredLayout.orientation == orientation, @"Expected orientation to be unarchived successfully");
    XCTAssert(CGRectEqualToRect(restoredLayout.assetPosition, assetPosition), @"Expected asset position to be unarchived successfully");
    XCTAssert(restoredLayout.horizontalPosition == horizontalPosition, @"Expected horizontal position to be unarchived successfully");
    XCTAssert(restoredLayout.verticalPosition == verticalPosition, @"Expected vertical position to be unarchived successfully");
}

@end
