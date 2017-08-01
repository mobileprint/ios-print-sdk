//
//  MPUtils.m
//  MobilePrintSDK
//
//  Created by yyjim on 31/07/2017.
//

#import "MP.h"
#import "MPUtils.h"

@implementation MPUtils

+ (NSBundle *)MPResourcesBundle
{
#ifdef COCOAPODS
    return [NSBundle bundleWithPath:[[NSBundle bundleForClass:[MP class]] pathForResource:@"MPResources" ofType:@"bundle"]];
#else
    return [NSBundle bundleForClass:[MP class]];
#endif
}

@end
