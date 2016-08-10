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
#import "MP.h"
#import "MPPaper.h"
#import "MPPrintManager.h"
#import "MPPrintManager+Options.h"
#import "MPPrintJobsViewController.h"

@interface MPGenericDelegate : NSObject<MPPrintDelegate> @end
@implementation MPGenericDelegate
- (void)didFinishPrintFlow:(UIViewController *)printViewController {}
- (void)didCancelPrintFlow:(UIViewController *)printViewController {}
@end

@interface MPGenericDataSource : NSObject<MPPrintDataSource>
@property (assign, nonatomic) NSInteger jobCount;
@end
@implementation MPGenericDataSource
- (void)printingItemForPaper:(MPPaper *)paper withCompletion:(void (^)(MPPrintItem * printItem))completion {}
- (void)previewImageForPaper:(MPPaper *)paper withCompletion:(void (^)(UIImage *previewImage))completion {}
- (NSInteger)numberOfPrintingItems { return self.jobCount; }
@end

@interface MPDerivedActivityDelegate : MPPrintActivity @end
@implementation MPDerivedActivityDelegate @end

@interface MPDerivedQueueDelegate : MPPrintJobsViewController @end
@implementation MPDerivedQueueDelegate @end

@interface MPPrintManagerTest : XCTestCase

@end

@implementation MPPrintManagerTest
{
    MPPrintManager *_printManager;
}

NSString * const kMPTestPaperSizeKey = @"kMPLastPaperSizeSetting";
NSString * const kMPTestPaperTypeKey = @"kMPLastPaperTypeSetting";
NSString * const kMPTestBlackAndWhiteKey = @"kMPLastBlackAndWhiteFilterSetting";
NSString * const kMPTestPrinterIdKey = @"kMPTestPrinterIdKey";
NSString * const kMPTestPrinterNameKey = @"kDefaultPrinterNameKey";
NSString * const kMPTestPrinterURLKey = @"kDefaultPrinterURLKey";
NSString * const kMPTestPrinterNetworkKey = @"kDefaultPrinterNetworkKey";
NSString * const kMPTestPrinterLatitudeCoordinateKey = @"kDefaultPrinterLatitudeCoordinateKey";
NSString * const kMPTestPrinterLongitudeCoordinateKey = @"kDefaultPrinterLongitudeCoordinateKey";
NSString * const kMPTestPrinterModelKey = @"kDefaultPrinterModelKey";
NSString * const kMPTestPrinterLocationKey = @"kDefaultPrinterLocationKey";
NSString * const kMPTestPrinterAvailableKey = @"kMPTestPrinterAvailableKey";
NSString * const kMPTestNumberOfCopiesKey = @"kMPTestNumberOfCopiesKey";

#pragma mark - Setup tests

- (void)setUp
{
    [super setUp];
    
    [MPPaper resetPaperList];
    [MP sharedInstance].printPaperDelegate = nil;

    [self setLastOptions];
    [self setDefaultValues];
}

- (void)tearDown
{
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
    [self resetUserDefaults];
}

#pragma mark - Test 'init'

- (void)testInit
{
    _printManager = [[MPPrintManager alloc] init];
    [self verifySettings:[self defaultSettings]];
}

- (void)testInitNoLastPaper
{
    NSUserDefaults * defaults = [NSUserDefaults standardUserDefaults];
    [defaults removeObjectForKey:kMPTestPaperSizeKey];
    [defaults removeObjectForKey:kMPTestPaperTypeKey];
    [defaults synchronize];
    
    NSMutableDictionary *noPaperSettings = [NSMutableDictionary dictionaryWithDictionary:[self defaultSettings]];
    NSNumber *defaultSize = [NSNumber numberWithUnsignedInteger:[MP sharedInstance].defaultPaper.paperSize];
    NSNumber *defaultType = [NSNumber numberWithUnsignedInteger:[MP sharedInstance].defaultPaper.paperType];
    [noPaperSettings setObject:defaultSize forKey:kMPTestPaperSizeKey];
    [noPaperSettings setObject:defaultType forKey:kMPTestPaperTypeKey];
    
    _printManager = [[MPPrintManager alloc] init];
    [self verifySettings:noPaperSettings];
}

