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

#import "HPPPPageView.h"

@protocol HPPPPageViewControllerDelegate;

@interface HPPPPageViewController : UIViewController

@property (weak, nonatomic) IBOutlet HPPPPageView *pageView;
@property (strong, nonatomic) UIImage *image;
@property (nonatomic, weak) id<HPPPPageViewControllerDelegate> delegate;

@end



@protocol HPPPPageViewControllerDelegate <NSObject>

- (void)pageViewController:(HPPPPageViewController *)pageViewController didTapPrintBarButtonItem:(UIBarButtonItem *)printBarButtonItem;

@end