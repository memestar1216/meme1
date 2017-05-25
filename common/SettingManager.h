//
//  SettingManager.h
//  iSpeaker
//
//  Created by user on 5/13/15.
//  Copyright (c) 2015 ptc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <CoreBluetooth/CoreBluetooth.h>

#define SETTING_KEY_TOKEN @"token"
#define SETTING_KEY_UID @"uid"
#define SETTING_KEY_APNTOKEN @"apntoken"
#define SETTING_KEY_ASSETGROUPS @"AssetGroups"
#define SETTING_KEY_SELECTEDMEDIA @"medialist"
#define SETTING_KEY_MEDIACOUNT @"mediacount"
#define SETTING_KEY_LOGINEMAIL @"loginemail"
#define SETTING_KEY_LOGINPASSWORD @"loginpassword"
#define SETTING_KEY_ORDERING @"ordering"
#define SETTING_KEY_UPLOADINGDATA @"uploadingdata"
#define SETTING_KEY_USERDATA @"userdata"
#define SETTING_KEY_PAYMENT @"payment"

#define SETTING_KEY_CARDNUMBER @"cardnumber"
#define SETTING_KEY_CARDNAME @"cardname"
#define SETTING_KEY_EXPIREDATE @"expDate"
#define SETTING_KEY_SECURITYCODE @"securitycode"

@interface SettingManager : NSObject

+ (void) setStringValue:(NSString *)string withKey:(NSString*) key;
+ (NSString*) stringValueWithKey:(NSString*) key;

+ (void) setBoolValue:(BOOL)value withKey:(NSString*) key;
+ (BOOL) boolValueWithKey:(NSString*) key;

+ (void) setIntegerValue:(NSInteger)value withKey:(NSString*) key;
+ (NSInteger) integerValueWithKey:(NSString*) key;

+ (void) setDoubleValue:(double)value withKey:(NSString*) key;
+ (double) doubleValueWithKey:(NSString*) key;

+ (void) setObject:(NSObject*)value withKey:(NSString*) key;
+ (NSObject*) objectWithKey:(NSString*) key;

+ (void) removeObjectForKey:(NSString*) key;

@end
