//
//  QZCrashLogManager.h
//  iOSProject
//
//  Created by QiaoZhiGuang on 15/12/25.
//  Copyright © 2015年 xingshulin. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface QZCrashLogManager : NSObject

+ (void)installExceptionHandler;
+ (NSDictionary *)getCrashLog;
+ (void)removeCrashLog;
@end
