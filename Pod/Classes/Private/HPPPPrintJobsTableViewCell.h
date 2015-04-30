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

#import <UIKit/UIKit.h>

@protocol HPPPPrintJobsTableViewCellDelegate;

@interface HPPPPrintJobsTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *jobThumbnailImageView;
@property (weak, nonatomic) IBOutlet UILabel *jobNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *jobDateLabel;
@property (weak, nonatomic) id<HPPPPrintJobsTableViewCellDelegate> delegate;

@end

@protocol HPPPPrintJobsTableViewCellDelegate <NSObject>

- (void)printJobsTableViewCellDidTapImage:(HPPPPrintJobsTableViewCell *)printJobsTableViewCell;

@end
