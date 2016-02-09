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

#import "MPLayoutPrepStep.h"
#import "MPLayoutAlgorithm.h"

/*!
 * @abstract A reusable layout class that applies or more preparation steps prior to applying a single layout algorithm
 */
@interface MPLayoutComposite : MPLayout <NSCoding>

/*!
 * @abstract Initializes the composite layout with preparation steps and an algorithm
 * @param algorithm The layout algorithm to use
 * @param prepSteps Zero or more preparation steps to be applied prior to laying out the content
 * @returns A composite layout instance
 */
- (id)initWithAlgorithm:(MPLayoutAlgorithm *)algorithm andPrepSteps:(NSArray *)prepSteps;

@end
