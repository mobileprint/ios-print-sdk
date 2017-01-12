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
#import "NSBundle+MPLocalizable.h"
#import <TTTAttributedLabel.h>

@interface MPBTTechnicalInformationViewController () <TTTAttributedLabelDelegate>

@property (strong, nonatomic) NSArray *links;

@property (strong, nonatomic) IBOutletCollection(UILabel) NSArray *titleLabels;
@property (strong, nonatomic) IBOutletCollection(UILabel) NSArray *textLabels;

@property (weak, nonatomic) IBOutlet UILabel *dataSheetsTitle;
@property (weak, nonatomic) IBOutlet TTTAttributedLabel *dataSheetsContent;
@property (weak, nonatomic) IBOutlet UILabel *chemicalTitle;
@property (weak, nonatomic) IBOutlet TTTAttributedLabel *chemicalContent;
@property (weak, nonatomic) IBOutlet UILabel *recycleTitle;
@property (weak, nonatomic) IBOutlet TTTAttributedLabel *recycleContent;
@property (weak, nonatomic) IBOutlet UILabel *batteryTitle;
@property (weak, nonatomic) IBOutlet TTTAttributedLabel *batteryContent;
@property (weak, nonatomic) IBOutlet UILabel *disposalTitle;
@property (weak, nonatomic) IBOutlet UILabel *disposalContent;


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
    
    self.dataSheetsTitle = MPLocalizedString(@"Safety data sheets", @"Title");
    self.dataSheetsContent = MPLocalizedString(@"Safety Data Sheets, product safety and environmental information are available at www.hp.com/go/ecodata or on request.", @"Description");
    self.chemicalTitle = MPLocalizedString(@"Chemical substances", @"Title");
    self.chemicalContent = MPLocalizedString(@"HP is committed to providing our customers with information about the chemical substances in our products as needed to comply with legal requirements such as REACH (Regulation EC No 1907/2006 of the European Parliament and the Council). A chemical information report for this product can be found at: www.hp.com/go/reach", @"Description");
    self.recycleTitle = MPLocalizedString(@"Recycling program", @"Title");
    self.recycleContent = MPLocalizedString(@"HP offers an increasing number of product return and recycling programs in many countries/regions, and partners with some of the largest electronic recycling centers throughout the world. HP conserves resources by reselling some of its most popular products. For more information regarding recycling of HP products, please visit: www.hp.com/recycle", @"Description");
    self.batteryTitle = MPLocalizedString(@"California Rechargeable Battery Take-back Notice", @"Title");
    self.batteryContent = MPLocalizedString(@"HP encourages customers to recycle used electronic hardware, HP original print cartridges, and rechargeable batteries. For more information about recycling programs, go to www.hp.com/recycle.", @"Description");
    self.disposalTitle = MPLocalizedString(@"Disposal of waste equipment by users", @"Title");;
    self.disposalContent = MPLocalizedString(@"This symbol means do not dispose of your product with your other household waste. Instead, you should protect human health and the environment by handing over your waste equipment to a designated collection point for the recycling of waste electrical and electronic equipment. For more information, please contact your household waste disposal service, or go to http://www.hp.com/recycle.", @"Description");
    
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

    self.scrollView.contentSize = CGSizeMake(self.view.frame.size.width, self.disposalContent.frame.origin.y + self.disposalContent.frame.size.height + 33);
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
