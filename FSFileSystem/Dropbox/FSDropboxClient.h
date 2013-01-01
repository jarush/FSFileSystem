//
//  FSDropboxClient.h
//  FSFileSystem
//
//  Created by Jason Rush on 1/1/13.
//  Copyright (c) 2013 Flush Software LLC. All rights reserved.
//

#import <DropboxSDK/DropboxSDK.h>

@interface FSDropboxClient : DBRestClient

@property (nonatomic, copy) id callback;

- (id)initWithSession:(DBSession *)inSession callback:(id)inCallback;

@end
