//
//  FetchRequestTableViewController.h
//  CoreDataConcurrency
//
//  Created by Kable Wang on 2013-1-22星期二.
//  Copyright (c) 2013年 Kable Wang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>

@interface FetchRequestTableViewController : UIViewController

@property (weak, nonatomic) UITableView *tableView;

@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;

// for FetchedResultsController auto update feature
@property (nonatomic) BOOL suspendAutomaticTrackingOfChangesInManagedObjectContext;
@property (nonatomic) BOOL beganUpdates;

// Set to YES to get some debugging output in the console.
@property (nonatomic) BOOL debug;

- (void)performFetch;

@end
