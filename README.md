# HPPhotoPrint

[![Version](https://img.shields.io/cocoapods/v/HPPhotoPrint.svg?style=flat)](http://cocoadocs.org/docsets/HPPhotoPrint)
[![License](https://img.shields.io/cocoapods/l/HPPhotoPrint.svg?style=flat)](http://cocoadocs.org/docsets/HPPhotoPrint)
[![Platform](https://img.shields.io/cocoapods/p/HPPhotoPrint.svg?style=flat)](http://cocoadocs.org/docsets/HPPhotoPrint)

## Usage

To run the example project, clone the repo, and run `pod install` from the Example directory first.

## Requirements

## Installation

HPPhotoPrint is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

    pod "HPPhotoPrint"

Afterwards, open a terminal window to your project directory and execute:

    pod install

## Documentation

Reference documentation can be found at http://hppp.herokuapp.com

## Usage

The print workflow can be invoked in one of two ways. The first is through the standard iOS sharing view using a custom print activity provided by the pod. 
The second is to present the printing view controller directly, for example when the user taps a "print" button in your app.

### Sharing Activity

To use the sharing activity, just prepare the iOS `UIActivityViewController` in the standard way and add the `HPPPPrintActivity` as an additional application activity. 
It is strongly advised that you also remove the built-in iOS print activity (UIActivityTypePrint) to avoid confusion.
If your app uses different printable assets for different paper sizes, then you also need to implement the `HPPPPrintActivityDataSource` protocol and set the data source on the print activity instance (see the 'Implementing HPPPPrintActivityDataSource' section below).

```objc

- (IBAction)shareBarButtonItemTap:(id)sender
{
    HPPPPrintActivity *printActivity = [[HPPPPrintActivity alloc] init];

    NSArray *applicationActivities = @[printActivity];

    UIImage *printableItem = [UIImage imageNamed:@"sample-portrait.jpg"];
    NSArray *activitiesItems = @[printableItem];

    UIActivityViewController *activityViewController = [[UIActivityViewController alloc] initWithActivityItems:activitiesItems applicationActivities:applicationActivities];
    activityViewController.excludedActivityTypes = @[UIActivityTypePrint];
    activityViewController.completionHandler = ^(NSString *activityType, BOOL completed) {
        NSLog(@"completed dialog - activity: %@ - finished flag: %d", activityType, completed);
        if (completed) {
            NSLog(@"completionHandler - Succeed");
            HPPP *hppp = [HPPP sharedInstance];
            NSLog(@"Paper Size used: %@", [hppp.lastOptionsUsed valueForKey:kHPPPPaperSizeId]);
        } else {
            NSLog(@"completionHandler - didn't succeed.");
        }
    };

    [self presentViewController:activityViewController animated:YES completion:nil];
}

```

### View Controller

To show the printing view directly, you must get a reference to the `HPPPPageSettingsViewController` from the `HPPP` storyboard.
Set the `image` property to the printable asset, and if needed, set the data source delegate that will regenerate the printable asset for different paper sizes (see the 'Implementing HPPPPrintActivityDataSource' section below).

```objc

- (IBAction)printBarButtonItemTap:(id)sender
{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"HPPP" bundle:nil];
    HPPPPageSettingsTableViewController *pageSettingsViewController = (HPPPPageSettingsTableViewController *)[storyboard instantiateViewControllerWithIdentifier:@"HPPPPageSettingsTableViewController"];
    pageSettingsViewController.image = [UIImage imageNamed:@"sample-portrait.jpg"];
    pageSettingsViewController.dataSource = self;
    [self presentViewController:pageSettingsViewController animated:YES completion:nil];
}

```

### Implementing HPPPPrintActivityDataSource

First, declare your view controller as an implementor of the `HPPPrintActivityDataSource` protocol.

```objc

@interface MyViewController () <HPPPPrintActivityDataSource>

```

Next, implement the function `printActivityRequestImageForPaper` within `MyViewController`

```objc

- (UIImage *)printActivityRequestImageForPaper:(HPPPPaper *)paper
{
    //Logic to determine what UIImage to return based on the paper.paperSize.
}

```

Next, set `MyViewController` as the delegate data source in the `HPPPPrintActivity` object in the `shareBarButtonItemTap` handler.

```objc

- (IBAction)shareBarButtonItemTap:(id)sender
{
    HPPPPrintActivity *printActivity = [[HPPPPrintActivity alloc] init];

    printActivity.dataSource = self; // <=== Set the delegate here

    NSArray *applicationActivities = @[printActivity];

    // ... rest of the code follows
}

```


## Print later integration (ONLY iOS 8 COMPATIBLE)

Some parts of the code to support print later must be implemented in the client app.

### Add capabilities to the target used

Add the following Background Modes to the target
* Location Updates
* Background Fetch


### Add keys to the project-Info.plist file

Inside the Information Property List add:

* NSLocationWhenInUseUsageDescription
* NSLocationAlwaysUsageDescription

NOTE: You can add a custom message explaining why you need access to the current location. For example: “Current location is required to identify when your printer connection is available.”

### Configure the app delegate file

* Copy these lines in the appDelegate didFinishLaunchingWithOptions if you are already using push notifications (otherwise we will be overriding your notification registration with the following one). If you are not using push notifications then you don’t need to add those lines, we will handle them for you.

```objc

        UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:UIUserNotificationTypeSound|UIUserNotificationTypeBadge|UIUserNotificationTypeAlert categories:[NSSet setWithObjects:[HPPPPrintLaterManager  sharedInstance].printLaterUserNotificationCategory, nil]];
        [[UIApplication sharedApplication] registerUserNotificationSettings:settings];

```

* Implement these two delegate methods in the appDelegate

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

NOTE: You need to import the HPPP header file for compiling:


```objc

#import <HPPP.h>

```


### Open the print jobs list screen from other locations

If you need to open the print jobs list screen from another location in your app you can call:

```objc

[HPPPPrintJobsTableViewController presentAnimated:YES usingController:self andCompletion:nil];

```

### Sharing Activity

You may want to add the print later activity to the collection of existing share activities:

```objc

- (IBAction)shareBarButtonItemTap:(id)sender
{
    HPPPPrintActivity *printActivity = [[HPPPPrintActivity alloc] init];
    HPPPPrintLaterActivity *printLaterActivity = [[HPPPPrintLaterActivity alloc] init];

    NSString *printLaterJobNextAvailableId = [[HPPPPrintLaterQueue sharedInstance] retrievePrintLaterJobNextAvailableId];
    HPPPPrintLaterJob *printLaterJob = [[HPPPPrintLaterJob alloc] init];
    printLaterJob.id = printLaterJobNextAvailableId;
    printLaterJob.name = @“PrintJob Name”;
    printLaterJob.date = [NSDate date];
    printLaterJob.images = @{@"4 x 6" : [UIImage imageNamed:@"sample-portrait.jpg"]};
    
    printLaterActivity.printLaterJob = printLaterJob;

    NSArray *applicationActivities = @[printActivity, printLaterActivity];

    UIImage *printableItem = [UIImage imageNamed:@"sample-portrait.jpg"];
    NSArray *activitiesItems = @[printableItem];

    UIActivityViewController *activityViewController = [[UIActivityViewController alloc] initWithActivityItems:activitiesItems applicationActivities:applicationActivities];
    activityViewController.excludedActivityTypes = @[UIActivityTypePrint];
    activityViewController.completionHandler = ^(NSString *activityType, BOOL completed) {
        NSLog(@"completed dialog - activity: %@ - finished flag: %d", activityType, completed);
        if (completed) {
            NSLog(@"completionHandler - Succeed");
            HPPP *hppp = [HPPP sharedInstance];
            NSLog(@"Paper Size used: %@", [hppp.lastOptionsUsed valueForKey:kHPPPPaperSizeId]);
        } else {
            NSLog(@"completionHandler - didn't succeed.");
        }
    };

    [self presentViewController:activityViewController animated:YES completion:nil];
}

```

## Author

Hewlett-Packard Company

## License

HPPhotoPrint is available under the MIT license. See the LICENSE file for more info.

