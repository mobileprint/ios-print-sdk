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

#import "HPPP.h"
#import "HPPPPageViewController.h"
#import "HPPPWiFiReachability.h"

@interface HPPPPageViewController ()

@property (weak, nonatomic) IBOutlet UIBarButtonItem *printBarButtonItem;
@property (strong, nonatomic) HPPPWiFiReachability *wifiReachability;

@end

@implementation HPPPPageViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.pageView.image = self.image;
    if (IS_OS_8_OR_LATER){
        self.navigationItem.rightBarButtonItems = nil;
    }
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.wifiReachability = [[HPPPWiFiReachability alloc] init];
    [self.wifiReachability start:self.printBarButtonItem];
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

- (IBAction)printButtonTapped:(id)sender
{
    if ([self.delegate respondsToSelector:@selector(pageViewController:didTapPrintBarButtonItem:)]) {
        [self.delegate pageViewController:self didTapPrintBarButtonItem:sender];
    }
}

@end
