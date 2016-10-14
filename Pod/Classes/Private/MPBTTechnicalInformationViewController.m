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

#import "MPBTTechnicalInformationViewController.h"
#import "MP.h"
#import <TTTAttributedLabel.h>

@interface MPBTTechnicalInformationViewController () <TTTAttributedLabelDelegate>

@property (strong, nonatomic) NSArray *links;
@property (weak, nonatomic) IBOutlet UILabel *disposalTextLabel;

@property (strong, nonatomic) IBOutletCollection(UILabel) NSArray *titleLabels;
@property (strong, nonatomic) IBOutletCollection(UILabel) NSArray *textLabels;
   
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;

@end

@implementation MPBTTechnicalInformationViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.links = @[ @"www.hp.com/go/ecodata",
                    @"http://www.hp.com/go/reach",
                    @"www.hp.com/recycle" ];

    UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"Back"]
                                                                   style:UIBarButtonItemStylePlain
                                                                  target:self
                                                                  action:@selector(didPressBack)];
    self.navigationItem.leftBarButtonItem = backButton;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    for (UILabel *label in self.titleLabels) {
        [self configureTitle:label];
    }

    for (UILabel *label in self.textLabels) {
        [self configureText:label];
    }
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];

    self.scrollView.contentSize = CGSizeMake(self.view.frame.size.width, self.disposalTextLabel.frame.origin.y + self.disposalTextLabel.frame.size.height + 33);
}
    
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)didPressBack
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)configureTitle:(UILabel*)titleLabel
{
    titleLabel.font = [[MP sharedInstance].appearance.settings objectForKey:kMPGeneralBackgroundPrimaryFont];
    titleLabel.textColor = [[MP sharedInstance].appearance.settings objectForKey:kMPGeneralBackgroundPrimaryFontColor];
    [titleLabel sizeToFit];
}

- (void)configureText:(UILabel *)textLabel
{
    textLabel.font = [[MP sharedInstance].appearance.settings objectForKey:kMPGeneralBackgroundSecondaryFont];
    textLabel.textColor = [[MP sharedInstance].appearance.settings objectForKey:kMPGeneralBackgroundSecondaryFontColor];
    
    for (NSString *link in self.links) {
        [self setLinkForLabel:textLabel range:[textLabel.text rangeOfString:link options:NSCaseInsensitiveSearch]];
    }

    [textLabel sizeToFit];
}

- (void)setLinkForLabel:(TTTAttributedLabel *)label range:(NSRange)range
{
    NSMutableDictionary *linkAttributes = [NSMutableDictionary dictionary];
    [linkAttributes setValue:[NSNumber numberWithBool:NO] forKey:(NSString *)kCTUnderlineStyleAttributeName];
    [linkAttributes setValue:(__bridge id)[[UIColor colorWithRed:12.0F/255.0F green:157.0F/255.0F blue:219.0F/255.0F alpha:1.0F] CGColor] forKey:(NSString *)kCTForegroundColorAttributeName];
    label.linkAttributes = linkAttributes;
    label.activeLinkAttributes = linkAttributes;
    
    label.enabledTextCheckingTypes = NSTextCheckingTypeLink;
    label.delegate = self;
    label.text = label.text;
    
    [label addLinkToURL:[NSURL URLWithString:@"#"] withRange:range];
}

#pragma mark - TTTAttributedLabelDelegate
    
- (void)attributedLabel:(__unused TTTAttributedLabel *)label didSelectLinkWithURL:(NSURL *)url
{
#ifndef TARGET_IS_EXTENSION
    [[UIApplication sharedApplication] openURL:url];
#endif
}

@end
