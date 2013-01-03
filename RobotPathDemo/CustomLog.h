//
//  Log.h
//  RobotPathDemo
//
//  Created by Jake on 13-01-02.
//  Copyright (c) 2013 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum LogLevel {
    LOG_LEVEL_ERROR = 0,
    LOG_LEVEL_WARNING = 10,
    LOG_LEVEL_INFO = 20,
    LOG_LEVEL_DEBUG = 30,
} LogLevel;

@interface CustomLog : NSObject

+(void) logMessage:(NSString *)message WithLogLevel:(LogLevel) level;

@end
