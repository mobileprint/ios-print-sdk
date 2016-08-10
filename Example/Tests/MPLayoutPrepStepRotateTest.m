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

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import "MPLayoutPrepStepRotate.h"

@interface MPLayoutPrepStepRotateTest : XCTestCase

@end

@implementation MPLayoutPrepStepRotateTest

typedef enum {
    MPLayoutTestSquare,
    MPLayoutTestPortrait,
    MPLayoutTestLandscape
} MPLayoutTestOrientation;

#pragma mark - Setup tests

- (void)setUp
{
    [super setUp];
}

- (void)tearDown
{
    [super tearDown];
}

#pragma mark - Test asset position

- (void)testRotationNeededLayoutLandscape
{
    
    [self checkLayoutOrientation:MPLayoutOrientationLandscape container:MPLayoutTestLandscape content:MPLayoutTestLandscape rotationNeeded:NO];
    [self checkLayoutOrientation:MPLayoutOrientationLandscape container:MPLayoutTestLandscape content:MPLayoutTestPortrait rotationNeeded:NO];
    [self checkLayoutOrientation:MPLayoutOrientationLandscape container:MPLayoutTestLandscape content:MPLayoutTestSquare rotationNeeded:NO];

    [self checkLayoutOrientation:MPLayoutOrientationLandscape container:MPLayoutTestPortrait content:MPLayoutTestLandscape rotationNeeded:YES];
    [self checkLayoutOrientation:MPLayoutOrientationLandscape container:MPLayoutTestPortrait content:MPLayoutTestPortrait rotationNeeded:YES];
    [self checkLayoutOrientation:MPLayoutOrientationLandscape container:MPLayoutTestPortrait content:MPLayoutTestSquare rotationNeeded:YES];

    [self checkLayoutOrientation:MPLayoutOrientationLandscape container:MPLayoutTestSquare content:MPLayoutTestLandscape rotationNeeded:YES];
    [self checkLayoutOrientation:MPLayoutOrientationLandscape container:MPLayoutTestSquare content:MPLayoutTestPortrait rotationNeeded:YES];
    [self checkLayoutOrientation:MPLayoutOrientationLandscape container:MPLayoutTestSquare content:MPLayoutTestSquare rotationNeeded:YES];
}

- (void)testRotationNeededLayoutPortrait
{
    [self checkLayoutOrientation:MPLayoutOrientationPortrait container:MPLayoutTestLandscape content:MPLayoutTestLandscape rotationNeeded:YES];
    [self checkLayoutOrientation:MPLayoutOrientationPortrait container:MPLayoutTestLandscape content:MPLayoutTestPortrait rotationNeeded:YES];
    [self checkLayoutOrientation:MPLayoutOrientationPortrait container:MPLayoutTestLandscape content:MPLayoutTestSquare rotationNeeded:YES];
    
    [self checkLayoutOrientation:MPLayoutOrientationPortrait container:MPLayoutTestPortrait content:MPLayoutTestLandscape rotationNeeded:NO];
    [self checkLayoutOrientation:MPLayoutOrientationPortrait container:MPLayoutTestPortrait content:MPLayoutTestPortrait rotationNeeded:NO];
    [self checkLayoutOrientation:MPLayoutOrientationPortrait container:MPLayoutTestPortrait content:MPLayoutTestSquare rotationNeeded:NO];
    
    [self checkLayoutOrientation:MPLayoutOrientationPortrait container:MPLayoutTestSquare content:MPLayoutTestLandscape rotationNeeded:NO];
    [self checkLayoutOrientation:MPLayoutOrientationPortrait container:MPLayoutTestSquare content:MPLayoutTestPortrait rotationNeeded:NO];
    [self checkLayoutOrientation:MPLayoutOrientationPortrait container:MPLayoutTestSquare content:MPLayoutTestSquare rotationNeeded:NO];
}

