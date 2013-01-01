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

#import "AppDelegate.h"
#import <DropboxSDK/DropboxSDK.h>
#import "FolderViewController.h"
#import "secrets.h"

@implementation AppDelegate

- (void)dealloc {
    [_window release];
    [_localFileSystem release];
    [_dropboxFileSystem release];
    [super dealloc];
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    self.window = [[[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]] autorelease];

    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    self.localFileSystem = [[[FSLocalFileSystem alloc] initWithRootPath:documentsDirectory] autorelease];

    self.dropboxFileSystem = [[[FSDropboxFileSystem alloc] initWithAppKey:DROPBOX_APP_KEY
                                                                addSecret:DROPBOX_APP_SECRET
                                                                     root:kDBRootDropbox] autorelease];

    FolderViewController *folderViewController = [[[FolderViewController alloc] initWithPath:self.dropboxFileSystem.rootPath] autorelease];

    self.window.rootViewController = [[[UINavigationController alloc] initWithRootViewController:folderViewController] autorelease];

    self.window.backgroundColor = [UIColor whiteColor];
    [self.window makeKeyAndVisible];

    return YES;
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
    if ([[DBSession sharedSession] handleOpenURL:url]) {
        if ([[DBSession sharedSession] isLinked]) {
            NSLog(@"App linked successfully!");
        }
        return YES;
    }
    // Add whatever other url handling code your app requires here
    return NO;
}

@end
