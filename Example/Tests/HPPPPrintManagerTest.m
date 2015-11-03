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
#import <HPPP.h>
#import <HPPPPaper.h>
#import <HPPPPrintManager.h>
#import <HPPPPrintManager+Options.h>

@interface HPPPPrintManagerTest : XCTestCase

@end

@implementation HPPPPrintManagerTest
{
    HPPPPrintManager *_printManager;
}

NSString * const kHPPPTestPaperSizeKey = @"kHPPPLastPaperSizeSetting";
NSString * const kHPPPTestPaperTypeKey = @"kHPPPLastPaperTypeSetting";
NSString * const kHPPPTestBlackAndWhiteKey = @"kHPPPLastBlackAndWhiteFilterSetting";
NSString * const kHPPPTestPrinterIdKey = @"kHPPPTestPrinterIdKey";
NSString * const kHPPPTestPrinterNameKey = @"kDefaultPrinterNameKey";
NSString * const kHPPPTestPrinterURLKey = @"kDefaultPrinterURLKey";
NSString * const kHPPPTestPrinterNetworkKey = @"kDefaultPrinterNetworkKey";
NSString * const kHPPPTestPrinterLatitudeCoordinateKey = @"kDefaultPrinterLatitudeCoordinateKey";
NSString * const kHPPPTestPrinterLongitudeCoordinateKey = @"kDefaultPrinterLongitudeCoordinateKey";
NSString * const kHPPPTestPrinterModelKey = @"kDefaultPrinterModelKey";
NSString * const kHPPPTestPrinterLocationKey = @"kDefaultPrinterLocationKey";
NSString * const kHPPPTestPrinterAvailableKey = @"kHPPPTestPrinterAvailableKey";
NSString * const kHPPPTestNumberOfCopiesKey = @"kHPPPTestNumberOfCopiesKey";

#pragma mark - Setup tests

- (void)setUp
{
    [super setUp];
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
    _printManager = [[HPPPPrintManager alloc] init];
    [self verifySettings:[self defaultSettings]];
}

- (void)testInitNoLastPaper
{
    NSUserDefaults * defaults = [NSUserDefaults standardUserDefaults];
    [defaults removeObjectForKey:kHPPPTestPaperSizeKey];
    [defaults removeObjectForKey:kHPPPTestPaperTypeKey];
    [defaults synchronize];
    
    NSMutableDictionary *noPaperSettings = [NSMutableDictionary dictionaryWithDictionary:[self defaultSettings]];
    NSNumber *defaultSize = [NSNumber numberWithUnsignedInteger:[HPPP sharedInstance].defaultPaper.paperSize];
    NSNumber *defaultType = [NSNumber numberWithUnsignedInteger:[HPPP sharedInstance].defaultPaper.paperType];
    [noPaperSettings setObject:defaultSize forKey:kHPPPTestPaperSizeKey];
    [noPaperSettings setObject:defaultType forKey:kHPPPTestPaperTypeKey];
    
    _printManager = [[HPPPPrintManager alloc] init];
    [self verifySettings:noPaperSettings];
}

#pragma mark - Test 'initWithPrintSettings'

- (void)testInitWithPrintSettings
{
    NSDictionary *customSettings = [self customSettings];
    HPPPPrintSettings *printSettings = [self printSettingsWithValues:customSettings];
    _printManager = [[HPPPPrintManager alloc] initWithPrintSettings:printSettings];
    [self verifySettings:customSettings];
}

- (void)testInitWithPrintSettingsUseLastPaper
{
    NSNumber *expectedPaperSize = [[self defaultSettings] objectForKey:kHPPPTestPaperSizeKey];
    NSNumber *expectedPaperType = [[self defaultSettings] objectForKey:kHPPPTestPaperTypeKey];
    NSMutableDictionary *useLastPaperSettings = [NSMutableDictionary dictionaryWithDictionary:[self customSettings]];
    [useLastPaperSettings setObject:expectedPaperSize forKey:kHPPPTestPaperSizeKey];
    [useLastPaperSettings setObject:expectedPaperType forKey:kHPPPTestPaperTypeKey];
    
    HPPPPrintSettings *printSettings = [self printSettingsWithValues:useLastPaperSettings];
    printSettings.paper = nil;
    
    _printManager = [[HPPPPrintManager alloc] initWithPrintSettings:printSettings];
    [self verifySettings:useLastPaperSettings];
}

