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
#import <OCMock/OCMock.h>
#import <MPLayoutFactory.h>

@interface MPLayoutTest : XCTestCase

@end

@implementation MPLayoutTest
{
    id _loggerMock;
}

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
    MPLayout *layout = [[MPLayout alloc] initWithOrientation:layoutOrientation assetPosition:[MPLayout completeFillRectangle]];
    CGRect contentRect = [self rectWithOrientation:contentOrientation];
    CGRect containerRect = [self rectWithOrientation:containerOrientation];
    BOOL recommendedRotation = [layout rotationNeededForContent:contentRect withContainer:containerRect];
    XCTAssert(
              expectedRotation == recommendedRotation,
              @"Expected recommended rotation (%@) to equal expected rotation (%@)",
              recommendedRotation ? @"YES" : @"NO",
              expectedRotation ? @"YES" : @"NO"
    );
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
