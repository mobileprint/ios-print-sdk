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

#import "MPSecretKeeper.h"
#import <CommonCrypto/CommonCrypto.h>

//
// How to set an obfuscated key
//
// 1 - Convert original key from ASCII to Hexadecimal. Use your preferred tool or www.asciitohex.com
// Ex: "asdf" => 61736466
//
// 2 - Obfuscate the Hex generated in the previous step by passing it through a XOR using the SHA1 for "MPSecretKeeper" as second input.
// SHA1 for "MPSecretKeeper" is 8572d49bd0f8558be0221e772ae7ef5ddb972c0c
// Use your preferred tool or xor.pw
// Ex: 61736466 XOR 8572d49bd0f8558be0221e772ae7ef5ddb972c0c => 8572d49bd0f8558be0221e772ae7ef5dbae4486a
//
// 3 - Expand the resulting obfuscated Hex in an unsigned char array. Remember to add 0x00 at the end as C arrays are null terminated
// Ex: { 0x8a, 0xba, 0xdb, 0x2d, ..., 0x00 }
//

unsigned char kObfuscatedEntryPrintMetricsUsername[] = { 0x85, 0x72, 0xd4, 0x9b, 0xd0, 0xf8, 0x55, 0xe3, 0x90, 0x4f, 0x71, 0x15, 0x43, 0x8b, 0x8a, 0x2d, 0xa9, 0xfe, 0x42, 0x78, 0x00 }; //@"hpmobileprint";
unsigned char kObfuscatedEntryPrintMetricsPassword[] = { 0x85, 0x72, 0xd4, 0x9b, 0xd0, 0xf8, 0x55, 0x8b, 0xe0, 0x22, 0x1e, 0x77, 0x2a, 0x97, 0x9d, 0x34, 0xb5, 0xe3, 0x1d, 0x78, 0x00 }; //@"print1t";


NSString * const kSecretKeeperEntryPrintMetricsUsername = @"kSecretKeeperEntryPrintMetricsUsername";
NSString * const kSecretKeeperEntryPrintMetricsPassword = @"kSecretKeeperEntryPrintMetricsPassword";


@interface MPSecretKeeper ()

@property (nonnull, strong) NSCache *secretCache;

@end

@implementation MPSecretKeeper

+ (instancetype)sharedInstance {
    static MPSecretKeeper *instance;
    static dispatch_once_t onceToken;

    dispatch_once(&onceToken, ^{
        instance = [[MPSecretKeeper alloc] init];
    });

    return instance;
}

- (instancetype)init {
    self = [super init];

    if (self) {
        self.secretCache = [[NSCache alloc] init];
    }

    return self;
}


- (NSString *)secretForEntry:(NSString *)entry {
    NSString *secret = [self.secretCache objectForKey:entry];

    if (secret) {
        return secret;
    }

    secret = [self clarifyEntry:[self byteArrayForEntry:entry]];

    [self.secretCache setObject:secret forKey:entry];

    return secret;
}

- (NSString *)clarifyEntry:(unsigned char *)entry {
    unsigned char obfuscator[CC_SHA1_DIGEST_LENGTH];
    NSData *className = [NSStringFromClass([self class]) dataUsingEncoding:NSUTF8StringEncoding];

    CC_SHA1(className.bytes, (CC_LONG)className.length, obfuscator);

    NSData *obfuscatorKeyData = [NSData dataWithBytes:obfuscator length:CC_SHA1_DIGEST_LENGTH];
    NSData *obfuscatedData = [NSData dataWithBytes:entry length:(int)strlen((char *)entry)];

    NSData *clarifiedData = [self xor:obfuscatedData with:obfuscatorKeyData];

    return [[NSString alloc] initWithData:clarifiedData encoding:NSUTF8StringEncoding];
}

- (NSData *)xor:(NSData *)data1 with:(NSData *)data2 {
    NSData *shorterData = data2;
    NSData *longerData = data1;

    if (data1.length <= data2.length) {
        shorterData = data1;
        longerData = data2;
    }

    char *shorterBytes = (char *)shorterData.bytes;
    char *longerBytes = (char *)longerData.bytes;

    NSMutableData *data = [[NSMutableData alloc] initWithCapacity:longerData.length];

    NSUInteger lengthPadding = longerData.length - shorterData.length;

    for (int i = 0; i < longerData.length; i++) {
        if (i < lengthPadding) {
            [data appendBytes:&longerBytes[i] length:1];
        } else {
            const char byte = shorterBytes[i - lengthPadding] ^ longerBytes[i];

            if (byte != 0x00) {
                [data appendBytes:&byte length:1];
            }
        }
    }
    
    return data;
}

- (unsigned char *)byteArrayForEntry:(NSString *)entry {
    if ([entry isEqualToString:kSecretKeeperEntryPrintMetricsUsername]) {
        return kObfuscatedEntryPrintMetricsUsername;
    }

    if ([entry isEqualToString:kSecretKeeperEntryPrintMetricsPassword]) {
        return kObfuscatedEntryPrintMetricsPassword;
    }

    return NULL;
}

@end
