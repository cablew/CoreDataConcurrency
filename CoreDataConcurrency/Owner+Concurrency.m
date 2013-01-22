//
//  Owner+Concurrency.m
//  CoreDataConcurrency
//
//  Created by Kable Wang on 2013-1-20星期日.
//  Copyright (c) 2013年 Kable Wang. All rights reserved.
//

#import "Owner+Concurrency.h"

@implementation Owner (Concurrency)

+ (Owner *)ownerWithFirstName:(NSString *)firstName lastName:(NSString *)lastName managedObjectContext:(NSManagedObjectContext *)context
{
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"Owner"];
    fetchRequest.predicate = [NSPredicate predicateWithFormat:@"first_name = %@ AND last_name = %@", firstName, lastName];
    
    NSError *error = nil;
    NSArray *matches = [context executeFetchRequest:fetchRequest error:&error];
    
    if (matches.count == 1) {
        return [matches lastObject];
    }
    
    Owner *owner = [NSEntityDescription insertNewObjectForEntityForName:@"Owner" inManagedObjectContext:context];
    owner.first_name = firstName;
    owner.last_name = lastName;
    
    return owner;
}

@end
