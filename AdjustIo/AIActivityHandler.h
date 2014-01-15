//
//  AIActivityHandler.h
//  AdjustIosApp
//
//  Created by Christian Wellenbrock on 2013-07-01.
//  Copyright (c) 2013 adeven. All rights reserved.
//

#import "AdjustIo.h"

@interface AIActivityHandler : NSObject

@property (nonatomic, copy) NSString *environment;
@property (nonatomic, assign) BOOL bufferEvents;
@property (nonatomic, assign) BOOL macAddressMd5TrackingEnabled;

+ (AIActivityHandler *)handlerWithAppToken:(NSString *)appToken;
- (id)initWithAppToken:(NSString *)appToken;
- (void)setSdkPrefix:(NSString *)sdkPrefix;

- (void)trackSubsessionStart;
- (void)trackSubsessionEnd;

- (void)trackEvent:(NSString *)eventToken
    withParameters:(NSDictionary *)parameters;

- (void)trackRevenue:(double)amount
            forEvent:(NSString *)eventToken
      withParameters:(NSDictionary *)parameters;

@end
