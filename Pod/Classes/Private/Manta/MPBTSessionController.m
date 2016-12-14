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

#import "MPBTSessionController.h"
#import "MPBTSprocketDefinitions.h"

const char SPROCKET_SESSION_PACKET_LENGTH = 34;

NSString *MPBTSessionDataReceivedNotification = @"MPBTSessionDataReceivedNotification";
NSString *MPBTSessionDataSentNotification = @"MPBTSessionDataSentNotification";
NSString *MPBTSessionAccessoryDisconnectedNotification = @"MPBTSessionAccessoryDisconnectedNotification";
NSString *MPBTSessionStreamErrorNotification = @"MPBTSessionStreamErrorNotification";
NSString *MPBTSessionDataBytesWritten = @"MPBTSessionDataBytesWritten";
NSString *MPBTSessionDataTotalBytesWritten = @"MPBTSessionDataTotalBytesWritten";

@interface MPBTSessionController()

@property NSMutableArray *packets;

@end

@implementation MPBTSessionController

@synthesize accessory = _accessory;
@synthesize protocolString = _protocolString;

static long long totalBytesWritten = 0;

#pragma mark Internal

// low level write method - write data to the accessory while there is space available and data to write
- (void)_writeData {
    while (([[_session outputStream] hasSpaceAvailable]) && ([_writeData length] > 0))
    {
        NSInteger bytesWritten = [[_session outputStream] write:[_writeData bytes] maxLength:[_writeData length]];
        if (bytesWritten == -1)
        {
            NSLog(@"write error");
            break;
        }
        else if (bytesWritten > 0)
        {
            totalBytesWritten += bytesWritten;

            [_writeData replaceBytesInRange:NSMakeRange(0, bytesWritten) withBytes:NULL length:0];
            //NSLog(@"Bytes written: %ld, total: %lld", (long)bytesWritten, totalBytesWritten);
            NSArray *info = @{
                               MPBTSessionDataBytesWritten : [NSNumber numberWithInteger:bytesWritten],
                               MPBTSessionDataTotalBytesWritten : [NSNumber numberWithLongLong:totalBytesWritten]
                             };
            [[NSNotificationCenter defaultCenter] postNotificationName:MPBTSessionDataSentNotification object:self userInfo:info];
        }
    }
}

// low level read method - read data while there is data and space available in the input buffer
- (void)_readData {
#define EAD_INPUT_BUFFER_SIZE 128
    uint8_t buf[EAD_INPUT_BUFFER_SIZE];
    while ([[_session inputStream] hasBytesAvailable])
    {
        NSInteger bytesRead = [[_session inputStream] read:buf maxLength:EAD_INPUT_BUFFER_SIZE];
        if (_readData == nil) {
            _readData = [[NSMutableData alloc] init];
        }
        [_readData appendBytes:(void *)buf length:bytesRead];
    }

    // We're only interested in 34 byte packets -- lets collect them from the get-go
    while (_readData.length >= SPROCKET_SESSION_PACKET_LENGTH) {
        char byteArray[SPROCKET_SESSION_PACKET_LENGTH];
        char remainingBytesArray[_readData.length - SPROCKET_SESSION_PACKET_LENGTH];
        
        [_readData getBytes:byteArray range:NSMakeRange(0,SPROCKET_SESSION_PACKET_LENGTH)];
        [_readData getBytes:remainingBytesArray range:NSMakeRange(SPROCKET_SESSION_PACKET_LENGTH,_readData.length - SPROCKET_SESSION_PACKET_LENGTH)];
        
        [self.packets addObject:[[NSData alloc] initWithBytes:byteArray length:SPROCKET_SESSION_PACKET_LENGTH]];
        
        _readData = [[NSMutableData alloc] initWithBytes:remainingBytesArray length:_readData.length - SPROCKET_SESSION_PACKET_LENGTH];
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:MPBTSessionDataReceivedNotification object:self userInfo:nil];
}

#pragma mark Public Methods

+ (MPBTSessionController *)sharedController
{
    static MPBTSessionController *sessionController = nil;
    if (sessionController == nil) {
        sessionController = [[MPBTSessionController alloc] init];
    }

    return sessionController;
}

- (void)dealloc
{
    [self closeSession];
    [self setupControllerForAccessory:nil withProtocolString:nil];
}

