//
//  FSSkyDriveOperation.h
//  FSFileSystem
//
//  Created by Jason Rush on 1/1/13.
//  Copyright (c) 2013 Flush Software LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FSSkyDriveOperation : NSObject

@property (nonatomic, copy) NSString *type;
@property (nonatomic, copy) id callback;

- (id)initWithType:(NSString *)type callback:(id)callback;

+ (FSSkyDriveOperation*)skyDriveOperationWithType:(NSString *)type callback:(id)callback;

@end
