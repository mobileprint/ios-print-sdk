//
//  PageRangeCollectionViewController.h
//  Pods
//
//  Created by Bozo on 6/10/15.
//
//

#import <UIKit/UIKit.h>
#import "HPPPView.h"

@protocol HPPPPageRangeViewDelegate;

@interface HPPPPageRangeView : HPPPView

@property (weak, nonatomic) id<HPPPPageRangeViewDelegate> delegate;

@end


@protocol HPPPPageRangeViewDelegate <NSObject>
@optional
- (void)didSelectPageRange:(HPPPPageRangeView *)view pageRange:(NSString *)pageRange;
@end