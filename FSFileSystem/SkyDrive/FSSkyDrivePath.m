//
//  FSSkyDrivePath.m
//  FSFileSystem
//
//  Created by Jason Rush on 1/1/13.
//  Copyright (c) 2013 Flush Software LLC. All rights reserved.
//

#import "FSSkyDrivePath.h"
#import "FSSkyDriveOperation.h"

@implementation FSSkyDrivePath

- (id)initWithObjectId:(NSString *)objectId name:(NSString *)name type:(NSString *)type fileSystem:(FSSkyDriveFileSystem *)fileSystem {
    self = [super init];
    if (self) {
        _objectId = [objectId copy];
        _name = [name copy];
        _type = [type copy];
        _fileSystem = [fileSystem retain];
    }
    return self;
}

- (void)dealloc {
    [_objectId release];
    [_name release];
    [_type release];
    [_fileSystem release];
    [super dealloc];
}

- (BOOL)isFolder {
    return [_type isEqual:@"folder"];
}

- (void)listFolderWithCallback:(FSListFolderCallback)callback {
    [self.fileSystem.liveConnectClient getWithPath:[NSString stringWithFormat:@"%@/files", self.objectId]
                                          delegate:self
                                         userState:[FSSkyDriveOperation skyDriveOperationWithType:@"list" callback:callback]];
}

- (void)loadPathWithCallback:(FSLoadPathCallback)callback {
    [self.fileSystem.liveConnectClient downloadFromPath:[NSString stringWithFormat:@"%@/content", self.objectId]
                                          delegate:self
                                         userState:[FSSkyDriveOperation skyDriveOperationWithType:@"load" callback:callback]];
}

- (void)savePathWithCallback:(FSSavePathCallback)callback {
    [self.fileSystem.liveConnectClient uploadToPath:nil // FIXME
                                           fileName:self.name
                                               data:[NSData dataWithContentsOfFile:_localPath]
                                          overwrite:LiveUploadOverwrite
                                           delegate:self
                                          userState:[FSSkyDriveOperation skyDriveOperationWithType:@"save" callback:callback]];
}

- (void)deletePathWithCallback:(FSDeletePathCallback)callback {
    [self.fileSystem.liveConnectClient deleteWithPath:self.objectId
                                             delegate:self
                                            userState:[FSSkyDriveOperation skyDriveOperationWithType:@"delete" callback:callback]];
}

- (void)liveOperationSucceeded:(LiveOperation *)operation {
    FSSkyDriveOperation *skyDriveOperation = operation.userState;
    if ([skyDriveOperation.type isEqualToString:@"list"]) {
        NSMutableArray *children = [NSMutableArray array];

        NSArray *rawFolderObjects = [operation.result objectForKey:@"data"];
        for (NSDictionary *rawObject in rawFolderObjects) {
            FSSkyDrivePath *path = [[[FSSkyDrivePath alloc] initWithObjectId:[rawObject objectForKey:@"id"]
                                                                        name:[rawObject objectForKey:@"name"]
                                                                        type:[rawObject objectForKey:@"type"]
                                                                  fileSystem:_fileSystem] autorelease];

            [children addObject:path];
        }

        FSListFolderCallback callback = operation.userState;
        if (callback != nil) {
            callback(self, children);
        }
    } else if ([skyDriveOperation.type isEqualToString:@"load"]) {
        FSLoadPathCallback callback = operation.userState;
        if (callback != nil) {
            callback(self);
        }
    } else if ([skyDriveOperation.type isEqualToString:@"save"]) {
        FSSavePathCallback callback = operation.userState;
        if (callback != nil) {
            callback(self);
        }
    } else if ([skyDriveOperation.type isEqualToString:@"delete"]) {
        FSDeletePathCallback callback = operation.userState;
        if (callback != nil) {
            callback(self);
        }
    }
}

@end
