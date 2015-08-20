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

#import "HPPPPrintJobsTableViewCell.h"
#import "HPPP.h"

@interface HPPPPrintJobsTableViewCell()

@property (strong, nonatomic) NSDateFormatter *formatter;
@property (weak, nonatomic) IBOutlet UIImageView *jobThumbnailImageView;
@property (weak, nonatomic) IBOutlet UILabel *jobNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *jobDateLabel;

@end

@implementation HPPPPrintJobsTableViewCell

- (void)awakeFromNib
{
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleImageTap:)];
    tap.cancelsTouchesInView = YES;
    tap.numberOfTapsRequired = 1;
    [self.jobThumbnailImageView addGestureRecognizer:tap];
    
    HPPP *hppp = [HPPP sharedInstance];
    
    self.jobNameLabel.font = [hppp.appearance.settings objectForKey:kHPPPJobSettingsPrimaryFont];
    self.jobNameLabel.textColor = [hppp.appearance.settings objectForKey:kHPPPJobSettingsPrimaryFontColor];
    
    NSString *formatString = [NSDateFormatter dateFormatFromTemplate:[[HPPP sharedInstance].appearance.settings objectForKey:kHPPPGeneralDefaultDateFormat]
                                                             options:0
                                                              locale:[NSLocale currentLocale]];
    self.formatter = [[NSDateFormatter alloc] init];
    [self.formatter setDateFormat:formatString];
    
    self.jobDateLabel.font = [hppp.appearance.settings objectForKey:kHPPPJobSettingsSecondaryFont];
    self.jobDateLabel.textColor = [hppp.appearance.settings objectForKey:kHPPPJobSettingsSecondaryFontColor];
}

- (void)setPrintLaterJob:(HPPPPrintLaterJob *)job
{
    _printLaterJob = job;
    
    self.jobNameLabel.text = job.name;
    
    self.jobDateLabel.text = [self.formatter stringFromDate:job.date];
    
    self.jobThumbnailImageView.image = [job previewImage];
}

- (void)handleImageTap:(UIGestureRecognizer *)gestureRecognizer
{
    if ([self.delegate respondsToSelector:@selector(printJobsTableViewCellDidTapImage:)]) {
        [self.delegate printJobsTableViewCellDidTapImage:self];
    }
}

@end
