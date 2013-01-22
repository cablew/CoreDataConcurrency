//
//  GCDQueueManager.m
//  CoreDataConcurrency
//
//  Created by Kable Wang on 2013-1-21星期一.
//  Copyright (c) 2013年 Kable Wang. All rights reserved.
//

#import "GCDQueueManager.h"

static dispatch_queue_t backgroundQueue_;
static dispatch_queue_t backgroundQueue1_;

@implementation GCDQueueManager

+ (dispatch_queue_t)backgroundQueue
{
    @synchronized (self) {
        if (backgroundQueue_ == nil) {
            backgroundQueue_ = dispatch_queue_create("com.kaible.CoreDataConcurrency.background", NULL);
        }
    }
    return backgroundQueue_;
}

+ (dispatch_queue_t)backgroundQueue1
{
    @synchronized (self) {
        if (backgroundQueue1_ == nil) {
            backgroundQueue1_ = dispatch_queue_create("com.kaible.CoreDataConcurrency.background1", NULL);
        }
    }
    return backgroundQueue1_;
}

@end
