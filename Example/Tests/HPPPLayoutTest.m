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

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import <OCMock/OCMock.h>
#import <HPPPLayoutFactory.h>

@interface HPPPLayoutTest : XCTestCase

@end

@implementation HPPPLayoutTest
{
    id _loggerMock;
}

typedef enum {
    HPPPLayoutTestSquare,
    HPPPLayoutTestPortrait,
    HPPPLayoutTestLandscape
} HPPPLayoutTestOrientation;

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
    
    [self checkLayoutOrientation:HPPPLayoutOrientationLandscape container:HPPPLayoutTestLandscape content:HPPPLayoutTestLandscape rotationNeeded:NO];
    [self checkLayoutOrientation:HPPPLayoutOrientationLandscape container:HPPPLayoutTestLandscape content:HPPPLayoutTestPortrait rotationNeeded:NO];
    [self checkLayoutOrientation:HPPPLayoutOrientationLandscape container:HPPPLayoutTestLandscape content:HPPPLayoutTestSquare rotationNeeded:NO];

    [self checkLayoutOrientation:HPPPLayoutOrientationLandscape container:HPPPLayoutTestPortrait content:HPPPLayoutTestLandscape rotationNeeded:YES];
    [self checkLayoutOrientation:HPPPLayoutOrientationLandscape container:HPPPLayoutTestPortrait content:HPPPLayoutTestPortrait rotationNeeded:YES];
    [self checkLayoutOrientation:HPPPLayoutOrientationLandscape container:HPPPLayoutTestPortrait content:HPPPLayoutTestSquare rotationNeeded:NO];

    [self checkLayoutOrientation:HPPPLayoutOrientationLandscape container:HPPPLayoutTestSquare content:HPPPLayoutTestLandscape rotationNeeded:NO];
    [self checkLayoutOrientation:HPPPLayoutOrientationLandscape container:HPPPLayoutTestSquare content:HPPPLayoutTestPortrait rotationNeeded:NO];
    [self checkLayoutOrientation:HPPPLayoutOrientationLandscape container:HPPPLayoutTestSquare content:HPPPLayoutTestSquare rotationNeeded:NO];
}

- (void)testRotationNeededLayoutPortrait
{
    [self checkLayoutOrientation:HPPPLayoutOrientationPortrait container:HPPPLayoutTestLandscape content:HPPPLayoutTestLandscape rotationNeeded:YES];
    [self checkLayoutOrientation:HPPPLayoutOrientationPortrait container:HPPPLayoutTestLandscape content:HPPPLayoutTestPortrait rotationNeeded:YES];
    [self checkLayoutOrientation:HPPPLayoutOrientationPortrait container:HPPPLayoutTestLandscape content:HPPPLayoutTestSquare rotationNeeded:NO];
    
    [self checkLayoutOrientation:HPPPLayoutOrientationPortrait container:HPPPLayoutTestPortrait content:HPPPLayoutTestLandscape rotationNeeded:NO];
    [self checkLayoutOrientation:HPPPLayoutOrientationPortrait container:HPPPLayoutTestPortrait content:HPPPLayoutTestPortrait rotationNeeded:NO];
    [self checkLayoutOrientation:HPPPLayoutOrientationPortrait container:HPPPLayoutTestPortrait content:HPPPLayoutTestSquare rotationNeeded:NO];
    
    [self checkLayoutOrientation:HPPPLayoutOrientationPortrait container:HPPPLayoutTestSquare content:HPPPLayoutTestLandscape rotationNeeded:NO];
    [self checkLayoutOrientation:HPPPLayoutOrientationPortrait container:HPPPLayoutTestSquare content:HPPPLayoutTestPortrait rotationNeeded:NO];
    [self checkLayoutOrientation:HPPPLayoutOrientationPortrait container:HPPPLayoutTestSquare content:HPPPLayoutTestSquare rotationNeeded:NO];
}

