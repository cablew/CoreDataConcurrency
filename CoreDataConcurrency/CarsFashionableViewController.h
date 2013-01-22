//
//  CarsFashionableViewController.h
//  CoreDataConcurrency
//
//  Created by Kable Wang on 2013-1-22星期二.
//  Copyright (c) 2013年 Kable Wang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FetchRequestTableViewController.h"

@interface CarsFashionableViewController : FetchRequestTableViewController;

@property (weak, nonatomic) IBOutlet UILabel *ownerName;
@property (weak, nonatomic) IBOutlet UITableView *realTableView;

- (void)setOwnerWithFirstName:(NSString *)firstName lastName:(NSString *)lastName;

@end
