//
//  MPBTAutoOffTableViewController.h
//  Pods
//
//  Created by Susy Snowflake on 7/12/16.
//
//

#import <UIKit/UIKit.h>
#import "MPBTSprocketDefinitions.h"

@protocol MPBTAutoOffTableViewControllerDelegate;

@interface MPBTAutoOffTableViewController : UITableViewController

@property (assign, nonatomic) MantaAutoPowerOffInterval currentAutoOffValue;
@property (weak, nonatomic) id<MPBTAutoOffTableViewControllerDelegate> delegate;

@end

@protocol MPBTAutoOffTableViewControllerDelegate <NSObject>

- (void)didSelectAutoOffInterval:(MantaAutoPowerOffInterval)sprocket;

@end;