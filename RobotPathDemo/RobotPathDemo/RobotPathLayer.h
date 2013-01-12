//
//  HelloWorldLayer.h
//  RobotPathDemo
//
//  Created by Jake on 12-12-22.
//  Copyright __MyCompanyName__ 2012. All rights reserved.
//

#import <GameKit/GameKit.h>

// When you import this file, you import all the cocos2d classes
#import "cocos2d.h"

// HelloWorldLayer
@interface RobotPathLayer : CCLayer
{
    BOOL LinesEnabled;
    BOOL LineStarted;
    CCPointArray *robotPath;
    CCSprite *robot;
}

// returns a CCScene that contains the HelloWorldLayer as the only child
+(CCScene *) scene;

@end
