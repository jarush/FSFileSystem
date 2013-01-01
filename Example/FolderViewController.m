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

#import "FolderViewController.h"
#import "AppDelegate.h"

@interface FolderViewController ()
@property (nonatomic, retain) FSPath *rootPath;
@property (nonatomic, retain) NSArray *children;
@end

@implementation FolderViewController

- (id)initWithPath:(FSPath *)path {
    self = [super initWithStyle:UITableViewStylePlain];
    if (self) {
        _rootPath = [path retain];

        self.title = _rootPath.name;
    }
    return self;
}

- (void)dealloc {
    [_rootPath release];
    [_children release];
    [super dealloc];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    if (![appDelegate.dropboxFileSystem isLinked]) {
        [appDelegate.dropboxFileSystem linkFromController:self];
    } else {
        [_rootPath listFolderWithCallback:^(FSPath *path, NSArray *children) {
            _children = [children retain];
            [self.tableView reloadData];
        }];
    }
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [_children count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"Cell";

    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }

    FSPath *path = [_children objectAtIndex:indexPath.row];
    cell.textLabel.text = path.name;

    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    FSPath *path = [_children objectAtIndex:indexPath.row];
    if ([path isFolder]) {
        FolderViewController *folderViewController = [[[FolderViewController alloc] initWithPath:path] autorelease];
        [self.navigationController pushViewController:folderViewController animated:YES];
    } else {
        [path loadPathWithCallback:^(FSPath *path) {
            NSString *fileContents = [NSString stringWithContentsOfFile:path.localPath
                                                               encoding:NSUTF8StringEncoding
                                                                  error:nil];

            UIAlertView *alertView = [[[UIAlertView alloc] initWithTitle:path.name
                                                                 message:fileContents
                                                                delegate:nil
                                                       cancelButtonTitle:@"Ok"
                                                       otherButtonTitles:nil] autorelease];
            [alertView show];
        }];
    }
}

@end
