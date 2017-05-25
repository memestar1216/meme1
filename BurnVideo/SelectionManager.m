//
//  UploadManager.m
//  BurnVideo
//
//  Created by user on 8/10/15.
//  Copyright (c) 2015 B24E. All rights reserved.
//

#import "SelectionManager.h"
#import "SettingManager.h"
#import "AppDelegate.h"
#import "SelectionObject.h"

#import "SQPersist.h"
#import "UploadedObject.h"

#define UPLOAD_KEY_EXIST @"uploading"
#define UPLOAD_KEY_TOKEN @"upload_token"
#define UPLOAD_KEY_UID @"upload_uid"
#define UPLOAD_KEY_ORDERID @"upload_orderid"
#define UPLOAD_KEY_FILES @"upload_files"

#define DBNAME @"sqlite.sqlite"

@implementation SelectionManager

+(instancetype)sharedInstance {
    static SelectionManager *sharedManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedManager = [[self alloc]init];
        [SQPDatabase sharedInstance].logRequests = YES;
        [SQPDatabase sharedInstance].logPropertyScan = YES;
        [SQPDatabase sharedInstance].addMissingColumns = YES;
        [[SQPDatabase sharedInstance] setupDatabaseWithName:DBNAME];
    });
    return sharedManager;
}

- (BOOL) isUploadedAssetFile:(NSString *) assetUrl {
    NSString *uid = [SettingManager stringValueWithKey:SETTING_KEY_UID];    
    return ([UploadedObject SQPFetchOneWhere:[NSString stringWithFormat:@"filepath = '%@' and uid = '%@'", assetUrl, uid]] != nil);
}

- (void)saveUploadedFiles {
    NSString *uid = [SettingManager stringValueWithKey:SETTING_KEY_UID];
    AppDelegate *appD = [UIApplication sharedApplication].delegate;
    for (SelectionObject *obj in appD.selectedArray) {
        if (obj.status == SELECTED) {
            if ([self isUploadedAssetFile:obj.assetURL.absoluteString]) {
                continue;
            }
            [[SQPDatabase sharedInstance] beginTransaction];
            UploadedObject *object = [[UploadedObject alloc] init];
            object.filepath = [obj.assetURL.absoluteString copy];
            object.remotefileid = obj.remoteFileURL;
            object.uploadtime = [NSDate date];
            object.uid = uid;
            [object SQPSaveEntity];
            [[SQPDatabase sharedInstance] commitTransaction];
        }
    }
    [appD.selectedArray removeAllObjects];
    [appD saveSelectedArray];
    [appD getMediaSpace];
}

@end
