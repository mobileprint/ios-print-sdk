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

/*!
 * @abstract A class for handling page range validation, manipulation, and querying
 */
@interface HPPPPageRange : NSObject

/*!
 * @abstract Turns a page range consisting of numbers, ",", and "-" characters into a valid page range
 * @param text The page range to be cleaned
 * @param allPagesIndicator The string indicating that all pages should be included in the cleaned page range.  If this string is found in the text, an empty string will be returned for the page range.
 * @param maxPageNum The largest page number to be allowed in the page range
 * @returns A valid page range based on the text argument.  If all pages, and only all pages, are to be included in the page range, an empty string is returned.
*/
+ (NSString *) cleanPageRange:(NSString *)text allPagesIndicator:(NSString *)allPagesIndicator maxPageNum:(NSInteger)maxPageNum;

/*!
 * @abstract Converts a valid page range into an array of NSNumbers
 * @param pageRange The page range to be converted into an array of page numbers
 * @param allPagesIndicator The string indicating that all pages should be included in the cleaned page range.  If this string is found in the text, an empty string will be returned for the page range.
 * @param maxPageNum The largest page number to be allowed in the page range
 * @returns A properly ordered array of NSNumbers.  IE, if page range "2-5,1" is given, the following array will be returned: [2,3,4,5,1]
 */
+ (NSArray *) getPagesFromPageRange:(NSString *)pageRange allPagesIndicator:(NSString *)allPagesIndicator maxPageNum:(NSInteger)maxPageNum;

/*!
 * @abstract Converts an array of NSNumbers into a page range
 * @param pages The array of page numbers to be converted into a page range
 * @param allPagesIndicator The string indicating that all pages should be included in the cleaned page range.  If this string is found in the text, an empty string will be returned for the page range.
 * @param maxPageNum The largest page number to be allowed in the page range
 * @returns A properly ordered page range.  IE, if arrray [2,3,4,5,1] is given, the following page range will be returned: "2-5,1"
 */
+ (NSString *) formPageRangeFromPages:(NSArray *)pages allPagesIndicator:(NSString *)allPagesIndicator maxPageNum:(NSInteger)maxPageNum;

@end
