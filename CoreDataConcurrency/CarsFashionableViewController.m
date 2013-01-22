//
//  CarsFashionableViewController.m
//  CoreDataConcurrency
//
//  Created by Kable Wang on 2013-1-22星期二.
//  Copyright (c) 2013年 Kable Wang. All rights reserved.
//

#import "CarsFashionableViewController.h"
#import "Helper.h"
#import "NSManagedObjectContext+Concurrency.h"
#import "Car+Concurrency.h"
#import "GCDQueueManager.h"
#import "Owner+Concurrency.h"

enum {
    singleThreadTest,
    dualThreadTest
};

@interface CarsFashionableViewController ()

@property (strong, nonatomic) NSString *firstName;
@property (strong, nonatomic) NSString *lastName;
@property (nonatomic, strong) NSTimer *carCreaterTimer;
@property (nonatomic, strong) NSTimer *carEraserTimer;
@property (nonatomic) NSInteger testType;
@property (strong, nonatomic) Helper *helper;
@property (strong, nonatomic) NSMutableArray *cars;

@end

@implementation CarsFashionableViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    // connect the symbol-like table view to the real table view
    self.tableView = self.realTableView;
    
    // setup fetched results controller
    [self setupFetchedResultsController];
    
    // setup environment for testing
    self.testType = singleThreadTest;
}

// setup table view title - owner name
- (void)setOwnerWithFirstName:(NSString *)firstName lastName:(NSString *)lastName
{
    self.firstName = firstName;
    self.lastName = lastName;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.ownerName.text = [NSString stringWithFormat:@"%@ %@", self.firstName, self.lastName];
    
    // perform fetch request
    [self performFetch];
    
    [self performTest];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [self.carCreaterTimer invalidate];
    [self.carEraserTimer invalidate];
}

#pragma marks - table view related block

- (void)setupFetchedResultsController
{
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Car"];
    request.predicate = [NSPredicate predicateWithFormat:@"owner.first_name = %@ AND owner.last_name = %@", self.firstName, self.lastName];
    request.sortDescriptors = [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"brand" ascending:NO]];
    [request setFetchBatchSize:20];
    NSManagedObjectContext *context = [NSManagedObjectContext MR_defaultContext];
    self.fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:request managedObjectContext:context sectionNameKeyPath:nil cacheName:nil];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [[self.fetchedResultsController sections] count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSInteger rowNumber = [[[self.fetchedResultsController sections] objectAtIndex:section] numberOfObjects];
    if (rowNumber > 10) {
        [self nextTestStep];
    }
    return rowNumber;
}

-(void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
	
	Car *car = [self.fetchedResultsController objectAtIndexPath:indexPath];
	cell.textLabel.text = [NSString stringWithFormat:@"%@ %@", car.brand, car.model];
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	
	static NSString *CellIdentifier = @"CarCell";
	
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
	
	if (cell == nil) {
		cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
	}
    
	[self configureCell:cell atIndexPath:indexPath];
    
	return cell;
}
#pragma marks - testing related block

- (void)nextTestStep
{
    if (![[NSThread currentThread] isMainThread]) {
        NSLog(@"@nextTestStep. note: this is not main thread");
    }
    [self.carCreaterTimer invalidate];
    self.carEraserTimer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(repeatDeleteTask) userInfo:nil repeats:YES];
}

- (void)nextTest
{
    if (![[NSThread currentThread] isMainThread]) {
        NSLog(@"@nextTest. note: this is not main thread");
    }
    [self.carEraserTimer invalidate];
    if (self.testType == singleThreadTest) {
        self.testType = dualThreadTest;
    } else {
        self.testType = singleThreadTest;
    }
    [self performTest];
}

- (void)performTest
{
    if (![[NSThread currentThread] isMainThread]) {
        NSLog(@"@performTest. note: this is not main thread");
    }
    if (self.testType == singleThreadTest) {
        self.carCreaterTimer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(repeatCreateTask) userInfo:nil repeats:YES];
    } else {
        self.carCreaterTimer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(repeatCreateTask1) userInfo:nil repeats:YES];
    }
}

- (void)repeatCreateTask
{
    dispatch_async([GCDQueueManager backgroundQueue], ^{
        [self appendCar];
    });
}

- (void)repeatCreateTask1
{
    dispatch_async([GCDQueueManager backgroundQueue1], ^{
        [self appendCar];
    });
}

- (void)repeatDeleteTask
{
    dispatch_async([GCDQueueManager backgroundQueue], ^{
        [self deleteCar];
    });
}

- (void)appendCar
{
	NSDictionary *carInfo = [self.helper newCar];
    NSManagedObjectContext *context = [NSManagedObjectContext MR_contextForCurrentThread];
	Owner *owner = [Owner ownerWithFirstName:self.firstName lastName:self.lastName managedObjectContext:context];
	Car *car = [Car carWithBrand:[carInfo objectForKey:@"brand"] model:[carInfo objectForKey:@"model"] forOwner:owner inManagedObjectContext:context];
    [context MR_saveToPersistentStoreAndWait];
    [self.cars addObject:car.objectID];
    NSLog(@"Create car brand: %@, model: %@", car.brand, car.model);
}

- (void)deleteCar
{
    if (self.cars.count > 0) {
        //NSLog(@"cars: %@", self.cars);
        NSManagedObjectContext *context = [NSManagedObjectContext MR_contextForCurrentThread];
        Car *car = (Car *)[context objectWithID:[self.cars lastObject]];
        NSLog(@"Delete car brand: %@, model: %@", car.brand, car.model);
        [context deleteObject:car];
        [context MR_saveToPersistentStoreAndWait];
        [self.cars removeLastObject];
    } else {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self nextTest];
        });
    }
}

- (Helper *)helper
{
    if (_helper == nil) {
        _helper = [Helper alloc];
    }
    return _helper;
}

- (NSMutableArray *)cars
{
    if (_cars == nil) {
        _cars = [NSMutableArray array];
    }
    return _cars;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
