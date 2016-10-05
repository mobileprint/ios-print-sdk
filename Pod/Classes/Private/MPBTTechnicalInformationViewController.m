//
//  MPBTTechnicalInformationViewController.m
//  Pods
//
//  Created by Susy Snowflake on 10/5/16.
//
//

#import "MPBTTechnicalInformationViewController.h"

@interface MPBTTechnicalInformationViewController ()

@property (weak, nonatomic) IBOutlet UILabel *plasticsTextLabel;

@end

@implementation MPBTTechnicalInformationViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self.plasticsTextLabel sizeToFit];
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
