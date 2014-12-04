//
//  HPPPViewController.m
//  HPPhotoPrint
//
//  Created by James on 12/03/2014.
//  Copyright (c) 2014 James. All rights reserved.
//

#import <HPPPView.h>
#import <HPPPViewController.h>

#import "HPPPExampleViewController.h"

@interface HPPPExampleViewController ()

@property (weak, nonatomic) IBOutlet HPPPView *hpppViewStoryboard;

@end

@implementation HPPPExampleViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    HPPPView *view = [[HPPPView alloc] initWithFrame:CGRectMake(100, 0, 100, 200)];
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 100, 200)];
    label.text = @"Loaded from initWithFrame";
    label.numberOfLines = 0;
    [view addSubview:label];
    [self.view addSubview:view];
    
    UILabel *label2 = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 100, 200)];
    label2.text = @"Loaded from initWithCoder";
    label2.numberOfLines = 0;
    [self.hpppViewStoryboard addSubview:label2];

    
    NSLog(@"BUNDLE :    %@", [NSBundle mainBundle].bundlePath);
    
    NSString *bundlePath = [NSString stringWithFormat:@"%@/HPPhotoPrint.bundle", [NSBundle mainBundle].bundlePath];
    NSBundle *bundle = [NSBundle bundleWithPath:bundlePath];
    
    NSLog(@"POD BUNDLE :    %@", [NSBundle bundleForClass:[HPPPView class]].bundlePath);
    
    HPPPView *rightCalloutAccessoryView = [[bundle loadNibNamed:@"HPPPView" owner:self options:nil] lastObject];
    
    [self.view addSubview:rightCalloutAccessoryView];
    
    
    
}

- (IBAction)buttonTap:(id)sender {
    NSString *bundlePath = [NSString stringWithFormat:@"%@/HPPhotoPrint.bundle", [NSBundle mainBundle].bundlePath];
    NSBundle *bundle = [NSBundle bundleWithPath:bundlePath];
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"HPPP" bundle:bundle];
    HPPPViewController *hpppViewController = (HPPPViewController *)[storyboard instantiateViewControllerWithIdentifier:@"HPPPViewController"];
    
    [self presentViewController:hpppViewController animated:YES completion:nil];
}

@end
