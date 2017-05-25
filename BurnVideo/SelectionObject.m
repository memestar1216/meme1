	//
//  SelectionObject.m
//  BurnVideo
//
//  Created by user on 8/13/15.
//  Copyright (c) 2015 B24E. All rights reserved.
//

#import "SelectionObject.h"
#import <UIKit/UIKit.h>
#import "AFNetworking.h"
#import "AFHTTPRequestOperationManager+timeout.h"
#import "SettingManager.h"
#import "Common.h"
#import "NSInputStream+POS.h"
#import "ALAsset+Export.h"

static inline double radians (double degrees) {return degrees * M_PI/180;}
UIImage* rotate(UIImage* src, UIImageOrientation orientation)
{
    double radian = 0;
    if (orientation == UIImageOrientationRight) {
        radian = radians(90);
    } else if (orientation == UIImageOrientationLeft) {
        radian = radians(-90);
    } else if (orientation == UIImageOrientationDown) {
        radian = radians(180);
    } else if (orientation == UIImageOrientationUp) {
        return src;
    }
    UIView *rotatedViewBox = [[UIView alloc] initWithFrame:CGRectMake(0,0,src.size.width, src.size.height)];
    CGAffineTransform t = CGAffineTransformMakeRotation(radian);
    rotatedViewBox.transform = t;
    CGSize rotatedSize = rotatedViewBox.frame.size;

    // Create the bitmap context
    UIGraphicsBeginImageContext(rotatedSize);
    CGContextRef bitmap = UIGraphicsGetCurrentContext();

    // Move the origin to the middle of the image so we will rotate and scale around the center.
    CGContextTranslateCTM(bitmap, rotatedSize.width/2, rotatedSize.height/2);

    //Rotate the image context
    CGContextRotateCTM(bitmap, radian);

    // Now, draw the rotated/scaled image into the context
    CGContextScaleCTM(bitmap, 1.0, -1.0);
    CGContextDrawImage(bitmap, CGRectMake(-src.size.width / 2, -src.size.height / 2, src.size.width, src.size.height), [src CGImage]);
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    CGContextRelease(bitmap);
    return newImage;
}

@interface SelectionObject ()
{
    dispatch_queue_t uploadqueue;
}
@end

@implementation SelectionObject

@dynamic uploadProgress;

+ (dispatch_queue_t) sharedQueue {
    static dispatch_queue_t uploadQueue = NULL;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        uploadQueue = dispatch_queue_create( "uploadqueue", NULL );
    });
    return uploadQueue;
}

- (id)initWithAsset:(ALAsset *)asset
{
    self = [super init];
    if (self) {
        self.assetfile = asset;
        self.assetURL = [asset valueForProperty:ALAssetPropertyAssetURL];
        self.duration = [[self.assetfile valueForProperty:ALAssetPropertyDuration] doubleValue];
        self.mediaSpace = (self.duration + 179) / (3 * 60);
        if ([[self.assetfile valueForProperty:ALAssetPropertyType] isEqualToString:ALAssetTypeVideo]) {
//            self.thumbImage = [UIImage imageWithCGImage:self.assetfile.thumbnail];
            self.isImage = false;
        }else{
//            self.thumbImage = [UIImage imageWithCGImage:self.assetfile.thumbnail];//[UIImage imageWithCGImage:self.assetfile.defaultRepresentation.fullResolutionImage];
            self.isImage = true;
        }
    }
    return self;
}

- (id)initWithAssetPath:(NSString *)path
{
    self = [super init];
    if (self) {
        self.assetURL = [NSURL URLWithString:path];
        ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
        [library assetForURL:[NSURL URLWithString:path] resultBlock:^(ALAsset *asset) {
            if (asset) {
                self.assetfile = asset;
                if ([[self.assetfile valueForProperty:ALAssetPropertyType] isEqualToString:ALAssetTypeVideo]) {
//                    self.thumbImage = [UIImage imageWithCGImage:self.assetfile.thumbnail];
                    self.duration = [[self.assetfile valueForProperty:ALAssetPropertyDuration] doubleValue];
                    self.mediaSpace = (self.duration + 179) / (3 * 60);
                    self.isImage = false;
                }else{
//                    self.thumbImage = [UIImage imageWithCGImage:self.assetfile.thumbnail];//[UIImage imageWithCGImage:self.assetfile.defaultRepresentation.fullResolutionImage];
                    self.duration = 0;
                    self.mediaSpace = 1;
                    self.isImage = true;
                }
            }
        } failureBlock:nil];
    }
    return self;
}

