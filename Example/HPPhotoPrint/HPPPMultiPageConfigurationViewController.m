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

#import "HPPPMultiPageConfigurationViewController.h"
#import <HPPP.h>

@interface HPPPMultiPageConfigurationViewController()

@property (weak, nonatomic) IBOutlet UISwitch *doubleTapEnabledSwitch;
@property (weak, nonatomic) IBOutlet UISwitch *zoomOnSingleTapSwitch;
@property (weak, nonatomic) IBOutlet UISwitch *zoomOnDoubleTapSwitch;

@end

@implementation HPPPMultiPageConfigurationViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setIntegerValue:[HPPP sharedInstance].interfaceOptions.multiPageMinimumGutter forIndex:0];
    [self setIntegerValue:[HPPP sharedInstance].interfaceOptions.multiPageMaximumGutter forIndex:1];
    [self setIntegerValue:[HPPP sharedInstance].interfaceOptions.multiPageBleed forIndex:2];
    [self setFloatValue:[HPPP sharedInstance].interfaceOptions.multiPageBackgroundPageScale * 100.0 forIndex:3];
    self.doubleTapEnabledSwitch.on = [HPPP sharedInstance].interfaceOptions.multiPageDoubleTapEnabled;
    self.zoomOnSingleTapSwitch.on = [HPPP sharedInstance].interfaceOptions.multiPageZoomOnSingleTap;
    self.zoomOnDoubleTapSwitch.on = [HPPP sharedInstance].interfaceOptions.multiPageZoomOnDoubleTap;
}

- (IBAction)doneButtonTapped:(id)sender {
    [HPPP sharedInstance].interfaceOptions.multiPageMinimumGutter = [self getIntegerValueForIndex:0];
    [HPPP sharedInstance].interfaceOptions.multiPageMaximumGutter = [self getIntegerValueForIndex:1];
    [HPPP sharedInstance].interfaceOptions.multiPageBleed = [self getIntegerValueForIndex:2];
    [HPPP sharedInstance].interfaceOptions.multiPageBackgroundPageScale = [self getFloatValueForIndex:3] / 100.0;
    [HPPP sharedInstance].interfaceOptions.multiPageDoubleTapEnabled = self.doubleTapEnabledSwitch.on;
    [HPPP sharedInstance].interfaceOptions.multiPageZoomOnSingleTap = self.zoomOnSingleTapSwitch.on;
    [HPPP sharedInstance].interfaceOptions.multiPageZoomOnDoubleTap = self.zoomOnDoubleTapSwitch.on;
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)textDidEdit:(id)sender {
    [self copyTextToSliders];
}

- (IBAction)sliderChanged:(id)sender {
    [self copySlidersToText];
}

- (void)copyTextToSliders
{
    for (int idx = 0; idx < 4; idx++) {
        UITextField *textField = (UITextField *)[self.view viewWithTag:10 + idx * 10];
        UISlider *slider = (UISlider *)[self.view viewWithTag:10 + idx * 10 + 1];
        slider.value = [textField.text floatValue];
    }
}

- (void)copySlidersToText
{
    for (int idx = 0; idx < 4; idx++) {
        UITextField *textField = (UITextField *)[self.view viewWithTag:10 + idx * 10];
        UISlider *slider = (UISlider *)[self.view viewWithTag:10 + idx * 10 + 1];
        if (idx < 3) {
            textField.text = [NSString stringWithFormat:@"%d", (int)slider.value];
        } else {
            textField.text = [NSString stringWithFormat:@"%.2f", slider.value];
        }
    }
}

- (NSUInteger)getIntegerValueForIndex:(int)idx
{
    UITextField *textField = (UITextField *)[self.view viewWithTag:10 + idx * 10];
    return [textField.text integerValue];

}

- (float)getFloatValueForIndex:(int)idx
{
    UITextField *textField = (UITextField *)[self.view viewWithTag:10 + idx * 10];
    return [textField.text floatValue];
}

- (void)setIntegerValue:(NSUInteger)value forIndex:(int)idx
{
    UITextField *textField = (UITextField *)[self.view viewWithTag:10 + idx * 10];
    UISlider *slider = (UISlider *)[self.view viewWithTag:10 + idx * 10 + 1];
    textField.text = [NSString stringWithFormat:@"%lu", value];
    slider.value = value;
}

- (void)setFloatValue:(float)value forIndex:(int)idx
{
    UITextField *textField = (UITextField *)[self.view viewWithTag:10 + idx * 10];
    UISlider *slider = (UISlider *)[self.view viewWithTag:10 + idx * 10 + 1];
    textField.text = [NSString stringWithFormat:@"%.2f", value];
    slider.value = value;
}

@end
