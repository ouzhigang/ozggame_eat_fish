//
//  EatFishGameScene.m
//  ozggame_eat_fish
//
//  Created by 欧志刚 on 13-11-3.
//  Copyright (c) 2013年 欧志刚. All rights reserved.
//

#import "EatFishGameScene.h"

@interface EatFishGameScene()
{
    NSString *_bg;
    
    NSInteger _score; //分数，最大为99999
    NSInteger _checkpoints; //关卡，最大为99
    NSInteger _playerLife; //player的生命值，最大为99
    
}

- (void)gameStart; //开始游戏
- (void)gameStartCallback; //gameStart的回调

- (void)onMenuTouched:(id)sender;
- (void)onButtonTouched:(id)sender;

@end

@implementation EatFishGameScene

- (id)init
{
    self = [super init];
    if(self)
    {
        CGSize winSize = [[CCDirector sharedDirector] winSize];
        
        //随机背景
        [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"Fishall.plist"];
        [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"cump.plist"];
        NSArray *bgArray = [NSArray arrayWithObjects:@"bg1.png", @"bg2.png", @"bg3.png", nil];
        
        _bg = [bgArray objectAtIndex:arc4random() % bgArray.count];
        CCSprite *bg = [CCSprite spriteWithFile:[OzgCCUtility getImagePath:_bg]];
        [bg setPosition:CGPointMake(winSize.width / 2, winSize.height / 2)];
        [bg setTag:kEatFishGameSceneTagBg];
        [self addChild:bg];
        
        //水泡
        CCParticleSystemQuad *blisterLeft = [CCParticleSystemQuad particleWithFile:@"blister.plist"];
        [blisterLeft setPosition:CGPointMake(winSize.width / 2 - 150, 60)];
        [blisterLeft setTag:kEatFishGameSceneTagBlisterLeft];
        [self addChild:blisterLeft];
        
        CCParticleSystemQuad *blisterRight = [CCParticleSystemQuad particleWithFile:@"blister.plist"];
        [blisterRight setPosition:CGPointMake(winSize.width / 2 + 150, 60)];
        [blisterRight setTag:kEatFishGameSceneTagBlisterRight];
        [self addChild:blisterRight];
        
        //玩家控制的鱼
        EatFishObjPlayerNode *player = [EatFishObjPlayerNode nodeWithFishSpriteFrameNames:[EatFishObjFishData getPlayFish]];
        [player setPosition:CGPointMake(winSize.width / 2, 400)];
        [player setTag:kEatFishGameSceneTagPlayer];
        [self addChild:player];
        
        //右上角的部分
        CCLabelTTF *checkpointsLab = [CCLabelTTF labelWithString:@"关卡：1" fontName:@"Arial-BoldMT" fontSize:15 dimensions:CGSizeMake(100, 20) hAlignment:kCCTextAlignmentLeft];
        [checkpointsLab setPosition:CGPointMake(winSize.width - 50, winSize.height - 12)];
        [checkpointsLab setTag:kEatFishGameSceneTagCheckpoints];
        [self addChild:checkpointsLab];
        
        CCLabelTTF *scoreLab = [CCLabelTTF labelWithString:@"分数：0" fontName:@"Arial-BoldMT" fontSize:15 dimensions:CGSizeMake(100, 20) hAlignment:kCCTextAlignmentLeft];
        [scoreLab setPosition:CGPointMake(winSize.width - 50, winSize.height - 28)];
        [scoreLab setTag:kEatFishGameSceneTagScore];
        [self addChild:scoreLab];
        
        CCMenuItemImage *menuPause = [CCMenuItemImage itemWithNormalImage:@"pause_up.png" selectedImage:@"pause_dw.png" target:self selector:@selector(onMenuTouched:)];
        [menuPause setTag:kEatFishGameSceneTagMenuPause];
        [menuPause setPosition:CGPointMake(winSize.width - 60, winSize.height - 50)];
        
        CCMenu *menu = [CCMenu menuWithItems:menuPause, nil];
        [menu setAnchorPoint:CGPointZero];
        [menu setPosition:CGPointZero];
        [menu setTag:kEatFishGameSceneTagMenu];
        [menu setEnabled:NO];
        [self addChild:menu];
        
        //左上角的部分
        CCSprite *progressBg = [CCSprite spriteWithSpriteFrameName:@"progress.png"];
        [progressBg setPosition:CGPointMake(40, 305)];
        [self addChild:progressBg];
        
        CCSprite *fishLife = [CCSprite spriteWithSpriteFrameName:@"fishlife.png"];
        [fishLife setPosition:CGPointMake(35, 275)];
        [self addChild:fishLife];
        
        CCLabelTTF *fishLifeLab = [CCLabelTTF labelWithString:@"1" fontName:@"Arial-BoldMT" fontSize:15 dimensions:CGSizeMake(50, 20) hAlignment:kCCTextAlignmentLeft];
        [fishLifeLab setPosition:CGPointMake(70, 270)];
        [self addChild:fishLifeLab];
        
        //如果有过场，需要延时执行这个方法
        [self scheduleOnce:@selector(gameStart) delay:APP_TRANSITION];
    }
    return self;
}

