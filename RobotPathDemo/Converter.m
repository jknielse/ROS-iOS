//
//  Converter.m
//  RobotPathDemo
//
//  Created by Jake on 13-01-09.
//
//

#import "Converter.h"
#import <math.h>
#define PI 3.1415926535

@implementation Converter

+(CGPoint)iOSToCoco:(CGPoint)input
{
    CGSize winSize = [[CCDirector sharedDirector] winSize];
    return CGPointMake(input.x, winSize.height - input.y);
}

+(CGFloat) DistanceBetween:(CGPoint) point1:(CGPoint) point2
{
    CGFloat dx = point2.x - point1.x;
    CGFloat dy = point2.y - point1.y;
    return sqrt(dx*dx + dy*dy );
};

+(CGFloat) AngleOf:(CGPoint) point1:(CGPoint) point2
{
    return  -CC_RADIANS_TO_DEGREES(ccpToAngle(ccpSub(point1, point2))) - 90.0;
}

+(CCPointArray *)CubicInterpolation:(CCPointArray *) points:(int) segments
{
    CCPointArray *vertices = [[CCPointArray alloc] init];
    
    int num = [points count];
    int count = 0;
    float dt = 1.f / (float) segments;
    
    if (num < 2) return vertices;
    
    // We need two extra points
    CGPoint d0, dN;
    
    d0 = ccpAdd([points getControlPointAtIndex:0], ccpNormalize(ccpSub([points getControlPointAtIndex:1], [points getControlPointAtIndex:0])));
    dN = ccpAdd([points getControlPointAtIndex:num-1], ccpNormalize(ccpSub([points getControlPointAtIndex:num-1], [points getControlPointAtIndex:num-2])));
    
    for (int i=0; i<(num-1); i++) {
        
        [vertices addControlPoint:[points getControlPointAtIndex:i]];
        count++;
        
        CGPoint y0, y1, y2, y3;
        
        if (i==0) {
            y0 = d0;
        } else {
            y0 = [points getControlPointAtIndex:i-1];
        }
        y1 = [points getControlPointAtIndex:i];
        y2 = [points getControlPointAtIndex:i+1];
        if (i==(num-2)) {
            y3 = dN;
        } else {
            y3 = [points getControlPointAtIndex:i+2];
        }
        
        for (float mu=dt; mu < 1.f; mu += dt) {
            CGPoint a0, a1, a2, a3, p;
            double mu2 = mu * mu;
            
            // Two variants, the second is smoother
            /*
            // First
            a0.x = y3.x - y2.x - y0.x + y1.x;
            a0.y = y3.y - y2.y - y0.y + y1.y;
            
            a1.x = y0.x - y1.x - a0.x;
            a1.y = y0.y - y1.y - a0.y;
            
            a2.x = y2.x - y0.x;
            a2.y = y2.y - y0.y;
            
            a3.x = y1.x;
            a3.y = y1.y;*/
            
            // Second, the same as Catmull/Rom
            
             a0.x = -0.5f * y0.x + 1.5f * y1.x -  1.5f * y2.x + 0.5f * y3.x;
             a0.y = -0.5f * y0.y + 1.5f * y1.y -  1.5f * y2.y + 0.5f * y3.y;
             
             a1.x = y0.x - 2.5f * y1.x + 2.f * y2.x - 0.5f * y3.x;
             a1.y = y0.y - 2.5f * y1.y + 2.f * y2.y - 0.5f * y3.y;
             
             a2.x = -0.5f * y0.x + 0.5f * y2.x;
             a2.y = -0.5f * y0.y + 0.5f * y2.y;
             
             a3.x = y1.x;
             a3.y = y1.y;
             
            
            // The point
            p.x = (a0.x * mu * mu2) + (a1.x * mu2) + (a2.x * mu) + a3.x;
            p.y = (a0.y * mu * mu2) + (a1.y * mu2) + (a2.y * mu) + a3.y;
            
            [vertices addControlPoint:p];
            count++;
        }
    }
    
    [vertices addControlPoint:[points getControlPointAtIndex:num-1]];
    
    return vertices;
}

+(NSArray *)PathToMovements:(CCPointArray *)path
{
    NSMutableArray *movements = [[NSMutableArray alloc] init];
    if ([path count]) {
        CGPoint prevprevPoint = [path getControlPointAtIndex:0];
        prevprevPoint.y = prevprevPoint.y + 1;
        CGPoint prevPoint = [path getControlPointAtIndex:0];
        CGPoint point;
        for (int i = 1; i < [path count]; i++) {
            point = [path getControlPointAtIndex:i];
            
            CGFloat angle1 = [self AngleOf:prevprevPoint :prevPoint];
            CGFloat angle2 = [self AngleOf:prevPoint :point];
            
            CGFloat diff = ABS(angle1 - angle2);
            if (diff > 180.0)
                diff = 360.0-diff;
            
            NSNumber *angle = [NSNumber numberWithFloat:(diff/180.0 * PI)];
            NSNumber *magnitude = [NSNumber numberWithFloat:[Converter DistanceBetween:prevPoint :point]];
            
            [movements addObject:[NSDictionary dictionaryWithObjects:
                                  [NSArray arrayWithObjects:[angle description],[magnitude description], nil] forKeys:[NSArray arrayWithObjects:@"angle",@"magnitude", nil]]];
            
            prevprevPoint = prevPoint;
            prevPoint = point;
        }
    }
    return movements;
}

@end