- (void)testRotationNeededLayoutBestFit
{
    
    [self checkLayoutOrientation:MPLayoutOrientationBestFit container:MPLayoutTestLandscape content:MPLayoutTestLandscape rotationNeeded:NO];
    [self checkLayoutOrientation:MPLayoutOrientationBestFit container:MPLayoutTestLandscape content:MPLayoutTestPortrait rotationNeeded:YES];
    [self checkLayoutOrientation:MPLayoutOrientationBestFit container:MPLayoutTestLandscape content:MPLayoutTestSquare rotationNeeded:NO];
    
    [self checkLayoutOrientation:MPLayoutOrientationBestFit container:MPLayoutTestPortrait content:MPLayoutTestLandscape rotationNeeded:YES];
    [self checkLayoutOrientation:MPLayoutOrientationBestFit container:MPLayoutTestPortrait content:MPLayoutTestPortrait rotationNeeded:NO];
    [self checkLayoutOrientation:MPLayoutOrientationBestFit container:MPLayoutTestPortrait content:MPLayoutTestSquare rotationNeeded:NO];
    
    [self checkLayoutOrientation:MPLayoutOrientationBestFit container:MPLayoutTestSquare content:MPLayoutTestLandscape rotationNeeded:NO];
    [self checkLayoutOrientation:MPLayoutOrientationBestFit container:MPLayoutTestSquare content:MPLayoutTestPortrait rotationNeeded:NO];
    [self checkLayoutOrientation:MPLayoutOrientationBestFit container:MPLayoutTestSquare content:MPLayoutTestSquare rotationNeeded:NO];
}

- (void)testRotationNeededLayoutFixed
{
    [self checkLayoutOrientation:MPLayoutOrientationFixed container:MPLayoutTestLandscape content:MPLayoutTestLandscape rotationNeeded:NO];
    [self checkLayoutOrientation:MPLayoutOrientationFixed container:MPLayoutTestLandscape content:MPLayoutTestPortrait rotationNeeded:NO];
    [self checkLayoutOrientation:MPLayoutOrientationFixed container:MPLayoutTestLandscape content:MPLayoutTestSquare rotationNeeded:NO];
    
    [self checkLayoutOrientation:MPLayoutOrientationFixed container:MPLayoutTestPortrait content:MPLayoutTestLandscape rotationNeeded:NO];
    [self checkLayoutOrientation:MPLayoutOrientationFixed container:MPLayoutTestPortrait content:MPLayoutTestPortrait rotationNeeded:NO];
    [self checkLayoutOrientation:MPLayoutOrientationFixed container:MPLayoutTestPortrait content:MPLayoutTestSquare rotationNeeded:NO];
    
    [self checkLayoutOrientation:MPLayoutOrientationFixed container:MPLayoutTestSquare content:MPLayoutTestLandscape rotationNeeded:NO];
    [self checkLayoutOrientation:MPLayoutOrientationFixed container:MPLayoutTestSquare content:MPLayoutTestPortrait rotationNeeded:NO];
    [self checkLayoutOrientation:MPLayoutOrientationFixed container:MPLayoutTestSquare content:MPLayoutTestSquare rotationNeeded:NO];
}

- (void)checkLayoutOrientation:(MPLayoutOrientation)layoutOrientation container:(MPLayoutTestOrientation)containerOrientation content:(MPLayoutTestOrientation)contentOrientation rotationNeeded:(BOOL)expectedRotation;
{
    MPLayoutPrepStepRotate *rotateStep = [[MPLayoutPrepStepRotate alloc] initWithOrientation:layoutOrientation];
    
    
    CGRect contentRect = [self rectWithOrientation:contentOrientation];
    UIImage *contentImage = [self sampleImage:contentRect.size];
    CGRect containerRect = [self rectWithOrientation:containerOrientation];
    CGFloat expectedWidth = contentRect.size.width;
    CGFloat expectedHeight = contentRect.size.height;
    if (expectedRotation) {
        expectedWidth = contentRect.size.height;
        expectedHeight = contentRect.size.width;
    }

    CGRect layoutRect = [rotateStep contentRectForContent:contentRect inContainer:containerRect];
    UIImage *layoutImage = [rotateStep imageForImage:contentImage inContainer:containerRect];
    
    XCTAssert(
              layoutRect.size.width == expectedWidth && layoutRect.size.height == expectedHeight,
              @"Layout rect (%.0f x %.0f) is not equal to expected layout rect (%.0f x %.0f)",
              layoutRect.size.width, layoutRect.size.height,
              expectedWidth, expectedHeight
    );
    
    XCTAssert(
              layoutImage.size.width == expectedWidth && layoutImage.size.height == expectedHeight,
              @"Layout image size (%.0f x %.0f) is not equal to expected layout image size (%.0f x %.0f)",
              layoutRect.size.width, layoutRect.size.height,
              expectedWidth, expectedHeight
              );
}

- (UIImage *)sampleImage:(CGSize)size
{
    UIGraphicsBeginImageContext(size);
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

- (CGRect)rectWithOrientation:(MPLayoutTestOrientation)orientation
{
    CGRect rect = CGRectMake(0, 0, 100, 100);
    if (MPLayoutTestPortrait == orientation) {
        rect = CGRectMake(0, 0, 50, 100);
    } else if (MPLayoutTestLandscape == orientation) {
        rect = CGRectMake(0, 0, 100, 50);
    }
    return rect;
}

@end