// initialize the accessory with the protocolString
- (void)setupControllerForAccessory:(EAAccessory *)accessory withProtocolString:(NSString *)protocolString
{
    _accessory = accessory;
    _protocolString = [protocolString copy];
}

// open a session with the accessory and set up the input and output stream on the default run loop
- (BOOL)openSession
{
    if (_session) {
        [self closeSession];
    }

    self.packets = [[NSMutableArray alloc] init];
    
    [_accessory setDelegate:self];
    
    _session = [[EASession alloc] initWithAccessory:_accessory forProtocol:_protocolString];

    if (_session)
    {
        [[_session inputStream] setDelegate:self];
        [[_session inputStream] scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
        [[_session inputStream] open];

        [[_session outputStream] setDelegate:self];
        [[_session outputStream] scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
        [[_session outputStream] open];
    }
    else
    {
        NSLog(@"creating session failed");
    }

    return (_session != nil);
}

// close the session with the accessory.
- (void)closeSession
{
    [[_session inputStream] close];
    [[_session inputStream] removeFromRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
    [[_session inputStream] setDelegate:nil];
    [[_session outputStream] close];
    [[_session outputStream] removeFromRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
    [[_session outputStream] setDelegate:nil];

    _session = nil;

    _writeData = nil;
    _readData = nil;
    self.packets = nil;
}

// high level write data method
- (void)writeData:(NSData *)data
{
    totalBytesWritten = 0;
    
    if (_writeData == nil) {
        _writeData = [[NSMutableData alloc] init];
    }

//    NSLog(@"Writing: %@", data);
    
    [_writeData appendData:data];
    [self _writeData];
}

- (NSArray *)getPackets
{
    NSArray *returnValue = [[NSArray alloc] init];
    
    [self flushReadData];
    if (self.packets) {
        returnValue = self.packets;
    }
    self.packets = [[NSMutableArray alloc] init];
    
    return returnValue;
}

- (void)flushReadData
{
    static NSInteger totalBytesRead = 0;
    NSUInteger bytesAvailable = 0;
    
    while ((bytesAvailable = [self readBytesAvailable]) > 0) {
        NSData *data = [self readData:bytesAvailable];
        if (data) {
            totalBytesRead += bytesAvailable;
        }
    }
}

// high level read method 
- (NSData *)readData:(NSUInteger)bytesToRead
{
    NSData *data = nil;
    if ([_readData length] >= bytesToRead) {
        NSRange range = NSMakeRange(0, bytesToRead);
        data = [_readData subdataWithRange:range];
        [_readData replaceBytesInRange:range withBytes:NULL length:0];
    }
    
    return data;
}

// get number of bytes read into local buffer
- (NSUInteger)readBytesAvailable
{
    return [_readData length];
}

#pragma mark EAAccessoryDelegate
- (void)accessoryDidDisconnect:(EAAccessory *)accessory
{
    [[NSNotificationCenter defaultCenter] postNotificationName:MPBTSessionAccessoryDisconnectedNotification object:self userInfo:nil];
}

#pragma mark NSStreamDelegateEventExtensions

// asynchronous NSStream handleEvent method
- (void)stream:(NSStream *)aStream handleEvent:(NSStreamEvent)eventCode
{
    switch (eventCode) {
        case NSStreamEventNone:
            NSLog(@"StreamEvent: NSStreamEventNone");
            break;
        case NSStreamEventOpenCompleted:
            NSLog(@"StreamEvent: NSStreamEventOpenCompleted");
            break;
        case NSStreamEventHasBytesAvailable:
            NSLog(@"StreamEvent: NSStreamEventHasBytesAvailable");
            [self _readData];
            break;
        case NSStreamEventHasSpaceAvailable:
            NSLog(@"StreamEvent: NSStreamEventHasSpaceAvailable");
            [self _writeData];
            break;
        case NSStreamEventErrorOccurred:
            MPLogError(@"Accessory disconnected");
            [[NSNotificationCenter defaultCenter] postNotificationName:MPBTSessionStreamErrorNotification object:self userInfo:nil];
            NSLog(@"StreamEvent: NSStreamEventErrorOccurred");
            break;
        case NSStreamEventEndEncountered:
            NSLog(@"StreamEvent: NSStreamEventEndEncountered");
            break;
        default:
            NSLog(@"StreamEvent: Unknown %lu", (unsigned long)eventCode);
            break;
    }
}

@end
