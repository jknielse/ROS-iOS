//
//  ServerCallPerformMovements.m
//  RobotPathDemo
//
//  Created by Jake on 13-01-02.
//  Copyright (c) 2013 __MyCompanyName__. All rights reserved.
//

#import "ServerCallPerformMovements.h"
#import "ASIHTTPRequest.h"

@implementation ServerCallPerformMovements

+(void)sendMovements:(NSArray *)movements success:(void (^)())success failure:(void (^)(NSError *))failure
{
    ServerCallPerformMovements *newCall = [[self alloc] init];
    newCall->successblock = success;
    newCall->failureblock = failure;
    
#warning Get rid of these, they leak memory. Use ARC instead.
    NSDictionary *dictionary = [NSDictionary dictionaryWithObjectsAndKeys:movements,@"movements",nil];
    [newCall sendGETRequestForLocation:@"move/performmovements" WithRequestKeysAndValues:dictionary];
}

-(void)success
{
    successblock();
}

-(void)failure
{
    failureblock([[self request] error]);
}

@end
