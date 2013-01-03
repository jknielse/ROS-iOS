//
//  ServerCallPerformMovements.h
//  RobotPathDemo
//
//  Created by Jake on 13-01-02.
//  Copyright (c) 2013 __MyCompanyName__. All rights reserved.
//

#import "ServerCall.h"

@interface ServerCallPerformMovements : ServerCall
{
    void (^successblock)();
    void (^failureblock)(NSError *);
}

+(void) sendMovements:(NSArray *)movements success:(void(^)())success 
              failure:(void(^)(NSError*))failure;

@end
