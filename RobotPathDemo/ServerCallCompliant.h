//
//  ServerCallCompliant.h
//  RobotPathDemo
//
//  Created by Jake on 13-01-02.
//  Copyright (c) 2013 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol ServerCallCompliant <NSObject>

//This method should return a dictionary who's members are all of
//JSONizable base types (i.e. NSArrays, NSDictionaries, and NSStrings)
-(NSDictionary *)makeJSONCompatible;

@end
