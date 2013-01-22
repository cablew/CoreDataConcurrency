//
//  Helper.m
//  CoreDataConcurrency
//
//  Created by Kable Wang on 2013-1-22星期二.
//  Copyright (c) 2013年 Kable Wang. All rights reserved.
//

#import "Helper.h"

@interface Helper ()

@property (nonatomic, strong) NSArray *carBrands;
@property (nonatomic, strong) NSArray *carModels;

@end

@implementation Helper

- (NSDictionary *)newCar
{
    NSUInteger randomBrand = arc4random() % self.carBrands.count;
	NSUInteger randomModel = arc4random() % self.carModels.count;
    return [NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:[self.carBrands objectAtIndex:randomBrand], [self.carModels objectAtIndex:randomModel], nil] forKeys:[NSArray arrayWithObjects:@"brand", @"model", nil]];
}

- (NSArray *)carBrands
{
    if (_carBrands == nil) {
        _carBrands = [NSArray arrayWithObjects:@"Honda", @"BMW", @"Benz", @"Buick", @"Ford", @"Mazda", @"Volkswagen", @"Ferrari", @"Aston Martin", nil];
    }
    return _carBrands;
}

- (NSArray *)carModels
{
    if (_carModels == nil) {
        _carModels = [NSArray arrayWithObjects:@"123", @"X6", @"S500", @"Enclave", @"Focus", @"6", @"BORA", @"Enzo", @"DB9", nil];
    }
    return _carModels;
}


@end