- (void)dealloc
{
    //停止水泡的粒子系统
    CCParticleSystemQuad *blisterLeft = (CCParticleSystemQuad*)[self getChildByTag:kEatFishGameSceneTagBlisterLeft];
    CCParticleSystemQuad *blisterRight = (CCParticleSystemQuad*)[self getChildByTag:kEatFishGameSceneTagBlisterRight];
    [blisterLeft stopSystem];
    [blisterRight stopSystem];
    
    [self removeAllChildrenWithCleanup:YES];
    
    [[CCTextureCache sharedTextureCache] removeTextureForKey:@"btn2_dw.png"];
    [[CCTextureCache sharedTextureCache] removeTextureForKey:@"btn2_up.png"];
    [[CCTextureCache sharedTextureCache] removeTextureForKey:[OzgCCUtility getImagePath:_bg]];
    [[CCSpriteFrameCache sharedSpriteFrameCache] removeSpriteFramesFromFile:@"Fishall.plist"];
    [[CCTextureCache sharedTextureCache] removeTextureForKey:@"Fishall.png"];
    [[CCSpriteFrameCache sharedSpriteFrameCache] removeSpriteFramesFromFile:@"cump.plist"];
    [[CCTextureCache sharedTextureCache] removeTextureForKey:@"cump.png"];
    [[CCTextureCache sharedTextureCache] removeTextureForKey:@"particleTexture.png"];
    [[CCTextureCache sharedTextureCache] removeTextureForKey:@"pause_dw.png"];
    [[CCTextureCache sharedTextureCache] removeTextureForKey:@"pause_up.png"];
    //[[CCTextureCache sharedTextureCache] dumpCachedTextureInfo];
    //NSLog(@"EatFishGameScene dealloc");
    [super dealloc];
}

+ (CCScene*)scene
{
    CCScene *s = [CCScene node];
    EatFishGameScene *layer = [EatFishGameScene node];
    [s addChild:layer];
    return s;
}

- (void)gameStart
{
    [[SimpleAudioEngine sharedEngine] playEffect:@"fishstart.mp3"];
    
    //鱼掉下来
    CCNode *player = [self getChildByTag:kEatFishGameSceneTagPlayer];
    [player runAction:[CCSequence actionOne:[CCMoveBy actionWithDuration:1.0 position:CGPointMake(0, -200)] two:[CCCallFunc actionWithTarget:self selector:@selector(gameStartCallback)]]];
    
    [self setTouchEnabled:NO];
    
}

- (void)gameStartCallback
{
    [self setTouchEnabled:YES];
    
    CCMenu *menu = (CCMenu*)[self getChildByTag:kEatFishGameSceneTagMenu];
    [menu setEnabled:YES];
    
}

- (void)ccTouchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    //UITouch *touch = [touches anyObject];
    //CGPoint point = [[CCDirector sharedDirector] convertToGL:[touch locationInView:touch.view]];
    
}

