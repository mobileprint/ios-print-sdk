//
// HP Inc.
// All rights reserved.
//
// This file, its contents, concepts, methods, behavior, and operation
// (collectively the "Software") are protected by trade secret, patent,
// and copyright laws. The use of the Software is governed by a license
// agreement. Disclosure of the Software to third parties, in any form,
// in whole or in part, is expressly prohibited except as authorized by
// the license agreement.
//

#import "MPPrintJobsPreviewViewController.h"
#import "MP.h"
#import "MPPaper.h"
#import "MPPrintItem.h"
#import "MPLayoutPaperView.h"
#import "MPLayoutFactory.h"
#import "NSBundle+MPLocalizable.h"
#import "MPPrintSettingsDelegateManager.h"

@interface MPPrintJobsPreviewViewController ()

@property (weak, nonatomic) IBOutlet UIButton *doneButton;
@property (weak, nonatomic) IBOutlet UILabel *printJobNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *printJobDateLabel;
@property (strong, nonatomic) NSDateFormatter *formatter;
@property (weak, nonatomic) IBOutlet MPLayoutPaperView *paperView;
@property (weak, nonatomic) IBOutlet UIView *containerView;
@property (weak, nonatomic) IBOutlet UIView *smokeyView;

@end

@implementation MPPrintJobsPreviewViewController

extern NSString * const kMPLastPaperSizeSetting;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    MP *mp = [MP sharedInstance];
    
    self.smokeyView.backgroundColor = [mp.appearance.settings objectForKey:kMPOverlayBackgroundColor];
    self.smokeyView.alpha = [[mp.appearance.settings objectForKey:kMPOverlayBackgroundOpacity] floatValue];

    [self.doneButton setTitle:MPLocalizedString(@"Done", nil) forState:UIControlStateNormal];
    self.doneButton.titleLabel.font = [mp.appearance.settings objectForKey:kMPOverlayLinkFont];
    [self.doneButton setTitleColor:[mp.appearance.settings objectForKey:kMPOverlayLinkFontColor] forState:UIControlStateNormal];
    
    self.printJobNameLabel.font = [mp.appearance.settings objectForKey:kMPOverlayPrimaryFont];
    self.printJobNameLabel.textColor = [mp.appearance.settings objectForKey:kMPOverlayPrimaryFontColor];
    
    self.printJobDateLabel.font = [mp.appearance.settings objectForKey:kMPOverlaySecondaryFont];
    self.printJobDateLabel.textColor = [mp.appearance.settings objectForKey:kMPOverlaySecondaryFontColor];
    
    NSString *formatString = [NSDateFormatter dateFormatFromTemplate:[[MP sharedInstance].appearance dateFormat]
                                                             options:0
                                                              locale:[NSLocale currentLocale]];
    self.formatter = [[NSDateFormatter alloc] init];
    [self.formatter setDateFormat:formatString];
    
    self.view.alpha = 0.0f;
    
    self.printJobNameLabel.text = self.printLaterJob.name;
    self.printJobDateLabel.text = [self.formatter stringFromDate:self.printLaterJob.date];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [self configurePaper];
    
    [UIView animateWithDuration:MP_ANIMATION_DURATION animations:^{
        self.view.alpha = 1.0f;
        
    }];
}

- (void)viewDidLayoutSubviews
{
    [self configurePaper];
}

- (void)configurePaper
{
    [self.view layoutIfNeeded];
    MPPaper *lastPaperUsed = [MPPrintSettingsDelegateManager lastPaperUsed];
    MPPrintItem *printItem = [self printItemForPaperSize:lastPaperUsed.paperSize];
    [MPLayout preparePaperView:self.paperView withPaper:lastPaperUsed image:[printItem previewImageForPaper:lastPaperUsed] layout:printItem.layout];
    MPLayout *fitLayout = [MPLayoutFactory layoutWithType:[MPLayoutFit layoutType] orientation:MPLayoutOrientationFixed assetPosition:[MPLayout completeFillRectangle]];
    [fitLayout layoutContentView:self.paperView inContainerView:self.containerView];
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
    [[NSNotificationCenter defaultCenter] postNotificationName:[self dismissalNotificationName]
                                                        object:nil
                                                      userInfo:nil];

    [UIView animateWithDuration:MP_ANIMATION_DURATION animations:^{
        self.view.alpha = 0.0f;
        
    } completion:^(BOOL finished) {
        [self dismissViewControllerAnimated:NO completion:nil];
    }];
}

- (NSString *)dismissalNotificationName
{
    return @"PrintQueuePreviewDismissed";
}

- (NSUInteger)lastPaperUsed
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    NSNumber *lastSizeUsed = [defaults objectForKey:kMPLastPaperSizeSetting];
    
    NSUInteger paperSize = [MP sharedInstance].defaultPaper.paperSize;
    
    if (lastSizeUsed) {
        paperSize = [lastSizeUsed unsignedIntegerValue];
    }
    
    return paperSize;
}

- (CGSize)paperSizeWithWidth:(CGFloat)width height:(CGFloat)height containerSize:(CGSize)containerSize
{
    CGFloat scaleX = containerSize.width / width;
    CGFloat scaleY = containerSize.height / height;
    
    CGSize finalSizeScale;
    
    CGFloat scale = fminf(scaleX, scaleY);
    
    finalSizeScale = CGSizeMake(scale, scale);
    
    return CGSizeMake(finalSizeScale.width * width, finalSizeScale.height * height);
}

- (MPPrintItem *)printItemForPaperSize:(NSUInteger)paperSize
{
    NSString *paperSizeTitle = [MPPaper titleFromSize:paperSize];
    MPPrintItem *printItem = [self.printLaterJob printItemForPaperSize:paperSizeTitle];
    
    if (printItem == nil) {
        printItem = [self.printLaterJob printItemForPaperSize:[MPPaper titleFromSize:[MP sharedInstance].defaultPaper.paperSize]];
    }
    return printItem;}

@end
