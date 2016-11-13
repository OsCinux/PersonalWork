//
//  NSString+MD5Encrypt.m
//  LabHelper
//
//  Created by ljc on 2016/11/10.
//  Copyright © 2016年 meitu. All rights reserved.
//

#import "NSString+MD5Encrypt.h"
#import <CommonCrypto/CommonDigest.h>

@implementation NSString (MD5Encrypt)

+(NSString *)md5StringForString:(NSString *)string{
    
    //要进行UTF8的转码
    const char* input = [string UTF8String];
    unsigned char result[CC_MD5_DIGEST_LENGTH];
    CC_MD5(input, (CC_LONG)strlen(input), result);
    
    NSMutableString *digest = [NSMutableString stringWithCapacity:CC_MD5_DIGEST_LENGTH * 2];
    for (NSInteger i = 0; i < CC_MD5_DIGEST_LENGTH; i++) {
        [digest appendFormat:@"%02X", result[i]];
    }
    
    return digest;
}

@end
