//
//  HPPPPageRange.m
//  Pods
//
//  Created by Christine Harris on 7/4/15.
//
//

#import "HPPPPageRange.h"

@implementation HPPPPageRange

+ (NSString *) cleanPageRange:(NSString *)text allPagesIndicator:(NSString *)allPagesIndicator maxPageNum:(NSInteger)maxPageNum
{
    NSString *scrubbedRange = text;
    
    // special case of attempting to use only page 0... which does not exist.  Change to page 1.
    if( [scrubbedRange isEqualToString:@"0"] ) {
        scrubbedRange = @"1";
    }
    
    if( [allPagesIndicator isEqualToString:text] ) {
        scrubbedRange = @"";
    } else {
        // No ",-"... replace with ","
        // No "-,"... replace with ","
        // No "--"... replace with "-"
        // No ",,"... replace with ","
        // No strings starting or ending with "," or "-"
        // Replace all page numbers of 0 with 1
        // Replace all page numbers greater than the doc length with the doc length
        // No "%d1-%d2-%d3"... replace with "%d1-%d3"
        
        scrubbedRange = [scrubbedRange stringByReplacingOccurrencesOfString:@",-" withString:@","];
        scrubbedRange = [scrubbedRange stringByReplacingOccurrencesOfString:@"-," withString:@","];
        scrubbedRange = [scrubbedRange stringByReplacingOccurrencesOfString:@",," withString:@","];
        scrubbedRange = [scrubbedRange stringByReplacingOccurrencesOfString:@"--" withString:@"-"];
        
        // The first page is 1, not 0
        scrubbedRange = [scrubbedRange stringByReplacingOccurrencesOfString:@"-0-" withString:@"-1-"];
        scrubbedRange = [scrubbedRange stringByReplacingOccurrencesOfString:@",0," withString:@",1,"];
        scrubbedRange = [scrubbedRange stringByReplacingOccurrencesOfString:@"-0," withString:@"-1,"];
        scrubbedRange = [scrubbedRange stringByReplacingOccurrencesOfString:@",0-" withString:@",1-"];
        
        scrubbedRange = [scrubbedRange stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"-,"]];
        scrubbedRange = [HPPPPageRange replaceOutOfBoundsPageNumbers:scrubbedRange maxPageNum:maxPageNum];
        scrubbedRange = [HPPPPageRange replaceBadDashUsage:scrubbedRange];
        
        if( ![text isEqualToString:scrubbedRange] ) {
            text = scrubbedRange;
            
            // keep calling this function until it makes no modification
            scrubbedRange = [HPPPPageRange cleanPageRange:scrubbedRange allPagesIndicator:allPagesIndicator maxPageNum:maxPageNum];
        }
    }
    
    return scrubbedRange;
}

+ (NSArray *) getPagesFromPageRange:(NSString *)pageRange allPagesIndicator:(NSString *)allPagesIndicator maxPageNum:(NSInteger)maxPageNum
{
    NSMutableArray *pageNums = [[NSMutableArray alloc] initWithCapacity:maxPageNum];
    
    if( [allPagesIndicator isEqualToString:pageRange] ) {
        for (int i=1; i <= maxPageNum; i++) {
            [pageNums addObject:[NSNumber numberWithInt:i]];
        }
    } else {
        // split on commas
        NSArray *chunks = [pageRange componentsSeparatedByString:@","];
        for (NSString *chunk in chunks) {
            if( [chunk containsString:@"-"] ) {
                // split on the dash
                NSArray *rangeChunks = [chunk componentsSeparatedByString:@"-"];
                NSAssert(2 == rangeChunks.count, @"Bad page range");
                int startOfRange = [(NSString *)rangeChunks[0] intValue];
                int endOfRange = [(NSString *)rangeChunks[1] intValue];
                
                if( startOfRange < endOfRange ) {
                    for (int i=startOfRange; i<=endOfRange; i++) {
                        [pageNums addObject:[NSNumber numberWithInt:i]];
                    }
                } else if( startOfRange > endOfRange ) {
                    for (int i=startOfRange; i>=endOfRange; i--) {
                        [pageNums addObject:[NSNumber numberWithInt:i]];
                    }
                } else { // they are equal
                    [pageNums addObject:[NSNumber numberWithInt:startOfRange]];
                }
                
            } else if( chunk.length > 0 ){
                [pageNums addObject:[NSNumber numberWithInteger:[chunk integerValue]]];
            }
        }
    }
    
    return pageNums;
}

+ (NSString *) formPageRangeFromPages:(NSArray *)pages allPagesIndicator:(NSString *)allPagesIndicator maxPageNum:(NSInteger)maxPageNum
{
    NSString *pageRange = nil;
    
    // Do we need to use the allPagesIndicator?
    if( pages.count == maxPageNum ) {
        NSMutableArray *mutablePages = [pages mutableCopy];
        NSSortDescriptor *lowestToHighest = [NSSortDescriptor sortDescriptorWithKey:@"self" ascending:YES];
        [mutablePages sortUsingDescriptors:[NSArray arrayWithObject:lowestToHighest]];
        pageRange = [HPPPPageRange formPageRange:mutablePages];
        
        NSString *fullPageRange = [NSString stringWithFormat:@"%d-%ld", 1, (long)maxPageNum];
        if( 1 == maxPageNum ) {
            fullPageRange = @"1";
        } else if( 2 == maxPageNum ) {
            fullPageRange = @"1,2";
        }
            
        if( [pageRange isEqualToString:fullPageRange] ) {
            pageRange = allPagesIndicator;
        } else {
            pageRange = nil;
        }
    }
    
    // If we didn't use the allPagesIndicator, calculate the page range
    if( nil == pageRange ) {
        pageRange = [HPPPPageRange formPageRange:pages];
    }
    
    return pageRange;
}

