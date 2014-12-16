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

## Documentation

Reference documentation can be found at http://hppp.herokuapp.com

## Usage

The print workflow can be invoked in one of two ways. The first is through the standard iOS sharing view using a custom print activity provided by the pod. 
The second is to present the printing view controller directly, for example when the user taps a "print" button in your app.

### Sharing Activity

To use the sharing activity just prepare the iOS `UIActivityViewController` in the standard way and add the `HPPPPrintActivity` as an additional application activity. 
It is strongly advised that you also remove the built-in iOS print activity to avoid confusion.
If your app uses different printable assets for different paper sizes then you also need to implement the `HPPPPrintActivityDataSource` protocol and set the data source on the print activity instance.

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

To show the printing view directly you must get a reference to the `HPPPPageSettingsViewController` from the `HPPP` storyboard.
Set the `image` property to the printable asset and if needed set the data source delegate that will regenerate the printable asset for different paper sizes.

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

## Author

Hewlett-Packard Company

## License

HPPhotoPrint is available under the MIT license. See the LICENSE file for more info.

