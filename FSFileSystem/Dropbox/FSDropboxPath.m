/*
 * Copyright 2011-2012 Jason Rush and John Flanagan. All rights reserved.
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

#import "FSDropboxPath.h"
#import <objc/runtime.h>
#import <DropboxSDK/DropboxSDK.h>

@interface FSDropboxPath () <DBRestClientDelegate>
- (DBRestClient *)restClient;
@end

@implementation FSDropboxPath

static char *CALLBACK = "CALLBACK";

- (id)initWithRemotePath:(NSString *)remotePath localPath:(NSString *)localPath folder:(BOOL)folder {
    self = [super init];
    if (self) {
        _remotePath = [remotePath copy];
        _localPath = [localPath copy];
        _folder = folder;
    }
    return self;
}

+ (FSDropboxPath *)dropboxPathForRoot {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString *cachePath = [[paths objectAtIndex:0] stringByAppendingPathComponent:@"Dropbox"];

    return [[[FSDropboxPath alloc] initWithRemotePath:@"/" localPath:cachePath folder:YES] autorelease];
}

+ (FSDropboxPath *)dropboxPathWithMetadata:(DBMetadata *)metadata {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString *cachePath = [[paths objectAtIndex:0] stringByAppendingPathComponent:@"Dropbox"];
    NSString *localPath = [cachePath stringByAppendingPathComponent:metadata.path];

    return [[[FSDropboxPath alloc] initWithRemotePath:metadata.path localPath:localPath folder:metadata.isDirectory] autorelease];
}

- (void)dealloc {
    [_remotePath release];
    [super dealloc];
}

- (NSString *)name {
    return [_localPath lastPathComponent];
}

- (BOOL)isFolder {
    return _folder;
}

- (DBRestClient *)restClient {
    DBRestClient *restClient = [[DBRestClient alloc] initWithSession:[DBSession sharedSession]];
    restClient.delegate = self;

    return restClient;
}

- (void)listFolderWithCallback:(FSListFolderCallback)callback {
    NSLog(@"list: %@", self.remotePath);
    
    DBRestClient *restClient = [self restClient];
    objc_setAssociatedObject(restClient, CALLBACK, callback, OBJC_ASSOCIATION_COPY_NONATOMIC);
        
    [restClient loadMetadata:self.remotePath];
}

- (void)loadPathWithCallback:(FSLoadPathCallback)callback {
    DBRestClient *restClient = [self restClient];
    objc_setAssociatedObject(restClient, CALLBACK, callback, OBJC_ASSOCIATION_COPY_NONATOMIC);

    NSString *localDir = [self.localPath stringByDeletingLastPathComponent];
    [[NSFileManager defaultManager] createDirectoryAtPath:localDir withIntermediateDirectories:YES attributes:nil error:nil];

    [restClient loadFile:self.remotePath intoPath:self.localPath];
}

- (void)savePathWithCallback:(FSSavePathCallback)callback {
    DBRestClient *restClient = [self restClient];
    objc_setAssociatedObject(restClient, CALLBACK, callback, OBJC_ASSOCIATION_COPY_NONATOMIC);

    [restClient uploadFile:self.name toPath:[self.remotePath stringByDeletingLastPathComponent] withParentRev:nil fromPath:self.localPath];
}

- (void)deletePathWithCallback:(FSDeletePathCallback)callback {
    DBRestClient *restClient = [self restClient];
    objc_setAssociatedObject(restClient, CALLBACK, callback, OBJC_ASSOCIATION_COPY_NONATOMIC);

    [restClient deletePath:self.remotePath];
}

- (void)restClient:(DBRestClient *)client loadedMetadata:(DBMetadata *)metadata {
    NSMutableArray *children = [NSMutableArray array];
    for (DBMetadata *m in metadata.contents) {
        [children addObject:[FSDropboxPath dropboxPathWithMetadata:m]];
    }

    FSListFolderCallback callback = objc_getAssociatedObject(client, CALLBACK);
    if (callback != nil) {
        callback(self, children);
    }
    
    [client autorelease];
}

- (void)restClient:(DBRestClient *)client loadedFile:(NSString *)destPath {
    FSLoadPathCallback callback = objc_getAssociatedObject(client, CALLBACK);
    if (callback != nil) {
        callback(self);
    }

    [client autorelease];
}

- (void)restClient:(DBRestClient *)client uploadedFile:(NSString *)destPath from:(NSString *)srcPath {
    FSSavePathCallback callback = objc_getAssociatedObject(client, CALLBACK);
    if (callback != nil) {
        callback(self);
    }

    [client autorelease];
}

- (void)restClient:(DBRestClient *)client deletedPath:(NSString *)path {
    FSDeletePathCallback callback = objc_getAssociatedObject(client, CALLBACK);
    if (callback != nil) {
        callback(self);
    }

    [client autorelease];
}

@end
