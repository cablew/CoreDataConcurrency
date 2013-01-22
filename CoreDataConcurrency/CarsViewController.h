//
//  CarsViewController.h
//  CoreDataConcurrency
//
//  Created by Kable Wang on 2013-1-21星期一.
//  Copyright (c) 2013年 Kable Wang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>
#import "FetchRequestTableViewController.h"

@interface CarsViewController : FetchRequestTableViewController

@property (weak, nonatomic) IBOutlet UITableView *realTableView;
@property (weak, nonatomic) IBOutlet UILabel *ownerName;

- (void)setOwnerWithFirstName:(NSString *)firstName lastName:(NSString *)lastName;

@end
