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
#import "HPPP.h"
#import "HPPPRuleView.h"
#import "XBCurlView.h"
#import "UIImage+HPPPResize.h"
#import "UIView+HPPPAnimation.h"
#import "HPPPLayoutPaperView.h"
#import "HPPPLayoutFactory.h"

#define PREVIEW_CONTAINER_SCALE 0.9f

@interface HPPPPageView ()

@property (weak, nonatomic) IBOutlet HPPPLayoutPaperView *paperView;
@property (weak, nonatomic) IBOutlet UIView *containerView;
@property (unsafe_unretained, nonatomic) IBOutlet UILabel *sizeLabel;
@property (strong, nonatomic) UIImage *blackAndWhiteImage;
@property (strong, nonatomic) UIImage *image;
@property (strong, nonatomic) HPPPPaper *paper;

@end

@implementation HPPPPageView

- (void)setPrintItem:(HPPPPrintItem *)printItem
{
    _printItem = printItem;
    self.image = [printItem defaultPreviewImage];
    self.paperView.image = self.blackAndWhite ? [self createBlackAndWhiteImage] : self.image;
    self.paperView.layout = _printItem.layout;
}

- (void)setImage:(UIImage *)image
{
    _image = image;
    self.blackAndWhiteImage = nil;
    self.isAnimating = FALSE;
}

- (void)setFilterWithImage:(UIImage *)image completion:(void (^)(void))completion
{
    [UIView transitionWithView:self.paperView
                      duration:0.25
                       options:UIViewAnimationOptionTransitionCrossDissolve
                    animations:^{
                        self.paperView.image = image;
                        [self.paperView setNeedsDisplay];
                    }
                    completion:^(BOOL finished) {
                        if (completion) {
                            completion();
                        }
                    }];
}

- (void)setColorWithCompletion:(void (^)(void))completion
{
    [self setFilterWithImage:self.image completion:completion];
}

- (void)setBlackAndWhiteWithCompletion:(void (^)(void))completion
{
    UIActivityIndicatorView *spinner = [self.paperView HPPPAddSpinner];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        [self createBlackAndWhiteImage];
        dispatch_async(dispatch_get_main_queue(), ^{
            [spinner removeFromSuperview];
            [self setFilterWithImage:self.blackAndWhiteImage completion:completion];
        });
    });
}

- (UIImage *)createBlackAndWhiteImage
{
    if (!self.blackAndWhiteImage) {
        @autoreleasepool {
            CIImage *image = [[CIImage alloc] initWithCGImage:self.image.CGImage options:nil];
            
            CIFilter *filter = [CIFilter filterWithName:@"CIPhotoEffectNoir"];
            
            [filter setValue:image forKey:kCIInputImageKey];
            
            CIImage *result = [filter valueForKey:kCIOutputImageKey];
            CIContext *context = [CIContext contextWithOptions:nil];
            CGImageRef cgImage = [context createCGImage:result fromRect:[result extent]];
            
            self.blackAndWhiteImage = [UIImage imageWithCGImage:cgImage
                                                          scale:self.image.scale
                                                    orientation:self.image.imageOrientation];
            
            CGImageRelease(cgImage);
        }
    }
    
    return self.blackAndWhiteImage;
}

- (void)refreshLayout
{
    if (!self.paper) {
        NSLog(@"Skipping paper layout due to no paper specified");
        return;
    }

    HPPPLayout *paperLayout = [HPPPLayoutFactory layoutWithType:HPPPLayoutTypeFit orientation:HPPPLayoutOrientationMatchContainer assetPosition:[HPPPLayout completeFillRectangle] allowContentRotation:YES];
    [HPPPLayout preparePaperView:self.paperView withPaper:self.paper];
    [paperLayout layoutContentView:self.paperView inContainerView:self.containerView];
        
    [self layoutSizeLabel];
}

- (void)layoutSizeLabel
{
    NSMutableArray *labelConstraints = [NSMutableArray array];
    for (NSLayoutConstraint *constraint in self.containerView.constraints) {
        if (constraint.firstItem == self.sizeLabel || constraint.secondItem == self.sizeLabel) {
            [labelConstraints addObject:constraint];
        }
    }
    
    if ([NSLayoutConstraint respondsToSelector:@selector(deactivateConstraints:)]) {
        [NSLayoutConstraint deactivateConstraints:labelConstraints];
    } else {
        [self.containerView removeConstraints:labelConstraints];
    }
    
    NSDictionary *views = @{ @"sizeLabel":self.sizeLabel, @"paperView":self.paperView };
    NSDictionary *values = @{ @"space":[NSNumber numberWithFloat:10.0f] };
    
    NSArray *horizontalConstraints = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-space-[sizeLabel]-space-|" options:0 metrics:values views:views];
    NSArray *verticalConstraints = [NSLayoutConstraint constraintsWithVisualFormat:@"V:[paperView]-space-[sizeLabel]" options:0 metrics:values views:views];
    labelConstraints = [NSMutableArray arrayWithArray:horizontalConstraints];
    [labelConstraints addObjectsFromArray:verticalConstraints];
    
    if ([NSLayoutConstraint respondsToSelector:@selector(activateConstraints:)]) {
        [NSLayoutConstraint activateConstraints:labelConstraints];
    } else {
        [self.containerView addConstraints:labelConstraints];
    }
    
    [self.containerView setNeedsLayout];
    [self.containerView layoutIfNeeded];
}

- (void)setPaperSize:(HPPPPaper *)paper animated:(BOOL)animated completion:(void (^)(void))completion
{
    self.sizeLabel.font = [HPPP sharedInstance].tableViewCellValueFont;
    self.sizeLabel.text = [NSString stringWithFormat:@"%@ x %@", paper.paperWidthTitle, paper.paperHeightTitle];
    
    self.paper = paper;
    
    [self refreshLayout];
    
    if (completion) {
        completion();
    }
}

- (void)curlPage
{
    self.isAnimating = TRUE;
    UIView *curlTargetView = self.paperView;
    XBCurlView *curlView = [[XBCurlView alloc] initWithFrame:curlTargetView.frame horizontalResolution:30 verticalResolution:42 antialiasing:NO];
    curlView.opaque = NO; //Transparency on the next page (so that the view behind curlView will appear)
    curlView.pageOpaque = YES; //The page to be curled has no transparency
    [curlView curlView:curlTargetView cylinderPosition:CGPointMake(curlTargetView.frame.size.width - 40, curlTargetView.frame.size.height - 40) cylinderAngle:M_PI_2 + M_PI_4 cylinderRadius:10 animatedWithDuration:0.4f completion:^{
        dispatch_async(dispatch_get_main_queue(), ^{
            [curlView uncurlAnimatedWithDuration:0.4f completion:^{
                self.isAnimating = FALSE;
            }];
        });
    }];
}

- (void)showPageAnimated:(BOOL)animated completion:(void (^)(void))completion;
{
    if (animated) {
        [self layoutIfNeeded];
        [UIView animateWithDuration:0.2f animations:^{
            self.containerView.alpha = 1.0f;
            [self layoutIfNeeded];
        } completion:^(BOOL finished) {
            if (completion) {
                completion();
            }
        }];
    } else {
        self.containerView.alpha = 1.0f;
        if (completion) {
            completion();
        }
    }
}

@end