- (void)testInitWithPrintSettingsNoLastPaper
{
    NSNumber *expectedPaperSize = [NSNumber numberWithUnsignedInteger:[HPPP sharedInstance].defaultPaper.paperSize];
    NSNumber *expectedPaperType = [NSNumber numberWithUnsignedInteger:[HPPP sharedInstance].defaultPaper.paperType];
    NSMutableDictionary *noPaperSettings = [NSMutableDictionary dictionaryWithDictionary:[self customSettings]];
    [noPaperSettings setObject:expectedPaperSize forKey:kHPPPTestPaperSizeKey];
    [noPaperSettings setObject:expectedPaperType forKey:kHPPPTestPaperTypeKey];
    
    HPPPPrintSettings *printSettings = [self printSettingsWithValues:noPaperSettings];
    printSettings.paper = nil;
    
    NSUserDefaults * defaults = [NSUserDefaults standardUserDefaults];
    [defaults removeObjectForKey:kHPPPTestPaperSizeKey];
    [defaults removeObjectForKey:kHPPPTestPaperTypeKey];
    [defaults synchronize];
    
    _printManager = [[HPPPPrintManager alloc] initWithPrintSettings:printSettings];
    [self verifySettings:noPaperSettings];
}

#pragma mark - Test 'saveLastOptionsForPrinter'

- (void)testsaveLastOptionsForPrinter
{
    NSDictionary *defaultSettings = [self defaultSettings];
    [HPPP sharedInstance].lastOptionsUsed = @{};
    _printManager = [[HPPPPrintManager alloc] init];
    _printManager.numberOfCopies = [[defaultSettings objectForKey:kHPPPTestNumberOfCopiesKey] integerValue];
    [_printManager saveLastOptionsForPrinter:@"fake printer"];
    
    HPPPPaper *expectedPaper = [[HPPPPaper alloc] initWithPaperSize:[[defaultSettings objectForKey:kHPPPTestPaperSizeKey] unsignedIntegerValue] paperType:[[defaultSettings objectForKey:kHPPPTestPaperTypeKey] unsignedIntegerValue] ];
    
    NSString *paperSize = [[HPPP sharedInstance].lastOptionsUsed objectForKey:kHPPPPaperSizeId];
    XCTAssert([expectedPaper.sizeTitle isEqualToString:paperSize], @"Expected last paper size (%@) to equal expected paper size (%@)", paperSize, expectedPaper.sizeTitle);

    NSString *paperType = [[HPPP sharedInstance].lastOptionsUsed objectForKey:kHPPPPaperTypeId];
    XCTAssert([expectedPaper.typeTitle isEqualToString:paperType], @"Expected last paper type (%@) to equal expected paper type (%@)", paperType, expectedPaper.typeTitle);

    NSNumber *width = [[HPPP sharedInstance].lastOptionsUsed objectForKey:kHPPPPaperWidthId];
    XCTAssert([width floatValue] == expectedPaper.width, @"Expected last paper width (%.3f) to equal expected paper width (%.3f)", [width floatValue], expectedPaper.width);

    NSNumber *height = [[HPPP sharedInstance].lastOptionsUsed objectForKey:kHPPPPaperHeightId];
    XCTAssert([height floatValue] == expectedPaper.height, @"Expected last paper height (%.3f) to equal expected paper height (%.3f)", [height floatValue], expectedPaper.height);
    
    NSNumber *expectedBlackAndWhite = IS_OS_8_OR_LATER ? [defaultSettings objectForKey:kHPPPTestBlackAndWhiteKey] : [NSNumber numberWithBool:NO];
    XCTAssert(
              expectedBlackAndWhite == [[HPPP sharedInstance].lastOptionsUsed objectForKey:kHPPPBlackAndWhiteFilterId],
              @"Expected last B/W option (%@) to equal expected B/W option (%@)",
              [[HPPP sharedInstance].lastOptionsUsed objectForKey:kHPPPPaperTypeId],
              expectedBlackAndWhite);
    
    XCTAssert(
              [defaultSettings objectForKey:kHPPPTestNumberOfCopiesKey] == [[HPPP sharedInstance].lastOptionsUsed objectForKey:kHPPPNumberOfCopies],
              @"Expected last number of copies (%@) to equal expected number of copies (%@)",
              [defaultSettings objectForKey:kHPPPTestNumberOfCopiesKey],
              [[HPPP sharedInstance].lastOptionsUsed objectForKey:kHPPPNumberOfCopies]);
    
    // TODO: still need to test "no printer" and "printer mismatch" scenarios
}

#pragma mark - Defaults helpers

