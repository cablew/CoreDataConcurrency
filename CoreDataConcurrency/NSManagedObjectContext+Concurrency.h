//
//  NSManagedObjectContext+Concurrency.h
//  CoreDataConcurrency
//
//  Created by Kable Wang on 2013-1-22星期二.
//  Copyright (c) 2013年 Kable Wang. All rights reserved.
//

#import <CoreData/CoreData.h>

typedef NS_OPTIONS(NSUInteger, MRSaveContextOptions) {
    MRSaveParentContexts = 1,   ///< When saving, continue saving parent contexts until the changes are present in the persistent store
    MRSaveSynchronously = 2     ///< Peform saves synchronously, blocking execution on the current thread until the save is complete
};

typedef void (^MRSaveCompletionHandler)(BOOL success, NSError *error);

@interface NSManagedObjectContext (Concurrency)

+ (void)MR_initializeDefaultContextWithCoordinator:(NSPersistentStoreCoordinator *)coordinator;
+ (NSManagedObjectContext *)MR_defaultContext;
+ (NSManagedObjectContext *)MR_contextForCurrentThread;
- (void)MR_saveToPersistentStoreAndWait;

@end
