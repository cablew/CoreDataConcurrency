//
//  Owner+Concurrency.h
//  CoreDataConcurrency
//
//  Created by Kable Wang on 2013-1-20星期日.
//  Copyright (c) 2013年 Kable Wang. All rights reserved.
//

#import "Owner.h"

@interface Owner (Concurrency)

+ (Owner *)ownerWithFirstName:(NSString *)firstName lastName:(NSString *)lastName managedObjectContext:(NSManagedObjectContext *)context;

@end
