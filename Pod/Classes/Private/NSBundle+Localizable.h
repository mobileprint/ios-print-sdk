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

#define HP_PHOTO_PRINT_LOCALIZATION_BUNDLE_NAME @"HPPhotoPrintLocalizable"

#define HPPPLocalizedString(key, comment) \
NSLocalizedStringFromTableInBundle(key, nil, [NSBundle localizableBundle], comment)

@interface NSBundle (Localizable)

+ (NSBundle *)localizableBundle;

@end
