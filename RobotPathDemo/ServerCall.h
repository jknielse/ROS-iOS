//
//  ServerCall.h
//  RobotPathDemo
//
//  Created by Jake on 13-01-02.
//  Copyright (c) 2013 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ASIHTTPRequestDelegate.h"

@interface ServerCall : NSObject <ASIHTTPRequestDelegate>
{
@private
    BOOL completed;
    
    NSInteger attemptCounter;
    NSString *uuid;
    ASIHTTPRequest *request;
}

-(void) sendGETRequestForLocation:(NSString*)location WithRequestKeysAndValues:(NSDictionary *)dict;
-(void) sendDELETERequestForLocation:(NSString*)location;
-(void) sendPOSTRequestForLocation:(NSString*)location WithBodyData:(NSData*)data;

-(void) success;
-(void) failure;

@property(readonly)BOOL completed;
@property(retain,readonly)ASIHTTPRequest* request;

@end
