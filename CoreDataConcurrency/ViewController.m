//
//  ViewController.m
//  CoreDataConcurrency
//
//  Created by Kable Wang on 2013-1-19星期六.
//  Copyright (c) 2013年 Kable Wang. All rights reserved.
//

#import "ViewController.h"
#import "Owner+Concurrency.h"
#import "ManagedObjectContextManager.h"
#import "CarsViewController.h"

@interface ViewController ()

@property (nonatomic, strong) UIManagedDocument *dataBase;

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
}

- (IBAction)save:(id)sender {
    
    if ([Owner ownerWithFirstName:self.firstName.text lastName:self.lastName.text managedObjectContext:[[ManagedObjectContextManager contextManager] managedObjectContextForCurrentThread]]) {
        // persist subject created to CoreData store
        NSError *error;
        [[[ManagedObjectContextManager contextManager] managedObjectContextForCurrentThread] save:&error];
        [self performSegueWithIdentifier:@"show cars" sender:self];
        self.firstName.text = @"";
        self.lastName.text = @"";
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"show cars"]){
        [segue.destinationViewController setOwnerWithFirstName:self.firstName.text lastName:self.lastName.text];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
