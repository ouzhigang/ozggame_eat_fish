//
//  EatFishObjFishNode.m
//  ozggame_eat_fish
//
//  Created by 欧志刚 on 13-11-3.
//  Copyright (c) 2013年 欧志刚. All rights reserved.
//

#import "EatFishObjFishNode.h"

@interface EatFishObjFishNode()

@end

@implementation EatFishObjFishNode

@synthesize orientation;
@synthesize typeName;

+ (id)nodeWithFishSpriteFrameNames:(NSArray*)fishSpriteFrameNames
{
    EatFishObjFishNode *obj = [[[EatFishObjFishNode alloc] initWithFishSpriteFrameNames:fishSpriteFrameNames] autorelease];
    return obj;
}

- (id)initWithFishSpriteFrameNames:(NSArray*)fishSpriteFrameNames
{
    self = [super init];
    if(self)
    {
        //用SpriteFrameName生成SpriteFrame的数组
        NSMutableArray *animationSpriteFrames = [NSMutableArray array];
        for (NSString *fishSpriteFrameName in fishSpriteFrameNames)
        {
            CCSpriteFrame *animationSpriteFrame = [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:fishSpriteFrameName];
            [animationSpriteFrames addObject:animationSpriteFrame];
        }
        //生成帧动画
        CCAnimation *animation = [CCAnimation animationWithSpriteFrames:animationSpriteFrames delay:APP_OBJ_FISH_ANIM];
        CCAnimate *anim = [CCAnimate actionWithAnimation:animation];
        
        CCSprite *fishObj = [CCSprite spriteWithSpriteFrame:[animationSpriteFrames objectAtIndex:0]];
        
        [self setAnchorPoint:CGPointMake(0.5, 0.5)];
        [self setContentSize:fishObj.contentSize];
        
        [fishObj setPosition:CGPointMake(self.contentSize.width / 2, self.contentSize.height / 2)];
        [fishObj setTag:kEatFishObjFishNodeTagMainSprite];
        [self addChild:fishObj];
        [fishObj runAction:[CCRepeatForever actionWithAction:anim]];

        [self scheduleUpdate];
    }
    return self;
}

- (void)dealloc
{
    [self unscheduleUpdate];
    
    CCNode *fishObj = [self getChildByTag:kEatFishObjFishNodeTagMainSprite];
    if(fishObj)
    {
        [fishObj stopAllActions];
        [fishObj removeFromParentAndCleanup:YES];
    }
    
    //NSLog(@"EatFishObjFishNode dealloc");
    [super dealloc];
}

- (void)orientationLeft
{
    self.orientation = kEatFishObjFishNodeOrientationLeft;
    
    CCSprite *fishObj = (CCSprite*)[self getChildByTag:kEatFishObjFishNodeTagMainSprite];
    [fishObj setFlipX:NO];
}

- (void)orientationRight
{
    self.orientation = kEatFishObjFishNodeOrientationRight;
    
    CCSprite *fishObj = (CCSprite*)[self getChildByTag:kEatFishObjFishNodeTagMainSprite];
    [fishObj setFlipX:YES];
}

- (void)update:(ccTime)delta
{
    //NSLog(@"刷新碰撞区域");
    
    CGPoint objZeroPoint = CGPointMake(self.position.x - (self.contentSize.width / 2), self.position.y - self.contentSize.height / 2);
    
    if(self.orientation == kEatFishObjFishNodeOrientationLeft)
        self.collisionArea = CGRectMake(objZeroPoint.x, objZeroPoint.y, self.contentSize.width / 2, self.contentSize.height); //碰撞区域
    else
        self.collisionArea = CGRectMake(objZeroPoint.x + (self.contentSize.width / 2), objZeroPoint.y, self.contentSize.width / 2, self.contentSize.height); //碰撞区域
    
}

@end
