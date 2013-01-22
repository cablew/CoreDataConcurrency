//
//  NSManagedObjectContext+Concurrency.m
//  CoreDataConcurrency
//
//  Created by Kable Wang on 2013-1-22星期二.
//  Copyright (c) 2013年 Kable Wang. All rights reserved.
//

#import "NSManagedObjectContext+Concurrency.h"

static NSManagedObjectContext *rootSavingContext = nil;
static NSManagedObjectContext *defaultManagedObjectContext_ = nil;

static NSString const * kMagicalRecordNSManagedObjectContextWorkingName = @"kNSManagedObjectContextWorkingName";
static NSString const * kMagicalRecordManagedObjectContextKey = @"MagicalRecord_NSManagedObjectContextForThreadKey";

@implementation NSManagedObjectContext (Concurrency)

+ (NSManagedObjectContext *) MR_defaultContext
{
	@synchronized (self)
	{
        NSAssert(defaultManagedObjectContext_ != nil, @"Default Context is nil! Did you forget to initialize the Core Data Stack?");
        return defaultManagedObjectContext_;
	}
}

+ (void) MR_setDefaultContext:(NSManagedObjectContext *)moc
{
    defaultManagedObjectContext_ = moc;
}

+ (void) MR_initializeDefaultContextWithCoordinator:(NSPersistentStoreCoordinator *)coordinator;
{
    if (defaultManagedObjectContext_ == nil)
    {
        NSManagedObjectContext *rootContext = [self MR_contextWithStoreCoordinator:coordinator];
        [self MR_setRootSavingContext:rootContext];
        
        NSManagedObjectContext *defaultContext = [self MR_newMainQueueContext];
        [self MR_setDefaultContext:defaultContext];
        
        [defaultContext setParentContext:rootContext];
    }
}

+ (void)MR_resetContextForCurrentThread
{
    [[NSManagedObjectContext MR_contextForCurrentThread] reset];
}

+ (NSManagedObjectContext *) MR_contextForCurrentThread;
{
	if ([NSThread isMainThread])
	{
		return [self MR_defaultContext];
	}
	else
	{
		NSMutableDictionary *threadDict = [[NSThread currentThread] threadDictionary];
		NSManagedObjectContext *threadContext = [threadDict objectForKey:kMagicalRecordManagedObjectContextKey];
		if (threadContext == nil)
		{
			threadContext = [self MR_contextWithParent:[NSManagedObjectContext MR_defaultContext]];
			[threadDict setObject:threadContext forKey:kMagicalRecordManagedObjectContextKey];
		}
		return threadContext;
	}
}

+ (NSManagedObjectContext *) MR_newMainQueueContext;
{
    NSManagedObjectContext *context = [[self alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
    return context;
}

+ (NSManagedObjectContext *) MR_rootSavingContext;
{
    return rootSavingContext;
}

+ (void) MR_setRootSavingContext:(NSManagedObjectContext *)context;
{
    if (rootSavingContext)
    {
        [[NSNotificationCenter defaultCenter] removeObserver:rootSavingContext];
    }
    
    rootSavingContext = context;
    [context MR_obtainPermanentIDsBeforeSaving];
    [rootSavingContext setMergePolicy:NSMergeByPropertyObjectTrumpMergePolicy];
    [rootSavingContext MR_setWorkingName:@"BACKGROUND SAVING (ROOT)"];
    NSLog(@"Set Root Saving Context: %@", rootSavingContext);
}

+ (NSManagedObjectContext *) MR_contextWithStoreCoordinator:(NSPersistentStoreCoordinator *)coordinator;
{
	NSManagedObjectContext *context = nil;
    if (coordinator != nil)
	{
        context = [self MR_contextWithoutParent];
        [context performBlockAndWait:^{
            [context setPersistentStoreCoordinator:coordinator];
        }];
        
        NSLog(@"-> Created Context %@", [context MR_workingName]);
    }
    return context;
}

- (void) MR_obtainPermanentIDsBeforeSaving;
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(MR_contextWillSave:)
                                                 name:NSManagedObjectContextWillSaveNotification
                                               object:self];
    
    
}

