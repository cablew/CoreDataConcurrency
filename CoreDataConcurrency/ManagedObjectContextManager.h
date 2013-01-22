//
//  ManagedObjectContextManager.h
//  CoreDataConcurrency
//
//  Created by Kable Wang on 2013-1-19星期六.
//  Copyright (c) 2013年 Kable Wang. All rights reserved.
//

#import <CoreData/CoreData.h>

// The naming is not appropriate, XXManager is XX's subclass? Come on..
// Plus, apple doc says:
/*
 Subclassing Notes
 You are strongly discouraged from subclassing NSManagedObjectContext. The change tracking and undo management mechanisms are highly optimized and hence intricate and delicate. Interposing your own additional logic that might impact processPendingChanges can have unforeseen consequences. In situations such as store migration, Core Data will create instances of NSManagedObjectContext for its own use. Under these circumstances, you cannot rely on any features of your custom subclass. Any NSManagedObject subclass must always be fully compatible with NSManagedObjectContext (that is, it cannot rely on features of a subclass of NSManagedObjectContext).
 */

// Are you absolutely sure what you are doing here?

@interface ManagedObjectContextManager : NSManagedObjectContext

+ (ManagedObjectContextManager *)contextManager;
- (NSManagedObjectContext *)managedObjectContextForCurrentThread;
@end
