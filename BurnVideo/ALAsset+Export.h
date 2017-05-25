//
//  ALAsset+Export.h
//  BurnVideo
//
//  Created by user on 8/19/15.
//  Copyright (c) 2015 B24E. All rights reserved.
//

#import <AssetsLibrary/AssetsLibrary.h>

@interface ALAsset (Export)

- (BOOL) exportDataToURL: (NSURL*) fileURL error: (NSError**) error;

@end
