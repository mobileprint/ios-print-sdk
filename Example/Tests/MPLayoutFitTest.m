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
#import <MPLayoutFactory.h>
#import "MPLayoutAlgorithmFit.h"
#import <MPLogger.h>
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

- (void)verifyLayout:(MPLayout *)layout imageSize:(CGSize)imageSize containerSize:(CGSize)containerSize expectedRect:(CGRect)expectedRect
{
    CGRect containerRect = CGRectMake(0, 0, containerSize.width, containerSize.height);
    UIImage *image = [self sampleImage:imageSize];
    UIImage *rotatedImage = [image MPRotate];
    __block id mock = OCMPartialMock(image);
    OCMStub([mock MPRotate]).andReturn(rotatedImage).andDo(^(NSInvocation *invocation) {
        mock = OCMPartialMock(rotatedImage);
    });
    
    [layout drawContentImage:image inRect:containerRect];
    OCMVerify([mock drawInRect:expectedRect]);
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

- (void)testHorizontalPositionProperty
{
    MPLayoutFit *fitLayout = (MPLayoutFit *)[MPLayoutFactory layoutWithType:[MPLayoutFit layoutType]];
    fitLayout.horizontalPosition = MPLayoutHorizontalPositionLeft;
    MPLayoutAlgorithmFit *fitAlgorithm = (MPLayoutAlgorithmFit *)fitLayout.algorithm;
    XCTAssert(
              MPLayoutHorizontalPositionLeft == fitAlgorithm.horizontalPosition,
              @"Expected algorithm horizontal position to change when property changes");
}

- (void)testVerticalPositionProperty
{
    MPLayoutFit *fitLayout = (MPLayoutFit *)[MPLayoutFactory layoutWithType:[MPLayoutFit layoutType]];
    fitLayout.verticalPosition = MPLayoutVerticalPositionTop;
    MPLayoutAlgorithmFit *fitAlgorithm = (MPLayoutAlgorithmFit *)fitLayout.algorithm;
    XCTAssert(
              MPLayoutVerticalPositionTop == fitAlgorithm.verticalPosition,
              @"Expected algorithm vertical position to change when property changes");
}

@end
