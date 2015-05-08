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
@property (strong, nonatomic) NSDateFormatter *formatter;

@end

@implementation HPPPPrintJobsPreviewViewController

extern NSString * const kHPPPLastPaperSizeSetting;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    HPPP *hppp = [HPPP sharedInstance];
    
    [self.doneButton setTitle:HPPPLocalizedString(@"Done", nil) forState:UIControlStateNormal];
    self.doneButton.titleLabel.font = [hppp.appearance.printQueueScreenAttributes objectForKey:kHPPPPrintQueueScreenPreviewDoneButtonFontAttribute];
    [self.doneButton setTitleColor:[hppp.appearance.printQueueScreenAttributes objectForKey:kHPPPPrintQueueScreenPreviewDoneButtonColorAttribute] forState:UIControlStateNormal];
    
    self.printJobNameLabel.font = [hppp.appearance.printQueueScreenAttributes objectForKey:kHPPPPrintQueueScreenPreviewJobNameFontAttribute];
    self.printJobNameLabel.textColor = [hppp.appearance.printQueueScreenAttributes objectForKey:kHPPPPrintQueueScreenPreviewJobNameColorAttribute];
    
    self.printJobDateLabel.font = [hppp.appearance.printQueueScreenAttributes objectForKey:kHPPPPrintQueueScreenPreviewJobDateFontAttribute];
    self.printJobDateLabel.textColor = [hppp.appearance.printQueueScreenAttributes objectForKey:kHPPPPrintQueueScreenPreviewJobDateColorAttribute];
    
    NSString *formatString = [NSDateFormatter dateFormatFromTemplate:[HPPP sharedInstance].defaultDateFormat options:0 locale:[NSLocale currentLocale]];
    self.formatter = [[NSDateFormatter alloc] init];
    [self.formatter setDateFormat:formatString];
    
    self.view.alpha = 0.0f;
    
    self.printJobNameLabel.text = self.printLaterJob.name;
    self.printJobDateLabel.text = [self.formatter stringFromDate:self.printLaterJob.date];
    NSString *paperSizeTitle = [HPPPPaper titleFromSize:[self lastPaperUsed]];
    self.imageView.image = [self.printLaterJob.images objectForKey:paperSizeTitle];
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

#pragma mark - Utils

- (void)dismissViewController
{
    [UIView animateWithDuration:0.5f animations:^{
        self.view.alpha = 0.0f;
        
    } completion:^(BOOL finished) {
        [self dismissViewControllerAnimated:NO completion:nil];
        
    }];
}

- (PaperSize)lastPaperUsed
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    NSNumber *lastSizeUsed = [defaults objectForKey:kHPPPLastPaperSizeSetting];
    
    PaperSize paperSize = [HPPP sharedInstance].initialPaperSize;
    
    if (lastSizeUsed) {
        paperSize = (PaperSize)[lastSizeUsed integerValue];
    }
    
    return paperSize;
}

@end
