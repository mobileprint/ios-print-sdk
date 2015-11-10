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

#import "MPPrintJobsTableViewCell.h"
#import "MP.h"

@interface MPPrintJobsTableViewCell()

@property (strong, nonatomic) NSDateFormatter *formatter;
@property (weak, nonatomic) IBOutlet UIImageView *jobThumbnailImageView;
@property (weak, nonatomic) IBOutlet UILabel *jobNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *jobDateLabel;
@property (weak, nonatomic) IBOutlet UIImageView *magnifyingGlassImageView;

@end

@implementation MPPrintJobsTableViewCell

- (void)awakeFromNib
{
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleImageTap:)];
    tap.cancelsTouchesInView = YES;
    tap.numberOfTapsRequired = 1;
    [self.jobThumbnailImageView addGestureRecognizer:tap];
    
    MP *mp = [MP sharedInstance];
    
    self.backgroundColor = [mp.appearance.settings objectForKey:kMPJobSettingsBackgroundColor];
    self.jobNameLabel.font = [mp.appearance.settings objectForKey:kMPJobSettingsPrimaryFont];
    self.jobNameLabel.textColor = [mp.appearance.settings objectForKey:kMPJobSettingsPrimaryFontColor];
    
    NSString *formatString = [NSDateFormatter dateFormatFromTemplate:[[MP sharedInstance].appearance dateFormat]
                                                             options:0
                                                              locale:[NSLocale currentLocale]];
    self.formatter = [[NSDateFormatter alloc] init];
    [self.formatter setDateFormat:formatString];
    
    self.jobDateLabel.font = [mp.appearance.settings objectForKey:kMPJobSettingsSecondaryFont];
    self.jobDateLabel.textColor = [mp.appearance.settings objectForKey:kMPJobSettingsSecondaryFontColor];
    
    self.magnifyingGlassImageView = [mp.appearance.settings objectForKey:kMPJobSettingsMagnifyingGlassIcon];
}

- (void)setPrintLaterJob:(MPPrintLaterJob *)job
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
