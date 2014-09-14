//
//  EatFishObjPlayerNode.m
//  ozggame_eat_fish
//
//  Created by ozg on 13-11-3.
//  Copyright (c) 2013年 ozg. All rights reserved.
//

#import "EatFishObjPlayerNode.h"

@interface EatFishObjPlayerNode()
{
    
}

//初始化时的无敌时间
- (void)invincible;
- (void)invincibleCallback:(ccTime)dt;

//使用道具的无敌时间
- (void)invincible2;
- (void)invincible2Callback:(ccTime)dt;

- (void)paralysisEnd:(id)sender;

@end

@implementation EatFishObjPlayerNode

@synthesize isTouchMoved;
@synthesize status;
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
        
        self.typeName = APP_OBJ_TYPE_PLAYER; //这个属性来自父类
        self.status = kEatFishObjPlayerNodeStatusSmall;
        
        self.isTouchMoved = YES;
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
            switch (self.status)
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
            switch (self.status)
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

- (void)changeStatus:(enum EatFishObjPlayerNodeStatus)_status
{
    if(self.status == _status)
        return;
    
    [[SimpleAudioEngine sharedEngine] playEffect:@"growth.mp3"];
    
    //清理旧的状态
    CCNode *fishObj = [self getChildByTag:kEatFishObjFishNodeTagMainSprite];
    [fishObj stopAllActions];
    [fishObj removeFromParentAndCleanup:YES];
    
    NSArray *fishSpriteFrameNames = NULL;
    
    self.status = _status;
    switch (self.status)
    {
        case kEatFishObjPlayerNodeStatusMiddle:
        {
            //中等状态
            fishSpriteFrameNames = [EatFishObjFishData getPlayerMFish];
            
        }
            break;
        case kEatFishObjPlayerNodeStatusBig:
        {
            //变大状态
            fishSpriteFrameNames = [EatFishObjFishData getPlayerBFish];
            
        }
            break;
        default:
        {
            //默认状态
            fishSpriteFrameNames = [EatFishObjFishData getPlayerFish];
            
        }
            break;
    }
    
    [self.animationSpriteFrames removeAllObjects]; //清理旧的数据后使用新的数据
    
    for (NSString *fishSpriteFrameName in fishSpriteFrameNames)
    {
        CCSpriteFrame *animationSpriteFrame = [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:fishSpriteFrameName];
        [self.animationSpriteFrames addObject:animationSpriteFrame];
    }
    //生成帧动画
    CCAnimation *animation = [CCAnimation animationWithSpriteFrames:self.animationSpriteFrames delay:APP_OBJ_FISH_ANIM];
    CCAnimate *anim = [CCAnimate actionWithAnimation:animation];
    
    CCSprite *newFishObj = [CCSprite spriteWithSpriteFrame:[self.animationSpriteFrames objectAtIndex:0]];
    [self setContentSize:newFishObj.contentSize];
    
    [newFishObj setPosition:CGPointMake(self.contentSize.width / 2, self.contentSize.height / 2)];
    [newFishObj setTag:kEatFishObjFishNodeTagMainSprite];
    [self addChild:newFishObj];
    [newFishObj runAction:[CCRepeatForever actionWithAction:anim]];
}

- (void)cump:(enum EatFishObjEnemyFishNodeStatus)_status
{
    if([OzgCCUtility randomRate:0.2])
        [[SimpleAudioEngine sharedEngine] playEffect:@"eatfish2.mp3"];
    else
        [[SimpleAudioEngine sharedEngine] playEffect:@"eatfish1.mp3"];
    
    CCLabelTTF *scoreEffect = nil;    
    switch (_status)
    {
        case kEatFishObjEnemyFishNodeStatus2:
            scoreEffect = [CCLabelTTF labelWithString:[NSString stringWithFormat:@"+%i", APP_SCORE_FISH2] fontName:@"Arial-BoldMT" fontSize:12 dimensions:CGSizeMake(self.contentSize.width, 15) hAlignment:kCCTextAlignmentCenter];
            break;
        case kEatFishObjEnemyFishNodeStatus3:
            scoreEffect = [CCLabelTTF labelWithString:[NSString stringWithFormat:@"+%i", APP_SCORE_FISH3] fontName:@"Arial-BoldMT" fontSize:12 dimensions:CGSizeMake(self.contentSize.width, 15) hAlignment:kCCTextAlignmentCenter];
            break;
        case kEatFishObjEnemyFishNodeStatus4:
            scoreEffect = [CCLabelTTF labelWithString:[NSString stringWithFormat:@"+%i", APP_SCORE_FISH4] fontName:@"Arial-BoldMT" fontSize:12 dimensions:CGSizeMake(self.contentSize.width, 15) hAlignment:kCCTextAlignmentCenter];
            break;
        default:
            scoreEffect = [CCLabelTTF labelWithString:[NSString stringWithFormat:@"+%i", APP_SCORE_FISH1] fontName:@"Arial-BoldMT" fontSize:12 dimensions:CGSizeMake(self.contentSize.width, 15) hAlignment:kCCTextAlignmentCenter];
            break;
    }
    
    [scoreEffect setColor:ccc3(255, 255, 0)];
    [scoreEffect setPosition:CGPointMake(self.contentSize.width / 2, self.contentSize.height)];
    [self addChild:scoreEffect];
    [scoreEffect runAction:[CCSequence actionOne:[CCMoveBy actionWithDuration:1.0 position:CGPointMake(0, 20)] two:[CCCallFuncN actionWithTarget:self selector:@selector(scoreEffectMoveEnd:)]]];
    
    [super cump];
}

- (void)paralysis
{
    if(!self.isTouchMoved)
        return;
    
    [[SimpleAudioEngine sharedEngine] playEffect:@"jellyfish.mp3"];
    self.isTouchMoved = NO;
    
    [self stopAllActions];
    CCNode *fishObj = [self getChildByTag:kEatFishObjFishNodeTagMainSprite];
    if(fishObj)
        [fishObj stopAllActions];
    
    CCMoveBy *act1 = [CCMoveBy actionWithDuration:0.01 position:CGPointMake(-3, 0)];
    CCMoveBy *act2 = [CCMoveBy actionWithDuration:0.02 position:CGPointMake(6, 0)];
    CCActionInterval *act3 = [act2 reverse];
    CCMoveBy *act4 = [CCMoveBy actionWithDuration:0.01 position:CGPointMake(3, 0)];
    
    [self unscheduleUpdate]; //停止update里面的计数
    
    //麻痹5秒后恢复正常
    [self runAction:[CCSequence actions:act1, act2, act3, act4, [CCDelayTime actionWithDuration:5], [CCCallFuncN actionWithTarget:self selector:@selector(paralysisEnd:)], nil]];
}

- (void)paralysisEnd:(id)sender
{
    //生成帧动画
    CCAnimation *animation = [CCAnimation animationWithSpriteFrames:self.animationSpriteFrames delay:APP_OBJ_FISH_ANIM];
    CCAnimate *anim = [CCAnimate actionWithAnimation:animation];
    
    CCNode *fishObj = [self getChildByTag:kEatFishObjFishNodeTagMainSprite];
    [fishObj runAction:[CCRepeatForever actionWithAction:anim]];
    
    self.isTouchMoved = YES;
    [self scheduleUpdate];
}

- (void)scoreEffectMoveEnd:(id)sender
{
    CCLabelTTF *scoreEffect = (CCLabelTTF*)sender;
    [scoreEffect removeFromParentAndCleanup:YES];
    
}

@end
