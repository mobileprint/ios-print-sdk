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

#import <CocoaLumberjack/DDLog.h>

// define our own logging context
#define HPPP_LOG_CONTEXT 2

#define HPPPLogError(frmt, ...)     SYNC_LOG_OBJC_MAYBE(ddLogLevel,  LOG_FLAG_ERROR,   HPPP_LOG_CONTEXT, frmt, ##__VA_ARGS__)
#define HPPPLogWarn(frmt, ...)      ASYNC_LOG_OBJC_MAYBE(ddLogLevel, LOG_FLAG_WARN,    HPPP_LOG_CONTEXT, frmt, ##__VA_ARGS__)
#define HPPPLogInfo(frmt, ...)      ASYNC_LOG_OBJC_MAYBE(ddLogLevel, LOG_FLAG_INFO,    HPPP_LOG_CONTEXT, frmt, ##__VA_ARGS__)
#define HPPPLogDebug(frmt, ...)     ASYNC_LOG_OBJC_MAYBE(ddLogLevel, LOG_FLAG_DEBUG,   HPPP_LOG_CONTEXT, frmt, ##__VA_ARGS__)
#define HPPPLogVerbose(frmt, ...)   ASYNC_LOG_OBJC_MAYBE(ddLogLevel, LOG_FLAG_VERBOSE, HPPP_LOG_CONTEXT, frmt, ##__VA_ARGS__)

