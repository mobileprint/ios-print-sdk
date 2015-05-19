//
// Hewlett-Packard Company
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
#import "HPPPPaper.h"

@interface HPPPPrintItem : NSObject<NSCoding>

extern CGFloat const kHPPPPointsPerInch;
extern NSString * const kHPPPPrintAssetKey;

typedef enum {
    Inches,
    Pixels
} HPPPUnits;

typedef enum {
    DefaultPrintRenderer,
    CustomPrintRenderer
} HPPPPrintRenderer;

@property (strong, nonatomic, readonly) id printAsset;
@property (assign, nonatomic, readonly) HPPPPrintRenderer renderer;

- (CGSize)sizeInUnits:(HPPPUnits)units;
- (NSInteger)numberOfPages;
- (UIImage *)defaultPreviewImage;
- (UIImage *)previewImageForPaper:(HPPPPaper *)paper;

@end
