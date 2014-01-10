//
//  EatFishObjPlayerNode.h
//  ozggame_eat_fish
//
//  Created by ozg on 13-11-3.
//  Copyright (c) 2013年 ozg. All rights reserved.
//

#import "OzgCCUtility.h"
#import "SimpleAudioEngine.h"
#import "EatFishObjFishNode.h"
#import "EatFishObjFishData.h"
#import "EatFishObjEnemyFishNode.h"
#import "AppConfig.h"

enum EatFishObjPlayerNodeTag
{
    kEatFishObjPlayerNodeTagWater = 1,
    kEatFishObjPlayerNodeTagFlower = 2
    
};

enum EatFishObjPlayerNodeStatus
{
    kEatFishObjPlayerNodeStatusSmall = 0,
    kEatFishObjPlayerNodeStatusMiddle = 1,
    kEatFishObjPlayerNodeStatusBig = 2
    
};

@interface EatFishObjPlayerNode : EatFishObjFishNode

@property (nonatomic, assign)BOOL isTouchMoved; //是否可操作player对象移动
@property (nonatomic, assign)enum EatFishObjPlayerNodeStatus status; //大小状态
@property (nonatomic, assign)BOOL statusIsInvincible; //是否是无敌状态
@property (nonatomic, assign)int statusInvincibleTime; //无敌时间，单位为秒

+ (id)nodeWithFishSpriteFrameNames:(NSArray*)fishSpriteFrameNames;
- (id)initWithFishSpriteFrameNames:(NSArray*)fishSpriteFrameNames;

- (void)changeStatus:(enum EatFishObjPlayerNodeStatus)status;

- (void)cump:(enum EatFishObjEnemyFishNodeStatus)_status; //吃掉一条鱼
- (void)paralysis; //麻痹，碰到了水母后执行

@end
