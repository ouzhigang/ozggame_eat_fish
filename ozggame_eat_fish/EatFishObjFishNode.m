//
//  EatFishObjFishNode.m
//  ozggame_eat_fish
//
//  Created by ozg on 13-11-3.
//  Copyright (c) 2013年 ozg. All rights reserved.
//

#import "EatFishObjFishNode.h"

@interface EatFishObjFishNode()
{
        
}

- (void)cumpAutoHide:(id)sender; //cump的精灵自动消失
- (void)paralysisEnd:(id)sender; //麻痹完毕恢复正常后执行

- (void)resumeMove; //继续移动

@end

@implementation EatFishObjFishNode

@synthesize isMoving;
@synthesize moveStartPoint;
@synthesize moveEndPoint;

@synthesize moveTimeElapsed;
@synthesize moveTime;
@synthesize collisionArea;
@synthesize orientation;
@synthesize typeName;

@synthesize animationSpriteFrames;

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
        self.animationSpriteFrames = [[NSMutableArray alloc] init];
        for (NSString *fishSpriteFrameName in fishSpriteFrameNames)
        {
            CCSpriteFrame *animationSpriteFrame = [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:fishSpriteFrameName];
            [self.animationSpriteFrames addObject:animationSpriteFrame];
        }
        //生成帧动画
        CCAnimation *animation = [CCAnimation animationWithSpriteFrames:self.animationSpriteFrames delay:APP_OBJ_FISH_ANIM];
        CCAnimate *anim = [CCAnimate actionWithAnimation:animation];
        
        CCSprite *fishObj = [CCSprite spriteWithSpriteFrame:[self.animationSpriteFrames objectAtIndex:0]];
        
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
    
    CCSprite *chumSprite = (CCSprite*)[self getChildByTag:kEatFishObjFishNodeTagCump];
    if(chumSprite)
        [chumSprite removeFromParentAndCleanup:YES];
    
    [self.animationSpriteFrames removeAllObjects];
    [self.animationSpriteFrames release];
    
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

- (void)cump
{
    CCSprite *chumSprite = (CCSprite*)[self getChildByTag:kEatFishObjFishNodeTagCump];
    if(chumSprite)
    {
        [chumSprite stopAllActions];
        [chumSprite removeFromParentAndCleanup:YES];
    }
    
    //随机的cump精灵
    NSArray *cumpList = [NSArray arrayWithObjects:@"cump1.png", @"cump2.png", @"cump3.png", @"cump4.png", @"cump5.png", nil];
    
    chumSprite = [CCSprite spriteWithSpriteFrameName:[cumpList objectAtIndex:(NSInteger)(arc4random() % cumpList.count)]];
    
    //定义左边或右边的位置
    if(self.orientation == kEatFishObjFishNodeOrientationLeft)
        [chumSprite setPosition:CGPointMake(-chumSprite.contentSize.width / 2, self.contentSize.height / 2)];
    else
        [chumSprite setPosition:CGPointMake(self.contentSize.width + (chumSprite.contentSize.width / 2), self.contentSize.height / 2)];
    
    [chumSprite setTag:kEatFishObjFishNodeTagCump];
    [self addChild:chumSprite];
    
    [chumSprite runAction:[CCSequence actionOne:[CCDelayTime actionWithDuration:0.2] two:[CCCallFuncN actionWithTarget:self selector:@selector(cumpAutoHide:)]]];
}

- (void)cumpAutoHide:(id)sender
{
    CCSprite *chumSprite = (CCSprite*)sender;
    [chumSprite stopAllActions];
    [chumSprite removeFromParentAndCleanup:YES];
}

- (void)paralysis
{
    if(!self.isMoving)
        return;
    
    [self stopAllActions];
    
    CCNode *fishObj = [self getChildByTag:kEatFishObjFishNodeTagMainSprite];
    if(fishObj)
        [fishObj stopAllActions];
    
    self.isMoving = NO;
    
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
    
    //继续移动
    [self resumeMove];
}

- (void)resumeMove
{
    [self scheduleUpdate]; //继续移动后继续执行update里面的计数
    
    //self.moveStartPoint = self.position; //更新开始点
    self.isMoving = YES;
    
    [self runAction:[CCSequence actionOne:[CCMoveTo actionWithDuration:self.moveTime - self.moveTimeElapsed position:self.moveEndPoint] two:[CCCallFunc actionWithTarget:self selector:@selector(resumeMoveEnd)]]];
}

- (void)resumeMoveEnd
{
    //NSLog(@"enemy fish消失了");
    [self stopAllActions];
    [self removeFromParentAndCleanup:YES];
}

- (void)update:(ccTime)delta
{
    //NSLog(@"刷新碰撞区域");
    
    self.moveTimeElapsed += delta;
    
    CGPoint objZeroPoint = CGPointMake(self.position.x - (self.contentSize.width / 2), self.position.y - self.contentSize.height / 2);
    
    if(self.orientation == kEatFishObjFishNodeOrientationLeft)
        self.collisionArea = CGRectMake(objZeroPoint.x, objZeroPoint.y, self.contentSize.width / 2, self.contentSize.height); //碰撞区域
    else
        self.collisionArea = CGRectMake(objZeroPoint.x + (self.contentSize.width / 2), objZeroPoint.y, self.contentSize.width / 2, self.contentSize.height); //碰撞区域
    
}

@end
