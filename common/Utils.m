//
//  Utils.m
//  iSpeaker
//
//  Created by user on 5/16/15.
//  Copyright (c) 2015 ptc. All rights reserved.
//

#import "Utils.h"
#import <CommonCrypto/CommonDigest.h>
#import <SystemConfiguration/CaptiveNetwork.h>
#import "AFHTTPRequestOperationManager.h"

#define LOG_FILENAME @"user.log"

@implementation Utils

+ (instancetype) sharedInstance
{
    static Utils *_sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedInstance = [[Utils alloc] init];
    });
    return _sharedInstance;
}

+ (NSString *) md5:(NSString *) input
{
    const char *cStr = [input UTF8String];
    unsigned char digest[16];
    CC_MD5( cStr, (unsigned int)strlen(cStr), digest ); // This is the md5 call
    
    NSMutableString *output = [NSMutableString stringWithCapacity:CC_MD5_DIGEST_LENGTH * 2];
    
    for(int i = 0; i < CC_MD5_DIGEST_LENGTH; i++)
        [output appendFormat:@"%02x", digest[i]];
    return  output;
}

+ (NSData *) md5Data:(NSString *)input
{
    const char *cStr = [input UTF8String];
    unsigned char digest[16];
    CC_MD5( cStr, (unsigned int)strlen(cStr), digest ); // This is the md5 call
    
    NSMutableData *data = [NSMutableData dataWithBytes:digest length:CC_MD5_DIGEST_LENGTH];
    return  data;
}

+ (NSString*) sha1:(NSString*) input
{
    const char *cstr = [input cStringUsingEncoding:NSUTF8StringEncoding];
    NSData *data = [NSData dataWithBytes:cstr length:input.length];
    
    uint8_t digest[CC_SHA1_DIGEST_LENGTH];
    
    CC_SHA1(data.bytes, (unsigned int)data.length, digest);
    
    NSMutableString* output = [NSMutableString stringWithCapacity:CC_SHA1_DIGEST_LENGTH * 2];
    
    for(int i = 0; i < CC_SHA1_DIGEST_LENGTH; i++)
        [output appendFormat:@"%02x", digest[i]];
    
    return output;
    
}

#pragma mark - get device information

+ (uint64_t)getFreeDiskspace {
    uint64_t totalFreeSpace = 0;
    NSError *error = nil;
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSDictionary *dictionary = [[NSFileManager defaultManager] attributesOfFileSystemForPath:[paths lastObject] error: &error];
    
    if (dictionary) {
        NSNumber *freeFileSystemSizeInBytes = [dictionary objectForKey:NSFileSystemFreeSize];
        totalFreeSpace = [freeFileSystemSizeInBytes unsignedLongLongValue];
    } else {
        NSLog(@"Error Obtaining System Memory Info: Domain = %@, Code = %ld", [error domain], (long)[error code]);
    }    
    return totalFreeSpace;
}

+ (uint64_t)setBoolValue {
    uint64_t totalSpace = 0;
    NSError *error = nil;
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSDictionary *dictionary = [[NSFileManager defaultManager] attributesOfFileSystemForPath:[paths lastObject] error: &error];
    
    if (dictionary) {
        NSNumber *fileSystemSizeInBytes = [dictionary objectForKey: NSFileSystemSize];
        totalSpace = [fileSystemSizeInBytes unsignedLongLongValue];
    } else {
        NSLog(@"Error Obtaining System Memory Info: Domain = %@, Code = %ld", [error domain], (long)[error code]);
    }
    return totalSpace;
}

#pragma mark - String utils
+ (NSString*) stringToHex:(NSString*) string
{
    NSInteger strLength = [string length];
    
    //alloc(full length of string bytes)
    unichar *AllChars = malloc(strLength * sizeof(unichar)); // or (strLength*2)
    
    //Copy characters from NSString to unichar array ...
    [string getCharacters:AllChars];
    //MutableString as result
    NSMutableString *hexResult = [[NSMutableString alloc] init];
    
    for(int i = 0; i < strLength; i++ )
    {
        [hexResult appendFormat:@"%02x", AllChars[i]];
    }
    free(AllChars); // Very important
    return [hexResult uppercaseString]; //returnd value
}

#pragma mark - UIAlertView delegate

