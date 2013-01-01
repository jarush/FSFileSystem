//
//  FSDropboxClient.m
//  FSFileSystem
//
//  Created by Jason Rush on 1/1/13.
//  Copyright (c) 2013 Flush Software LLC. All rights reserved.
//

#import "FSDropboxClient.h"

@implementation FSDropboxClient

- (id)initWithSession:(DBSession *)inSession callback:(id)inCallback {
    self = [super initWithSession:inSession];
    if (self) {
        _callback = [inCallback copy];
    }
    return self;
}

- (void)dealloc {
    [_callback release];
    [super dealloc];
}

@end
