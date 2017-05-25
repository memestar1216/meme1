//
//  Common.h
//  BurnVideo
//
//  Created by user on 7/27/15.
//  Copyright (c) 2015 B24E. All rights reserved.
//

#ifndef BurnVideo_Common_h
#define BurnVideo_Common_h

#import <AWSCore/AWSCore.h>

//#define BASE_URL @"http://192.168.1.107:8086/api/"
#define BASE_URL @"http://54.174.229.176/api"

#define MEDIA_COUNT 40
#define UPLOAD_TIMEOUT_INTERVAL (60*20)

#define CognitoRegionType AWSRegionUSEast1
#define DefaultServiceRegionType AWSRegionUSEast1
#define CognitoIdentityPoolId @"us-east-1:985b0e33-2bec-42e5-892f-d6d5d9d0355c"
#define S3BucketName @"burunvideo"

#endif