- (id)initWithDictionary:(NSDictionary *)dictionary
{
    NSString *path = (dictionary?dictionary[@"asseturl"]:@"");
    self = [self initWithAssetPath:path];
    if (self) {
        self.status = (dictionary?[dictionary[@"status"] intValue]:0);
        self.remoteFileURL = (dictionary?dictionary[@"remotefileid"]:nil);
    }
    return self;
}

- (NSDictionary *)toDictionary
{
    return @{@"asseturl":(self.assetURL?[self.assetURL absoluteString]:@"")
             , @"status":[NSNumber numberWithInt:self.status]
             , @"remotefileid":(self.remoteFileURL?self.remoteFileURL:@"")};
}

- (void)setSelect: (uploadProcessBlock) block {
    if (self.remoteFileURL) {
        self.status = SELECTED;
        block(SELECTED, nil);
        return;
    }
    self.status = UPLOADING;
    self.block = block;
    block(UPLOADING, nil);
    
    dispatch_async([SelectionObject sharedQueue], ^{
        NSError *error;
        if (uploadRequest == nil) {
            uploadRequest = [self buildUploadManagerWitherror:&error];
            if (error) {
                self.status = UNSELECTED;
                self.block(UPLOADINGFAIL, nil);
                return;
            }
        }
        AWSS3TransferManagerUploadRequest *request = [self upload:self.block];
        if (self.uploadProgress) {
            [request setUploadProgress:self.uploadProgress];
        }
    });
}

- (void)setUploadProgress:(AWSNetworkingUploadProgressBlock)uploadProgress
{
    _uploadProgress = uploadProgress;
    if (uploadRequest) {
        [uploadRequest setUploadProgress:uploadProgress];
    }
}

- (AWSNetworkingUploadProgressBlock)uploadProgress
{
    return _uploadProgress;
}

- (AWSS3TransferManagerUploadRequest*) buildUploadManagerWitherror: (NSError**) error {
    if (self.isImage) {
        fileName = [[[NSProcessInfo processInfo] globallyUniqueString] stringByAppendingString:@".jpeg"];
        NSString *filePath = [NSTemporaryDirectory() stringByAppendingPathComponent:fileName];
        
//        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
//        NSString *documentsDirectory = [paths objectAtIndex:0];
//        NSString *filePath = [documentsDirectory stringByAppendingPathComponent:fileName];
        
        UIImageOrientation orientation = UIImageOrientationUp;
        ALAssetRepresentation *representation = [self.assetfile defaultRepresentation];
        NSNumber* orientationValue = [self.assetfile valueForProperty:@"ALAssetPropertyOrientation"];
        if (orientationValue != nil) {
            orientation = [orientationValue intValue];
        }
        
        CGFloat scale  = 1;
        UIImage *originImage = [UIImage imageWithCGImage:[representation fullResolutionImage]];
        UIImage* image = rotate(originImage, orientation);
        NSData *data;
        if (image) {
            data = UIImageJPEGRepresentation(image, scale);
        }else{
            data = UIImageJPEGRepresentation(originImage, scale);
        }
        
        [data writeToFile:filePath options:NSDataWritingAtomic error:error];        
        if (*error) {
            return nil;
        }
        AWSS3TransferManagerUploadRequest *request = [AWSS3TransferManagerUploadRequest new];
        request.body = [NSURL fileURLWithPath:filePath];
        request.key = fileName;
        request.bucket = S3BucketName;        
        request.ACL = AWSS3ObjectCannedACLPublicRead;
        return request;
    }else{
        fileName = [[[NSProcessInfo processInfo] globallyUniqueString] stringByAppendingString:@".m4v"];
        NSString *filePath = [NSTemporaryDirectory() stringByAppendingPathComponent:fileName];
        [self.assetfile exportDataToURL:[NSURL URLWithString:filePath] error:error];
        if (*error) {
            return nil;
        }
        AWSS3TransferManagerUploadRequest *request = [AWSS3TransferManagerUploadRequest new];
        request.body = [NSURL fileURLWithPath:filePath];
        request.key = fileName;
        request.bucket = S3BucketName;
        request.ACL = AWSS3ObjectCannedACLPublicRead;
        return request;
    }
}

