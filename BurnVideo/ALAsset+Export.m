//
//  ALAsset+Export.m
//  BurnVideo
//
//  Created by user on 8/19/15.
//  Copyright (c) 2015 B24E. All rights reserved.
//

#import "ALAsset+Export.h"


static const NSUInteger BufferSize = 1024*1024;

@implementation ALAsset (Export)

- (BOOL) exportDataToURL: (NSURL*) fileURL error: (NSError**) error
{
    [[NSFileManager defaultManager] createFileAtPath:[fileURL path] contents:nil attributes:nil];
    NSFileHandle *handle = [NSFileHandle fileHandleForWritingToURL:fileURL error:error];
    if (!handle) {
        NSLog(@"export asset error: %@", [*error localizedDescription]);
        return NO;
    }
    
    ALAssetRepresentation *rep = [self defaultRepresentation];
    uint8_t *buffer = calloc(BufferSize, sizeof(*buffer));
    NSUInteger offset = 0, bytesRead = 0;
    
    do {
        @try {
            bytesRead = [rep getBytes:buffer fromOffset:offset length:BufferSize error:error];
            [handle writeData:[NSData dataWithBytesNoCopy:buffer length:bytesRead freeWhenDone:NO]];
            offset += bytesRead;
        } @catch (NSException *exception) {
            free(buffer);
            return NO;
        }
    } while (bytesRead > 0);
    
    free(buffer);
    return YES;
}

@end
