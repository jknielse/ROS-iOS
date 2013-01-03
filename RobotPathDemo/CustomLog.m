//
//  Log.m
//  RobotPathDemo
//
//  Created by Jake on 13-01-02.
//  Copyright (c) 2013 __MyCompanyName__. All rights reserved.
//

#import "CustomLog.h"
#import "LogConfig.h"

@implementation CustomLog

+(void)logMessage:(NSString *)message WithLogLevel:(LogLevel)level
{
    if (CURRENT_LOG_LEVEL >= level) {
        if (level == LOG_LEVEL_ERROR) {
            NSLog(@"%@%@", @"ERROR: ",message);
        }
        else if (level == LOG_LEVEL_WARNING) {
            NSLog(@"%@%@", @"WARNING: ",message);
        }
        else if (level == LOG_LEVEL_INFO) {
            NSLog(@"%@%@", @"INFO: ",message);
        }
        else if (level == LOG_LEVEL_DEBUG) {
            NSLog(@"%@%@", @"DEBUG: ",message);
        }
        else {
            NSLog(@"LOG LEVEL %@: %@", [NSNumber numberWithInt:level] ,message);
        }
    }
}

@end
