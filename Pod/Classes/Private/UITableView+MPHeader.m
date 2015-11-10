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

#import "MP.h"
#import "UITableView+MPHeader.h"
#import "UIColor+MPHexString.h"
#import "NSBundle+MPLocalizable.h"

#define TITLE_LEFT_OFFSET 10.0f
#define TITLE_HEIGHT 30.0f

@implementation UITableView (MPHeader)

- (UIView *)MPHeaderViewForSupportSection
{
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, self.frame.size.width, HEADER_HEIGHT)];
    
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(TITLE_LEFT_OFFSET, HEADER_HEIGHT - TITLE_HEIGHT, self.frame.size.width, TITLE_HEIGHT)];
    titleLabel.text =  MPLocalizedString(@"SUPPORT:", @"Title of a table section");
    titleLabel.font = [[MP sharedInstance].appearance.settings objectForKey:kMPGeneralBackgroundPrimaryFont];
    titleLabel.textColor = [[MP sharedInstance].appearance.settings objectForKey:kMPGeneralBackgroundPrimaryFontColor];
    
    [headerView addSubview:titleLabel];
    
    return headerView;
}

@end
