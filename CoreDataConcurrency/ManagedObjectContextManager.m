//
//  ManagedObjectContextManager.m
//  CoreDataConcurrency
//
//  Created by Kable Wang on 2013-1-19星期六.
//  Copyright (c) 2013年 Kable Wang. All rights reserved.
//

#import "ManagedObjectContextManager.h"

#define kMergePolicy NSMergeByPropertyObjectTrumpMergePolicy
#define DATABASE_NAME @"testingdb.sqlite"

static ManagedObjectContextManager *contextManager_;

@interface ManagedObjectContextManager()

@property (nonatomic, strong) NSManagedObjectContext *managedObjectContextForMainThread;
@property (nonatomic, strong) NSMutableDictionary *managedObjectContexts;
@property (nonatomic, strong) NSPersistentStoreCoordinator *persistentStoreCoordinator;
@property (nonatomic, strong) NSManagedObjectModel *managedObjectModel;

- (void)discardManagedObjectContext;

@end

@implementation ManagedObjectContextManager

+ (ManagedObjectContextManager *)contextManager
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        contextManager_ = [[ManagedObjectContextManager alloc] init];
    });
    
    return contextManager_;
}

- (NSManagedObjectContext *)managedObjectContextForCurrentThread
{
	NSThread *thread = [NSThread currentThread];
	
	if ([thread isMainThread]) {
        NSLog(@"Main Thread context");
		return self.managedObjectContextForMainThread;
	}
	
	// a key to cache the moc for the current thread
	NSString *threadKey = [NSString stringWithFormat:@"%p", thread];
	
    NSLog(@"context for thread %@", threadKey);
    if ( [self.managedObjectContexts objectForKey:threadKey] == nil ) {
		// create a moc for this thread
        NSManagedObjectContext *threadContext = [[NSManagedObjectContext alloc] init];
        [threadContext setPersistentStoreCoordinator:[self persistentStoreCoordinator]];
		[threadContext setMergePolicy:kMergePolicy];
		
        // cache the moc for this thread
        [self.managedObjectContexts setObject:threadContext forKey:threadKey];
		
		// attach a notification thingie
		[[NSNotificationCenter defaultCenter] addObserver:self
												 selector:@selector(mocDidSave:)
													 name:NSManagedObjectContextDidSaveNotification
												   object:threadContext];
    }
	
	return [self.managedObjectContexts objectForKey:threadKey];
}

- (NSManagedObjectContext *)managedObjectContextForMainThread
{
	if (_managedObjectContextForMainThread == nil) {
		NSAssert([NSThread isMainThread], @"Must be instantiated on main thread.");
		_managedObjectContextForMainThread = [[NSManagedObjectContext alloc] init];
		[_managedObjectContextForMainThread setPersistentStoreCoordinator:[self persistentStoreCoordinator]];
		[_managedObjectContextForMainThread setMergePolicy:kMergePolicy];
	}
	
	return _managedObjectContextForMainThread;
}

- (void)mocDidSave:(NSNotification *)saveNotification
{
    if ([NSThread isMainThread]) {
        [[self managedObjectContextForMainThread] mergeChangesFromContextDidSaveNotification:saveNotification];
    } else {
        [self performSelectorOnMainThread:@selector(mocDidSave:) withObject:saveNotification waitUntilDone:NO];
    }
}

- (void)discardManagedObjectContext {
	NSString *threadKey = [NSString stringWithFormat:@"%p", [NSThread currentThread]];
	NSManagedObjectContext *threadContext = [self.managedObjectContexts objectForKey:threadKey];
	[[NSNotificationCenter defaultCenter] removeObserver:self name:NSManagedObjectContextDidSaveNotification object:threadContext];
	[self.managedObjectContexts removeObjectForKey:threadKey];
}

