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

#import "MPRuleView.h"

@interface MPRuleView ()

@property (strong, nonatomic) IBOutlet UIView *heightView;
@property (strong, nonatomic) IBOutlet UIView *widthView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *verticalRulerViewWidthConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *horizontalRulerViewHeightConstraint;

@end

@implementation MPRuleView

-(void) showRulers:(BOOL)showRulers;
{
    if( showRulers ) {
        self.widthView.hidden = FALSE;
        self.heightView.hidden = FALSE;
        self.sizeLabel.hidden = TRUE;
    }
    else {
        self.widthView.hidden = TRUE;
        self.heightView.hidden = TRUE;
        self.sizeLabel.hidden = FALSE;
    }
}

-(CGFloat)verticalRulerWidth
{
    return self.verticalRulerViewWidthConstraint.constant;
}

-(CGFloat)horizontalRulerHeight
{
    return self.horizontalRulerViewHeightConstraint.constant;
}

@end