#pragma mark - Test 'initWithPrintSettings'

- (void)testInitWithPrintSettings
{
    NSDictionary *customSettings = [self customSettings];
    MPPrintSettings *printSettings = [self printSettingsWithValues:customSettings];
    _printManager = [[MPPrintManager alloc] initWithPrintSettings:printSettings];
    [self verifySettings:customSettings];
}

- (void)testInitWithPrintSettingsUseLastPaper
{
    NSNumber *expectedPaperSize = [[self defaultSettings] objectForKey:kMPTestPaperSizeKey];
    NSNumber *expectedPaperType = [[self defaultSettings] objectForKey:kMPTestPaperTypeKey];
    NSMutableDictionary *useLastPaperSettings = [NSMutableDictionary dictionaryWithDictionary:[self customSettings]];
    [useLastPaperSettings setObject:expectedPaperSize forKey:kMPTestPaperSizeKey];
    [useLastPaperSettings setObject:expectedPaperType forKey:kMPTestPaperTypeKey];
    
    MPPrintSettings *printSettings = [self printSettingsWithValues:useLastPaperSettings];
    printSettings.paper = nil;
    
    _printManager = [[MPPrintManager alloc] initWithPrintSettings:printSettings];
    [self verifySettings:useLastPaperSettings];
}

- (void)testInitWithPrintSettingsNoLastPaper
{
    NSNumber *expectedPaperSize = [NSNumber numberWithUnsignedInteger:[MP sharedInstance].defaultPaper.paperSize];
    NSNumber *expectedPaperType = [NSNumber numberWithUnsignedInteger:[MP sharedInstance].defaultPaper.paperType];
    NSMutableDictionary *noPaperSettings = [NSMutableDictionary dictionaryWithDictionary:[self customSettings]];
    [noPaperSettings setObject:expectedPaperSize forKey:kMPTestPaperSizeKey];
    [noPaperSettings setObject:expectedPaperType forKey:kMPTestPaperTypeKey];
    
    MPPrintSettings *printSettings = [self printSettingsWithValues:noPaperSettings];
    printSettings.paper = nil;
    
    NSUserDefaults * defaults = [NSUserDefaults standardUserDefaults];
    [defaults removeObjectForKey:kMPTestPaperSizeKey];
    [defaults removeObjectForKey:kMPTestPaperTypeKey];
    [defaults synchronize];
    
    _printManager = [[MPPrintManager alloc] initWithPrintSettings:printSettings];
    [self verifySettings:noPaperSettings];
}

#pragma mark - Test 'saveLastOptionsForPrinter'

