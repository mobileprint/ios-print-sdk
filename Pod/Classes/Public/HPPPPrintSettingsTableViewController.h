//
//  HPPPPrintSettingsTableViewController.h
//  Pods
//
//  Created by Fredy on 2/5/15.
//
//

#import <UIKit/UIKit.h>
#import "HPPPPrintSettings.h"

@protocol HPPPPrintSettingsTableViewControllerDelegate;

@interface HPPPPrintSettingsTableViewController : UITableViewController

@property (nonatomic, weak) id<HPPPPrintSettingsTableViewControllerDelegate> delegate;
@property (nonatomic, strong) HPPPPrintSettings *printSettings;

@end


@protocol HPPPPrintSettingsTableViewControllerDelegate <NSObject>

- (void)printSettingsTableViewController:(HPPPPrintSettingsTableViewController *)paperTypeTableViewController didChangePrintSettings:(HPPPPrintSettings *)printSettings;

@end

