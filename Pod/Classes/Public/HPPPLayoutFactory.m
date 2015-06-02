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

#import "HPPP.h"
#import "HPPPLayoutFactory.h"
#import "HPPPLayoutFill.h"
#import "HPPPLayoutFit.h"
#import "HPPPLayoutStretch.h"

@implementation HPPPLayoutFactory

HPPPLayoutType const kHPPPLayoutTypeDefault = HPPPLayoutTypeFit;

+ (HPPPLayout *)layoutWithType:(HPPPLayoutType)layoutType
{
    return [HPPPLayoutFactory layoutWithType:layoutType orientation:HPPPLayoutOrientationBestFit assetPosition:[HPPPLayout defaultAssetPosition]];
}

+ (HPPPLayout *)layoutWithType:(HPPPLayoutType)layoutType orientation:(HPPPLayoutOrientation)orientation assetPosition:(CGRect)assetPosition
{
    HPPPLayout *layout = nil;
    
    if (layoutType == HPPPLayoutTypeFill) {
        layout = [[HPPPLayoutFill alloc] initWithOrientation:orientation andAssetPosition:assetPosition];
    } else if (layoutType == HPPPLayoutTypeFit) {
        layout = [[HPPPLayoutFit alloc] initWithOrientation:orientation andAssetPosition:assetPosition];
    } else if (layoutType == HPPPLayoutTypeStretch) {
        layout = [[HPPPLayoutStretch alloc] initWithOrientation:orientation andAssetPosition:assetPosition];
    }
    
    if (nil == layout) {
        HPPPLogWarn(@"Unable to create a layout using type %u", layoutType);
    }
    
    return layout;
}

@end
