//
//  HelloWorldLayer.m
//  RobotPathDemo
//
//  Created by Jake on 12-12-22.
//  Copyright __MyCompanyName__ 2012. All rights reserved.
//


// Import the interfaces
#import "RobotPathLayer.h"

// Needed to obtain the Navigation Controller
#import "AppDelegate.h"
#import "Converter.h"
#import "OpenGL_Internal.h"
#import <GLKit/GLKit.h>
#import "ServerCallPerformMovements.h"

#pragma mark - HelloWorldLayer

#define ROBOT_IMAGE_NAME @"UpArrow.png"
#define HITBOX_RADIUS 34
#define MIN_POINT_DISTANCE 15.0
#define MOVEMENT_SPEED 100.0
#define ROTATION_SPEED 120.0
#define RETURN_TIME 0.4

// HelloWorldLayer implementation
@implementation RobotPathLayer

// Helper class method that creates a Scene with the HelloWorldLayer as the only child.
+(CCScene *) scene
{
	// 'scene' is an autorelease object.
	CCScene *scene = [CCScene node];
	
	// 'layer' is an autorelease object.
	RobotPathLayer *layer = [RobotPathLayer node];
	
	// add layer as a child to scene
	[scene addChild: layer];
	
	// return the scene
	return scene;
}

// on "init" you need to initialize your instance
-(id) init
{
	// always call "super" init
	if( (self=[super init]) ) {
        
        //Create the robot object
        CGSize winSize = [[CCDirector sharedDirector] winSize];
        robot = [CCSprite spriteWithFile:ROBOT_IMAGE_NAME];
        robot.position = ccp(winSize.width/2.0, robot.contentSize.height/2.0);
        
        robotPath = [[CCPointArray alloc] init];
        
        LinesEnabled = YES;
        LineStarted = NO;
        
        [self addChild:robot];
        [self setIsTouchEnabled:YES];
    }
	return self;
}


-(void)draw{
    [self drawLine:robotPath];
}

-(void)drawLine:(CCPointArray *)points
{
    if ([points count] >= 2) {
        CGPoint start = [points getControlPointAtIndex:0];
        CGPoint end;
        glLineWidth(6.0);
        glEnable(GL_LINE_SMOOTH);
        glEnable(GL_BLEND);
        glBlendFunc (GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
        glHint (GL_LINE_SMOOTH_HINT, GL_NICEST);
        for (int i = 1; i < [points count]; i++) {
            end = [points getControlPointAtIndex:i];
            ccDrawLine(start, end);
            start = end;
        }
    }
}

-(void)ccTouchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    if (LinesEnabled) {
        //Remove all items from the path object
        while ([robotPath count]) {
            [robotPath removeControlPointAtIndex:0];
        }
        UITouch *touch = [touches anyObject];
        
        CGPoint touchPoint = [Converter iOSToCoco:[touch locationInView:[touch view]]];
        
        CGPoint robotPoint = robot.position;
        
        //We first need to check that the person drawing the line actually
        //started on the robot:
        
        if ([Converter DistanceBetween:robotPoint:touchPoint] < HITBOX_RADIUS) {
            [robotPath addControlPoint:robotPoint];
            [robotPath addControlPoint:touchPoint];
            LineStarted = YES;
        }
    }
}

-(void)ccTouchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    if (LinesEnabled && LineStarted) {
        UITouch *touch = [touches anyObject];
        CGPoint touchPoint = [Converter iOSToCoco:[touch locationInView:[touch view]]];
        
        if ([Converter DistanceBetween:touchPoint :[robotPath getControlPointAtIndex:[robotPath count]-1]] > MIN_POINT_DISTANCE) {
            [robotPath addControlPoint:[Converter iOSToCoco:[touch locationInView:[touch view]]]];
        }
    }
}

-(void)ccTouchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    if (LinesEnabled && LineStarted) {
        LinesEnabled = NO;
        UITouch *touch = [touches anyObject];
        [robotPath addControlPoint:[Converter iOSToCoco:[touch locationInView:[touch view]]]];
        
        //We're just going to touch up the path a little bit to make it more
        //noise-free.
        int cutPoints = 1;
        if ([robotPath count] > 20) {
            for (int i = 0; i < cutPoints; i++) {
                [robotPath removeControlPointAtIndex:1];
                [robotPath removeControlPointAtIndex:[robotPath count] - 2];
            }
        }
        
        [self commitPath];
    }
    LineStarted = NO;
}

-(void)commitPath
{
    //Interpolate a smoother path for robotPath:
    robotPath = [Converter CubicInterpolation:robotPath :3];
    
    //Tell the server what we're doing
    [ServerCallPerformMovements sendMovements:[Converter PathToMovements:robotPath] success:^{
        //Now we convert the robot path into CCActions:
        NSMutableArray *actionArray = [[NSMutableArray alloc] init];
        CGPoint prevPoint = [robotPath getControlPointAtIndex:0];
        CGFloat prevAngle = 0.0;
        
        for (int i = 1; i < [robotPath count]; i++)
        {
            CGPoint point = [robotPath getControlPointAtIndex:i];
            
            CGFloat angle = [Converter AngleOf:prevPoint:point];
            NSLog(@"Angle: %f", angle);
            
            CGFloat diff = ABS(angle - prevAngle);
            if (diff > 180.0)
                diff = 360.0-diff;
            
            CGFloat duration = [Converter DistanceBetween:prevPoint :point]/ MOVEMENT_SPEED + diff/ROTATION_SPEED;
            
            id actionMove = [CCMoveTo actionWithDuration:duration
                                                position:point];
            
            id actionRotate = [CCRotateTo actionWithDuration:duration angle:angle];
            
            [actionArray addObject:[CCSpawn actionOne:actionMove two:actionRotate]];
            
            [actionArray addObject:[CCCallFuncN actionWithTarget:self
                                                        selector:@selector(removePoint)]];
            
            prevAngle = angle;
            prevPoint = point;
        }
        
        id actionMoveDone = [CCCallFuncN actionWithTarget:self
                                                 selector:@selector(moveDone)];
        [actionArray addObject:actionMoveDone];
        
        [robot runAction:[CCSequence actionWithArray:actionArray]];
    } failure:^(NSError *err) {
        UIAlertView *error = [[UIAlertView alloc] initWithTitle:@"Uh Oh" message:[NSString stringWithFormat:@"An error occured:%@",err,nil] delegate:nil cancelButtonTitle:@"Okay" otherButtonTitles: nil];
        [error show];
        
        [self moveDone];
    }];
}

-(void)removePoint
{
    if ([robotPath count]) {
        [robotPath removeControlPointAtIndex:0];
    }
}

-(void)moveDone
{
    CGSize winSize = [[CCDirector sharedDirector] winSize];
    LinesEnabled = YES;
    while ([robotPath count]) {
        [robotPath removeControlPointAtIndex:0];
    }
    
    CGPoint returnPoint = ccp(winSize.width/2.0, robot.contentSize.height/2.0);
    
    id actionMove = [CCMoveTo actionWithDuration:RETURN_TIME position:returnPoint];
    id actionRotate = [CCRotateTo actionWithDuration:RETURN_TIME angle:0.0f];
    
    [robot runAction:[CCSpawn actionOne:actionMove two:actionRotate]];
    
}



@end
