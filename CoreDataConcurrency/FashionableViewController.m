//
//  FashionableViewController.m
//  CoreDataConcurrency
//
//  Created by Kable Wang on 2013-1-22星期二.
//  Copyright (c) 2013年 Kable Wang. All rights reserved.
//

#import "FashionableViewController.h"
#import "Owner+Concurrency.h"
#import "NSManagedObjectContext+Concurrency.h"
#import "ManagedObjectContextManager.h"
#import "CarsFashionableViewController.h"

@interface FashionableViewController ()

@end

@implementation FashionableViewController

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
    
    [NSManagedObjectContext MR_initializeDefaultContextWithCoordinator:[[ManagedObjectContextManager contextManager] persistentStoreCoordinator]];
}

- (IBAction)save:(id)sender
{
    if ([Owner ownerWithFirstName:self.firstName.text lastName:self.lastName.text managedObjectContext:[NSManagedObjectContext MR_defaultContext]]) {
        [[NSManagedObjectContext MR_defaultContext] MR_saveToPersistentStoreAndWait];
        [self performSegueWithIdentifier:@"show cars fashionable way" sender:self];
        self.firstName.text = @"";
        self.lastName.text = @"";
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"show cars fashionable way"]){
        [segue.destinationViewController setOwnerWithFirstName:self.firstName.text lastName:self.lastName.text];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
