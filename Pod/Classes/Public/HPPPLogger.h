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

#define HPPPLogError(frmt, ...)     [[HPPPLogger sharedInstance] logError:[NSString stringWithFormat:frmt, ##__VA_ARGS__]]
#define HPPPLogWarn(frmt, ...)      [[HPPPLogger sharedInstance] logWarn:[NSString stringWithFormat:frmt, ##__VA_ARGS__]]
#define HPPPLogInfo(frmt, ...)      [[HPPPLogger sharedInstance] logInfo:[NSString stringWithFormat:frmt, ##__VA_ARGS__]]
#define HPPPLogDebug(frmt, ...)     [[HPPPLogger sharedInstance] logDebug:[NSString stringWithFormat:frmt, ##__VA_ARGS__]]
#define HPPPLogVerbose(frmt, ...)   [[HPPPLogger sharedInstance] logVerbose:[NSString stringWithFormat:frmt, ##__VA_ARGS__]]

/*!
 * @abstract Protocol used for delegating logging to the client app
 */
@protocol HPPPLoggerDelegate <NSObject>

/*!
 * @abstract Log an error message
 */
- (void) logError:(NSString*)msg;

/*!
 * @abstract Log a warning message
 */
- (void) logWarn:(NSString*)msg;

/*!
 * @abstract Log an info message
 */
- (void) logInfo:(NSString*)msg;

/*!
 * @abstract Log a debug message
 */
- (void) logDebug:(NSString*)msg;

/*!
 * @abstract Log a detailed message
 */
- (void) logVerbose:(NSString*)msg;

@end

/*!
 * @abstract Class that manages logging
 */
@interface HPPPLogger : NSObject <HPPPLoggerDelegate>

/*!
 * @abstract Used to access the singleton instance of this class
 */
+ (HPPPLogger *)sharedInstance;

/*!
 * @abstract An optional delegate used for logging
 * @discussion If provided, this delegate is used to provide fine-grained logging. The client typically uses a library such as Lumberjack for this purpose.
 */
@property (nonatomic, weak) id<HPPPLoggerDelegate> delegate;

@end

