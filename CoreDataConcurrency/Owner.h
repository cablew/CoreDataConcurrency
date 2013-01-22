//
//  Owner.h
//  CoreDataConcurrency
//
//  Created by Kable Wang on 2013-1-20星期日.
//  Copyright (c) 2013年 Kable Wang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Car;

@interface Owner : NSManagedObject

@property (nonatomic, retain) NSString * first_name;
@property (nonatomic, retain) NSString * last_name;
@property (nonatomic, retain) NSSet *cars;
@end

@interface Owner (CoreDataGeneratedAccessors)

- (void)addCarsObject:(Car *)value;
- (void)removeCarsObject:(Car *)value;
- (void)addCars:(NSSet *)values;
- (void)removeCars:(NSSet *)values;

@end
