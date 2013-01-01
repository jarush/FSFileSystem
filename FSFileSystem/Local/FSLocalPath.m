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

#import "FSLocalPath.h"

@implementation FSLocalPath

- (id)initWithLocalPath:(NSString *)localPath {
    self = [super init];
    if (self != nil) {
        _localPath = [localPath copy];
    }
    return self;
}

- (void)dealloc {
    [_localPath release];
    [super dealloc];
}

- (NSString *)name {
    return [_localPath lastPathComponent];
}

- (BOOL)isFolder {
    BOOL folder = NO;
    if (![[NSFileManager defaultManager] fileExistsAtPath:_localPath isDirectory:&folder]) {
        return NO;
    }
    return folder;
}

- (void)listFolderWithCallback:(FSListFolderCallback)callback {
    // Get the directory contents
    NSArray *dirContents = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:_localPath
                                                                               error:nil];

    // Convert the directory contents to path objects
    NSMutableArray *children = [NSMutableArray arrayWithCapacity:[dirContents count]];
    for (NSString *p in dirContents) {
        [children addObject:[[FSLocalPath alloc] initWithLocalPath:[_localPath stringByAppendingPathComponent:p]]];
    }

    // Call the callback
    if (callback != nil) {
        callback(self, children);
    }
}

- (void)loadPathWithCallback:(FSLoadPathCallback)callback {
    // Call the callback
    if (callback != nil) {
        callback(self);
    }
}

- (void)savePathWithCallback:(FSSavePathCallback)callback {
    // Call the callback
    if (callback != nil) {
        callback(self);
    }
}

- (void)deletePathWithCallback:(FSDeletePathCallback)callback {
    // Delete the local path
    [[NSFileManager defaultManager] removeItemAtPath:_localPath error:nil];

    // Call the callback
    if (callback != nil) {
        callback(self);
    }
}


@end
