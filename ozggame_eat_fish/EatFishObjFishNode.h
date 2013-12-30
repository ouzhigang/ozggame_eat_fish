//
//  EatFishObjFishNode.h
//  ozggame_eat_fish
//
//  Created by ozg on 13-11-3.
//  Copyright (c) 2013年 ozg. All rights reserved.
//

#import "cocos2d.h"
#import "AppConfig.h"

enum EatFishObjFishNodeTag
{
    kEatFishObjFishNodeTagMainSprite = 0,
    kEatFishObjFishNodeTagCump = 10
};

enum EatFishObjFishNodeOrientation
{
    kEatFishObjFishNodeOrientationLeft = 0,
    kEatFishObjFishNodeOrientationRight = 1
};

@interface EatFishObjFishNode : CCNode

@property (nonatomic, assign)BOOL isMoving; //是否正在移动
@property (nonatomic, assign)CGPoint moveStartPoint; //移动的开始点
@property (nonatomic, assign)CGPoint moveEndPoint; //移动的结束点

@property (nonatomic, assign)ccTime moveTimeElapsed; //已经经过了的移动时间
@property (nonatomic, assign)ccTime moveTime; //移动时间
@property (nonatomic, assign)CGRect collisionArea; //碰撞区域
@property (nonatomic, assign)enum EatFishObjFishNodeOrientation orientation; //朝向
@property (nonatomic, assign)NSString* typeName;

@property (nonatomic, assign)NSMutableArray *animationSpriteFrames;

+ (id)nodeWithFishSpriteFrameNames:(NSArray*)fishSpriteFrameNames;
- (id)initWithFishSpriteFrameNames:(NSArray*)fishSpriteFrameNames;

- (void)orientationLeft; //转向左边
- (void)orientationRight; //转向右边

- (void)cump; //吃了一条比自己小的鱼，（水母类不会调用这个方法）
- (void)paralysis; //麻痹，碰到了水母后执行，鲨鱼不调用这个方法

@end
