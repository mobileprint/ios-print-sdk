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

#import "MPPrintJobsActionView.h"
#import "MP.h"
#import "NSBundle+MPLocalizable.h"

@interface MPPrintJobsActionView ()

@property (weak, nonatomic) IBOutlet UIView *selectAllSeparatorView;
@property (weak, nonatomic) IBOutlet UIView *deleteSeparatorView;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *selectAllButtonWidth;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *deleteButtonWidth;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *nextButtonWidth;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *selectAllButtonLeadingSpace;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *deleteButtonLeadingSpace;

@end

@implementation MPPrintJobsActionView

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self setup];
    }
    return self;
}

- (void)setup
{
    MP *mp = [MP sharedInstance];

    UIColor *enableColor = [mp.appearance.settings objectForKey:kMPMainActionActiveLinkFontColor];
    UIColor *disableColor = [mp.appearance.settings objectForKey:kMPMainActionInactiveLinkFontColor];

    UIColor *separatorColor = [mp.appearance.settings objectForKey:kMPGeneralBackgroundColor];

    UIFont *font = [mp.appearance.settings objectForKey:kMPMainActionLinkFont];
    
    self.selectAllButton.titleLabel.font = font;
    self.deleteButton.titleLabel.font = font;
    self.nextButton.titleLabel.font = font;
    
    [self.selectAllButton setBackgroundColor:[mp.appearance.settings objectForKey:kMPMainActionBackgroundColor]];
    [self.selectAllButton setTitleColor:enableColor forState:UIControlStateNormal];
    [self.selectAllButton setTitle:MPLocalizedString(@"Select All", nil) forState:UIControlStateNormal];

    [self.deleteButton setBackgroundColor:[mp.appearance.settings objectForKey:kMPMainActionBackgroundColor]];
    [self.deleteButton setTitleColor:enableColor forState:UIControlStateNormal];
    [self.deleteButton setTitleColor:disableColor forState:UIControlStateDisabled];
    [self.deleteButton setTitle:MPLocalizedString(@"Delete", nil) forState:UIControlStateNormal];

    [self.nextButton setBackgroundColor:[mp.appearance.settings objectForKey:kMPMainActionBackgroundColor]];
    [self.nextButton setTitleColor:enableColor forState:UIControlStateNormal];
    [self.nextButton setTitleColor:disableColor forState:UIControlStateDisabled];
    [self.nextButton setTitle:MPLocalizedString(@"Next", nil) forState:UIControlStateNormal];
    
    self.selectAllSeparatorView.backgroundColor = separatorColor;
    self.deleteSeparatorView.backgroundColor = separatorColor;
    
    CGFloat screenWidth = [UIScreen mainScreen].bounds.size.width;
    self.selectAllButtonWidth.constant = screenWidth / 3.0f;
    self.deleteButtonLeadingSpace.constant = screenWidth / 3.0f;
    self.deleteButtonWidth.constant = screenWidth / 3.0f;
    self.nextButtonWidth.constant = screenWidth / 3.0f;
    
    self.selectAllState = YES;
}

#pragma mark - Button action methods

- (IBAction)selectAllButtonTapped:(id)sender
{
    if ([self.delegate respondsToSelector:@selector(printJobsActionViewDidTapSelectAllButton:)]) {
        [self.delegate printJobsActionViewDidTapSelectAllButton:self];
    }
}

- (IBAction)deleteButtonTapped:(id)sender
{
    if ([self.delegate respondsToSelector:@selector(printJobsActionViewDidTapDeleteButton:)]) {
        [self.delegate printJobsActionViewDidTapDeleteButton:self];
    }
}

- (IBAction)nextButtonTapped:(id)sender
{
    if ([self.delegate respondsToSelector:@selector(printJobsActionViewDidTapNextButton:)]) {
        [self.delegate printJobsActionViewDidTapNextButton:self];
    }
}

#pragma mark - Setter methods

-(void)setSelectAllState:(BOOL)selectAllState
{
    _selectAllState = selectAllState;
    if (selectAllState) {
        [self.selectAllButton setTitle:MPLocalizedString(@"Select All", nil) forState:UIControlStateNormal];
    } else {
        [self.selectAllButton setTitle:MPLocalizedString(@"Unselect All", nil) forState:UIControlStateNormal];
    }
}

#pragma mark - Utils

- (void)hideSelectAllButton
{
    self.selectAllButton.hidden = YES;
    self.selectAllSeparatorView.hidden = YES;
    
    CGFloat screenWidth = [UIScreen mainScreen].bounds.size.width;
    self.deleteButtonLeadingSpace.constant = 0.0f;
    
    if (self.nextButton.hidden) {
        self.deleteButtonWidth.constant = screenWidth;
    } else {
        self.deleteButtonWidth.constant = screenWidth / 2.0f;
        self.nextButtonWidth.constant = screenWidth / 2.0f;
    }
}

- (void)hideNextButton
{
    self.nextButton.hidden = YES;
    self.deleteSeparatorView.hidden = YES;
    
    CGFloat screenWidth = [UIScreen mainScreen].bounds.size.width;
    
    if (self.selectAllButton.hidden) {
        self.deleteButtonLeadingSpace.constant = 0.0f;
        self.deleteButtonWidth.constant = screenWidth;
    } else {
        self.deleteButtonLeadingSpace.constant = screenWidth / 2.0f;
        self.selectAllButtonWidth.constant = screenWidth / 2.0f;
        self.deleteButtonWidth.constant = screenWidth / 2.0f;
    }
}

- (void)showNextButton
{
    self.nextButton.hidden = NO;
    self.deleteSeparatorView.hidden = NO;
    
    CGFloat screenWidth = [UIScreen mainScreen].bounds.size.width;
    
    if (self.selectAllButton.hidden) {
        self.deleteButtonLeadingSpace.constant = 0.0f;
        self.deleteButtonWidth.constant = screenWidth / 2.0f;
        self.nextButtonWidth.constant = screenWidth / 2.0f;
    } else {
        self.selectAllButtonWidth.constant = screenWidth / 3.0f;
        self.deleteButtonLeadingSpace.constant = screenWidth / 3.0f;
        self.deleteButtonWidth.constant = screenWidth / 3.0f;
        self.nextButtonWidth.constant = screenWidth / 3.0f;
    }
}

@end