- (void)testsaveLastOptionsForPrinter
{
    NSDictionary *defaultSettings = [self defaultSettings];
    [MP sharedInstance].lastOptionsUsed = @{};
    _printManager = [[MPPrintManager alloc] init];
    _printManager.numberOfCopies = [[defaultSettings objectForKey:kMPTestNumberOfCopiesKey] integerValue];
    [_printManager saveLastOptionsForPrinter:@"fake printer"];
    
    MPPaper *expectedPaper = [[MPPaper alloc] initWithPaperSize:[[defaultSettings objectForKey:kMPTestPaperSizeKey] unsignedIntegerValue] paperType:[[defaultSettings objectForKey:kMPTestPaperTypeKey] unsignedIntegerValue] ];
    
    NSString *paperSize = [[MP sharedInstance].lastOptionsUsed objectForKey:kMPPaperSizeId];
    XCTAssert([expectedPaper.sizeTitle isEqualToString:paperSize], @"Expected last paper size (%@) to equal expected paper size (%@)", paperSize, expectedPaper.sizeTitle);
    
    NSString *paperType = [[MP sharedInstance].lastOptionsUsed objectForKey:kMPPaperTypeId];
    XCTAssert([expectedPaper.typeTitle isEqualToString:paperType], @"Expected last paper type (%@) to equal expected paper type (%@)", paperType, expectedPaper.typeTitle);
    
    NSNumber *width = [[MP sharedInstance].lastOptionsUsed objectForKey:kMPPaperWidthId];
    XCTAssert([width floatValue] == expectedPaper.width, @"Expected last paper width (%.3f) to equal expected paper width (%.3f)", [width floatValue], expectedPaper.width);
    
    NSNumber *height = [[MP sharedInstance].lastOptionsUsed objectForKey:kMPPaperHeightId];
    XCTAssert([height floatValue] == expectedPaper.height, @"Expected last paper height (%.3f) to equal expected paper height (%.3f)", [height floatValue], expectedPaper.height);
    
    NSNumber *expectedBlackAndWhite = IS_OS_8_OR_LATER ? [defaultSettings objectForKey:kMPTestBlackAndWhiteKey] : [NSNumber numberWithBool:NO];
    XCTAssert(
              expectedBlackAndWhite == [[MP sharedInstance].lastOptionsUsed objectForKey:kMPBlackAndWhiteFilterId],
              @"Expected last B/W option (%@) to equal expected B/W option (%@)",
              [[MP sharedInstance].lastOptionsUsed objectForKey:kMPPaperTypeId],
              expectedBlackAndWhite);
    
    XCTAssert(
              [defaultSettings objectForKey:kMPTestNumberOfCopiesKey] == [[MP sharedInstance].lastOptionsUsed objectForKey:kMPNumberOfCopies],
              @"Expected last number of copies (%@) to equal expected number of copies (%@)",
              [defaultSettings objectForKey:kMPTestNumberOfCopiesKey],
              [[MP sharedInstance].lastOptionsUsed objectForKey:kMPNumberOfCopies]);
    
    // TODO: still need to test "no printer" and "printer mismatch" scenarios
}

#pragma mark - Test setting options

- (void)testPrintCustom
{
    MPPrintManager *printManager = [[MPPrintManager alloc] init];
    MPGenericDelegate *delegate = [[MPGenericDelegate alloc] init];
    MPGenericDataSource *dataSource = [[MPGenericDataSource alloc] init];
    [printManager setOptionsForPrintDelegate:delegate dataSource:dataSource];
    [self expectOptions:printManager.options include:YES value:MPPrintManagerOriginCustom name:@"MPPrintManagerOriginCustom"];
    [self expectOptions:printManager.options include:NO value:MPPrintManagerMultiJob name:@"MPPrintManagerMultiJob"];
}

- (void)testPrintFromShare
{
    MPPrintManager *printManager = [[MPPrintManager alloc] init];
    MPPrintActivity *delegate = [[MPPrintActivity alloc] init];
    MPGenericDataSource *dataSource = [[MPGenericDataSource alloc] init];
    [printManager setOptionsForPrintDelegate:(id<MPPrintDelegate>)delegate dataSource:dataSource];
    [self expectOptions:printManager.options include:YES value:MPPrintManagerOriginShare name:@"MPPrintManagerOriginShare"];
    [self expectOptions:printManager.options include:NO value:MPPrintManagerMultiJob name:@"MPPrintManagerMultiJob"];
}

- (void)testPrintFromQueue
{
    MPPrintManager *printManager = [[MPPrintManager alloc] init];
    MPPrintJobsViewController *delegate = [[MPPrintJobsViewController alloc] init];
    MPGenericDataSource *dataSource = [[MPGenericDataSource alloc] init];
    [printManager setOptionsForPrintDelegate:(id<MPPrintDelegate>)delegate dataSource:dataSource];
    [self expectOptions:printManager.options include:YES value:MPPrintManagerOriginQueue name:@"MPPrintManagerOriginQueue"];
    [self expectOptions:printManager.options include:NO value:MPPrintManagerMultiJob name:@"MPPrintManagerMultiJob"];
}