- (void)ccTouchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [touches anyObject];
    CGPoint point = [[CCDirector sharedDirector] convertToGL:[touch locationInView:touch.view]];
    
    EatFishObjPlayerNode *player = (EatFishObjPlayerNode*)[self getChildByTag:kEatFishGameSceneTagPlayer];
    
    CGSize winSize = [[CCDirector sharedDirector] winSize];
    CGRect moveRect = CGRectMake(player.contentSize.width / 2, player.contentSize.height / 2, winSize.width - (player.contentSize.width / 2), winSize.height - (player.contentSize.height / 2));
    
    CGPoint endPoint = [[CCDirector sharedDirector] convertToGL:[touch previousLocationInView:touch.view]];
    
    CGPoint offSet = ccpSub(point, endPoint);
    CGPoint toPoint = ccpAdd(player.position, offSet);
    
    CGFloat toX = player.position.x;
    CGFloat toY = player.position.y;
    
    //如果toPoint的x存在moveRect的宽度范围里面则x为可移动，y的情况一样
    if(toPoint.x >= moveRect.origin.x && toPoint.x <= moveRect.size.width)
        toX = toPoint.x;
    if(toPoint.y >= moveRect.origin.y && toPoint.y <= moveRect.size.height)
        toY = toPoint.y;
    
    [player setPosition:CGPointMake(toX, toY)];
    if(offSet.x > 0)
        [player orientationRight]; //向右移动则转向右边
    else if(offSet.x < 0)
        [player orientationLeft]; //向左移动则转向左边
    
}

- (void)ccTouchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    //UITouch *touch = [touches anyObject];
    //CGPoint point = [[CCDirector sharedDirector] convertToGL:[touch locationInView:touch.view]];
    
}

- (void)onMenuTouched:(id)sender
{
    CCNode *menuItem = (CCNode*)sender;
    switch (menuItem.tag)
    {
        case kEatFishGameSceneTagMenuPause:
        {
            if(![[CCDirector sharedDirector] isPaused])
            {
                NSLog(@"暂停游戏");
                [[CCDirector sharedDirector] pause];
                
                CGSize winSize = [[CCDirector sharedDirector] winSize];
                
                CCMenu *menu = (CCMenu*)[self getChildByTag:kEatFishGameSceneTagMenu];
                [menu setEnabled:NO];
                [self setTouchEnabled:NO];
                
                //弹出暂停时的菜单
                CCNode *pauseMainNode = [CCBReader nodeGraphFromFile:[OzgCCUtility getImagePath:@"scene_game_pausemenu.ccbi"] owner:self];
                [pauseMainNode setPosition:CGPointMake(winSize.width / 2, winSize.height / 2)];
                [pauseMainNode setTag:kEatFishGameSceneTagPauseMainNode];
                [self addChild:pauseMainNode];
                
            }
            
        }
            break;
            
    }
    
}

- (void)onButtonTouched:(id)sender
{
    CCNode *btn = (CCNode*)sender;
    switch (btn.tag)
    {
        case kEatFishGameSceneTagPauseBtnReset:
        {
            //NSLog(@"返回游戏");
            CCNode *pauseMainNode = [self getChildByTag:kEatFishGameSceneTagPauseMainNode];
            [pauseMainNode removeFromParentAndCleanup:YES];
            
            CCMenu *menu = (CCMenu*)[self getChildByTag:kEatFishGameSceneTagMenu];
            [menu setEnabled:YES];
            [self setTouchEnabled:YES];
            
            [[CCDirector sharedDirector] resume];
        }
            break;
        case kEatFishGameSceneTagPauseBtnBgSound:
        {
            //NSLog(@"背景音乐");
            
        }
            break;
        case kEatFishGameSceneTagPauseBtnEffect:
        {
            //NSLog(@"效果声音");
            
        }
            break;
        case kEatFishGameSceneTagPauseBtnQuit:
        {
            //NSLog(@"退出游戏");
            
            UIAlertView *alert = [[[UIAlertView alloc] initWithTitle:APP_ALERT_TITLE message:@"是否退出游戏？" delegate:self cancelButtonTitle:@"否" otherButtonTitles:@"是", nil] autorelease];
            [alert setTag:kEatFishGameSceneAlertTagQuit];
            [alert show];
        }
            break;
    }
}

//UIAlertViewDelegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    switch (alertView.tag)
    {
        case kEatFishGameSceneAlertTagQuit:
        {
            //是否退出游戏
            if(buttonIndex == 1)
            {
                [[CCDirector sharedDirector] resume];
                
                CCScene *s = [EatFishStartScene scene];
                CCTransitionFade *t = [CCTransitionFade transitionWithDuration:APP_TRANSITION scene:s];
                [[CCDirector sharedDirector] replaceScene:t];
                
            }
        }
            break;
    }
}

@end