- (void)testRotationNeededLayoutBestFit
{
    
    [self checkLayoutOrientation:HPPPLayoutOrientationBestFit container:HPPPLayoutTestLandscape content:HPPPLayoutTestLandscape rotationNeeded:NO];
    [self checkLayoutOrientation:HPPPLayoutOrientationBestFit container:HPPPLayoutTestLandscape content:HPPPLayoutTestPortrait rotationNeeded:YES];
    [self checkLayoutOrientation:HPPPLayoutOrientationBestFit container:HPPPLayoutTestLandscape content:HPPPLayoutTestSquare rotationNeeded:NO];
    
    [self checkLayoutOrientation:HPPPLayoutOrientationBestFit container:HPPPLayoutTestPortrait content:HPPPLayoutTestLandscape rotationNeeded:YES];
    [self checkLayoutOrientation:HPPPLayoutOrientationBestFit container:HPPPLayoutTestPortrait content:HPPPLayoutTestPortrait rotationNeeded:NO];
    [self checkLayoutOrientation:HPPPLayoutOrientationBestFit container:HPPPLayoutTestPortrait content:HPPPLayoutTestSquare rotationNeeded:NO];
    
    [self checkLayoutOrientation:HPPPLayoutOrientationBestFit container:HPPPLayoutTestSquare content:HPPPLayoutTestLandscape rotationNeeded:NO];
    [self checkLayoutOrientation:HPPPLayoutOrientationBestFit container:HPPPLayoutTestSquare content:HPPPLayoutTestPortrait rotationNeeded:NO];
    [self checkLayoutOrientation:HPPPLayoutOrientationBestFit container:HPPPLayoutTestSquare content:HPPPLayoutTestSquare rotationNeeded:NO];
}

- (void)testRotationNeededLayoutFixed
{
    [self checkLayoutOrientation:HPPPLayoutOrientationFixed container:HPPPLayoutTestLandscape content:HPPPLayoutTestLandscape rotationNeeded:NO];
    [self checkLayoutOrientation:HPPPLayoutOrientationFixed container:HPPPLayoutTestLandscape content:HPPPLayoutTestPortrait rotationNeeded:NO];
    [self checkLayoutOrientation:HPPPLayoutOrientationFixed container:HPPPLayoutTestLandscape content:HPPPLayoutTestSquare rotationNeeded:NO];
    
    [self checkLayoutOrientation:HPPPLayoutOrientationFixed container:HPPPLayoutTestPortrait content:HPPPLayoutTestLandscape rotationNeeded:NO];
    [self checkLayoutOrientation:HPPPLayoutOrientationFixed container:HPPPLayoutTestPortrait content:HPPPLayoutTestPortrait rotationNeeded:NO];
    [self checkLayoutOrientation:HPPPLayoutOrientationFixed container:HPPPLayoutTestPortrait content:HPPPLayoutTestSquare rotationNeeded:NO];
    
    [self checkLayoutOrientation:HPPPLayoutOrientationFixed container:HPPPLayoutTestSquare content:HPPPLayoutTestLandscape rotationNeeded:NO];
    [self checkLayoutOrientation:HPPPLayoutOrientationFixed container:HPPPLayoutTestSquare content:HPPPLayoutTestPortrait rotationNeeded:NO];
    [self checkLayoutOrientation:HPPPLayoutOrientationFixed container:HPPPLayoutTestSquare content:HPPPLayoutTestSquare rotationNeeded:NO];
}

- (void)checkLayoutOrientation:(HPPPLayoutOrientation)layoutOrientation container:(HPPPLayoutTestOrientation)containerOrientation content:(HPPPLayoutTestOrientation)contentOrientation rotationNeeded:(BOOL)expectedRotation;
{
    HPPPLayout *layout = [[HPPPLayout alloc] initWithOrientation:layoutOrientation assetPosition:[HPPPLayout completeFillRectangle]];
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

- (CGRect)rectWithOrientation:(HPPPLayoutTestOrientation)orientation
{
    CGRect rect = CGRectMake(0, 0, 100, 100);
    if (HPPPLayoutTestPortrait == orientation) {
        rect = CGRectMake(0, 0, 50, 100);
    } else if (HPPPLayoutTestLandscape == orientation) {
        rect = CGRectMake(0, 0, 100, 50);
    }
    return rect;
}

@end