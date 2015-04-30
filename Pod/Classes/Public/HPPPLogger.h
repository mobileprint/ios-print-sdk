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

@protocol HPPPLoggerDelegate <NSObject>

- (void) logError:(NSString*)msg;
- (void) logWarn:(NSString*)msg;
- (void) logInfo:(NSString*)msg;
- (void) logDebug:(NSString*)msg;
- (void) logVerbose:(NSString*)msg;

@end

@interface HPPPLogger : NSObject <HPPPLoggerDelegate>

+ (HPPPLogger *)sharedInstance;

@property (nonatomic, weak) id<HPPPLoggerDelegate> delegate;

@end