- (void)setLastOptions
{
    NSDictionary *defaultSettings = [self defaultSettings];
    NSUserDefaults * defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:[defaultSettings objectForKey:kHPPPTestPaperSizeKey] forKey:kHPPPTestPaperSizeKey];
    [defaults setObject:[defaultSettings objectForKey:kHPPPTestPaperTypeKey] forKey:kHPPPTestPaperTypeKey];
    [defaults setObject:[defaultSettings objectForKey:kHPPPTestBlackAndWhiteKey] forKey:kHPPPTestBlackAndWhiteKey];
    [defaults synchronize];
}

- (void)setDefaultValues
{
    NSDictionary *defaultSettings = [self defaultSettings];
    NSUserDefaults * defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:[defaultSettings objectForKey:kHPPPTestPrinterNameKey] forKey:kHPPPTestPrinterNameKey];
    [defaults setObject:[defaultSettings objectForKey:kHPPPTestPrinterURLKey] forKey:kHPPPTestPrinterURLKey];
    [defaults setObject:[defaultSettings objectForKey:kHPPPTestPrinterNetworkKey] forKey:kHPPPTestPrinterNetworkKey];
    [defaults setObject:[defaultSettings objectForKey:kHPPPTestPrinterLatitudeCoordinateKey] forKey:kHPPPTestPrinterLatitudeCoordinateKey];
    [defaults setObject:[defaultSettings objectForKey:kHPPPTestPrinterLongitudeCoordinateKey] forKey:kHPPPTestPrinterLongitudeCoordinateKey];
    [defaults setObject:[defaultSettings objectForKey:kHPPPTestPrinterModelKey] forKey:kHPPPTestPrinterModelKey];
    [defaults setObject:[defaultSettings objectForKey:kHPPPTestPrinterLocationKey] forKey:kHPPPTestPrinterLocationKey];
    [defaults synchronize];
}

- (void)resetUserDefaults
{
    NSUserDefaults * defaults = [NSUserDefaults standardUserDefaults];
    [defaults removeObjectForKey:kHPPPTestPaperSizeKey];
    [defaults removeObjectForKey:kHPPPTestPaperTypeKey];
    [defaults removeObjectForKey:kHPPPTestBlackAndWhiteKey];
    [defaults removeObjectForKey:kHPPPTestPrinterNameKey];
    [defaults removeObjectForKey:kHPPPTestPrinterURLKey];
    [defaults removeObjectForKey:kHPPPTestPrinterNetworkKey];
    [defaults removeObjectForKey:kHPPPTestPrinterLatitudeCoordinateKey];
    [defaults removeObjectForKey:kHPPPTestPrinterLongitudeCoordinateKey];
    [defaults removeObjectForKey:kHPPPTestPrinterModelKey];
    [defaults removeObjectForKey:kHPPPTestPrinterLocationKey];
    [defaults synchronize];
}

#pragma mark - Settings helpers

- (NSDictionary *)defaultSettings
{
    return @{
             kHPPPTestPaperSizeKey:[NSNumber numberWithUnsignedInteger:HPPPPaperSizeLetter],
             kHPPPTestPaperTypeKey:[NSNumber numberWithUnsignedInteger:HPPPPaperTypePlain],
             kHPPPTestPrinterIdKey:[NSNull null],
             kHPPPTestPrinterNameKey:@"fake printer",
             kHPPPTestPrinterURLKey:@"http://fake.url",
             kHPPPTestPrinterNetworkKey:@"fakenet",
             kHPPPTestPrinterLatitudeCoordinateKey:[NSNumber numberWithFloat:1.23456],
             kHPPPTestPrinterLongitudeCoordinateKey:[NSNumber numberWithFloat:6.54321],
             kHPPPTestPrinterModelKey:@"fake model",
             kHPPPTestPrinterLocationKey:@"Disneyland",
             kHPPPTestPrinterAvailableKey:[NSNumber numberWithBool:YES],
             kHPPPTestBlackAndWhiteKey:[NSNumber numberWithBool:YES],
             kHPPPTestNumberOfCopiesKey:[NSNumber numberWithUnsignedInteger:5]
             };
}

