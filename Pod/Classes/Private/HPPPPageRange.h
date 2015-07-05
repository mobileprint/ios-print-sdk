//
//  HPPPPageRange.h
//  Pods
//
//  Created by Christine Harris on 7/4/15.
//
//

#import <Foundation/Foundation.h>

@interface HPPPPageRange : NSObject

+ (NSString *) cleanPageRange:(NSString *)text allPagesIndicator:(NSString *)allPagesIndicator maxPageNum:(NSInteger)maxPageNum;
+ (NSArray *) getPagesFromPageRange:(NSString *)pageRange allPagesIndicator:(NSString *)allPagesIndicator maxPageNum:(NSInteger)maxPageNum;
+ (NSString *) formPageRangeFromPages:(NSArray *)pages allPagesIndicator:(NSString *)allPagesIndicator maxPageNum:(NSInteger)maxPageNum;

@end