- (void)testPrintMultiple
{
    MPPrintManager *printManager = [[MPPrintManager alloc] init];
    MPGenericDelegate *delegate = [[MPGenericDelegate alloc] init];
    MPGenericDataSource *dataSource = [[MPGenericDataSource alloc] init];
    dataSource.jobCount = 2;
    [printManager setOptionsForPrintDelegate:delegate dataSource:dataSource];
    [self expectOptions:printManager.options include:YES value:MPPrintManagerMultiJob name:@"MPPrintManagerMultiJob"];
}

- (void)testDerivedActivity
{
    MPPrintManager *printManager = [[MPPrintManager alloc] init];
    MPDerivedActivityDelegate *delegate = [[MPDerivedActivityDelegate alloc] init];
    MPGenericDataSource *dataSource = [[MPGenericDataSource alloc] init];
    [printManager setOptionsForPrintDelegate:(id<MPPrintDelegate>)delegate dataSource:dataSource];
    [self expectOptions:printManager.options include:YES value:MPPrintManagerOriginShare name:@"MPPrintManagerOriginShare"];
    [self expectOptions:printManager.options include:NO value:MPPrintManagerMultiJob name:@"MPPrintManagerMultiJob"];
}

- (void)testDerivedQueue
{
    MPPrintManager *printManager = [[MPPrintManager alloc] init];
    MPDerivedQueueDelegate *delegate = [[MPDerivedQueueDelegate alloc] init];
    MPGenericDataSource *dataSource = [[MPGenericDataSource alloc] init];
    [printManager setOptionsForPrintDelegate:(id<MPPrintDelegate>)delegate dataSource:dataSource];
    [self expectOptions:printManager.options include:YES value:MPPrintManagerOriginQueue name:@"MPPrintManagerOriginQueue"];
    [self expectOptions:printManager.options include:NO value:MPPrintManagerMultiJob name:@"MPPrintManagerMultiJob"];
}

- (void)expectOptions:(MPPrintManagerOptions)options include:(BOOL)include value:(MPPrintManagerOptions)value name:(NSString *)name
{
    BOOL expectationMet = include ? (options & value) : !(options & value);
    XCTAssert(
              expectationMet,
              @"Expected options (%lu) %@to include %@ (%lu)",
              (unsigned long)options,
              include ? @"" : @"not ",
              name,
              (unsigned long)include);
}

#pragma mark - Defaults helpers

- (void)setLastOptions
{
    NSDictionary *defaultSettings = [self defaultSettings];
    NSUserDefaults * defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:[defaultSettings objectForKey:kMPTestPaperSizeKey] forKey:kMPTestPaperSizeKey];
    [defaults setObject:[defaultSettings objectForKey:kMPTestPaperTypeKey] forKey:kMPTestPaperTypeKey];
    [defaults setObject:[defaultSettings objectForKey:kMPTestBlackAndWhiteKey] forKey:kMPTestBlackAndWhiteKey];
    [defaults synchronize];
}

- (void)setDefaultValues
{
    NSDictionary *defaultSettings = [self defaultSettings];
    NSUserDefaults * defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:[defaultSettings objectForKey:kMPTestPrinterNameKey] forKey:kMPTestPrinterNameKey];
    [defaults setObject:[defaultSettings objectForKey:kMPTestPrinterURLKey] forKey:kMPTestPrinterURLKey];
    [defaults setObject:[defaultSettings objectForKey:kMPTestPrinterNetworkKey] forKey:kMPTestPrinterNetworkKey];
    [defaults setObject:[defaultSettings objectForKey:kMPTestPrinterLatitudeCoordinateKey] forKey:kMPTestPrinterLatitudeCoordinateKey];
    [defaults setObject:[defaultSettings objectForKey:kMPTestPrinterLongitudeCoordinateKey] forKey:kMPTestPrinterLongitudeCoordinateKey];
    [defaults setObject:[defaultSettings objectForKey:kMPTestPrinterModelKey] forKey:kMPTestPrinterModelKey];
    [defaults setObject:[defaultSettings objectForKey:kMPTestPrinterLocationKey] forKey:kMPTestPrinterLocationKey];
    [defaults synchronize];
}