- (NSDictionary *)customSettings
{
    return @{
             kHPPPTestPaperSizeKey:[NSNumber numberWithUnsignedInteger:HPPPPaperSizeA6],
             kHPPPTestPaperTypeKey:[NSNumber numberWithUnsignedInteger:HPPPPaperTypePhoto],
             kHPPPTestPrinterIdKey:@"other printer ID",
             kHPPPTestPrinterNameKey:@"other printer",
             kHPPPTestPrinterURLKey:@"http://other.url",
             kHPPPTestPrinterNetworkKey:@"othernet",
             kHPPPTestPrinterLatitudeCoordinateKey:[NSNumber numberWithFloat:2.468],
             kHPPPTestPrinterLongitudeCoordinateKey:[NSNumber numberWithFloat:8.642],
             kHPPPTestPrinterModelKey:@"other model",
             kHPPPTestPrinterLocationKey:@"Disneyworld",
             kHPPPTestPrinterAvailableKey:[NSNumber numberWithBool:NO],
             kHPPPTestBlackAndWhiteKey:[NSNumber numberWithBool:NO]
             };
}

- (HPPPPrintSettings *)printSettingsWithValues:(NSDictionary *)values
{
    HPPPPrintSettings *printSettings = [[HPPPPrintSettings alloc] init];
    printSettings.printerId = [values objectForKey:kHPPPTestPrinterIdKey];
    printSettings.printerName = [values objectForKey:kHPPPTestPrinterNameKey];
    printSettings.printerUrl = [NSURL URLWithString:[values objectForKey:kHPPPTestPrinterURLKey]];
    printSettings.printerModel= [values objectForKey:kHPPPTestPrinterModelKey];
    printSettings.printerLocation= [values objectForKey:kHPPPTestPrinterLocationKey];
    printSettings.printerIsAvailable = [[values objectForKey:kHPPPTestPrinterAvailableKey] boolValue];
    printSettings.color = ![[values objectForKey:kHPPPTestPrinterAvailableKey] boolValue];
    printSettings.paper = [[HPPPPaper alloc] initWithPaperSize:[[values objectForKey:kHPPPTestPaperSizeKey] unsignedIntegerValue] paperType:[[values objectForKey:kHPPPTestPaperTypeKey] unsignedIntegerValue] ];
    return printSettings;
}

- (void)verifySettings:(NSDictionary *)expectedSettings
{
    XCTAssert(
              _printManager.options == HPPPPrintManagerOriginDirect ,
              @"Expected options to equal HPPPPrintManagerOriginDirect");
    
    [self checkSetting:@"Printer ID" value:_printManager.currentPrintSettings.printerId expected:[expectedSettings objectForKey:kHPPPTestPrinterIdKey]];
    [self checkSetting:@"Printer Name" value:_printManager.currentPrintSettings.printerName expected:[expectedSettings objectForKey:kHPPPTestPrinterNameKey]];
    [self checkSetting:@"Printer URL" value:_printManager.currentPrintSettings.printerUrl.absoluteString expected:[expectedSettings objectForKey:kHPPPTestPrinterURLKey]];
    [self checkSetting:@"Printer Model" value:_printManager.currentPrintSettings.printerModel expected:[expectedSettings objectForKey:kHPPPTestPrinterModelKey]];
    [self checkSetting:@"Printer Location" value:_printManager.currentPrintSettings.printerLocation expected:[expectedSettings objectForKey:kHPPPTestPrinterLocationKey]];
    
    NSString *value = [NSString stringWithFormat:@"%ul", _printManager.currentPrintSettings.printerIsAvailable];
    NSString *expected = [NSString stringWithFormat:@"%ul", [[expectedSettings objectForKey:kHPPPTestPrinterAvailableKey] boolValue]];
    [self checkSetting:@"Printer Available" value:value expected:expected];
    
    value = [NSString stringWithFormat:@"%ul", _printManager.currentPrintSettings.color];
    BOOL blackAndWhite = IS_OS_8_OR_LATER ? [[expectedSettings objectForKey:kHPPPTestBlackAndWhiteKey] boolValue]: NO;
    expected = [NSString stringWithFormat:@"%ul", !blackAndWhite];
    [self checkSetting:@"Color Filter" value:value expected:expected];
    
    value = [NSString stringWithFormat:@"%lul", (unsigned long)_printManager.currentPrintSettings.paper.paperSize];
    expected = [NSString stringWithFormat:@"%ul", [[expectedSettings objectForKey:kHPPPTestPaperSizeKey] unsignedIntegerValue]];
    [self checkSetting:@"Paper Size" value:value expected:expected];
    
    value = [NSString stringWithFormat:@"%lul", (unsigned long)_printManager.currentPrintSettings.paper.paperType];
    expected = [NSString stringWithFormat:@"%ul", [[expectedSettings objectForKey:kHPPPTestPaperTypeKey] unsignedIntegerValue]];
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
