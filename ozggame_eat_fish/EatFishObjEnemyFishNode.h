//
//  EatFishObjEnemyFishNode.h
//  ozggame_eat_fish
//
//  Created by ozg on 13-11-6.
//  Copyright (c) 2013年 ozg. All rights reserved.
//

#import "EatFishObjFishNode.h"
#import "EatFishObjFishData.h"
#import "AppConfig.h"

enum EatFishObjEnemyFishNodeStatus
{
    kEatFishObjEnemyFishNodeStatus1 = 0,
    kEatFishObjEnemyFishNodeStatus2 = 1,
    kEatFishObjEnemyFishNodeStatus3 = 2,
    kEatFishObjEnemyFishNodeStatus4 = 3,
    kEatFishObjEnemyFishNodeStatus5 = 4,
    kEatFishObjEnemyFishNodeStatus6 = 5
    
};

@interface EatFishObjEnemyFishNode : EatFishObjFishNode

@property (nonatomic, assign)enum EatFishObjEnemyFishNodeStatus status; //鱼的大小级别

+ (id)nodeWithStatus:(enum EatFishObjEnemyFishNodeStatus)_status;
- (id)initWithStatus:(enum EatFishObjEnemyFishNodeStatus)_status;

@end
