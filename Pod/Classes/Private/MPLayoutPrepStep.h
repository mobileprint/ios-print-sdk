//
//  MPLayoutPrepStep.h
//  Pods
//
//  Created by James Trask on 12/9/15.
//
//

#import <Foundation/Foundation.h>
#import "MPLayout.h"

@interface MPLayoutPrepStep : NSObject

@property (strong, nonatomic, readonly) MPLayout *layout;

- (id)initWithLayout:(MPLayout *)layout;

- (UIImage *)imageForImage:(UIImage *)image inContainer:(CGRect)containerRect;
- (CGRect)containerForImage:(UIImage *)image inContainer:(CGRect)containerRect;

@end
