//
//  EatFishObjPlayerNode.m
//  ozggame_eat_fish
//
//  Created by 欧志刚 on 13-11-3.
//  Copyright (c) 2013年 欧志刚. All rights reserved.
//

#import "EatFishObjPlayerNode.h"

@interface EatFishObjPlayerNode()
{
    enum EatFishObjPlayerNodeStatus _status;
    
}

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
        
        _status = kEatFishObjPlayerNodeStatusSmall;
        
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
    
    CCNode *water = [self getChildByTag:kEatFishObjPlayerNodeTagWater];
    
    if(self.statusInvincibleTime == 0)
    {
        //没有了无敌时间就修改状态和清理水泡
        self.statusIsInvincible = NO;
        
        if(water)
            [water removeFromParentAndCleanup:YES];
        
        [self unschedule:@selector(invincibleCallback:)];
    }
    else
    {
        if(water)
        {
            [water setPosition:CGPointMake(self.contentSize.width / 2, self.contentSize.height / 2)];
            switch (_status)
            {
                case kEatFishObjPlayerNodeStatusMiddle:
                    //中等状态
                    [water setScale:10.0];
                
                    break;
                case kEatFishObjPlayerNodeStatusBig:
                    //变大状态
                    [water setScale:15.0];
                
                    break;
                default:                
                    //默认状态
                    [water setScale:5.0];
                
                    break;
            }
        }
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
    CCNode *water = [self getChildByTag:kEatFishObjPlayerNodeTagWater];
    
    self.statusInvincibleTime--;
    if(self.statusInvincibleTime == 0)
    {
        //没有了无敌时间就修改状态和清理水泡粒子效果
        self.statusIsInvincible = NO;
        
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
    else
    {
        if(water)
        {
            [water setPosition:CGPointMake(self.contentSize.width / 2, self.contentSize.height / 2)];
            switch (_status)
            {
                case kEatFishObjPlayerNodeStatusMiddle:
                    //中等状态
                    [water setScale:10.0];
                    
                    break;
                case kEatFishObjPlayerNodeStatusBig:
                    //变大状态
                    [water setScale:15.0];
                    
                    break;
                default:
                    //默认状态
                    [water setScale:5.0];
                    
                    break;
            }
        }
        
        if(self.statusInvincibleTime <= 3)
        {
            //剩下最后的3秒执行闪烁效果
            CCBlink *blink = [CCBlink actionWithDuration:1.0 blinks:5];
            
            if(water)
                [water runAction:blink];
        }
    }
    
}

- (void)changeStatus:(enum EatFishObjPlayerNodeStatus)status
{
    if(_status == status)
        return;
    
    //清理旧的状态
    CCNode *fishObj = [self getChildByTag:kEatFishObjFishNodeTagMainSprite];
    [fishObj stopAllActions];
    [fishObj removeFromParentAndCleanup:YES];
    
    NSArray *fishSpriteFrameNames = NULL;
    
    _status = status;
    switch (_status)
    {
        case kEatFishObjPlayerNodeStatusMiddle:
        {
            //中等状态
            fishSpriteFrameNames = [EatFishObjFishData getPlayMFish];
            
        }
            break;
        case kEatFishObjPlayerNodeStatusBig:
        {
            //变大状态
            fishSpriteFrameNames = [EatFishObjFishData getPlayBFish];
            
        }
            break;
        default:
        {
            //默认状态
            fishSpriteFrameNames = [EatFishObjFishData getPlayFish];
            
        }
            break;
    }
    
    NSMutableArray *animationSpriteFrames = [NSMutableArray array];
    for (NSString *fishSpriteFrameName in fishSpriteFrameNames)
    {
        CCSpriteFrame *animationSpriteFrame = [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:fishSpriteFrameName];
        [animationSpriteFrames addObject:animationSpriteFrame];
    }
    //生成帧动画
    CCAnimation *animation = [CCAnimation animationWithSpriteFrames:animationSpriteFrames delay:APP_OBJ_FISH_ANIM];
    CCAnimate *anim = [CCAnimate actionWithAnimation:animation];
    
    CCSprite *newFishObj = [CCSprite spriteWithSpriteFrame:[animationSpriteFrames objectAtIndex:0]];
    [self setContentSize:newFishObj.contentSize];
    
    [newFishObj setPosition:CGPointMake(self.contentSize.width / 2, self.contentSize.height / 2)];
    [newFishObj setTag:kEatFishObjFishNodeTagMainSprite];
    [self addChild:newFishObj];
    [newFishObj runAction:[CCRepeatForever actionWithAction:anim]];
}

@end
