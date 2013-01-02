//
//  FSSkyDriveOperation.m
//  FSFileSystem
//
//  Created by Jason Rush on 1/1/13.
//  Copyright (c) 2013 Flush Software LLC. All rights reserved.
//

#import "FSSkyDriveOperation.h"

@implementation FSSkyDriveOperation

- (id)initWithType:(NSString *)type callback:(id)callback {
    self = [super init];
    if (self) {
        _type = [type copy];
        _callback = [callback copy];
    }
    return self;
}

+ (FSSkyDriveOperation*)skyDriveOperationWithType:(NSString *)type callback:(id)callback {
    return [[[FSSkyDriveOperation alloc] initWithType:type callback:callback] autorelease];
}

- (void)dealloc {
    [_type release];
    [_callback release];
    [super dealloc];
}

@end
