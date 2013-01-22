//
//  Car.h
//  CoreDataConcurrency
//
//  Created by Kable Wang on 2013-1-21星期一.
//  Copyright (c) 2013年 Kable Wang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Owner;

@interface Car : NSManagedObject

@property (nonatomic, retain) NSString * model;
@property (nonatomic, retain) NSString * brand;
@property (nonatomic, retain) NSString * type;
@property (nonatomic, retain) Owner *owner;

@end
