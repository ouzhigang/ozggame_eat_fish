//
//  EatFishObjPlayerNode.m
//  ozggame_eat_fish
//
//  Created by 欧志刚 on 13-11-3.
//  Copyright (c) 2013年 欧志刚. All rights reserved.
//

#import "EatFishObjPlayerNode.h"

@interface EatFishObjPlayerNode()

//初始化时的无敌时间
- (void)invincible;
- (void)invincibleCallback:(ccTime)dt;

//使用道具的无敌时间
- (void)invincible2;
- (void)invincible2Callback:(ccTime)dt;

@end

@implementation EatFishObjPlayerNode

@synthesize statusIsInvincible;
@synthesize statusInvincibleTime;

+ (id)nodeWithFishSpriteFrameNames:(NSArray*)fishSpriteFrameNames
{
    EatFishObjPlayerNode *obj = [[[EatFishObjPlayerNode alloc] initWithFishSpriteFrameNames:fishSpriteFrameNames] autorelease];
    return obj;
}

- (id)initWithFishSpriteFrameNames:(NSArray*)fishSpriteFrameNames
{
    self = [super initWithFishSpriteFrameNames:fishSpriteFrameNames];
    if(self)
    {
        //无敌时间
        self.statusInvincibleTime = APP_PLAYER_INVINCIBLE;
        [self invincible];
        
        //test
        //self.statusInvincibleTime = APP_PLAYER_INVINCIBLE2;
        //[self invincible2];
        
    }
    return self;
}

- (void)dealloc
{
    [self removeAllChildrenWithCleanup:YES];
    
    [super dealloc];
}

- (void)invincible
{    
    self.statusIsInvincible = YES;
    
    //水泡
    CCSprite *water = [CCSprite spriteWithSpriteFrameName:@"water1.png"];
    [water setPosition:CGPointMake(self.contentSize.width / 2, self.contentSize.height / 2)];
    [water setScale:5.0];
    [water setTag:kEatFishObjPlayerNodeTagWater];
    [self addChild:water];
    
    //自动取消无敌时间
    [self schedule:@selector(invincibleCallback:) interval:1.0];
}

- (void)invincibleCallback:(ccTime)dt
{
    self.statusInvincibleTime--;
    if(self.statusInvincibleTime == 0)
    {
        //没有了无敌时间就修改状态和清理水泡
        self.statusIsInvincible = NO;
        CCNode *water = [self getChildByTag:kEatFishObjPlayerNodeTagWater];
        if(water)
            [water removeFromParentAndCleanup:YES];
        
        [self unschedule:@selector(invincibleCallback:)];
    }
    
}

- (void)invincible2
{
    self.statusIsInvincible = YES;
    
    //水泡
    CCSprite *water = [CCSprite spriteWithSpriteFrameName:@"water1.png"];
    [water setPosition:CGPointMake(self.contentSize.width / 2, self.contentSize.height / 2)];
    [water setScale:5.0];
    [water setTag:kEatFishObjPlayerNodeTagWater];
    [self addChild:water];
    
    //跟随的粒子效果
    CCParticleSystemQuad *flower = [CCParticleSystemQuad particleWithFile:@"flower.plist"];
    [flower setPosition:CGPointMake(self.contentSize.width / 2, self.contentSize.height / 2)];
    [flower setTag:kEatFishObjPlayerNodeTagFlower];
    [self addChild:flower];
    
    //自动取消无敌时间
    [self schedule:@selector(invincible2Callback:) interval:1.0];
    
}

- (void)invincible2Callback:(ccTime)dt
{
    self.statusInvincibleTime--;
    if(self.statusInvincibleTime == 0)
    {
        //没有了无敌时间就修改状态和清理水泡粒子效果
        self.statusIsInvincible = NO;
        CCNode *water = [self getChildByTag:kEatFishObjPlayerNodeTagWater];
        if(water)
        {
            [water stopAllActions];
            [water removeFromParentAndCleanup:YES];
        }
        
        CCParticleSystemQuad *flower = (CCParticleSystemQuad*)[self getChildByTag:kEatFishObjPlayerNodeTagFlower];
        if(flower)
        {
            [flower stopSystem];
            [flower removeFromParentAndCleanup:YES];
        }
        
        [self unschedule:@selector(invincible2Callback:)];
    }
    else if(self.statusInvincibleTime <= 3)
    {
        //剩下最后的3秒执行闪烁效果
        CCBlink *blink = [CCBlink actionWithDuration:1.0 blinks:5];
        CCNode *water = [self getChildByTag:kEatFishObjPlayerNodeTagWater];
        [water runAction:blink];
        
    }
    
}

@end
