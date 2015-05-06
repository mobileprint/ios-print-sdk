# HPPhotoPrint

[![Version](https://img.shields.io/badge/pod-2.0.4-blue.svg)](http://hppp.herokuapp.com)
[![Platform](https://img.shields.io/badge/platform-ios-lightgrey.svg)](http://hppp.herokuapp.com)
[![Awesome](https://img.shields.io/badge/awesomeness-verified-green.svg)](http://hppp.herokuapp.com)

## Contents

- [Documentation](#documentation)
- [Installation](#installation)
- [Usage](#usage)
    - [Print Workflow](#print-workflow)
        - [Share Activity (Print)](#share-activity-print)
        - [View Controller](#view-controller)
        - [Delegate](#delegate)
        - [Data Source](#data-source)
        - [Customization](#customization)
            - [Appearance](#appearance)
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

<!-- end toc 4 -->

## Documentation

Reference documentation can be found at http://hppp.herokuapp.com. This includes complete documentation for all classes, properties, methods, constants, and so on.

## Installation

The __HPPhotoPrint__ pod is not yet available publicly (i.e. via [cocoapods.org](http://cocoapods.org)). To install the pod you must have read access to this repo ([hp\_photo\_print](https://github.com/IPGPTP/hp_photo_print)) as well as HP's private pod trunk ([hp\_mss\_pods](https://github.com/IPGPTP/hp_mss_pods)). To request access send an email to hp-mobile-dev@hp.com.

Add the private pod trunk as a source in your `Podfile`. It is important that this entry is before the source for the public Cocoapod trunk:

    source 'https://github.com/IPGPTP/hp_mss_pods.git'

Add an entry for the __HPPhotoPrint__ pod with the desired version number:

    pod 'HPPhotoPrint', '2.0.4'

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
pod 'HPPhotoPrint', '2.0.4'
pod 'ZipArchive', '1.4.0'

xcodeproj 'MyProject/MyProject.xcodeproj'

```

## Usage

The __HPPhotoPrint__ pod provides three main features.

1. A print workflow that provides enhanced features beyond what standard iOS AirPrint provides (e.g. graphical print preview).
2. A print queue that allows users to save jobs for printing later.
3. The ability to notify with a reminder when they return to their printer.

### Print Workflow

The print workflow can be invoked in one of two ways. 
The first is through the standard iOS sharing view using a custom print activity provided by the pod. 
The second is to present the printing view controller directly, for example when the user taps a "print" button in your app. 
Either method can make use of a delegate to handle print completion (and canceling). 
If your app needs custom printing for various paper sizes, a custom data source can be provided. 
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
    UIImage *printableItem = [UIImage imageNamed:@"sample-portrait.jpg"];
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
    UIViewController *vc = [[HPPP sharedInstance] printViewControllerWithDelegate:self dataSource:self image:[UIImage imageNamed:@"sample2-portrait.jpg"] fromQueue:NO];
    [self presentViewController:vc animated:YES completion:nil];
}

```

#### Delegate

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

#### Data Source

You can optionally provide a printing data source by implementing the [`HPPPPrintDataSource`](http://hppp.herokuapp.com/HPPP_h/Protocols/HPPPPrintDataSource/index.html) protocol. This allows you to control what gets printed for any given paper size. 
When you implement this protocol you will get a request for a new printable image each time the user selects a different paper size.

> __Note:__ If you implement this protocol, you _must_ implement the single-image method. If your app supports multi-image print jobs then you _must_ implement all three methods in the protocol

```objc

- (void)imageForPaper:(HPPPPaper *)paper withCompletion:(void (^)(UIImage *))completion
{
    if (completion) {
        completion([UIImage imageNamed:@"sample2-portrait.jpg"]);
    }
}

- (NSInteger)numberOfImagesToPrint
{
    return 1;
}

- (NSArray *)imagesForPaper:(HPPPPaper *)paper
{
    return @[ [UIImage imageNamed:@"sample2-portrait.jpg"] ];
}

```

#### Customization

The appearance of the priting views can be customized setting properties on the shared instance of the [`HPPP`](http://hppp.herokuapp.com/HPPP_h/Classes/HPPP/index.html) class. 
See the [properties](http://hppp.herokuapp.com/HPPP_h/Classes/HPPP/index.html#HeaderDoc_props) documention for a complete list. 
This setup is typically done in the app delegate at startup.

```objc

+ (void)setPrintOptions
{
    [HPPP sharedInstance].tableViewCellLinkLabelColor = [UIColor blueColor];
    [HPPP sharedInstance].zoomAndCrop = NO;
    [HPPP sharedInstance].initialPaperSize = Size4x6;
    [HPPP sharedInstance].defaultPaperWidth = 4.0f;
    [HPPP sharedInstance].defaultPaperHeight = 5.0f;
    [HPPP sharedInstance].defaultPaperType = Photo;
    [HPPP sharedInstance].hideBlackAndWhiteOption = FALSE;
    [HPPP sharedInstance].hidePaperSizeOption = FALSE;
    [HPPP sharedInstance].hidePaperTypeOption = FALSE;
    [HPPP sharedInstance].paperSizes = @[ [HPPPPaper titleFromSize:Size4x6], [HPPPPaper titleFromSize:Size5x7], [HPPPPaper titleFromSize:SizeLetter] ];
}

```

##### Appearance

There are additional appearance options that you can set via the [`appearance`](http://hppp.herokuapp.com/HPPP_h/Classes/HPPP/index.html#//apple_ref/occ/instp/HPPP/appearance) property of the [`HPPP`](http://hppp.herokuapp.com/HPPP_h/Classes/HPPP/index.html) class. 
In this case you create an [`HPPPAppearance`](http://hppp.herokuapp.com/HPPPAppearance_h/Classes/HPPPAppearance/index.html#//apple_ref/occ/cl/HPPPAppearance) instance and set its properties to dictionaries of attributes using the keys defined in the class.


```objc

+ (void)setPrintOptions
{
    NSMutableDictionary *printQueueScreenAttributes = [NSMutableDictionary dictionaryWithDictionary:[HPPP sharedInstance].appearance.printQueueScreenAttributes];
    
    [printQueueScreenAttributes setObject:[UIFont fontWithName:@"Helvetica" size:17] forKey:HPPPPrintQueueScreenEmptyQueueFontAttribute];
    [printQueueScreenAttributes setObject:[UIColor darkGrayColor] forKey:HPPPPrintQueueScreenEmptyQueueColorAttribute];
    
    [printQueueScreenAttributes setObject:[UIFont fontWithName:@"Helvetica" size:20] forKey:HPPPPrintQueueScreenPreviewJobNameFontAttribute];
    [printQueueScreenAttributes setObject:[UIColor whiteColor] forKey:HPPPPrintQueueScreenPreviewJobNameColorAttribute];
    
    [printQueueScreenAttributes setObject:[UIFont fontWithName:@"Helvetica" size:16] forKey:HPPPPrintQueueScreenPreviewJobDateFontAttribute];
    [printQueueScreenAttributes setObject:[UIColor whiteColor] forKey:HPPPPrintQueueScreenPreviewJobDateColorAttribute];
    
    [printQueueScreenAttributes setObject:[UIFont fontWithName:@"Helvetica" size:16] forKey:HPPPPrintQueueScreenPreviewDoneButtonFontAttribute];
    [printQueueScreenAttributes setObject:[UIColor whiteColor] forKey:HPPPPrintQueueScreenPreviewDoneButtonColorAttribute];
    
    [HPPP sharedInstance].appearance.printQueueScreenAttributes = [NSDictionary dictionaryWithDictionary:printQueueScreenAttributes];
}

```

##### Print Layout

If the image to be printed does not match the size of the paper to be printed on, then one of two behaviors can be configured. This behavior is controlled via the [`zoomAndCrop`](http://hppp.herokuapp.com/HPPP_h/Classes/HPPP/index.html#//apple_ref/occ/instp/HPPP/zoomAndCrop) property of the [`HPPP`](http://hppp.herokuapp.com/HPPP_h/Classes/HPPP/index.html) class. 

If [`zoomAndCrop`](http://hppp.herokuapp.com/HPPP_h/Classes/HPPP/index.html#//apple_ref/occ/instp/HPPP/zoomAndCrop) is set to `YES`, the image aspect ratio is maintained but the image is reduced or enlarged so that it just fills the entire page. 
Some top/bottom or left/right cropping of the image may occur. 
This behavior is identical to the [`UIViewContentModeScaleAspectFill`](https://developer.apple.com/library/ios/documentation/UIKit/Reference/UIView_Class/index.html#//apple_ref/c/tdef/UIViewContentMode) content mode setting of `UIView`.

If [`zoomAndCrop`](http://hppp.herokuapp.com/HPPP_h/Classes/HPPP/index.html#//apple_ref/occ/instp/HPPP/zoomAndCrop) is set to `NO`, the image layout on the page depends on the ratio of the page width to the image width.
If this ratio is less than 1.25 then the image is reduced or enlarged so that its width is exactly equal to the page width. Then the top edge of the image is aligned with the top edge of the page. The bottom of the image may be cropped or there may be empty space left at the bottom of the print.
If the ratio is greater than 1.25 then the image is simply centered horizontally and vertically on the page.

> __Note:__ The reason for this unique behavior has to do with the custom needs of a proprietary HP app.

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
    HPPPPrintLaterJob *job = [self createJobWithImage:[UIImage imageNamed:@"sample-portrait.jpg"]];
    HPPPPrintLaterActivity *printLaterActivity = [[HPPPPrintLaterActivity alloc] init];
    printLAterActivity.printLaterJob = job;
    NSArray *applicationActivities = @[printLaterActivity];
    UIImage *printableItem = [UIImage imageNamed:@"sample-portrait.jpg"]; // required but not used for print later
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
