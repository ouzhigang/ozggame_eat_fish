//
//  EatFishObjPlayerNode.h
//  ozggame_eat_fish
//
//  Created by 欧志刚 on 13-11-3.
//  Copyright (c) 2013年 欧志刚. All rights reserved.
//

#import "EatFishObjFishNode.h"
#import "AppConfig.h"

enum EatFishObjPlayerNodeTag
{
    kEatFishObjPlayerNodeTagWater = 1,
    kEatFishObjPlayerNodeTagFlower = 2
    
};

@interface EatFishObjPlayerNode : EatFishObjFishNode

@property (nonatomic, assign)BOOL statusIsInvincible; //是否是无敌状态
@property (nonatomic, assign)int statusInvincibleTime; //无敌时间，单位为秒

+ (id)nodeWithFishSpriteFrameNames:(NSArray*)fishSpriteFrameNames;
- (id)initWithFishSpriteFrameNames:(NSArray*)fishSpriteFrameNames;

@end
