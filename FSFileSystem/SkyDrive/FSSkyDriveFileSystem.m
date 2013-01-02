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

#import "FSSkyDriveFileSystem.h"
#import "FSSkyDrivePath.h"

@implementation FSSkyDriveFileSystem

- (id)initWithClientId:(NSString *)clientId {
    self = [super init];
    if (self) {
        _liveConnectClient = [[LiveConnectClient alloc] initWithClientId:clientId
                                                                  scopes:@[@"wl.signin", @"wl.basic", @"wl.skydrive", @"skydrive_update"]
                                                                delegate:self];
    }
    return self;
}

- (void)dealloc {
    [_liveConnectClient release];
    [super dealloc];
}

- (void)loginFromController:(UIViewController *)controller {
    [_liveConnectClient login:controller delegate:self];
}

- (void)logout {
    [self.liveConnectClient logout];
}

- (FSPath *)rootPath {
    return [[[FSSkyDrivePath alloc] initWithObjectId:@"me/skydrive" name:@"SkyDrive" type:@"folder" fileSystem:self] autorelease];
}

- (void)authCompleted:(LiveConnectSessionStatus)status session:(LiveConnectSession *)session userState:(id)userState {
    // TODO
}

@end
