# HPPhotoPrint

[![Version](https://img.shields.io/badge/pod-2.6.9-blue.svg)](http://hppp.herokuapp.com)
[![Platform](https://img.shields.io/badge/platform-ios-lightgrey.svg)](http://hppp.herokuapp.com)
[![Awesome](https://img.shields.io/badge/awesomeness-verified-green.svg)](http://hppp.herokuapp.com)

## Contents

- [Documentation](#documentation)
- [Installation](#installation)
- [Usage](#usage)
    - [Print Workflow](#print-workflow)
        - [Share Activity (Print)](#share-activity-print)
        - [View Controller](#view-controller)
        - [Direct Print](#direct-print)
        - [Protocols](#protocols)
            - [Print Delegate](#print-delegate)
            - [Print Data Source](#print-data-source)
            - [Print Paper Delegate](#print-paper-delegate)
        - [Customization](#customization)
            - [Appearance](#appearance)
            - [Interface Options](#interface-options)
            - [Print Paper](#print-paper)
            - [Print Layout](#print-layout)
    - [Print Later Workflow](#print-later-workflow)
        - [Print Job](#print-job)
        - [Share Activity (Add Job)](#share-activity-add-job)
        - [Show Print Queue](#show-print-queue)
    - [Printer Notifications](#printer-notifications)
        - [Project Capabilities](#project-capabilities)
        - [Entries in `plist` File](#entries-in-plist-file)
        - [App Delegate](#app-delegate)
        - [Registering Notifications](#registering-notifications)
- [Author](#author)
- [License](#license)

## Documentation

Reference documentation can be found at http://hppp.herokuapp.com. This includes complete documentation for all classes, properties, methods, constants, and so on.

Release notes can be found [here](https://github.com/IPGPTP/hp_photo_print/wiki/Release-Notes) on the Wiki page.

## Installation

The __HPPhotoPrint__ pod is not yet available publicly (i.e. via [cocoapods.org](http://cocoapods.org)). To install the pod you must have read access to this repo ([hp\_photo\_print](https://github.com/IPGPTP/hp_photo_print)) as well as HP's private pod trunk ([hp\_mss\_pods](https://github.com/IPGPTP/hp_mss_pods)). To request access complete this [form](http://downloads.print-dev.com/mobile-print-sdk).

Add the private pod trunk as a source in your `Podfile`. It is important that this entry is before the source for the public Cocoapod trunk:

    source 'https://github.com/IPGPTP/hp_mss_pods.git'

Add an entry for the __HPPhotoPrint__ pod with the desired version number:

    pod 'HPPhotoPrint', '2.6.9'

On the command line, switch to the directory containing the `Podfile` and run the install command:

    pod install

The following is an example of a typical complete `Podfile`:

 ```ruby

platform :ios, '7.0'

source 'https://github.com/IPGPTP/hp_mss_pods.git'
source 'https://github.com/CocoaPods/Specs.git'

pod 'GoogleAnalytics-iOS-SDK'
pod 'TTTAttributedLabel', '~> 1.10.1'
pod 'XMLDictionary', '~> 1.4.0'
pod 'CocoaLumberjack', '1.9.1'
pod 'HPPhotoPrint', '2.6.9'
pod 'ZipArchive', '1.4.0'

xcodeproj 'MyProject/MyProject.xcodeproj'

```

## Usage

The __HPPhotoPrint__ pod provides three main features.

1. A print workflow that provides enhanced features beyond what standard iOS AirPrint provides (e.g. graphical print preview).
2. A print queue that allows users to save jobs for printing later.
3. The ability to notify the user with a reminder when they return to their printer area and have jobs in queue.

### Print Workflow

The print workflow can be invoked in one of three ways:

- The first is through the __standard iOS sharing__ view using a custom print activity provided by the pod. 
- The second is to present the __printing view controller__ directly, for example when the user taps a "print" button in your app. 
- The third method is __print directly__ without showing a UI. This is useful when all print settings have already been set/saved.

All print methods can make use of a delegate to handle print completion (and canceling). 
A custom data source can be provided by your app which allows it provide custom print assets (e.g. image, PDF) when the user selects different paper sizes.
And finally, you can customize the appearance of printing views and how the print is laid out on the page.

#### Share Activity (Print)

To use the sharing activity, you configure and present the iOS share panel (see [`UIActivityViewController`](https://developer.apple.com/library/ios/documentation/UIKit/Reference/UIActivityViewController_Class/)). 
In the configuration, you include the [`HPPPPrintActivity`](http://hppp.herokuapp.com/HPPPPrintActivity_h/Classes/HPPPPrintActivity/index.html) provided by the pod. 
You must provide a single printable image as part of the initial sharing setup, but prior to printing you can optionally customize the image via the data source described below.

> __Tip:__ It is strongly advised that you also remove the built-in iOS print activity to avoid confusion (see [`UIActivityTypePrint`](https://developer.apple.com/library/ios/documentation/UIKit/Reference/UIActivity_Class/index.html#//apple_ref/doc/constant_group/Built_in_Activity_Types)). 

```objc

- (IBAction)shareBarButtonItemTap:(id)sender
{
    HPPPPrintActivity *printActivity = [[HPPPPrintActivity alloc] init];
    printActivity.dataSource = self;
    NSArray *applicationActivities = @[printActivity];
    UIImage *printableItem = [UIImage imageNamed:@"sample.jpg"];
    NSArray *activitiesItems = @[printableItem];
    UIActivityViewController *activityViewController = [[UIActivityViewController alloc] initWithActivityItems:activitiesItems applicationActivities:applicationActivities];
    activityViewController.excludedActivityTypes = @[UIActivityTypePrint];
    activityViewController.completionHandler = ^(NSString *activityType, BOOL completed) {
        if (completed) {
            NSLog(@"Activity completed");
        } else {
            NSLog(@"Activity NOT completed");
        }
    };
    [self presentViewController:activityViewController animated:YES completion:nil];
}

```

#### View Controller

To present the print workflow directly without using the sharing view, obtain and present the printing view controller. 
You can obtain the view controller configured for your device and iOS version using the [utility method](http://hppp.herokuapp.com/HPPP_h/Classes/HPPP/index.html#//apple_ref/occ/instm/HPPP/printViewControllerWithDelegate:dataSource:image:fromQueue:) provided by the [`HPPP`](http://hppp.herokuapp.com/HPPP_h/Classes/HPPP/index.html) class.
You must provide an initial image and optional delegate and data source (described below).

```objc

- (IBAction)printButtonTapped:(id)sender {
    UIViewController *vc = [[HPPP sharedInstance] printViewControllerWithDelegate:self dataSource:self image:[UIImage imageNamed:@"sample.jpg"] fromQueue:NO];
    [self presentViewController:vc animated:YES completion:nil];
}

```
#### Direct Print

To print directly without showing a user interface (e.g. print preview), you create an instance of an [HPPPPrintManager](http://hppp.herokuapp.com/HPPPPrintManager_h/Classes/HPPPPrintManager/index.html) and call the [print:pageRange:numCopies:error](http://hppp.herokuapp.com/HPPPPrintManager_h/Classes/HPPPPrintManager/index.html#//apple_ref/occ/instm/HPPPPrintManager/print:pageRange:numCopies:error:) method.
You can initialize the print manager to use the default/stored settings or you can pass in your own [HPPPPrintSettings](http://hppp.herokuapp.com/HPPPPrintSettings_h/Classes/HPPPPrintSettings/index.html) object. 
Once initialized you can call the [print:pageRange:numCopies:error](http://hppp.herokuapp.com/HPPPPrintManager_h/Classes/HPPPPrintManager/index.html#//apple_ref/occ/instm/HPPPPrintManager/print:pageRange:numCopies:error:) method and use the [HPPPPrintManagerDelegate](http://hppp.herokuapp.com/HPPPPrintManager_h/Protocols/HPPPPrintManagerDelegate/index.html) to be notified when the print job is queued succesfully.

> __Tip:__ You can use the [`HPPP`](http://hppp.herokuapp.com/HPPP_h/Classes/HPPP/index.html) object's [printViewControllerWithDelegate:dataSource:printItem:fromQueue:settingsOnly](http://hppp.herokuapp.com/HPPP_h/Classes/HPPP/index.html#//apple_ref/occ/instm/HPPP/printViewControllerWithDelegate:dataSource:printItem:fromQueue:settingsOnly:) method (with `settingsOnly` = `YES`) to obtain and present a print settings view controller that allows the user to choose settings such as printer and paper size.

```objc

- (void)print:(HPPPPrintItem *)printItem
{
    HPPPPrintManager *printManager = [[HPPPPrintManager alloc] init];

    NSError *error;
    [printManager print:printItem
              pageRange:nil
              numCopies:1
                  error:&error];

    if (HPPPPrintManagerErrorNone != error.code) {
        NSString *reason;
        switch (error.code) {
            case HPPPPrintManagerErrorNoPaperType:
                reason = @"No paper type selected";
                break;
            case HPPPPrintManagerErrorNoPrinterUrl:
                reason = @"No printer URL";
                break;
            case HPPPPrintManagerErrorPrinterNotAvailable:
                reason = @"Printer not available";
                break;
            case HPPPPrintManagerErrorDirectPrintNotSupported:
                reason = @"Direct print is not supported";
                break;
            case HPPPPrintManagerErrorUnknown:
                reason = @"Unknown error";
                break;
            default:
                break;
        }
        [[[UIAlertView alloc] initWithTitle:@"Direct Print Failed"
                                    message:[NSString stringWithFormat:@"Reason: %@",reason]
                                   delegate:nil
                          cancelButtonTitle:@"OK"
                          otherButtonTitles:nil] show];
    }
}

```
#### Protocols

For each of the printing methods it is possible to provide a delegate and a data source. 
The delegate handles completion and cancelation of the print flow while the data source provides a callback for providing a custom print asset for each specific paper sizes.

##### Print Delegate

The printing delegate ([`HPPPPrintDelegate`](http://hppp.herokuapp.com/HPPP_h/Protocols/HPPPPrintDelegate/index.html)) allows you to respond when the print flow is completed or canceled.
If you want to dismiss the printing view controller after printing is complete, use this delegate.

> __Note:__ The print flow completes when the job is sent to the print and queued. This does not mean that the job has actually finished printing on the printer. There is ability to notify when the job is fully complete, only when it is queued for printing.

```objc

- (void)didFinishPrintFlow:(UIViewController *)printViewController;
{
    [printViewController dismissViewControllerAnimated:YES completion:nil];
}

- (void)didCancelPrintFlow:(UIViewController *)printViewController;
{
    [printViewController dismissViewControllerAnimated:YES completion:nil];
}

```

##### Print Data Source

You can optionally provide a printing data source by implementing the [`HPPPPrintDataSource`](http://hppp.herokuapp.com/HPPP_h/Protocols/HPPPPrintDataSource/index.html) protocol. This allows you to control what gets printed for any given paper size. 
When you implement this protocol you will get a request for a new printable item each time the user selects a different paper size. When preparing the item for the given paper size you can also specify a layout (see [Print Layout](#print-layout)).

To specify multiple items for printing you can implement the protocol method [`numberOfPrintingItems`](http://hppp.herokuapp.com/HPPP_h/Protocols/HPPPPrintDataSource/index.html#//apple_ref/occ/intfm/HPPPPrintDataSource/numberOfPrintingItems) to specify the number of separate items to be printed. Then implement the [`printingItemsForPaper:`](http://hppp.herokuapp.com/HPPP_h/Protocols/HPPPPrintDataSource/index.html#//apple_ref/occ/intfm/HPPPPrintDataSource/printingItemsForPaper:) method to specify the list of items and, optionally, implement additional methods to supply details about the print job for each item (e.g. [`blackAndWhiteSelections`](http://hppp.herokuapp.com/HPPP_h/Protocols/HPPPPrintDataSource/index.html#//apple_ref/occ/intfm/HPPPPrintDataSource/blackAndWhiteSelections), [`numberOfCopiesSelections`](http://hppp.herokuapp.com/HPPP_h/Protocols/HPPPPrintDataSource/index.html#//apple_ref/occ/intfm/HPPPPrintDataSource/numberOfCopiesSelections), [`pageRangeSelections`](http://hppp.herokuapp.com/HPPP_h/Protocols/HPPPPrintDataSource/index.html#//apple_ref/occ/intfm/HPPPPrintDataSource/pageRangeSelections)). As an alternative, you can simply implement [`printLaterJobs`](http://hppp.herokuapp.com/HPPP_h/Protocols/HPPPPrintDataSource/index.html#//apple_ref/occ/intfm/HPPPPrintDataSource/printLaterJobs) to supply an array of [`HPPPPrintLaterJob`](http://hppp.herokuapp.com/HPPPPrintLaterJob_h/Classes/HPPPPrintLaterJob/index.html) objects that each contain full information about their print item and job details, but you will still need to implement the [`numberOfPrintingItems`](http://hppp.herokuapp.com/HPPP_h/Protocols/HPPPPrintDataSource/index.html#//apple_ref/occ/intfm/HPPPPrintDataSource/numberOfPrintingItems) method.

> __Tip:__ Regardless which type of data source you provide, it is important to implement the [`previewImageForPaper:withCompletion`](http://hppp.herokuapp.com//HPPP_h/Protocols/HPPPPrintDataSource/index.html#//apple_ref/occ/intfm/HPPPPrintDataSource/previewImageForPaper:withCompletion:) method and provide a single image to use as a preview in the on-screen print user interface.

###### Data Source Examples

_Single Job_

```objc

- (void)printingItemForPaper:(HPPPPaper *)paper withCompletion:(void (^)(HPPPPrintItem *printItem))completion;
{
    if (completion) {
        completion([self.printItemList objectForKey:paper.paperSize]);
    }
}

- (void)previewImageForPaper:(HPPPPaper *)paper withCompletion:(void (^)(UIImage *previewImage))completion
{
    if (completion) {
        completion([self.previewImageList objectForKey:paper.paperSize]);
    }
}

```

_Multiple Jobs with [HPPPPrintItem](http://hppp.herokuapp.com/HPPPPrintItem_h/Classes/HPPPPrintItem/index.html) Objects_

```objc

- (NSInteger)numberOfPrintingItems
{
    return 3;
}

- (NSArray *)printingItemsForPaper:(HPPPPaper *)paper
{
    HPPPPrintItem *printItem1 = [HPPPPrintItemFactory printItemWithAsset:[UIImage imageNamed:@"sample1.jpg"]];
    printItem1.layout = [HPPPLayoutFactory layoutWithType:[HPPPLayoutFill layoutType]];

    HPPPPrintItem *printItem2 = [HPPPPrintItemFactory printItemWithAsset:[UIImage imageNamed:@"sample2.jpg"]];
    printItem2.layout = [HPPPLayoutFactory layoutWithType:[HPPPLayoutFill layoutType]];

    HPPPPrintItem *printItem3 = [HPPPPrintItemFactory printItemWithAsset:[UIImage imageNamed:@"sample3.jpg"]];
    printItem3.layout = [HPPPLayoutFactory layoutWithType:[HPPPLayoutFill layoutType]];

    return @[ printItem1, printItem2, printItem3 ];
}

- (NSArray *)blackAndWhiteSelections
{
    return @[
        [NSNumber numberWithBool:YES],
        [NSNumber numberWithBool:YES],
        [NSNumber numberWithBool:NO]
    ];
}

- (NSArray *)pageRangeSelections
{
    return @[
        [[HPPPPageRange alloc] initWithString:@"All" allPagesIndicator:@"All" maxPageNum:3 sortAscending:TRUE],
        [[HPPPPageRange alloc] initWithString:@"1-5" allPagesIndicator:@"All" maxPageNum:5 sortAscending:TRUE],
        [[HPPPPageRange alloc] initWithString:@"1" allPagesIndicator:@"All" maxPageNum:1 sortAscending:TRUE]
    ];
    
}

- (NSArray *)numberOfCopiesSelections
{
    return @[ 1, 1, 2 ];
}

- (void)previewImageForPaper:(HPPPPaper *)paper withCompletion:(void (^)(UIImage *previewImage))completion
{
    if (completion) {
        completion([self.previewImageList objectForKey:paper.paperSize]);
    }
}

```

_Multiple Jobs with [HPPPPrintLaterJob](http://hppp.herokuapp.com/HPPPPrintLaterJob_h/Classes/HPPPPrintLaterJob/index.html) Objects_

```objc

- (NSInteger)numberOfPrintingItems
{
    return 3;
}

- (NSArray *)printLaterJobs
{
        HPPPPrintLaterJob *job1 = [[HPPPPrintLaterJob alloc] init];
        job1.id = [[HPPP sharedInstance] nextPrintJobId];
        job1.name = @"Print Job #1";
        job1.date = [NSDate date];
        job1.printItems = @{ [HPPP sharedInstance].defaultPaper.paperSize: [UIImage imageNamed:@"sample1.jpg"]  };
        job1.numCopies = 1;
        job1.blackAndWhite = NO;
        job1.pageRange = [[HPPPPageRange alloc] initWithString:@"All" allPagesIndicator:@"All" maxPageNum:3 sortAscending:TRUE];
        
        HPPPPrintLaterJob *job2 = [[HPPPPrintLaterJob alloc] init];
        job2.id = [[HPPP sharedInstance] nextPrintJobId];
        job2.name = @"Print Job #2";
        job2.date = [NSDate date];
        job2.printItems = @{ [HPPP sharedInstance].defaultPaper.paperSize: [UIImage imageNamed:@"sample2.jpg"]  };
        job2.numCopies = 2;
        job2.blackAndWhite = NO;
        job2.pageRange = [[HPPPPageRange alloc] initWithString:@"All" allPagesIndicator:@"All" maxPageNum:3 sortAscending:TRUE];
        
        HPPPPrintLaterJob *job3 = [[HPPPPrintLaterJob alloc] init];
        job3.id = [[HPPP sharedInstance] nextPrintJobId];
        job3.name = @"Print Job #3";
        job3.date = [NSDate date];
        job3.printItems = @{ [HPPP sharedInstance].defaultPaper.paperSize: [UIImage imageNamed:@"sample3.jpg"]  };
        job3.numCopies = 3;
        job3.blackAndWhite = NO;
        job3.pageRange = [[HPPPPageRange alloc] initWithString:@"All" allPagesIndicator:@"All" maxPageNum:3 sortAscending:TRUE];

        return @[ job1, job2, job3 ];
}

- (void)previewImageForPaper:(HPPPPaper *)paper withCompletion:(void (^)(UIImage *previewImage))completion
{
    if (completion) {
        completion([self.previewImageList objectForKey:paper.paperSize]);
    }
}

```
##### Print Paper Delegate

You can optionally provide a delegate for managing paper by implementing the [`HPPPPrintPaperDelegate`](http://hppp.herokuapp.com/HPPP_h/Protocols/HPPPPrintPaperDelegate/index.html) protocol and setting the [`printPaperDelegate`](http://hppp.herokuapp.com/HPPP_h/Classes/HPPP/index.html#//apple_ref/occ/instp/HPPP/printPaperDelegate) property of the [`HPPP`](http://hppp.herokuapp.com/HPPP_h/Classes/HPPP/index.html) class.
This delegate receives callbacks that allow you to adjust paper-related features when the print settings are changed (e.g. new printer selected).
Additionally, you can choose to handle the low-level print delegate callbacks that are normally part of the [`UIPrintInteractionControllerDelegate`](https://developer.apple.com/library/prerelease/ios/documentation/UIKit/Reference/UIPrintInteractionControllerDelegate_Protocol/index.html) protocol.
These features allow you to control the paper features on a per-printer basis and support specialty printers such as roll-feed printers.

#### Customization

The appearance of the printing interface can be customized by setting properties on the shared instance of the [`HPPP`](http://hppp.herokuapp.com/HPPP_h/Classes/HPPP/index.html) class. 
The properties [`appearance`](http://hppp.herokuapp.com/HPPP_h/Classes/HPPP/index.html#//apple_ref/occ/instp/HPPP/appearance) and [`interfaceOptions`](http://hppp.herokuapp.com/HPPP_h/Classes/HPPP/index.html#//apple_ref/occ/instp/HPPP/interfaceOptions) control the look and feel.

The actual print output itself can be customized using the [`layout`](http://hppp.herokuapp.com/HPPPPrintItem_h/Classes/HPPPPrintItem/index.html#//apple_ref/occ/instp/HPPPPrintItem/layout) property of an [`HPPPPrintItem`](http://hppp.herokuapp.com/HPPPPrintItem_h/Classes/HPPPPrintItem/index.html)  object.

##### Appearance

The visual appearance of the printing user interface is controlled by setting values in the [`settings`](http://hppp.herokuapp.com//HPPPAppearance_h/Classes/HPPPAppearance/index.html#//apple_ref/occ/instp/HPPPAppearance/settings) dictionary. 
The values that can be controlled are specified by key constants defined in the [`HPPPAppearance`](http://hppp.herokuapp.com/HPPPAppearance_h/Classes/HPPPAppearance/index.html#//apple_ref/occ/cl/HPPPAppearance) class.

> __Note:__ There is graphical overview available that shows where and how the print user interface can be customized. 
> Download the [Map](http://d3fep8xjnjngo0.cloudfront.net/ios/StyleMap.pdf) and [Key](http://d3fep8xjnjngo0.cloudfront.net/ios/StyleKey.pdf) for reference.

Map  | Key
------------- | -------------
[![Map](http://d3fep8xjnjngo0.cloudfront.net/ios/map.preview.png)](http://d3fep8xjnjngo0.cloudfront.net/ios/StyleMap.pdf)  | [![Key](http://d3fep8xjnjngo0.cloudfront.net/ios/key.preview.png)](http://d3fep8xjnjngo0.cloudfront.net/ios/StyleKey.pdf)

The following example shows how to customize various fonts, colors, icons, and other values.

```objc

- (void)customizeAppearance
{
    NSString *regularFont = @"Baskerville-Bold";
    NSString *lightFont   = @"Baskerville-Italic";
    [HPPP sharedInstance].appearance.settings = @{
         
         // General
         kHPPPGeneralBackgroundColor:             [UIColor colorWithRed:0x00/255.0F green:0x00/255.0F blue:0xFF/255.0F alpha:1.0F],
         kHPPPGeneralBackgroundPrimaryFont:       [UIFont fontWithName:regularFont size:14],
         kHPPPGeneralBackgroundPrimaryFontColor:  [UIColor colorWithRed:0xFF/255.0F green:0x00/255.0F blue:0x00/255.0F alpha:1.0F],
         kHPPPGeneralBackgroundSecondaryFont:     [UIFont fontWithName:lightFont size:12],
         kHPPPGeneralBackgroundSecondaryFontColor:[UIColor colorWithRed:0x00/255.0F green:0xFF/255.0F blue:0x00/255.0F alpha:1.0F],
         kHPPPGeneralTableSeparatorColor:         [UIColor colorWithRed:0x33/255.0F green:0x33/255.0F blue:0x33/255.0F alpha:1.0F],
         
         // Selection Options
         kHPPPSelectionOptionsBackgroundColor:   [UIColor colorWithRed:0xFF/255.0F green:0xA5/255.0F blue:0x00/255.0F alpha:1.0F],
         kHPPPSelectionOptionsPrimaryFont:       [UIFont fontWithName:regularFont size:16],
         kHPPPSelectionOptionsPrimaryFontColor:  [UIColor colorWithRed:0xFF/255.0F green:0x00/255.0F blue:0x00/255.0F alpha:1.0F],
         kHPPPSelectionOptionsSecondaryFont:     [UIFont fontWithName:regularFont size:16],
         kHPPPSelectionOptionsSecondaryFontColor:[UIColor colorWithRed:0x00/255.0F green:0xFF/255.0F blue:0x00/255.0F alpha:1.0F],
         kHPPPSelectionOptionsLinkFont:          [UIFont fontWithName:regularFont size:16],
         kHPPPSelectionOptionsLinkFontColor:     [UIColor colorWithRed:0x00/255.0F green:0x00/255.0F blue:0xFF/255.0F alpha:1.0F],
         
         // Job Settings
         kHPPPJobSettingsBackgroundColor:              [UIColor colorWithRed:0x00/255.0F green:0xFF/255.0F blue:0x00/255.0F alpha:1.0F],
         kHPPPJobSettingsPrimaryFont:                  [UIFont fontWithName:regularFont size:16],
         kHPPPJobSettingsPrimaryFontColor:             [UIColor colorWithRed:0xFF/255.0F green:0x00/255.0F blue:0x00/255.0F alpha:1.0F],
         kHPPPJobSettingsSecondaryFont:                [UIFont fontWithName:regularFont size:12],
         kHPPPJobSettingsSecondaryFontColor:           [UIColor colorWithRed:0x00/255.0F green:0x00/255.0F blue:0xFF/255.0F alpha:1.0F],
         kHPPPJobSettingsSelectedPageIcon:             [UIImage imageNamed:@"HPPPSelected.png"],
         kHPPPJobSettingsUnselectedPageIcon:           [UIImage imageNamed:@"HPPPUnselected.png"],
         kHPPPSelectionOptionsDisclosureIndicatorImage:[UIImage imageNamed:@"HPPPArrow"],
         kHPPPSelectionOptionsCheckmarkImage:          [UIImage imageNamed:@"HPPPCheck"],
         
         // Main Action
         kHPPPMainActionBackgroundColor:       [UIColor colorWithRed:0x8A/255.0F green:0x2B/255.0F blue:0xE2/255.0F alpha:1.0F],
         kHPPPMainActionLinkFont:              [UIFont fontWithName:regularFont size:18],
         kHPPPMainActionActiveLinkFontColor:   [UIColor colorWithRed:0xFF/255.0F green:0x00/255.0F blue:0x00/255.0F alpha:1.0F],
         kHPPPMainActionInactiveLinkFontColor: [UIColor colorWithRed:0x00/255.0F green:0x00/255.0F blue:0x00/255.0F alpha:1.0F],
         
         // Queue Project Count
         kHPPPQueuePrimaryFont:     [UIFont fontWithName:regularFont size:16],
         kHPPPQueuePrimaryFontColor:[UIColor colorWithRed:0x00 green:0x00 blue:0x00 alpha:1.0F],
         
         // Form Field
         kHPPPFormFieldBackgroundColor:  [UIColor colorWithRed:0xFF/255.0F green:0xD7/255.0F blue:0x00/255.0F alpha:1.0F],
         kHPPPFormFieldPrimaryFont:      [UIFont fontWithName:regularFont size:16],
         kHPPPFormFieldPrimaryFontColor: [UIColor colorWithRed:0xFF/255.0F green:0x00/255.0F blue:0x00/255.0F alpha:1.0F],
         
         // Overlay
         kHPPPOverlayBackgroundColor:    [UIColor colorWithRed:0x8D/255.0F green:0xEE/255.0F blue:0xEE/255.0F alpha:1.0F],
         kHPPPOverlayBackgroundOpacity:  [NSNumber numberWithFloat:.60F],
         kHPPPOverlayPrimaryFont:        [UIFont fontWithName:regularFont size:16],
         kHPPPOverlayPrimaryFontColor:   [UIColor colorWithRed:0xFF/255.0F green:0x00/255.0F blue:0x00/255.0F alpha:1.0F],
         kHPPPOverlaySecondaryFont:      [UIFont fontWithName:regularFont size:14],
         kHPPPOverlaySecondaryFontColor: [UIColor colorWithRed:0x00/255.0F green:0xFF/255.0F blue:0x00/255.0F alpha:1.0F],
         kHPPPOverlayLinkFont:           [UIFont fontWithName:regularFont size:18],
         kHPPPOverlayLinkFontColor:      [UIColor colorWithRed:0x00/255.0F green:0x00/255.0F blue:0xFF/255.0F alpha:1.0F]
     };
}

```
##### Interface Options

Certain interface options are set by changing property values on the [`HPPPInterfaceOptions`](http://hppp.herokuapp.com/HPPPInterfaceOptions_h/Classes/HPPPInterfaceOptions/index.html) object stored in the [interfaceOptions](http://hppp.herokuapp.com/HPPP_h/Classes/HPPP/index.html#//apple_ref/occ/instp/HPPP/interfaceOptions) property of the [`HPPP`](http://hppp.herokuapp.com/HPPP_h/Classes/HPPP/index.html) object. 
Currently, only the muli-page preview interface is controlled via this object.

```objc
[HPPP sharedInstance].interfaceOptions.multiPageMaximumGutter = 0;
[HPPP sharedInstance].interfaceOptions.multiPageBleed = 40;
[HPPP sharedInstance].interfaceOptions.multiPageBackgroundPageScale = 0.61803399;
[HPPP sharedInstance].interfaceOptions.multiPageDoubleTapEnabled = YES;
[HPPP sharedInstance].interfaceOptions.multiPageZoomOnSingleTap = NO;
[HPPP sharedInstance].interfaceOptions.multiPageZoomOnDoubleTap = YES;
```
##### Print Paper

The list of print papers presented to the user and used for printing can be customized via the [`defaultPaper`](http://hppp.herokuapp.com/HPPP_h/Classes/HPPP/index.html#//apple_ref/occ/instp/HPPP/defaultPaper) and [`supportedPapers`](http://hppp.herokuapp.com/HPPP_h/Classes/HPPP/index.html#//apple_ref/occ/instp/HPPP/supportedPapers) properties of the [`HPPP`](http://hppp.herokuapp.com/HPPP_h/Classes/HPPP/index.html) class.
Each paper in the list of supported papers consists of a size (e.g. 5x7) and a type (e.g. photo paper). 
There is a default list of available sizes and types to choose from.
This list includes most common US and international paper sizes (see [`HPPPPaperSize`](http://hppp.herokuapp.com/HPPPPaper_h/Classes/HPPPPaper/index.html#//apple_ref/occ/tdef/HPPPPaper/HPPPPaperSize)). 
It is also possible to register your own custom sizes and types.

> __Tip:__ The are utility methods available for building standard paper lists for US and international papers. See [`standardUSAPapers`](http://hppp.herokuapp.com/HPPPPaper_h/Classes/HPPPPaper/index.html#//apple_ref/occ/clm/HPPPPaper/standardUSAPapers) and [`standardInternationalPapers`](http://hppp.herokuapp.com/HPPPPaper_h/Classes/HPPPPaper/index.html#//apple_ref/occ/clm/HPPPPaper/standardInternationalPapers).

###### Size and type association

[`HPPPPaper`](http://hppp.herokuapp.com/HPPPPaper_h/Classes/HPPPPaper/index.html) objects should be instantiated using the supplied [`initWithPaperSize:paperType:`](http://hppp.herokuapp.com/HPPPPaper_h/Classes/HPPPPaper/index.html#//apple_ref/occ/instm/HPPPPaper/initWithPaperSize:paperType:) method.
This method requires that the size and type being created are allowed to be paired together.
For example, by default it is not possible to create 4x6 plain paper, only 4x6 photo paper.
See the next section for information about registering custom sizes, types, and associations.

###### Custom size and types

The [`HPPPPaper`](http://hppp.herokuapp.com/HPPPPaper_h/Classes/HPPPPaper/index.html) class maintains the list of available sizes, types, and which size/type combinations are allowed.
Register custom sizes using the [`registerSize`](http://hppp.herokuapp.com/HPPPPaper_h/Classes/HPPPPaper/index.html#//apple_ref/occ/clm/HPPPPaper/registerSize:) class method. 
Register custom types using the [`registerType`](http://hppp.herokuapp.com/HPPPPaper_h/Classes/HPPPPaper/index.html#//apple_ref/occ/clm/HPPPPaper/registerType:) class method.
Register an existing size and type to be an allowed comination using the [`associatePaperSize:withType`](http://hppp.herokuapp.com/HPPPPaper_h/Classes/HPPPPaper/index.html#//apple_ref/occ/clm/HPPPPaper/associatePaperSize:withType:) class method.
Once registered, you can instantiate the size/type combo as an [`HPPPPaper`](http://hppp.herokuapp.com/HPPPPaper_h/Classes/HPPPPaper/index.html) instance and use it in the [`supportedPapers`](http://hppp.herokuapp.com/HPPP_h/Classes/HPPP/index.html#//apple_ref/occ/instp/HPPP/supportedPapers) list and [`defaultPaper`](http://hppp.herokuapp.com/HPPP_h/Classes/HPPP/index.html#//apple_ref/occ/instp/HPPP/defaultPaper) property.

##### Print Layout

Each [`HPPPPrintItem`](http://hppp.herokuapp.com/HPPPPrintItem_h/Classes/HPPPPrintItem/index.html) instance can be configured with a layout class that defines the strategy used to lay out the content on the page. The layout class is an instance of [`HPPPLayout`](http://hppp.herokuapp.com/HPPPLayout_h/Classes/HPPPLayout/index.html) and can be created using class methods in [`HPPPLayoutFactory`](http://hppp.herokuapp.com/HPPPLayoutFactory_h/Classes/HPPPLayoutFactory/index.html). 

> __Note:__ It is possible to specify different layouts for different paper sizes by implementing the [`HPPPPrintDataSource`](http://hppp.herokuapp.com/HPPP_h/Protocols/HPPPPrintDataSource/index.html) protocol and responding to the [`printingItemForPaper:withCompletion:`](http://hppp.herokuapp.com/HPPP_h/Protocols/HPPPPrintDataSource/index.html#//apple_ref/occ/intfm/HPPPPrintDataSource/printingItemForPaper:withCompletion:) method.

```objc

- (HPPPPrintItem *)createPrintItemWithAsset:(id)asset
{
    HPPPPrintItem *printItem = [HPPPPrintItemFactory printItemWithAsset:asset];
    HPPPLayout  *layout = [HPPPLayoutFactory layoutWithType:[HPPPLayoutFit layoutType]];
    printItem.layout = layout;
    return printItem;
}

```

There are three basic layout classes provided: [`HPPPLayoutFit`](http://hppp.herokuapp.com/HPPPLayoutFit_h/Classes/HPPPLayoutFit/index.html), [`HPPPLayoutFill`](http://hppp.herokuapp.com/HPPPLayoutFill_h/Classes/HPPPLayoutFill/index.html), and [`HPPPLayoutStretch`](http://hppp.herokuapp.com/HPPPLayoutStretch_h/Classes/HPPPLayoutStretch/index.html). 
Custom layouts can be created by subclassing these 3 basic types or by subclassing the [`HPPPLayout`](http://hppp.herokuapp.com/HPPPLayout_h/Classes/HPPPLayout/index.html#//apple_ref/occ/cl/HPPPLayout) base class. 
When creating a custom layout you must extend the [`HPPPLayoutFactory`](http://hppp.herokuapp.com/HPPPLayoutFactory_h/Classes/HPPPLayoutFactory/index.html) by implementing the [`HPPPLayoutFactoryDelegate`](http://hppp.herokuapp.com/HPPPLayoutFactory_h/Protocols/HPPPLayoutFactoryDelegate/index.html) protocol and using [`addDelegate:`](http://hppp.herokuapp.com/HPPPLayoutFactory_h/Classes/HPPPLayoutFactory/index.html#//apple_ref/occ/clm/HPPPLayoutFactory/addDelegate:).

By default the layout rectangle is the entire page. See [`assetPosition`](http://hppp.herokuapp.com/HPPPLayout_h/Classes/HPPPLayout/index.html#//apple_ref/occ/instp/HPPPLayout/assetPosition) for details on adjusting the layout rectangle. 
This can be useful for things like centering the asset on the page without filling the page entirely or without changing the size of the asset.

###### Layout Types

Original | Fit  | Fill | Stretch
--- | --- | --- | ---
[![Map](http://d3fep8xjnjngo0.cloudfront.net/ios/original.thumb.jpg)](http://d3fep8xjnjngo0.cloudfront.net/ios/original.jpg) | [![Map](http://d3fep8xjnjngo0.cloudfront.net/ios/fit.thumb.jpg)](http://d3fep8xjnjngo0.cloudfront.net/ios/fit.jpg)  | [![Key](http://d3fep8xjnjngo0.cloudfront.net/ios/fill.thumb.jpg)](http://d3fep8xjnjngo0.cloudfront.net/ios/fill.jpg) | [![Key](http://d3fep8xjnjngo0.cloudfront.net/ios/stretch.thumb.jpg)](http://d3fep8xjnjngo0.cloudfront.net/ios/stretch.jpg)
> __Note:__ The red outline box indicates the paper dimensions.

###### Fit Layout

The default [`HPPPLayoutFit`](http://hppp.herokuapp.com/HPPPLayoutFit_h/Classes/HPPPLayoutFit/index.html) will reduce or enlarge the print asset until it just fits in the layout rectangle without cropping. 
This means that either the horizontal or vertical edges of the asset will be touching the edge of the layout rectangle and the other dimension will include white space on either side.
If the asset is the exact aspect ratio of the layout rectangle then both the horizontal and vertical edges will touch and the asset will completely cover the rectangle.
When the asset does not fit exactly you can use the [`horizontalPosition`](http://hppp.herokuapp.com/HPPPLayoutFit_h/Classes/HPPPLayoutFit/index.html#//apple_ref/occ/instp/HPPPLayoutFit/horizontalPosition) and/or [`verticalPosition`](http://hppp.herokuapp.com/HPPPLayoutFit_h/Classes/HPPPLayoutFit/index.html#//apple_ref/occ/instp/HPPPLayoutFit/verticalPosition) properties to adjust where the asset is placed within the rectangle.

###### Fill Layout

The default [`HPPPLayoutFill`](http://hppp.herokuapp.com/HPPPLayoutFill_h/Classes/HPPPLayoutFill/index.html) will reduce or enlarge the print asset to the smallest possible size that completely fills the area of the layout rectangle without leaving any white space. 
Note that this will often involve cropping either the horizontal or vertical edges of the asset. 
If the asset is the exact aspect ratio of the layout rectangle then both the horizontal and vertical edges will touch and the asset will completely cover the rectangle without cropping.

###### Stretch Layout

The default [`HPPPLayoutStretch`](http://hppp.herokuapp.com/HPPPLayoutStretch_h/Classes/HPPPLayoutStretch/index.html) will adjust the size of the asset to exactly fit the layout rectangle. 
If the asset is _not_ the exact aspect ratio of the layout rectangle then distortion of the asset will occur as it is stretched to fit.

> __Tip:__ Almost all printer brands and models use a technique called "overspray" to acheive true borderless printing.
They enlarge the printed file by 2-3% and actually print the given image _beyond_ the edge of the paper thus clipping the content at the very edge of the print item.
For this reason, it is recommended to respect a "safe zone" in your content approximately 0.25" from the very edge of the page. 
For instance, avoid placing logos or other important content right at the edge of the print.

### Print Later Workflow

The print later workflow allows the user to add a print job to a queue for printing later. 
The pod provides the views for adding jobs and viewing the list of jobs. 
Users can print or delete jobs from their queue. 
Similar to printing, the print later workflow can be accessed via the share panel or by presenting the print queue view controller directly.

#### Print Job

To add a job to the print queue you must prepare an instance of [`HPPPPrintLaterJob`](http://hppp.herokuapp.com/HPPPPrintLaterJob_h/Classes/HPPPPrintLaterJob/index.html). You must provide at least one image to be printed later. 
However, if your job requires a custom image for each paper size, you must provide the image for each paper size at the time the print job is created and added to the print queue. 
The print queue system will handle the data sourcing interface at the time the job is printed. It does this by using the [`HPPPPrintDataSource`](http://hppp.herokuapp.com/HPPP_h/Protocols/HPPPPrintDataSource/index.html) protocol to query the print job for paper-specific images. 
A print job requires a unique ID which can be obtained via the utility method [`nextPrintJobId`](http://hppp.herokuapp.com/HPPP_h/Classes/HPPP/index.html#//apple_ref/occ/instm/HPPP/nextPrintJobId).

```objc

- (HPPPPrintLaterJob *)createJobWithImage:(UIImage *)image
{
    NSString *jobID = [[HPPP sharedInstance] nextPrintJobId];
    HPPPPrintLaterJob *printLaterJob = [[HPPPPrintLaterJob alloc] init];
    printLaterJob.id = jobID;
    printLaterJob.name = @"My Job";
    printLaterJob.date = [NSDate date];
    printLaterJob.images = @{ [HPPPPaper titleFromSize:Size4x6]:image };
}

```

#### Share Activity (Add Job)

Similar to the printing workflow, the print later workflow can be invoked using the share panel. 
With this method, an icon is added to the share panel that allows the user to add the print job to their print queue for printing later.
In this case, the HPPPPrintLaterActivity is configured and added to the act.


```objc

- (IBAction)shareBarButtonItemTap:(id)sender
{
    HPPPPrintLaterJob *job = [self createJobWithImage:[UIImage imageNamed:@"sample.jpg"]];
    HPPPPrintLaterActivity *printLaterActivity = [[HPPPPrintLaterActivity alloc] init];
    printLAterActivity.printLaterJob = job;
    NSArray *applicationActivities = @[printLaterActivity];
    UIImage *printableItem = [UIImage imageNamed:@"sample.jpg"]; // required but not used for print later
    NSArray *activitiesItems = @[printableItem];
    UIActivityViewController *activityViewController = [[UIActivityViewController alloc] initWithActivityItems:activitiesItems applicationActivities:applicationActivities];
    activityViewController.excludedActivityTypes = @[UIActivityTypePrint];
    activityViewController.completionHandler = ^(NSString *activityType, BOOL completed) {
        if (completed) {
            NSLog(@"Activity completed");
        } else {
            NSLog(@"Activity NOT completed");
        }
    };
    [self presentViewController:activityViewController animated:YES completion:nil];
}

```

#### Show Print Queue

It is also possible to directly show the current list of jobs to be printed later (i.e. print queue). 
This is useful if you have a button in your app that allows the user to view their queue. 
Use the utility method [presentPrintQueueFromController:animated:completion:](http://hppp.herokuapp.com/HPPP_h/Classes/HPPP/index.html#//apple_ref/occ/instm/HPPP/presentPrintQueueFromController:animated:completion:)

```objc

- (IBAction)showPrintQueueTapped:(id)sender
{
    [[HPPP sharedInstance] presentPrintQueueFromController:self animated:YES completion:nil];
}

``` 

### Printer Notifications

The __HPPhotoPrint__ pod provides the ability to notify the user with a reminder when they return to their printer. 
This feature uses the geofencing feature of iOS to detect when the user returns to the general vicinity of the last printer they used.
The app then checks in the background to see if the Wi-Fi network is available and the printer is connected. 
Finally, if the user has at least one job in their queue to print, a notification is triggered to inform the user that the printer is available.

To support this feature, the client app using the pod must implement the configurations detailed below. 
Once the app is configured properly, the pod will automatically handle the geofencing setup and notifications to the user.

#### Project Capabilities

The app must declare certain background capabilities. Under _Project Settings -> Capabilities -> Background Modes_ enable the following:

* Location updates
* Background fetch

#### Entries in `plist` File

Populate the following entries in your project's `plist` file. This is found under `<project name>-info.plist`.

* NSLocationWhenInUseUsageDescription
* NSLocationAlwaysUsageDescription

These values are used in the 'location permission' dialog(s) presented by iOS. They allow the app to explain to the user why location permission is needed. An example message:

> Current location is required to identify when your printer connection is available.

#### App Delegate

Notifications events are handled in the app delegate. Add the following two handlers to your app delegate file. This allows the pod to handle user actions on print notifications.

```objc

- (void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification
{
    if (application.applicationState == UIApplicationStateInactive) {
        [[HPPPPrintLaterManager sharedInstance] handleNotification:notification];
    } 
}

- (void)application:(UIApplication *)application handleActionWithIdentifier:(NSString *)identifier forLocalNotification:(UILocalNotification *)notification completionHandler:(void(^)())completionHandler
{
    [[HPPPPrintLaterManager sharedInstance] handleNotification:notification action:identifier];
    
    completionHandler();
}

```

#### Registering Notifications

The __HPPhotoPrint__ pod will automatically register the user notification for print later reminders. 
However, if your app uses other notifications of its own, then you must register the print later notification yourself at the time you register your other app notifications. 
Just make sure to include [`printLaterUserNotificationCategory`](http://hppp.herokuapp.com/HPPPPrintLaterManager_h/Classes/HPPPPrintLaterManager/index.html#//apple_ref/occ/instp/HPPPPrintLaterManager/printLaterUserNotificationCategory) in [`UIUserNotificationSettings`](https://developer.apple.com/library/prerelease/ios/documentation/UIKit/Reference/UIUserNotificationSettings_class/index.html) when you call [`registerUserNotificationSettings`](https://developer.apple.com/library/ios/documentation/UIKit/Reference/UIApplication_Class/#//apple_ref/occ/instm/UIApplication/registerUserNotificationSettings:). 
The pod will detect that you have done this and will _not_ overwrite existing notification registrations.

## Author

Hewlett-Packard Company

## License

__HPPhotoPrint__ is available under special arrangement with Hewlett-Packard Company.