#pragma mark - Helpers

+ (NSString *)formPageRange:(NSArray *)pages
{
    NSString *pageRange = @"";
    NSString *separator = @"";
    
    for( int i=0; i<pages.count; i++ ) {
        NSInteger currentPage = [pages[i] integerValue];
        
        int newIndex = i;
        NSInteger newCurrentPage = currentPage;
        
        // check for an ascending range
        while (newIndex+1 < pages.count && [pages[newIndex+1] integerValue] == newCurrentPage+1) {
            newCurrentPage++;
            newIndex++;
        }
        
        // append the ascending range
        if( newIndex-i > 1 ) {
            NSString *range = [NSString stringWithFormat:@"%@%ld-%ld", separator, currentPage, (long)newCurrentPage];
            pageRange = [pageRange stringByAppendingString:range];
            
            // or look for a descending range
        } else if( newIndex == i ){
            while (newIndex+1 < pages.count && [pages[newIndex+1] integerValue] == newCurrentPage-1) {
                newCurrentPage--;
                newIndex++;
            }
            
            // append the descending range
            if( newIndex-i > 1 ) {
                NSString *range = [NSString stringWithFormat:@"%ld-%ld", currentPage, (long)newCurrentPage];
                pageRange = [pageRange stringByAppendingString:range];
            }
        }
        
        // if no ranges were found, just append the page number
        if( newIndex-i <= 1 ) {
            NSString *nextPage = [NSString stringWithFormat:@"%@%ld", separator, (long)currentPage];
            pageRange = [pageRange stringByAppendingString:nextPage];
        } else {
            i = newIndex;
        }
        
        separator = @",";
    }
    
    return pageRange;
}

+ (NSArray *)getNumsFromString:(NSString *)string
{
    NSMutableArray *returnArray = nil;
    
    NSRange range = NSMakeRange(0,[string length]);
    
    NSRegularExpression *regex = [HPPPPageRange regularExpressionWithString:@"\\d+" options:nil];
    NSArray *matches = [regex matchesInString:string options:NSMatchingReportCompletion range:range];
    
    if( matches  &&  0 < matches.count ) {
        returnArray = [[NSMutableArray alloc] init];
        
        for( NSTextCheckingResult *pageNumRes in matches ) {
            NSString *pageNumStr = [string substringWithRange:pageNumRes.range];
            [returnArray addObject:[NSNumber numberWithInteger:[pageNumStr integerValue]]];
        }
    }
    
    return returnArray;
}

+ (NSRegularExpression *)regularExpressionWithString:(NSString *)pattern options:(NSDictionary *)options
{
    // Create a regular expression
    NSError *error = NULL;
    NSRegularExpressionOptions regexOptions = NSRegularExpressionCaseInsensitive;
    
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:pattern options:regexOptions error:&error];
    if (error)
    {
        NSLog(@"Couldn't create regex with given string and options");
    }
    
    return regex;
}

+ (NSString *)replaceBadDashUsage:(NSString *)string
{
    NSMutableString *scrubbedString = [string mutableCopy];
    
    NSRange range = NSMakeRange(0,[string length]);
    
    NSRegularExpression *regex = [HPPPPageRange regularExpressionWithString:@"(\\d+)-(\\d+)-(\\d+)" options:nil];
    [regex replaceMatchesInString:scrubbedString options:0 range:range withTemplate:@"$1-$3"];
    
    return scrubbedString;
}

+ (NSString *)replaceOutOfBoundsPageNumbers:(NSString *)string maxPageNum:(NSInteger)maxPageNum
{
    BOOL corrected = FALSE;
    NSString *scrubbedString = string;
    
    NSArray *matches = [HPPPPageRange getNumsFromString:string];
    if( matches  &&  0 < matches.count ) {
        for( NSNumber *pageNumber in matches ) {
            NSInteger pageNum = [pageNumber integerValue];
            if( pageNum > maxPageNum ) {
                NSLog(@"error-- page num out of range: %ld, Word on Mac responds poorly in this scenario... what should we do?", (long)pageNum);
                scrubbedString = [scrubbedString stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@"%ld", (long)pageNum] withString:[NSString stringWithFormat:@"%ld", (long)maxPageNum]];
                corrected = TRUE;
                break;
            }
        }
        
        if( corrected ) {
            scrubbedString = [HPPPPageRange replaceOutOfBoundsPageNumbers:scrubbedString maxPageNum:maxPageNum];
        }
    }
    
    return scrubbedString;
}

@end
