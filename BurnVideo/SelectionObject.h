//
//  SelectionObject.h
//  BurnVideo
//
//  Created by user on 8/13/15.
//  Copyright (c) 2015 B24E. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import "AFNetworking.h"
#import "AppDelegate.h"

#import <AWSS3/AWSS3.h>

typedef enum : NSUInteger {
    UNSELECTED = 0,
    UPLOADING,
    SELECTED,
    UPLOADINGFAIL
} SelectionStatus;

typedef void (^uploadProcessBlock)(SelectionStatus status, NSError *err);

@interface SelectionObject : NSObject
{
    AWSS3TransferManagerUploadRequest *uploadRequest;
    NSURL *tempPath;
    NSString *fileName;
    AWSNetworkingUploadProgressBlock _uploadProgress;
}

@property (nonatomic) ALAsset *assetfile;
@property (nonatomic, copy) NSURL *assetURL;
@property (nonatomic, copy) NSString *remoteFileURL;
@property (atomic, assign) SelectionStatus status;
@property (nonatomic, copy) uploadProcessBlock block;
@property (nonatomic, copy) AWSNetworkingUploadProgressBlock uploadProgress;
@property (nonatomic, assign) int mediaSpace;
@property (nonatomic, assign) double duration;
@property (nonatomic, assign) BOOL isImage;

@property (nonatomic) UIImage *thumbImage;

- (id) initWithAsset:(ALAsset*) asset;
- (id) initWithAssetPath:(NSString*) path;
- (NSDictionary*) toDictionary;
- (id) initWithDictionary:(NSDictionary*) dictionary;
- (void) setSelect: (uploadProcessBlock) block;
- (void) setCancel;

- (AWSS3TransferManagerUploadRequest*) upload:(uploadProcessBlock) block;
- (AWSS3TransferManagerUploadRequest*) uploadRequest;

+ (AFURLSessionManager *) sharedSessionManager;

@end
