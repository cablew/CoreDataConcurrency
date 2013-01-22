//
//  GCDQueueManager.h
//  CoreDataConcurrency
//
//  Created by Kable Wang on 2013-1-21星期一.
//  Copyright (c) 2013年 Kable Wang. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GCDQueueManager : NSObject

+ (dispatch_queue_t)backgroundQueue;

+ (dispatch_queue_t)backgroundQueue1;

@end
