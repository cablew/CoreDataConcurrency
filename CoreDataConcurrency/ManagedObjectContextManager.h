//
//  ManagedObjectContextManager.h
//  CoreDataConcurrency
//
//  Created by Kable Wang on 2013-1-19星期六.
//  Copyright (c) 2013年 Kable Wang. All rights reserved.
//

#import <CoreData/CoreData.h>

@interface ManagedObjectContextManager : NSManagedObjectContext

+ (ManagedObjectContextManager *)contextManager;
- (NSManagedObjectContext *)managedObjectContextForCurrentThread;
@end
