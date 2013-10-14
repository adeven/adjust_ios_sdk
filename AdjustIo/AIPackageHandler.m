//
//  AIPackageHandler.m
//  AdjustIosApp
//
//  Created by Christian Wellenbrock on 2013-07-03.
//  Copyright (c) 2013 adeven. All rights reserved.
//

#import "AIPackageHandler.h"
#import "AIRequestHandler.h"
#import "AIActivityPackage.h"
#import "AILogger.h"
#import "NSURL+AIAdditions.h"

static NSString   * const kPackageQueueFilename = @"AdjustIoPackageQueue";
static const char * const kInternalQueueName    = "io.adjust.PackageQueue";


#pragma mark - private
@interface AIPackageHandler()

@property (nonatomic) dispatch_queue_t internalQueue;
@property (nonatomic) dispatch_semaphore_t sendingSemaphore;
@property (nonatomic, retain) AIRequestHandler *requestHandler;
@property (nonatomic, retain) NSMutableArray *packageQueue;
@property (nonatomic, assign, getter = isPaused) BOOL paused;

@end


#pragma mark -
@implementation AIPackageHandler

- (id)init {
    self = [super init];
    if (self == nil) return nil;

    self.internalQueue = dispatch_queue_create(kInternalQueueName, DISPATCH_QUEUE_SERIAL);

    dispatch_async(self.internalQueue, ^{
        [self initInternal];
    });

    return self;
}

- (void)addPackage:(AIActivityPackage *)package {
    dispatch_async(self.internalQueue, ^{
        [self addInternal:package];
    });
}

- (void)sendFirstPackage {
    dispatch_async(self.internalQueue, ^{
        [self sendFirstInternal];
    });
}

- (void)sendNextPackage {
    dispatch_async(self.internalQueue, ^{
        [self sendNextInternal];
    });
}

- (void)closeFirstPackage {
    dispatch_semaphore_signal(self.sendingSemaphore);
}

- (void)pauseSending {
    self.paused = YES;
}

- (void)resumeSending {
    self.paused = NO;
}


#pragma mark - internal
- (void)initInternal {
    self.requestHandler = [AIRequestHandler handlerWithPackageHandler:self];
    self.sendingSemaphore = dispatch_semaphore_create(1);
    [self readPackageQueue];
}

- (void)addInternal:(AIActivityPackage *)newPackage {
    [self.packageQueue addObject:newPackage];
    [AILogger debug:@"Added package %d (%@)", self.packageQueue.count, newPackage];
    [AILogger verbose:@"%@", newPackage.extendedString];

    [self writePackageQueue];
}

- (void)sendFirstInternal {
    if (self.packageQueue.count == 0) return;

    if (self.isPaused) {
        [AILogger debug:@"Package handler is paused"];
        return;
    }

    if (dispatch_semaphore_wait(self.sendingSemaphore, DISPATCH_TIME_NOW) != 0) {
        [AILogger verbose:@"Package handler is already sending"];
        return;
    }

    AIActivityPackage *activityPackage = [self.packageQueue objectAtIndex:0];
    if (![activityPackage isKindOfClass:[AIActivityPackage class]]) {
        [AILogger error:@"Failed to read activity package"];
        [self sendNextInternal];
        return;
    }

    [self.requestHandler sendPackage:activityPackage];
}

- (void)sendNextInternal {
    [self.packageQueue removeObjectAtIndex:0];
    [self writePackageQueue];
    dispatch_semaphore_signal(self.sendingSemaphore);
    [self sendFirstInternal];
}

#pragma mark - private
- (void)readPackageQueue {
    @try {
        NSString *filename = [self packageQueueFilename];
        id object = [NSKeyedUnarchiver unarchiveObjectWithFile:filename];
        if ([object isKindOfClass:[NSArray class]]) {
            self.packageQueue = object;
            [AILogger debug:@"Package handler read %d packages", self.packageQueue.count];
            return;
        } else if (object == nil) {
            [AILogger verbose:@"Package queue file not found"];
        } else {
            [AILogger error:@"Failed to read package queue"];
        }
    } @catch (NSException *exception) {
        [AILogger error:@"Failed to read package queue (%@)", exception];
    }

    // start with a fresh package queue in case of any exception
    self.packageQueue = [NSMutableArray array];
}

- (void)writePackageQueue {
    NSString *filename = [self packageQueueFilename];
    BOOL result = [NSKeyedArchiver archiveRootObject:self.packageQueue toFile:filename];
    if (result == YES) {
        // set flag to not backup to iCloud
        [NSURL ai_addSkipBackupAttributeToItemAtFilePath:filename];
        [AILogger debug:@"Package handler wrote %d packages", self.packageQueue.count];
    } else {
        [AILogger error:@"Failed to write package queue"];
    }
}

- (NSString *)packageQueueFilename {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *path = [paths objectAtIndex:0];
    NSString *filename = [path stringByAppendingPathComponent:kPackageQueueFilename];
    return filename;
}

@end
