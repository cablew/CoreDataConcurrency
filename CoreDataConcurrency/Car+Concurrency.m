//
//  Car+Concurrency.m
//  CoreDataConcurrency
//
//  Created by Kable Wang on 2013-1-21星期一.
//  Copyright (c) 2013年 Kable Wang. All rights reserved.
//

#import "Car+Concurrency.h"

@implementation Car (Concurrency)

+ (Car *)carWithBrand:(NSString *)brand model:(NSString *)model forOwner:(Owner *)owner inManagedObjectContext:(NSManagedObjectContext *)context
{
    Car *car = [NSEntityDescription insertNewObjectForEntityForName:@"Car" inManagedObjectContext:context];
    car.brand = brand;
    car.model = model;
    car.owner = owner;
    
    return car;
}

@end
