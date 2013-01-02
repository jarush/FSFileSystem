//
//  FSSkyDrivePath.h
//  FSFileSystem
//
//  Created by Jason Rush on 1/1/13.
//  Copyright (c) 2013 Flush Software LLC. All rights reserved.
//

#import "FSPath.h"
#import "FSSkyDriveFileSystem.h"

@interface FSSkyDrivePath : FSPath <LiveOperationDelegate, LiveDownloadOperationDelegate, LiveUploadOperationDelegate>

@property (nonatomic, copy) NSString *objectId;
@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *type;
@property (nonatomic, copy) NSString *localPath;
@property (nonatomic, retain) FSSkyDriveFileSystem *fileSystem;

- (id)initWithObjectId:(NSString *)objectId name:(NSString *)name type:(NSString *)type fileSystem:(FSSkyDriveFileSystem *)fileSystem;

@end