- (void)setCancel {
    if (uploadRequest.state == AWSS3TransferManagerRequestStateRunning) {
        [[uploadRequest pause] continueWithBlock:^id(AWSTask *task) {
            if (task.error) {
                NSLog(@"The pause request failed: [%@]", task.error);
            }
            return nil;
        }];
    }
    self.status = UNSELECTED;
}

- (AWSS3TransferManagerUploadRequest*) upload:(uploadProcessBlock) block{
    AWSS3TransferManager *transferManager = [AWSS3TransferManager defaultS3TransferManager];
    [[transferManager upload:uploadRequest] continueWithBlock:^id(AWSTask *task) {
        if (task.error) {
            if ([task.error.domain isEqualToString:AWSS3TransferManagerErrorDomain]) {
                switch (task.error.code) {
                    case AWSS3TransferManagerErrorCancelled:
                    case AWSS3TransferManagerErrorPaused:
                    {
                        dispatch_async(dispatch_get_main_queue(), ^{

                        });
                    }
                        break;
                        
                    default:
                        if (self.status != UNSELECTED) {
                            self.status = UNSELECTED;
                            block(UPLOADINGFAIL, task.error);
                        }
                        
                        NSLog(@"Upload failed: [%@]", task.error);
                        break;
                }
            } else {
                if (self.status != UNSELECTED) {
                    self.status = UNSELECTED;
                    block(UPLOADINGFAIL, task.error);
                }
            }
        }
        
        if (task.result) {
            dispatch_async(dispatch_get_main_queue(), ^{
                self.remoteFileURL = [NSString stringWithFormat:@"https://s3.amazonaws.com/burunvideo/%@", fileName];
                self.status = SELECTED;
                AppDelegate *appDel = (AppDelegate*)[[UIApplication sharedApplication] delegate];
                [appDel saveSelectedArray];
                if ([[NSFileManager defaultManager] fileExistsAtPath:uploadRequest.body.absoluteString]) {
                    [[NSFileManager defaultManager] removeItemAtURL:uploadRequest.body error:nil];
                }
                block(SELECTED, nil);                
            });
        }
        
        return nil;
    }];
    
    return uploadRequest;

    
    
    
//    if (self.assetfile) {
//        if ([[self.assetfile valueForProperty:ALAssetPropertyType] isEqualToString:ALAssetTypePhoto]) {
//            UIImage *img = [UIImage imageWithCGImage:[self.assetfile.defaultRepresentation fullResolutionImage]];
//            NSData *data = UIImageJPEGRepresentation(img, 1);
//            NSDictionary *dic = @{@"token":[SettingManager stringValueWithKey:SETTING_KEY_TOKEN]
//                                   , @"uid":[SettingManager stringValueWithKey:SETTING_KEY_UID]
//                                  , @"devicetype":[NSNumber numberWithInt:1]
//                                  , @"ftype":@"image"
//                                  , @"fplaytime":[NSNumber numberWithInt:(int)self.duration]
//                                  , @"fweight":[NSNumber numberWithInt:self.mediaSpace]};
//            
//            AFHTTPRequestOperationManager *manager = [[AFHTTPRequestOperationManager alloc] initWithBaseURL:[NSURL URLWithString:BASE_URL]];
//            
//            
//            
//            return [manager POST:@"FileUpload" parameters:dic timeoutInterval:UPLOAD_TIMEOUT_INTERVAL constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
//                [formData appendPartWithFileData:data name:@"file" fileName:self.assetfile.defaultRepresentation.filename mimeType:@"jpeg"];
//            } success:^(AFHTTPRequestOperation *operation, id responseObject) {
//                
//                NSDictionary *response = (NSDictionary *)responseObject;
//                
//                if ([[response objectForKey:@"retCode"] intValue] == 0) {
//                    block(SELECTED, nil);
//                    self.status = SELECTED;
//                    self.remoteFileURL = responseObject[@"fid"];
//                    AppDelegate *appDel = (AppDelegate*)[[UIApplication sharedApplication] delegate];
//                    [appDel saveSelectedArray];
//                }
//                else {
//                    self.status = UNSELECTED;
//                    block(UPLOADINGFAIL, [NSError errorWithDomain:@"" code:-1 userInfo:@{NSLocalizedDescriptionKey:@"Response error"}]);
//                    NSLog(@"Failed to set user profile");
//                }
//            } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
//                if (self.status == UPLOADING) {
//                    block(UPLOADINGFAIL, error);
//                }
//                self.status = UNSELECTED;
//                
//                NSLog(@"%@", error.localizedDescription);
//            }];
//        }else{
//            __block NSInputStream *stream = [NSInputStream pos_inputStreamWithAssetURL:self.assetURL];
//            NSDictionary *dic = @{@"token":[SettingManager stringValueWithKey:SETTING_KEY_TOKEN]
//                                  , @"uid":[SettingManager stringValueWithKey:SETTING_KEY_UID]
//                                  , @"devicetype":[NSNumber numberWithInt:1]
//                                  , @"ftype":@"video"
//                                  , @"fplaytime":[NSNumber numberWithInt:(int)self.duration]
//                                  , @"fweight":[NSNumber numberWithInt:self.mediaSpace]};
//            AFHTTPRequestOperationManager *manager = [[AFHTTPRequestOperationManager alloc] initWithBaseURL:[NSURL URLWithString:BASE_URL]];
//            [stream open];
//            return [manager POST:@"FileUpload" parameters:dic timeoutInterval:UPLOAD_TIMEOUT_INTERVAL constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
//                [formData appendPartWithInputStream:stream name:@"file" fileName:self.assetfile.defaultRepresentation.filename length:self.assetfile.defaultRepresentation.size mimeType:@"m4v"];
//            } success:^(AFHTTPRequestOperation *operation, id responseObject) {
//                [stream close];
//                NSDictionary *response = (NSDictionary *)responseObject;
//                
//                if ([[response objectForKey:@"retCode"] intValue] == 0) {
//                    block(SELECTED, nil);
//                    self.status = SELECTED;
//                    self.remoteFileURL = responseObject[@"fid"];
//                    AppDelegate *appDel = (AppDelegate*)[[UIApplication sharedApplication] delegate];
//                    [appDel saveSelectedArray];
//                }
//                else {
//                    self.status = UNSELECTED;
//                    block(UPLOADINGFAIL, [NSError errorWithDomain:@"" code:-1 userInfo:@{NSLocalizedDescriptionKey:@"Response error"}]);
//                    NSLog(@"Failed to set user profile");
//                }
//            } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
//                [stream close];
//                if (self.status == UPLOADING) {
//                    block(UPLOADINGFAIL, error);
//                }
//                self.status = UNSELECTED;
//                NSLog(@"%@", error.localizedDescription);
//            }];
//        }
//    }else{
//        self.status = UNSELECTED;
//        block(UPLOADINGFAIL, [NSError errorWithDomain:@"FileNotFind" code:-1 userInfo:nil]);
//        return nil;
//    }
}

- (AWSS3TransferManagerUploadRequest *)uploadRequest
{
    return uploadRequest;
}

+ (AFURLSessionManager *) sharedSessionManager {
    static dispatch_once_t pred  ;
    static AFURLSessionManager *manager = nil;
    dispatch_once(&pred, ^{
        manager = [[AFURLSessionManager alloc] initWithSessionConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    });
    return manager;
}

@end