/**
 * Returns the persistent store coordinator for the application.
 * If the coordinator doesn't already exist, it is created and the application's store added to it.
 */
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator {
	
	@synchronized(self) {
		if (_persistentStoreCoordinator == nil) {
			
			// This next block is useful when the store is initialized for the first time.  If the DB doesn't already
			// exist and a copy of the db (with the same name) exists in the bundle, it'll be copied over and used.  This
			// is useful for the initial seeding of data in the app.
			NSString *storePath = [self storePath];
			NSFileManager *fileManager = [NSFileManager defaultManager];
			
			if (![fileManager fileExistsAtPath:storePath]) {
				NSString *defaultStorePath = [[NSBundle mainBundle] pathForResource:[self databaseName] ofType:nil];
				
				if ([fileManager fileExistsAtPath:defaultStorePath]) {
					[fileManager copyItemAtPath:defaultStorePath toPath:storePath error:NULL];
				}
			}
			
			NSURL *storeURL = [NSURL fileURLWithPath:storePath];
			NSError *error = nil;
			
			self.persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
			
			// https://developer.apple.com/library/mac/#documentation/Cocoa/Conceptual/CoreDataVersioning/Articles/vmLightweightMigration.html#//apple_ref/doc/uid/TP40004399-CH4-SW1
			NSDictionary *options = [NSDictionary dictionaryWithObjectsAndKeys:
									 [NSNumber numberWithBool:YES], NSMigratePersistentStoresAutomaticallyOption,
									 [NSNumber numberWithBool:YES], NSInferMappingModelAutomaticallyOption, nil];
			
			if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:options error:&error]) {
				/*
				 Replace this implementation with code to handle the error appropriately.
				 
				 abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. If it is not possible to recover from the error, display an alert panel that instructs the user to quit the application by pressing the Home button.
				 
				 Typical reasons for an error here include:
				 * The persistent store is not accessible;
				 * The schema for the persistent store is incompatible with current managed object model.
				 Check the error message to determine what the actual problem was.
				 
				 
				 If the persistent store is not accessible, there is typically something wrong with the file path. Often, a file URL is pointing into the application's resources directory instead of a writeable directory.
				 
				 If you encounter schema incompatibility errors during development, you can reduce their frequency by:
				 * Simply deleting the existing store:
				 [[NSFileManager defaultManager] removeItemAtURL:storeURL error:nil]
				 
				 * Performing automatic lightweight migration by passing the following dictionary as the options parameter:
				 [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:YES],NSMigratePersistentStoresAutomaticallyOption, [NSNumber numberWithBool:YES], NSInferMappingModelAutomaticallyOption, nil];
				 
				 Lightweight migration will only work for a limited set of schema changes; consult "Core Data Model Versioning and Data Migration Programming Guide" for details.
				 
				 */
				NSLog(@"[%@ %@] Unresolved error %@, %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd), error, [error userInfo]);
				abort();
			}
		}
	} // end @synchronized
	
	return _persistentStoreCoordinator;
}

// Used to flush and reset the database.
-(void)deleteStore {
	NSFileManager *fm = [NSFileManager defaultManager];
	NSError *error;
	
	if (_persistentStoreCoordinator == nil) {
		NSString *storePath = [self storePath];
		
		if ([fm fileExistsAtPath:storePath] && [fm isDeletableFileAtPath:storePath]) {
			[fm removeItemAtPath:storePath error:&error];
		}
		
	} else {
		NSPersistentStoreCoordinator *storeCoordinator = [self persistentStoreCoordinator];
		
		for (NSPersistentStore *store in [storeCoordinator persistentStores]) {
			NSURL *storeURL = store.URL;
			NSString *storePath = storeURL.path;
			[storeCoordinator removePersistentStore:store error:&error];
			
			if ([fm fileExistsAtPath:storePath] && [fm isDeletableFileAtPath:storePath]) {
				[fm removeItemAtPath:storePath error:&error];
			}
		}
	}
	
	self.managedObjectContextForMainThread = nil;
	self.managedObjectContexts = nil;
	self.managedObjectModel = nil;
	self.persistentStoreCoordinator = nil;
	
}

-(NSMutableDictionary *)managedObjectContexts {
	if (_managedObjectContexts == nil) {
		_managedObjectContexts = [NSMutableDictionary dictionary];
	}
	return _managedObjectContexts;
}

/**
 * Returns the managed object model for the application.
 * If the model doesn't already exist, it is created from the application's model.
 */

// simply call this:
// return [NSManagedObjectModel mergedModelFromBundles:nil];

-(NSManagedObjectModel *)managedObjectModel {
	if (_managedObjectModel == nil) {
        /*
		NSString *modelPath = [[NSBundle mainBundle] pathForResource:@"Model" ofType:@"momd"];
		NSURL *modelURL = [NSURL fileURLWithPath:modelPath];
		_managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
         */
        _managedObjectModel = [NSManagedObjectModel mergedModelFromBundles:nil];
	}
	
	return _managedObjectModel;
}

#pragma mark -
#pragma mark Application's Documents directory
-(NSString *)storePath {
	return [[self applicationDocumentsDirectory] stringByAppendingPathComponent:[self databaseName]];
}

-(NSURL *)storeURL {
	return [NSURL fileURLWithPath:[self storePath]];
}

-(NSString *)databaseName {
    return DATABASE_NAME;
}

-(NSString *)applicationDocumentsDirectory {
	return [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
}


@end
