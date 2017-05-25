//
//  UploadedObject.h
//  BurnVideo
//
//  Created by user on 8/16/15.
//  Copyright (c) 2015 B24E. All rights reserved.
//

#import "SQPObject.h"
#import <Foundation/Foundation.h>

@interface UploadedObject : SQPObject

@property (nonatomic, strong) NSString *filepath;
@property (nonatomic, strong) NSString *remotefileid;
@property (nonatomic, strong) NSString *uid;
@property (nonatomic, strong) NSDate *uploadtime;

@end
