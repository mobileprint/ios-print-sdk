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

#import "MP.h"
#import "MPAppDelegate.h"
#import <DBChooser/DBChooser.h>

@implementation MPAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleTrackableScreenNotification:) name:kMPTrackableScreenNotification object:nil];
    
    // Check if the app was opened by local notification
    UILocalNotification *localNotification = launchOptions[UIApplicationLaunchOptionsLocalNotificationKey];
    if (localNotification) {
        NSLog(@"App starts to run because of a notification");
        [[MP sharedInstance] handleNotification:localNotification];
    }
        
    self.logger = [[MPExampleLogger alloc] init];
    [[MPLogger sharedInstance] setDelegate:self.logger];
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

- (void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification
{
    if (application.applicationState == UIApplicationStateInactive) {
        NSLog(@"Receive local notification while the app was inactive and the user tap in the notification (instead of the action).");
        [[MP sharedInstance] handleNotification:notification];
    } else if (application.applicationState == UIApplicationStateActive) {
        NSLog(@"Receive local notification while the app was active.");
    }
}

- (void)application:(UIApplication *)application handleActionWithIdentifier:(NSString *)identifier forLocalNotification:(UILocalNotification *)notification completionHandler:(void(^)())completionHandler
{
    NSLog(@"Action %@", identifier);
    
    [[MP sharedInstance] handleNotification:notification action:identifier];
    
    completionHandler();
}

#pragma mark - Notifications

- (void)handleTrackableScreenNotification:(NSNotification *)notification
{
    NSString *screenName = [notification.userInfo objectForKey:kMPTrackableScreenNameKey];
    NSLog(@"Entering in screen: %@", screenName);
}

#pragma mark - URL handler

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation
{
    if ([[DBChooser defaultChooser] handleOpenURL:url]) {
        // This was a Chooser response and handleOpenURL automatically ran the completion block
        return YES;
    }
    
    return NO;
}

@end
