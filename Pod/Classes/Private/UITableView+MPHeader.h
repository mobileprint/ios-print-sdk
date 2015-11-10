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

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#define HEADER_HEIGHT 50.0f

// http://stackoverflow.com/questions/19056428/how-to-hide-first-section-header-in-uitableview-grouped-style
#define ZERO_HEIGHT 0.0001f

#define SEPARATOR_SECTION_FOOTER_HEIGHT 15.0f
#define PRINTER_WARNING_SECTION_FOOTER_HEIGHT 25.0f


@interface UITableView (MPHeader)

- (UIView *)MPHeaderViewForSupportSection;

@end
