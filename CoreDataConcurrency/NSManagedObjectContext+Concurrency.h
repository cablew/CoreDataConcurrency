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

// what MR means?
// why use underscore in middle of method name? it's not conventional

// init the default MOC for main thread
// also create a root MOC for single point of CoreData saving
+ (void)MR_initializeDefaultContextWithCoordinator:(NSPersistentStoreCoordinator *)coordinator;

// Could you explain the purpose of the following two methods?

// Singleton for main thread default context
+ (NSManagedObjectContext *)MR_defaultContext;

// return the temporary context for current thread
// the returned context is a child of the default context
+ (NSManagedObjectContext *)MR_contextForCurrentThread;

// save changes in all related contexts and the persistent store
// like the [context save:&error]; in single MOC app
- (void)MR_saveToPersistentStoreAndWait;

@end
