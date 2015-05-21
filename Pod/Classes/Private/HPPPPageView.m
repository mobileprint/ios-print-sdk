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

#define PREVIEW_CONTAINER_SCALE 0.9f

@interface HPPPPageView ()

@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UIView *paperView;
@property (weak, nonatomic) IBOutlet HPPPRuleView *ruleView;
@property (weak, nonatomic) IBOutlet UIView *containerView;
@property (strong, nonatomic) UIImage *blackAndWhiteImage;

@property (strong, nonatomic) IBOutlet NSLayoutConstraint *paperWidthConstraint;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *paperHeightConstraint;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *imageWidthConstraint;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *imageHeightConstraint;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *ruleWidthContraint;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *ruleHeightContraint;
@property (weak, nonatomic) IBOutlet UIImageView *multipleImagesImageView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *paperViewHorizConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *paperViewVertConstraint;

@property (strong, nonatomic) UIImage *image;

@end

@implementation HPPPPageView

- (void)setPrintItem:(HPPPPrintItem *)printItem
{
    _printItem = printItem;
    self.image = [printItem defaultPreviewImage];
}

- (void)setImage:(UIImage *)image
{
    _image = image;
    self.imageView.image = image;
    self.blackAndWhiteImage = nil;
    
    if (self.isMultipleImages) {
        self.multipleImagesImageView.hidden = NO;
    }
    
    if( [[HPPP sharedInstance] showRulers] ) {
        [self.ruleView showRulers:TRUE];
    } else {
        [self.ruleView showRulers:FALSE];
        
        self.paperViewHorizConstraint.constant = (self.ruleView.frame.size.width - self.paperView.frame.size.width)/2;
        self.paperViewVertConstraint.constant = (self.ruleView.frame.size.height - self.paperView.frame.size.height)/2;
    }
    
    self.isAnimating = FALSE;
}

- (void)setFilterWithImage:(UIImage *)image completion:(void (^)(void))completion
{
    [UIView transitionWithView:self.imageView
                      duration:0.25
                       options:UIViewAnimationOptionTransitionCrossDissolve
                    animations:^{
                        self.imageView.image = image;
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
    if (self.blackAndWhiteImage == nil) {
        
        UIActivityIndicatorView *spinner = [self.imageView HPPPAddSpinner];
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            
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
            
            dispatch_async(dispatch_get_main_queue(), ^{
                
                [spinner removeFromSuperview];
                
                [self setFilterWithImage:self.blackAndWhiteImage completion:completion];
            });
        });
    } else {
        [self setFilterWithImage:self.blackAndWhiteImage completion:completion];
    }
}

