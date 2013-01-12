//
//  Converter.h
//  RobotPathDemo
//
//  Created by Jake on 13-01-09.
//
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"

@interface Converter : NSObject

+(CGPoint) iOSToCoco: (CGPoint)input;

+(CGFloat) DistanceBetween:(CGPoint) point1:(CGPoint) point2;

+(CGFloat) AngleOf:(CGPoint) point1:(CGPoint) point2;

+(CCPointArray *)CubicInterpolation:(CCPointArray *) points:(int) segments;

+(NSArray *)PathToMovements:(CCPointArray *)path;

@end
