//
//  EatFishObjEnemyFishNode.m
//  ozggame_eat_fish
//
//  Created by ozg on 13-11-6.
//  Copyright (c) 2013年 ozg. All rights reserved.
//

#import "EatFishObjEnemyFishNode.h"

@interface EatFishObjEnemyFishNode()

@end

@implementation EatFishObjEnemyFishNode

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
        
    }
    
    return self;
}

- (void)dealloc
{
        
    [super dealloc];
}

@end