- (void)setPaperSize:(HPPPPaper *)paperSize animated:(BOOL)animated completion:(void (^)(void))completion
{
    HPPP *hppp = [HPPP sharedInstance];
    self.ruleView.widthLabel.font = hppp.rulesLabelFont;
    self.ruleView.heightLabel.font = hppp.rulesLabelFont;
    self.ruleView.sizeLabel.font = hppp.tableViewCellValueFont;
    
    CGSize computedPaperSize = [self paperSizeWithWidth:paperSize.width height:paperSize.height containerSize:self.containerView.frame.size containerScale:PREVIEW_CONTAINER_SCALE];
    
    CGSize computedImageSize;
    
    if (DefaultPrintRenderer == self.printItem.renderer || (((paperSize.width != hppp.defaultPaper.width) || (paperSize.height != hppp.defaultPaper.height)) && (paperSize.paperSize != SizeLetter))) {
        if (hppp.zoomAndCrop) {
            computedImageSize = CGSizeMake(computedPaperSize.height * hppp.defaultPaper.width / hppp.defaultPaper.height, computedPaperSize.height);
        } else {
            computedImageSize = computedPaperSize;
        }
    } else {
        computedImageSize = CGSizeMake(computedPaperSize.width * hppp.defaultPaper.width / paperSize.width, computedPaperSize.height * hppp.defaultPaper.height / paperSize.height);
    }
    
    [self HPPPAnimateConstraintsWithDuration:0.5f constraints:^{
        
        self.ruleView.widthLabel.text = [NSString stringWithFormat:@"%@″", paperSize.paperWidthTitle];
        self.ruleView.heightLabel.text = [NSString stringWithFormat:@"%@″", paperSize.paperHeightTitle];
        self.ruleView.sizeLabel.text = [NSString stringWithFormat:@"%@ x %@", paperSize.paperWidthTitle, paperSize.paperHeightTitle];

        if ([self.image HPPPIsPortraitImage]) {
            self.paperWidthConstraint.constant = computedPaperSize.width;
            self.paperHeightConstraint.constant = computedPaperSize.height;
            
            self.imageWidthConstraint.constant = computedImageSize.width;
            self.imageHeightConstraint.constant = computedImageSize.height;
            
            if (self.isMultipleImages) {
                self.multipleImagesImageView.image = [UIImage imageNamed:@"HPPPMultipage"];
            }
        } else {
            if (paperSize.width == 8.5f) {
                self.paperWidthConstraint.constant = computedPaperSize.width;
                self.paperHeightConstraint.constant = computedPaperSize.height;
                
                if (self.isMultipleImages) {
                    self.multipleImagesImageView.image = [UIImage imageNamed:@"HPPPMultipage"];
                }
            } else {
                self.ruleView.widthLabel.text = [NSString stringWithFormat:@"%@″", paperSize.paperHeightTitle];
                self.ruleView.heightLabel.text = [NSString stringWithFormat:@"%@″", paperSize.paperWidthTitle];

                self.paperWidthConstraint.constant = computedPaperSize.height;
                self.paperHeightConstraint.constant = computedPaperSize.width;
                
                if (self.isMultipleImages) {
                    self.multipleImagesImageView.image = [UIImage imageNamed:@"HPPPMultipageLandscape"];
                }
            }
            
            self.imageWidthConstraint.constant = computedImageSize.height;
            self.imageHeightConstraint.constant = computedImageSize.width;
        }
        
        self.ruleHeightContraint.constant = self.paperHeightConstraint.constant + 50;
        self.ruleWidthContraint.constant = self.paperWidthConstraint.constant + 50;
        
    } completion:^(BOOL finished) {
        if (animated) {
            self.isAnimating = TRUE;
            
            UIView *curlTargetView = self.paperView;
            
            // if we don't call the completion handler here, the user will not be able to
            //  interact with the screen until the page curl animation finishes
            if (completion) {
                completion();
            }

            if (paperSize.paperSize == Size4x5) {
                curlTargetView = self.imageView;
            }
            
            XBCurlView *curlView = [[XBCurlView alloc] initWithFrame:curlTargetView.frame horizontalResolution:30 verticalResolution:42 antialiasing:NO];
            
            curlView.opaque = NO; //Transparency on the next page (so that the view behind curlView will appear)
            curlView.pageOpaque = YES; //The page to be curled has no transparency
            [curlView curlView:curlTargetView cylinderPosition:CGPointMake(curlTargetView.frame.size.width - 40, curlTargetView.frame.size.height - 40) cylinderAngle:M_PI_2 + M_PI_4 cylinderRadius:10 animatedWithDuration:0.6f completion:^{
                dispatch_async(dispatch_get_main_queue(), ^{
                    
                    [curlView uncurlAnimatedWithDuration:0.6f completion:^{
                        self.isAnimating = FALSE;
                    }];
                });
            }];
        } else {
            if (completion) {
                completion();
            }
        }
    }];
}

- (CGSize)paperSizeWithWidth:(CGFloat)width height:(CGFloat)height containerSize:(CGSize)containerSize containerScale:(CGFloat)containerScale
{
    if( [[HPPP sharedInstance] showRulers] ) {
        containerSize.height -= (self.ruleView.horizontalRulerHeight + 2);
        containerSize.width -= (self.ruleView.verticalRulerWidth + 2);
    }
    
    containerSize.height *= containerScale;
    containerSize.width *= containerScale;
    
    CGFloat scaleX = containerSize.width / width;
    CGFloat scaleY = containerSize.height / height;
    
    CGSize finalSizeScale;
    
    CGFloat scale = fminf(scaleX, scaleY);
    
    finalSizeScale = CGSizeMake(scale, scale);
    
    return CGSizeMake(finalSizeScale.width * width, finalSizeScale.height * height);
}

@end
