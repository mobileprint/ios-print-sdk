//
//  HPPPViewController.m
//  HPPhotoPrint
//
//  Created by James on 12/03/2014.
//  Copyright (c) 2014 James. All rights reserved.
//

#import <HPPhotoPrint/HPPPView.h>

#import "HPPPViewController.h"

@interface HPPPViewController ()

@end

@implementation HPPPViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    HPPPView *view = [[HPPPView alloc] initWithFrame:CGRectMake(0, 0, 100, 200)];
    
    [self.view addSubview:view];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