+ (void) showAlertView:(NSString*) title message:(NSString*) message cancelButtonTitle:(NSString*) cancelTitle doneButtonTitle:(NSString*) doneTitle alertHandle:(void (^)(UIAlertView *alertView, NSInteger index)) handle
{
    Utils *shareUtils = [Utils sharedInstance];
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title message:message delegate:shareUtils cancelButtonTitle:cancelTitle otherButtonTitles:doneTitle, nil];
    shareUtils.dismissHandle = handle;
    [alert show];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (self.dismissHandle) {
        self.dismissHandle(alertView, buttonIndex);
    }
}

+ (void) showCenterToast:(NSString*) text
{
    [SVProgressHUD showImage:nil status:text];
}

+ (NSDictionary*) getWLANInfo
{
    CFArrayRef ref = (CFArrayRef)CNCopySupportedInterfaces();
    NSArray *ifs = (__bridge NSArray *)(ref);
    NSLog(@"Supported interfaces: %@", ifs);
    NSDictionary *info;
    for (NSString *ifnam in ifs) {
        CFDictionaryRef dicref = (CFDictionaryRef)CNCopyCurrentNetworkInfo((__bridge CFStringRef)ifnam);
        info = (__bridge_transfer NSDictionary *)dicref;
        NSLog(@"%@ => %@", ifnam, info);
        if (info && [info count]) { break; }
    }
    return info;
}

#pragma mark - Check New version in app store
+ (void) hasNewVersionInAppStore:(void (^)(NSString *, NSError *))block
{
    //NSString *bundleId = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleIdentifier"];
    NSString *bundleId = @"com.uvicugate.YYBanban";
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    //NSString *appurl = [NSString stringWithFormat:@"http://itunes.apple.com/lookup?id=%@", APPLE_APPID];
    NSString *appurl = [NSString stringWithFormat:@"http://itunes.apple.com/lookup?bundleId=%@", bundleId];

    [manager GET:appurl parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        if ([[responseObject objectForKey:@"resultCount"] intValue] == 0) {
            
            block(nil, nil);
        
        }else{
            
            NSDictionary *results = [[responseObject objectForKey:@"results"] objectAtIndex:0];
            NSString *version = [results objectForKey:@"version"];
            NSString *appurl = [results objectForKey:@"trackViewUrl"];
            NSString *localVersion = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
            
            if ([version isEqualToString:localVersion]) {
                block(nil, nil);
            }else{
                block(appurl, nil);
            }
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        block(nil, error);
    }];
}

#pragma mark - Log
+(void) writeToLogWithString:(NSString *)string
{
    NSDate *date = [NSDate date];
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"yyyy-MM-dd-HH-mm-ss"];
    
    //[date description];
    NSFileManager *filemanager = [[NSFileManager alloc] init];
    
    NSString *targetString = [NSString stringWithFormat:@"%@: %@\n", [dateFormat stringFromDate:date], string];
    NSString *logPath = [[NSHomeDirectory() stringByAppendingPathComponent:@"Documents"] stringByAppendingPathComponent:LOG_FILENAME];
    if (![filemanager fileExistsAtPath:logPath]) {
        [filemanager createFileAtPath:logPath contents:nil attributes:nil];
    }
    NSFileHandle *file = [NSFileHandle fileHandleForWritingAtPath:logPath];
    [file synchronizeFile];
    [file seekToEndOfFile];
    [file writeData:[targetString dataUsingEncoding:NSUTF8StringEncoding]];
    [file closeFile];
}

+ (void) LOGD:(NSString*) string, ...
{
    va_list args;
    va_start(args, string);
#if SHOWLOG_DEBUG
#if WRITE_LOG_TOFILE
    
    [self writeToLogWithString:[NSString stringWithFormat:@"%@ %@", LOG_DEBUGMARK, [[NSString alloc] initWithFormat:string arguments:args]]];
#endif
    NSLogv(string, args);
#endif
    va_end(args);
}
+ (void) LOGE:(NSString*) string, ...
{
    va_list args;
    va_start(args, string);
#if SHOWLOG_ERROR
#if WRITE_LOG_TOFILE
    [self writeToLogWithString:[NSString stringWithFormat:@"%@ %@", LOG_ERRORMARK, [[NSString alloc] initWithFormat:string arguments:args]]];
#endif
    NSLogv(string, args);
#endif
    va_end(args);
}
+ (void) LOGI:(NSString*) string, ...
{
    va_list args;
    va_start(args, string);
#if SHOWLOG_INFO
    
#if WRITE_LOG_TOFILE
    [self writeToLogWithString:[NSString stringWithFormat:@"%@ %@", LOG_INFORMATIONMARK, [[NSString alloc] initWithFormat:string arguments:args]]];
#endif
    
    NSLogv(string, args);
#endif
    va_end(args);
}

@end
