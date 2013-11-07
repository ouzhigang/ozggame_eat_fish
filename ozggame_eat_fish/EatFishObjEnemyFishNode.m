//
//  EatFishObjEnemyFishNode.m
//  ozggame_eat_fish
//
//  Created by 欧志刚 on 13-11-6.
//  Copyright (c) 2013年 欧志刚. All rights reserved.
//

#import "EatFishObjEnemyFishNode.h"

@interface EatFishObjEnemyFishNode()

@end

@implementation EatFishObjEnemyFishNode

@synthesize isMoving;
@synthesize moveTimeElapsed;
@synthesize moveTime;
@synthesize moveStartPoint;
@synthesize moveEndPoint;
@synthesize status;

+ (id)nodeWithStatus:(enum EatFishObjEnemyFishNodeStatus)_status
{
    EatFishObjEnemyFishNode *obj = [[[EatFishObjEnemyFishNode alloc] initWithStatus:_status] autorelease];
    return obj;
}

- (id)initWithStatus:(enum EatFishObjEnemyFishNodeStatus)_status
{
    switch (_status)
    {
        case kEatFishObjEnemyFishNodeStatus2:
            self = [super initWithFishSpriteFrameNames:[EatFishObjFishData getFish2]];
            break;
        case kEatFishObjEnemyFishNodeStatus3:
            self = [super initWithFishSpriteFrameNames:[EatFishObjFishData getFish3]];
            break;
        case kEatFishObjEnemyFishNodeStatus4:
            self = [super initWithFishSpriteFrameNames:[EatFishObjFishData getFish4]];
            break;
        case kEatFishObjEnemyFishNodeStatus5:
            self = [super initWithFishSpriteFrameNames:[EatFishObjFishData getFish5]];
            break;
        case kEatFishObjEnemyFishNodeStatus6:
            self = [super initWithFishSpriteFrameNames:[EatFishObjFishData getFish6]];
            break;
        default:
            self = [super initWithFishSpriteFrameNames:[EatFishObjFishData getFish1]];
            break;
    }
    
    if(self)
    {
        self.typeName = APP_OBJ_TYPE_FISH; //这个属性来自父类
        self.status = _status;
        
        [self scheduleUpdate];
    }
    
    return self;
}

- (void)dealloc
{
    [self unscheduleUpdate];
    
    [super dealloc];
}

- (void)update:(ccTime)delta
{
    self.moveTimeElapsed += delta;
    
}

- (CCAction*)runAction:(CCAction *)action
{
    //修改是否正在移动的状态
    self.isMoving = YES;
    return [self runAction:action];
}

- (void)stopAllActions
{
    //修改是否正在移动的状态
    self.isMoving = NO;
    [super stopAllActions];
}

- (void)resumeMove:(id)target withSelector:(SEL)selector
{
    if(!self.isMoving)
    {
        self.moveTime -= self.moveTimeElapsed; //减去经过的时间
        
        //self.moveStartPoint = self.position; //更新开始点
        
        [self runAction:[CCSequence actionOne:[CCMoveTo actionWithDuration:self.moveTime position:self.moveEndPoint] two:[CCCallFuncN actionWithTarget:target selector:selector]]];
    }
}

@end