+ (NSManagedObjectContext *) MR_contextWithoutParent;
{
    NSManagedObjectContext *context = [[self alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
    return context;
}

+ (NSManagedObjectContext *) MR_contextWithParent:(NSManagedObjectContext *)parentContext;
{
    NSManagedObjectContext *context = [self MR_contextWithoutParent];
    [context setParentContext:parentContext];
    [context MR_obtainPermanentIDsBeforeSaving];
    return context;
}

- (void) MR_contextWillSave:(NSNotification *)notification
{
    NSManagedObjectContext *context = [notification object];
    NSSet *insertedObjects = [context insertedObjects];
    
    if ([insertedObjects count])
    {
        NSLog(@"Context %@ is about to save. Obtaining permanent IDs for new %lu inserted objects", [context MR_workingName], (unsigned long)[insertedObjects count]);
        NSError *error = nil;
        BOOL success = [context obtainPermanentIDsForObjects:[insertedObjects allObjects] error:&error];
        if (!success)
        {
            //[MagicalRecord handleErrors:error];
        }
    }
}

- (void) MR_setWorkingName:(NSString *)workingName;
{
    [[self userInfo] setObject:workingName forKey:kMagicalRecordNSManagedObjectContextWorkingName];
}

- (NSString *) MR_workingName;
{
    NSString *workingName = [[self userInfo] objectForKey:kMagicalRecordNSManagedObjectContextWorkingName];
    if (nil == workingName)
    {
        workingName = @"UNNAMED";
    }
    return workingName;
}

#pragma marks - save related block

- (void) MR_saveToPersistentStoreAndWait;
{
    [self MR_saveWithOptions:MRSaveParentContexts | MRSaveSynchronously completion:nil];
}

- (void)MR_saveWithOptions:(MRSaveContextOptions)mask completion:(MRSaveCompletionHandler)completion;
{
    BOOL syncSave           = ((mask & MRSaveSynchronously) == MRSaveSynchronously);
    BOOL saveParentContexts = ((mask & MRSaveParentContexts) == MRSaveParentContexts);
    
    if (![self hasChanges]) {
        NSLog(@"NO CHANGES IN ** %@ ** CONTEXT - NOT SAVING", [self MR_workingName]);
        
        if (completion)
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                completion(NO, nil);
            });
        }
        
        return;
    }
    
    NSLog(@"→ Saving %@", [self MR_description]);
    NSLog(@"→ Save Parents? %@", @(saveParentContexts));
    NSLog(@"→ Save Synchronously? %@", @(syncSave));
    
    id saveBlock = ^{
        NSError *error = nil;
        BOOL     saved = NO;
        
        @try
        {
            saved = [self save:&error];
        }
        @catch(NSException *exception)
        {
            NSLog(@"Unable to perform save: %@", (id)[exception userInfo] ? : (id)[exception reason]);
        }
        
        @finally
        {
            if (!saved) {
                //[MagicalRecord handleErrors:error];
                
                if (completion) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        completion(saved, error);
                    });
                }
            } else {
                // If we're the default context, save to disk too (the user expects it to persist)
                if (self == [[self class] MR_defaultContext]) {
                    [[[self class] MR_rootSavingContext] MR_saveWithOptions:MRSaveSynchronously completion:completion];
                }
                // If we're saving parent contexts, do so
                else if ((YES == saveParentContexts) && [self parentContext]) {
                    [[self parentContext] MR_saveWithOptions:MRSaveSynchronously | MRSaveParentContexts completion:completion];
                }
                // If we are not the default context (And therefore need to save the root context, do the completion action if one was specified
                else {
                    NSLog(@"→ Finished saving: %@", [self MR_description]);
                    
                    if (completion) {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            completion(saved, error);
                        });
                    }
                }
            }
        }
    };
    
    if (YES == syncSave) {
        [self performBlockAndWait:saveBlock];
    } else {
        [self performBlock:saveBlock];
    }
}


- (NSString *) MR_description;
{
    NSString *contextLabel = [NSString stringWithFormat:@"*** %@ ***", [self MR_workingName]];
    NSString *onMainThread = [NSThread isMainThread] ? @"*** MAIN THREAD ***" : @"*** BACKGROUND THREAD ***";
    
    return [NSString stringWithFormat:@"<%@ (%p): %@> on %@", NSStringFromClass([self class]), self, contextLabel, onMainThread];
}

@end
