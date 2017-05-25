//
//  UploadManager.h
//  BurnVideo
//
//  Created by user on 8/10/15.
//  Copyright (c) 2015 B24E. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SelectionManager : NSObject
{
    NSMutableArray *selectedArray;
}

@property (nonatomic, copy) NSString *token;
@property (nonatomic, copy) NSString *uid;
@property (nonatomic, copy) NSString *orderid;
@property (nonatomic) NSMutableArray *filelist;

- (void) saveUploadedFiles;

- (BOOL) isUploadedAssetFile:(NSString *) assetUrl;

+(instancetype)sharedInstance;

@end