- (void)resetUserDefaults
{
    NSUserDefaults * defaults = [NSUserDefaults standardUserDefaults];
    [defaults removeObjectForKey:kMPTestPaperSizeKey];
    [defaults removeObjectForKey:kMPTestPaperTypeKey];
    [defaults removeObjectForKey:kMPTestBlackAndWhiteKey];
    [defaults removeObjectForKey:kMPTestPrinterNameKey];
    [defaults removeObjectForKey:kMPTestPrinterURLKey];
    [defaults removeObjectForKey:kMPTestPrinterNetworkKey];
    [defaults removeObjectForKey:kMPTestPrinterLatitudeCoordinateKey];
    [defaults removeObjectForKey:kMPTestPrinterLongitudeCoordinateKey];
    [defaults removeObjectForKey:kMPTestPrinterModelKey];
    [defaults removeObjectForKey:kMPTestPrinterLocationKey];
    [defaults synchronize];
}

#pragma mark - Settings helpers

- (NSDictionary *)defaultSettings
{
    return @{
             kMPTestPaperSizeKey:[NSNumber numberWithUnsignedInteger:MPPaperSizeLetter],
             kMPTestPaperTypeKey:[NSNumber numberWithUnsignedInteger:MPPaperTypePlain],
             kMPTestPrinterIdKey:[NSNull null],
             kMPTestPrinterNameKey:@"fake printer",
             kMPTestPrinterURLKey:@"http://fake.url",
             kMPTestPrinterNetworkKey:@"fakenet",
             kMPTestPrinterLatitudeCoordinateKey:[NSNumber numberWithFloat:1.23456],
             kMPTestPrinterLongitudeCoordinateKey:[NSNumber numberWithFloat:6.54321],
             kMPTestPrinterModelKey:@"fake model",
             kMPTestPrinterLocationKey:@"Disneyland",
             kMPTestPrinterAvailableKey:[NSNumber numberWithBool:YES],
             kMPTestBlackAndWhiteKey:[NSNumber numberWithBool:YES],
             kMPTestNumberOfCopiesKey:[NSNumber numberWithUnsignedInteger:5]
             };
}

- (NSDictionary *)customSettings
{
    return @{
             kMPTestPaperSizeKey:[NSNumber numberWithUnsignedInteger:MPPaperSizeA6],
             kMPTestPaperTypeKey:[NSNumber numberWithUnsignedInteger:MPPaperTypePhoto],
             kMPTestPrinterIdKey:@"other printer ID",
             kMPTestPrinterNameKey:@"other printer",
             kMPTestPrinterURLKey:@"http://other.url",
             kMPTestPrinterNetworkKey:@"othernet",
             kMPTestPrinterLatitudeCoordinateKey:[NSNumber numberWithFloat:2.468],
             kMPTestPrinterLongitudeCoordinateKey:[NSNumber numberWithFloat:8.642],
             kMPTestPrinterModelKey:@"other model",
             kMPTestPrinterLocationKey:@"Disneyworld",
             kMPTestPrinterAvailableKey:[NSNumber numberWithBool:NO],
             kMPTestBlackAndWhiteKey:[NSNumber numberWithBool:NO]
             };
}

