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

    }
    return self;
}

- (void)dealloc
{
    CCNode *fishObj = [self getChildByTag:kEatFishObjFishNodeTagMainSprite];
    if(fishObj)
    {
        [fishObj stopAllActions];
        [fishObj removeFromParentAndCleanup:YES];
    }
    
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

@end
