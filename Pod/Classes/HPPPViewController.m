//
//  HPPPViewController.m
//  Pods
//
//  Created by Andre Gatti on 12/4/14.
//
//

#import "HPPPViewController.h"

@interface HPPPViewController ()

@property (weak, nonatomic) IBOutlet UILabel *label;

@end

@implementation HPPPViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.label.text = @"Hi";
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
