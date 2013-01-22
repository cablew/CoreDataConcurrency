//
//  Car+Concurrency.h
//  CoreDataConcurrency
//
//  Created by Kable Wang on 2013-1-21星期一.
//  Copyright (c) 2013年 Kable Wang. All rights reserved.
//

#import "Car.h"

@interface Car (Concurrency)

+ (Car *)carWithBrand:(NSString *)brand model:(NSString *)model forOwner:(Owner *)owner inManagedObjectContext:(NSManagedObjectContext *)context;

@end