- (MPPrintSettings *)printSettingsWithValues:(NSDictionary *)values
{
    MPPrintSettings *printSettings = [[MPPrintSettings alloc] init];
    printSettings.printerId = [values objectForKey:kMPTestPrinterIdKey];
    printSettings.printerName = [values objectForKey:kMPTestPrinterNameKey];
    printSettings.printerUrl = [NSURL URLWithString:[values objectForKey:kMPTestPrinterURLKey]];
    printSettings.printerModel= [values objectForKey:kMPTestPrinterModelKey];
    printSettings.printerLocation= [values objectForKey:kMPTestPrinterLocationKey];
    printSettings.printerIsAvailable = [[values objectForKey:kMPTestPrinterAvailableKey] boolValue];
    printSettings.color = ![[values objectForKey:kMPTestPrinterAvailableKey] boolValue];
    printSettings.paper = [[MPPaper alloc] initWithPaperSize:[[values objectForKey:kMPTestPaperSizeKey] unsignedIntegerValue] paperType:[[values objectForKey:kMPTestPaperTypeKey] unsignedIntegerValue] ];
    return printSettings;
}

- (void)verifySettings:(NSDictionary *)expectedSettings
{
    XCTAssert(
              _printManager.options == MPPrintManagerOriginDirect ,
              @"Expected options to equal MPPrintManagerOriginDirect");
    
    [self checkSetting:@"Printer ID" value:_printManager.currentPrintSettings.printerId expected:[expectedSettings objectForKey:kMPTestPrinterIdKey]];
    [self checkSetting:@"Printer Name" value:_printManager.currentPrintSettings.printerName expected:[expectedSettings objectForKey:kMPTestPrinterNameKey]];
    [self checkSetting:@"Printer URL" value:_printManager.currentPrintSettings.printerUrl.absoluteString expected:[expectedSettings objectForKey:kMPTestPrinterURLKey]];
    [self checkSetting:@"Printer Model" value:_printManager.currentPrintSettings.printerModel expected:[expectedSettings objectForKey:kMPTestPrinterModelKey]];
    [self checkSetting:@"Printer Location" value:_printManager.currentPrintSettings.printerLocation expected:[expectedSettings objectForKey:kMPTestPrinterLocationKey]];
    
    NSString *value = [NSString stringWithFormat:@"%ul", _printManager.currentPrintSettings.printerIsAvailable];
    NSString *expected = [NSString stringWithFormat:@"%ul", [[expectedSettings objectForKey:kMPTestPrinterAvailableKey] boolValue]];
    [self checkSetting:@"Printer Available" value:value expected:expected];
    
    value = [NSString stringWithFormat:@"%ul", _printManager.currentPrintSettings.color];
    BOOL blackAndWhite = IS_OS_8_OR_LATER ? [[expectedSettings objectForKey:kMPTestBlackAndWhiteKey] boolValue]: NO;
    expected = [NSString stringWithFormat:@"%ul", !blackAndWhite];
    [self checkSetting:@"Color Filter" value:value expected:expected];
    
    value = [NSString stringWithFormat:@"%lul", (unsigned long)_printManager.currentPrintSettings.paper.paperSize];
    expected = [NSString stringWithFormat:@"%lul", [[expectedSettings objectForKey:kMPTestPaperSizeKey] unsignedLongValue]];
    [self checkSetting:@"Paper Size" value:value expected:expected];
    
    value = [NSString stringWithFormat:@"%lul", (unsigned long)_printManager.currentPrintSettings.paper.paperType];
    expected = [NSString stringWithFormat:@"%lul", [[expectedSettings objectForKey:kMPTestPaperTypeKey] unsignedLongValue]];
    [self checkSetting:@"Paper Type" value:value expected:expected];
}

- (void)checkSetting:(NSString *)setting value:(NSString *)value expected:(id)expected
{
    if ([NSNull null] == expected || nil == expected) {
        XCTAssert(
                  value == nil,
                  @"%@ (%@) should be nil",
                  setting,
                  value);
        
    } else {
        XCTAssert(
                  [value isEqualToString:expected],
                  @"%@ (%@) does not match expected (%@)",
                  setting,
                  value,
                  expected);
    }
}

@end


