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

#import "HPPPPrintJobsPreviewViewController.h"
#import "HPPP.h"
#import "NSBundle+HPPPLocalizable.h"

@interface HPPPPrintJobsPreviewViewController ()

@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UIButton *doneButton;
@property (weak, nonatomic) IBOutlet UILabel *printJobNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *printJobDateLabel;

@end

@implementation HPPPPrintJobsPreviewViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.imageView.image = self.image;
    
    HPPP *hppp = [HPPP sharedInstance];
    
    [self.doneButton setTitle:HPPPLocalizedString(@"Done", nil) forState:UIControlStateNormal];
    self.doneButton.titleLabel.font = [hppp.appearance.printQueueScreenAttributes objectForKey:HPPPPrintQueueScreenPreviewDoneButtonFontAttribute];
    [self.doneButton setTitleColor:[hppp.appearance.printQueueScreenAttributes objectForKey:HPPPPrintQueueScreenPreviewDoneButtonColorAttribute] forState:UIControlStateNormal];
    
    self.printJobNameLabel.font = [hppp.appearance.printQueueScreenAttributes objectForKey:HPPPPrintQueueScreenPreviewJobNameFontAttribute];
    self.printJobNameLabel.textColor = [hppp.appearance.printQueueScreenAttributes objectForKey:HPPPPrintQueueScreenPreviewJobNameColorAttribute];
    
    self.printJobDateLabel.font = [hppp.appearance.printQueueScreenAttributes objectForKey:HPPPPrintQueueScreenPreviewJobDateFontAttribute];
    self.printJobDateLabel.textColor = [hppp.appearance.printQueueScreenAttributes objectForKey:HPPPPrintQueueScreenPreviewJobDateColorAttribute];
    
    self.printJobNameLabel.text = self.name;
    self.printJobDateLabel.text = self.date;
    
    self.view.alpha = 0.0f;
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [UIView animateWithDuration:0.5f animations:^{
        self.view.alpha = 1.0f;
        
    }];
}

- (IBAction)doneButtonTapped:(id)sender
{
    [self dismissViewController];
}

- (IBAction)outsideImageTapped:(id)sender
{
    [self dismissViewController];
}

- (void)dismissViewController
{
    [UIView animateWithDuration:0.5f animations:^{
        self.view.alpha = 0.0f;
        
    } completion:^(BOOL finished) {
        [self dismissViewControllerAnimated:NO completion:nil];
        
    }];
}

@end
