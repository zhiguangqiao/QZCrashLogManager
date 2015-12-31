//
//  QZCrashLogManager.m
//  iOSProject
//
//  Created by QiaoZhiGuang on 15/12/25.
//  Copyright © 2015年 xingshulin. All rights reserved.
//

#import "QZCrashLogManager.h"

#import "QZBinaryImageInfoHelper.h"

void MRUncaughtExceptionHandler(NSException * exception);
void addBinaryImageInfoTo(NSMutableDictionary *logDic);
static NSUncaughtExceptionHandler * _orignalHandler = NULL;

@interface QZCrashLogManager()
+ (void)addLog:(NSDictionary *)logDictionary;
@end

@implementation QZCrashLogManager

+ (void)installExceptionHandler {
//    [NSException aspect_hookSelector:@selector(initWithName:reason:userInfo:) withOptions:AspectPositionBefore usingBlock:^{
//        NSUncaughtExceptionHandler *handler = NSGetUncaughtExceptionHandler();
//        if (handler != MRUncaughtExceptionHandler) {
            NSSetUncaughtExceptionHandler(MRUncaughtExceptionHandler);
//            _orignalHandler = handler;
//        }
//        
//    }error:nil];
}

#pragma mark LogFile Method
+ (NSString *)logCacheFilePath {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString *cachePath = paths.firstObject;
    return [cachePath stringByAppendingPathComponent:@"crashLogs.dic"];
}

+ (NSMutableDictionary *)getCrashLog {
    NSMutableDictionary *dic = nil;
    if ([[NSFileManager defaultManager] fileExistsAtPath:[self logCacheFilePath]]) {
        dic = [NSMutableDictionary dictionaryWithContentsOfFile:[self logCacheFilePath]];
    }
    return dic;
}

+ (void)addLog:(NSDictionary *)logDictionary {
    [logDictionary writeToFile:[self logCacheFilePath] atomically:YES];
}

+ (void)removeCrashLog {
    [[NSFileManager defaultManager]removeItemAtPath:[self logCacheFilePath] error:nil];
}

@end

NSArray* getStackSymbols(NSException *exception) {
    NSArray *symbols = exception.callStackSymbols;
    NSArray *addresses = exception.callStackReturnAddresses;
    long count = symbols.count;
    long slide = [QZBinaryImageInfoHelper getBinaryLoadSlide];
    NSMutableArray *symBol_AddressArray = [NSMutableArray arrayWithCapacity:count];
    for (int i = 0; i < count; i ++) {
        [symBol_AddressArray addObject:[NSString stringWithFormat:@"0x%lx - %@",[addresses[i] longValue] - slide,symbols[i]]];
    }
    return symBol_AddressArray;
}

void MRUncaughtExceptionHandler(NSException * exception) {
    
    NSString *reason = [exception reason]?[exception reason]:@"";
    NSString *name = [exception name]?[exception name]:@"";
    NSArray *symbols = getStackSymbols(exception);
    NSDictionary *except = @{@"ExceptionName":name,@"ExceptionReason":reason,@"ExceptionStack":symbols};
    
    NSMutableDictionary *logDic = [NSMutableDictionary dictionary];
    logDic[@"Exception"] = except;
    addBinaryImageInfoTo(logDic);
    [QZCrashLogManager addLog:logDic];
    
    if (_orignalHandler) {
        _orignalHandler(exception);
    }
    
}

void addBinaryImageInfoTo(NSMutableDictionary *logDic) {
    NSDateFormatter *dateFormater = [[NSDateFormatter alloc]init];
    dateFormater.dateFormat = @"yyyy-MM-dd HH:mm:ss";
    logDic[@"Date"] = [dateFormater stringFromDate:[NSDate date]];
    logDic[@"uuid"] = [QZBinaryImageInfoHelper getUUIDString];
    logDic[@"arch"] = [QZBinaryImageInfoHelper getArchString];
}
