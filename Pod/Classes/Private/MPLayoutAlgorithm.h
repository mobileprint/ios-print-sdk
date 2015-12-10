//
//  MPLayoutAlgorithm.h
//  Pods
//
//  Created by James Trask on 12/9/15.
//
//

#import <Foundation/Foundation.h>
#import "MPLayout.h"

@interface MPLayoutAlgorithm : NSObject

@property (strong, nonatomic, readonly) MPLayout *layout;

- (id)initWithLayout:(MPLayout *)layout;

- (void)drawImage:(UIImage *)image inContainer:(CGRect)containerRect;

@end
