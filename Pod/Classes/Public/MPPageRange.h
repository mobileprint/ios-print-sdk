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

#import <Foundation/Foundation.h>

/*!
 * @abstract A class for handling page range validation, manipulation, and querying
 */
@interface MPPageRange : NSObject <NSCoding>

/*!
 * @abstract The page range in its string format
 */
@property (strong, nonatomic) NSString *range;

/*!
 * @abstract The text used to describe all pages being included in the page range
 */
@property (strong, nonatomic) NSString *allPagesIndicator;

/*!
 * @abstract The highest allowed page number.
 * @discussion For a 10 page document, this would be 10.
 */
@property (assign, nonatomic) NSInteger maxPageNum;

/*!
 * @abstract If TRUE, page ranges are forced into ascending order
 */
@property (assign, nonatomic) BOOL sortAscending;

/*!
 * @abstract Used to construct a page range with a string
 * @param range The string describing a page range (consisting of digits, dashes, and commas)
 * @param allPagesIndicator Used as the flag to indicate that all pages should be included in the page range.
 * @param maxPageNum The largest allowed page number
 * @param sortAscending Set to TRUE if the page range should be forced into ascending order.  If FALSE, the page range will be left in whatever order it is currently in.
 * @returns An initialized MPPageRange object
 */
-(id)initWithString:(NSString *)range allPagesIndicator:(NSString *)allPagesIndicator maxPageNum:(NSInteger)maxPageNum sortAscending:(BOOL)sortAscending;

/*!
 * @abstract Used to obtain an array of pages included in the page range.
 * @returns An NSArray filled with NSNumbers.  The array is ordered in exactly the same way the range property is ordered.  Duplicate pages are included when/where expected.
 */
- (NSArray *) getPages;

/*!
 * @abstract Used to obtain an array of unique pages (no duplicates) included in the page range.
 * @returns An NSArray filled with NSNumbers.  The array is always returned in ascending order.  Duplicate pages are not included.
 */
- (NSArray *) getUniquePages;

/*!
 * @abstract Used to add a page to the page range.
 * @discussion The page number is added to the existing page range.
 */
- (void) addPage:(NSNumber *)page;

/*!
 * @abstract Used to remove a page to the page range.
 * @discussion All instances of the specified page number are removed from the page range.
 */
- (void) removePage:(NSNumber *)page;

@end
