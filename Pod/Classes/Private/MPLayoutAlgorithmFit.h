//
//  MPLayoutAlgorithmFit.h
//  Pods
//
//  Created by James Trask on 12/9/15.
//
//

#import "MPLayoutAlgorithm.h"

@interface MPLayoutAlgorithmFit : MPLayoutAlgorithm

typedef enum {
    MPLayoutAlgorithmFitTop,
    MPLayoutAlgorithmFitMiddle,
    MPLayoutAlgorithmFitBottom
} MPLayoutAlgorithmFitVerticalPosition;

typedef enum {
    MPLayoutAlgorithmFitLeft,
    MPLayoutAlgorithmFitCenter,
    MPLayoutAlgorithmFitRight
} MPLayoutAlgorithmFitHorizontalPosition;

@property (assign, nonatomic) MPLayoutAlgorithmFitHorizontalPosition horizontalPosition;
@property (assign, nonatomic) MPLayoutAlgorithmFitVerticalPosition verticalPosition;

@end
