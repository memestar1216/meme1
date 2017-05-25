//
//  Utils.h
//  iSpeaker
//
//  Created by user on 5/16/15.
//  Copyright (c) 2015 ptc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "SVProgressHUD.h"

typedef void (^UIAlertViewDismissHandle)(UIAlertView *alertView, NSInteger index);

@interface Utils : NSObject<UIAlertViewDelegate>

@property (nonatomic, copy) UIAlertViewDismissHandle dismissHandle;
@property (nonatomic, retain) UIAlertView *alertView;

+ (void) showAlertView:(NSString*) title message:(NSString*) message cancelButtonTitle:(NSString*) cancelTitle doneButtonTitle:(NSString*) doneTitle alertHandle:(void (^)(UIAlertView *alertView, NSInteger index)) handle;

+ (void) showCenterToast:(NSString*) text;

+ (NSString *) md5:(NSString *) input;
+ (NSData *) md5Data:(NSString *) input;
+ (NSString*) sha1:(NSString*) input;

#pragma mark - get device information
+ (uint64_t)getFreeDiskspace;
+ (uint64_t)getTotalDiskspace;
+ (NSDictionary*) getWLANInfo;

#pragma mark - String utils
+ (NSString*) stringToHex:(NSString*) string;

#pragma mark - Check New version in app store
+ (void) hasNewVersionInAppStore:(void (^)(NSString *appUrl, NSError *error))block;

#pragma mark - Log

+ (void) LOGD:(NSString*) string, ...;
+ (void) LOGE:(NSString*) string, ...;
+ (void) LOGI:(NSString*) string, ...;

@end
