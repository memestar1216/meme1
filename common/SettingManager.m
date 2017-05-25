//
//  SettingManager.m
//  iSpeaker
//
//  Created by user on 5/13/15.
//  Copyright (c) 2015 ptc. All rights reserved.
//

#import "SettingManager.h"
#import "Utils.h"

@implementation SettingManager

+ (void)setStringValue:(NSString *)string withKey:(NSString*) key
{
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    [userDefault setObject:string forKey:key];
    [userDefault synchronize];
}

+ (NSString *)stringValueWithKey:(NSString *)key
{
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    return [userDefault stringForKey:key];
}

+ (void)setBoolValue:(BOOL)value withKey:(NSString *)key
{
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    [userDefault setBool:value forKey:key];
    [userDefault synchronize];
}

+ (BOOL)boolValueWithKey:(NSString *)key
{
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    return [userDefault boolForKey:key];
}

+ (void)setIntegerValue:(NSInteger)value withKey:(NSString *)key
{
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    [userDefault setInteger:value forKey:key];
    [userDefault synchronize];
}

+ (NSInteger)integerValueWithKey:(NSString *)key
{
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    return [userDefault integerForKey:key];
}

+ (void)setDoubleValue:(double)value withKey:(NSString *)key
{
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    [userDefault setDouble:value forKey:key];
    [userDefault synchronize];
}

+ (double)doubleValueWithKey:(NSString *)key
{
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    return [userDefault doubleForKey:key];
}

+ (void)setObject:(NSObject*)value withKey:(NSString*) key
{
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    [userDefault setObject:value forKey:key];
    [userDefault synchronize];
}

+ (NSObject*) objectWithKey:(NSString*) key {
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    return [userDefault objectForKey:key];
}

+ (void) removeObjectForKey:(NSString*) key {
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    [userDefault removeObjectForKey:key];

}

@end
