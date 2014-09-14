//
//  EatFishGameScene.m
//  ozggame_eat_fish
//
//  Created by ozg on 13-11-3.
//  Copyright (c) 2013年 ozg. All rights reserved.
//

#import "EatFishGameScene.h"

@interface EatFishGameScene()
{
    NSString *_bg;
    
    NSInteger _score; //分数，最大为99999
    NSInteger _checkpoints; //关卡，最大为99
    NSInteger _playerLife; //player的生命值，最大为99
    
    NSInteger _eatFish; //吃了多少条鱼，用这个值来判断player的成长，小鱼+1，中鱼+2，大鱼+3（死命后此值不会清0，过关后清0）
    NSInteger _eatFishTotal; //这一关吃了的鱼的总数，逻辑跟_eatFish一样，功能是用来判断是否过关，但这个值只有过关时和重新开始时才清0
    
    //这三个值用于过关时的统计，过关后清0
    NSInteger _eatFishTotalStatus1And2;
    NSInteger _eatFishTotalStatus3;
    NSInteger _eatFishTotalStatus4;
    
#ifdef __CC_PLATFORM_MAC
    NSPoint _endPoint;
#endif
}

- (void)gameStart; //开始游戏
- (void)gameStartCallback; //gameStart的回调

- (void)gameRestart:(ccTime)delta; //挂了之后重新开始游戏
- (void)gameRestartCallback; //gameRestartCallback的回调

- (void)onMenuTouched:(id)sender;
- (void)onButtonTouched:(id)sender;

- (void)changeScore:(enum EatFishObjEnemyFishNodeStatus)enemyFishNodeStatus; //分数改变，吃掉鱼时调用

#ifdef __CC_PLATFORM_MAC
- (void)alertDidEnd:(NSAlert *)alert withReturnCode:(NSInteger)returnCode withContextInfo:(void *)contextInfo;
#endif

- (void)changeCheckpoints:(NSInteger)checkpoints; //关卡发生改变时调用
- (void)changePlayerLife:(NSInteger)playerLife; //player生命值发生改变时调用

- (void)jellyfishMoveEnd:(id)sender; //水母的动作执行完毕后执行
- (void)enemyFishMoveEnd:(id)sender; //AI鱼的动作执行完毕后执行

//生成随机AI鱼的左边点和右边点
- (CGPoint)enemyFishRandomLeftPoint:(EatFishObjEnemyFishNode*)_enemyFishNode;
- (CGPoint)enemyFishRandomRightPoint:(EatFishObjEnemyFishNode*)_enemyFishNode;

- (void)enemyFishEmergence:(EatFishObjEnemyFishNode*)_enemyFishNode; //出现了一条AI鱼

@end

@implementation EatFishGameScene

- (id)init
{
    self = [super init];
    if(self)
    {
        CGSize winSize = [[CCDirector sharedDirector] winSize];
        
        //游戏的初始化数据
        _score = 0;
        _checkpoints = 1;
        _playerLife = APP_PLAYER_LIFE;
        
        _eatFish = 0;
        _eatFishTotal = 0;
        
        _eatFishTotalStatus1And2 = 0;
        _eatFishTotalStatus3 = 0;
        _eatFishTotalStatus4 = 0;
        
        [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"Fishtales.plist"];
        [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"Fishall.plist"];
        [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"cump.plist"];
        
        //随机背景
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
        
        //test
        //[player changeStatus:kEatFishObjPlayerNodeStatusBig];
        
        //AI控制的鱼和水母的层
        CCNode *nodeFish = [CCNode node];
        [nodeFish setAnchorPoint:CGPointZero];
        [nodeFish setPosition:CGPointZero];
        [nodeFish setTag:kEatFishGameSceneTagNodeFish];
        [self addChild:nodeFish];
        
        //玩家控制的鱼
        EatFishObjPlayerNode *player = [EatFishObjPlayerNode nodeWithFishSpriteFrameNames:[EatFishObjFishData getPlayerFish]];
        [player setPosition:CGPointMake(winSize.width / 2, 400)];
        [player setTag:kEatFishGameSceneTagPlayer];
        [nodeFish addChild:player];
        
        //右上角的部分
#ifdef __CC_PLATFORM_IOS
        CCLabelTTF *checkpointsLab = [CCLabelTTF labelWithString:[NSString stringWithFormat:@"%@%i", NSLocalizedString(@"GameScene_LabCheckpoints", nil), _checkpoints] fontName:@"Arial-BoldMT" fontSize:15 dimensions:CGSizeMake(100, 20) hAlignment:kCCTextAlignmentLeft];
#elif defined(__CC_PLATFORM_MAC)
        CCLabelTTF *checkpointsLab = [CCLabelTTF labelWithString:[NSString stringWithFormat:@"%@%ld", NSLocalizedString(@"GameScene_LabCheckpoints", nil), _checkpoints] fontName:@"Arial-BoldMT" fontSize:15 dimensions:CGSizeMake(100, 20) hAlignment:kCCTextAlignmentLeft];
#endif
        
        [checkpointsLab setPosition:CGPointMake(winSize.width - 50, winSize.height - 12)];
        [checkpointsLab setTag:kEatFishGameSceneTagCheckpoints];
        [self addChild:checkpointsLab];
        
#ifdef __CC_PLATFORM_IOS
        CCLabelTTF *scoreLab = [CCLabelTTF labelWithString:[NSString stringWithFormat:@"%@%i", NSLocalizedString(@"GameScene_LabScore", nil), _score] fontName:@"Arial-BoldMT" fontSize:15 dimensions:CGSizeMake(100, 20) hAlignment:kCCTextAlignmentLeft];
#elif defined(__CC_PLATFORM_MAC)
        CCLabelTTF *scoreLab = [CCLabelTTF labelWithString:[NSString stringWithFormat:@"%@%ld", NSLocalizedString(@"GameScene_LabScore", nil), _score] fontName:@"Arial-BoldMT" fontSize:15 dimensions:CGSizeMake(100, 20) hAlignment:kCCTextAlignmentLeft];
#endif
        
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
        [progressBg setTag:kEatFishGameSceneTagProgressBg];
        [self addChild:progressBg];
        
        //关卡进度条
        CCSprite *progress = [CCSprite spriteWithFile:@"progressk.png"];
        [progress setPosition:CGPointMake(40, 297)];
        [progress setTag:kEatFishGameSceneTagProgress];
        [progress setAnchorPoint:CGPointMake(0.0, 0.5)];
        [progress setPosition:CGPointMake(progress.position.x - (progress.contentSize.width / 2), progress.position.y)];
        [progress setScaleX:0];
        [self addChild:progress];
        //test
        //[progress setScaleX:0.29];
        //[progress setScaleX:0.61];
        //[progress setScaleX:1];
        
        CCSprite *fishLife = [CCSprite spriteWithSpriteFrameName:@"fishlife.png"];
        [fishLife setPosition:CGPointMake(35, 275)];
        [fishLife setTag:kEatFishGameSceneTagFishLife];
        [self addChild:fishLife];
        
#ifdef __CC_PLATFORM_IOS
        CCLabelTTF *fishLifeLab = [CCLabelTTF labelWithString:[NSString stringWithFormat:@"%i", _playerLife] fontName:@"Arial-BoldMT" fontSize:15 dimensions:CGSizeMake(50, 20) hAlignment:kCCTextAlignmentLeft];
#elif defined(__CC_PLATFORM_MAC)
        CCLabelTTF *fishLifeLab = [CCLabelTTF labelWithString:[NSString stringWithFormat:@"%ld", _playerLife] fontName:@"Arial-BoldMT" fontSize:15 dimensions:CGSizeMake(50, 20) hAlignment:kCCTextAlignmentLeft];
#endif
        [fishLifeLab setPosition:CGPointMake(70, 270)];
        [fishLifeLab setTag:kEatFishGameSceneTagFishLifeLab];
        [self addChild:fishLifeLab];
        
        //配合过场的时间，所以延时执行这个方法
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
    [[CCSpriteFrameCache sharedSpriteFrameCache] removeSpriteFramesFromFile:@"Fishtales.plist"];
    [[CCTextureCache sharedTextureCache] removeTextureForKey:@"Fishtales.png"];
    [[CCSpriteFrameCache sharedSpriteFrameCache] removeSpriteFramesFromFile:@"Fishall.plist"];
    [[CCTextureCache sharedTextureCache] removeTextureForKey:@"Fishall.png"];
    [[CCSpriteFrameCache sharedSpriteFrameCache] removeSpriteFramesFromFile:@"cump.plist"];
    [[CCTextureCache sharedTextureCache] removeTextureForKey:@"cump.png"];
    [[CCTextureCache sharedTextureCache] removeTextureForKey:@"particleTexture.png"];
    [[CCTextureCache sharedTextureCache] removeTextureForKey:@"pause_dw.png"];
    [[CCTextureCache sharedTextureCache] removeTextureForKey:@"pause_up.png"];
    [[CCTextureCache sharedTextureCache] removeTextureForKey:@"progressk.png"];
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
    
    CCNode *nodeFish = [self getChildByTag:kEatFishGameSceneTagNodeFish];
    
    //鱼掉下来
    CCNode *player = [nodeFish getChildByTag:kEatFishGameSceneTagPlayer];
    [player runAction:[CCSequence actionOne:[CCMoveBy actionWithDuration:1.0 position:CGPointMake(0, -200)] two:[CCCallFunc actionWithTarget:self selector:@selector(gameStartCallback)]]];
    
#ifdef __CC_PLATFORM_IOS
    [self setTouchEnabled:NO];
#elif defined(__CC_PLATFORM_MAC)
    [self setMouseEnabled:NO];
#endif
}

- (void)gameStartCallback
{
#ifdef __CC_PLATFORM_IOS
    [self setTouchEnabled:YES];
#elif defined(__CC_PLATFORM_MAC)
    [self setMouseEnabled:YES];
#endif
    
    CCMenu *menu = (CCMenu*)[self getChildByTag:kEatFishGameSceneTagMenu];
    [menu setEnabled:YES];
    
    //随机性质的事件和AI都在这里计算
    [self scheduleUpdate];
}

- (void)gameRestart:(ccTime)delta
{
    [[SimpleAudioEngine sharedEngine] playEffect:@"fishstart.mp3"];
    
    CGSize winSize = [[CCDirector sharedDirector] winSize];
    
    CCNode *nodeFish = [self getChildByTag:kEatFishGameSceneTagNodeFish];
    
    EatFishObjPlayerNode *player = [EatFishObjPlayerNode nodeWithFishSpriteFrameNames:[EatFishObjFishData getPlayerFish]];
    [player setPosition:CGPointMake(winSize.width / 2, 400)];
    [player setTag:kEatFishGameSceneTagPlayer];
    [nodeFish addChild:player];
    
    //鱼掉下来
    [player runAction:[CCSequence actionOne:[CCMoveBy actionWithDuration:1.0 position:CGPointMake(0, -200)] two:[CCCallFunc actionWithTarget:self selector:@selector(gameRestartCallback)]]];
    
#ifdef __CC_PLATFORM_IOS
    [self setTouchEnabled:NO];
#elif defined(__CC_PLATFORM_MAC)
    [self setMouseEnabled:NO];
#endif
}

- (void)gameRestartCallback
{
#ifdef __CC_PLATFORM_IOS
    [self setTouchEnabled:YES];
#elif defined(__CC_PLATFORM_MAC)
    [self setMouseEnabled:YES];
#endif
    
    CCMenu *menu = (CCMenu*)[self getChildByTag:kEatFishGameSceneTagMenu];
    [menu setEnabled:YES];
    
}

#ifdef __CC_PLATFORM_IOS
- (void)ccTouchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
#elif defined(__CC_PLATFORM_MAC)
- (BOOL)ccMouseDown:(NSEvent *)event
#endif
{
    //UITouch *touch = [touches anyObject];
    //CGPoint point = [[CCDirector sharedDirector] convertToGL:[touch locationInView:touch.view]];
#ifdef __CC_PLATFORM_MAC
    _endPoint = [event locationInWindow];
    return YES;
#endif
}

#ifdef __CC_PLATFORM_IOS
- (void)ccTouchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
#elif defined(__CC_PLATFORM_MAC)
- (BOOL)ccMouseDragged:(NSEvent *)event
#endif
{
#ifdef __CC_PLATFORM_IOS
    UITouch *touch = [touches anyObject];
    CGPoint point = [[CCDirector sharedDirector] convertToGL:[touch locationInView:touch.view]];
#elif defined(__CC_PLATFORM_MAC)
    CGPoint point = CGPointMake(event.locationInWindow.x, event.locationInWindow.y);
#endif
    
    CCNode *nodeFish = [self getChildByTag:kEatFishGameSceneTagNodeFish];
    
    EatFishObjPlayerNode *player = (EatFishObjPlayerNode*)[nodeFish getChildByTag:kEatFishGameSceneTagPlayer];
    if(player && player.isTouchMoved)
    {
        CGSize winSize = [[CCDirector sharedDirector] winSize];
        CGRect moveRect = CGRectMake(player.contentSize.width / 2, player.contentSize.height / 2, winSize.width - (player.contentSize.width / 2), winSize.height - (player.contentSize.height / 2));
#ifdef __CC_PLATFORM_IOS
        CGPoint endPoint = [[CCDirector sharedDirector] convertToGL:[touch previousLocationInView:touch.view]];
#elif defined(__CC_PLATFORM_MAC)
        CGPoint endPoint = CGPointMake(_endPoint.x, _endPoint.y);
#endif
        
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
#ifdef __CC_PLATFORM_MAC
        _endPoint = NSPointFromCGPoint(point);
#endif
    }
    
#ifdef __CC_PLATFORM_MAC
    return YES;
#endif
}
#ifdef __CC_PLATFORM_IOS
- (void)ccTouchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
#elif defined(__CC_PLATFORM_MAC)
- (BOOL)ccMouseUp:(NSEvent *)event
#endif
{
    //UITouch *touch = [touches anyObject];
    //CGPoint point = [[CCDirector sharedDirector] convertToGL:[touch locationInView:touch.view]];
    
#ifdef __CC_PLATFORM_MAC
    return YES;
#endif
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
                //NSLog(@"暂停游戏");
                [[SimpleAudioEngine sharedEngine] playEffect:@"btn.wav"];
                
                //暂停游戏节点的所有子对象
                CCNode *nodeFish = [self getChildByTag:kEatFishGameSceneTagNodeFish];
                NSArray *fishs = [[nodeFish children] getNSArray];
                for (CCNode *fish in fishs)
                {
                    NSArray *fishChildren = [[fish children] getNSArray];
                    for (CCNode *fishChild in fishChildren)
                        [fishChild pauseSchedulerAndActions];
                    
                    [fish pauseSchedulerAndActions];
                }
                [self unscheduleUpdate];
                
                CGSize winSize = [[CCDirector sharedDirector] winSize];
                
                CCMenu *menu = (CCMenu*)[self getChildByTag:kEatFishGameSceneTagMenu];
                [menu setEnabled:NO];
#ifdef __CC_PLATFORM_IOS
                [self setTouchEnabled:NO];
#elif defined(__CC_PLATFORM_MAC)
                [self setMouseEnabled:NO];
#endif
                
                //弹出暂停时的菜单
                CCNode *pauseMainNode = [CCBReader nodeGraphFromFile:[OzgCCUtility getImagePath:@"scene_game_pausemenu.ccbi"] owner:self];
                [pauseMainNode setPosition:CGPointMake(winSize.width / 2, winSize.height / 2)];
                [pauseMainNode setTag:kEatFishGameSceneTagPauseMainNode];
                [self addChild:pauseMainNode];
                
                CCControlButton *btnResume = (CCControlButton*)[pauseMainNode getChildByTag:kEatFishGameSceneTagPauseBtnResume];
                CCControlButton *btnBgSound = (CCControlButton*)[pauseMainNode getChildByTag:kEatFishGameSceneTagPauseBtnBgSound];
                CCControlButton *btnEffect = (CCControlButton*)[pauseMainNode getChildByTag:kEatFishGameSceneTagPauseBtnEffect];
                CCControlButton *btnQuit = (CCControlButton*)[pauseMainNode getChildByTag:kEatFishGameSceneTagPauseBtnQuit];
                [btnResume setTitle:NSLocalizedString(@"GameScene_PauseBtnResume", nil) forState:CCControlStateNormal];
                [btnQuit setTitle:NSLocalizedString(@"GameScene_PauseBtnQuit", nil) forState:CCControlStateNormal];
                
                if([[NSUserDefaults standardUserDefaults] boolForKey:APP_CFG_BGSOUND])
                    [btnBgSound setTitle:[NSString stringWithFormat:@"%@(OFF)", NSLocalizedString(@"GameScene_PauseBtnBgSound", nil)] forState:CCControlStateNormal];
                else
                    [btnBgSound setTitle:[NSString stringWithFormat:@"%@(NO)", NSLocalizedString(@"GameScene_PauseBtnBgSound", nil)] forState:CCControlStateNormal];
                
                if([[NSUserDefaults standardUserDefaults] boolForKey:APP_CFG_EFFECT])
                    [btnEffect setTitle:[NSString stringWithFormat:@"%@(OFF)", NSLocalizedString(@"GameScene_PauseBtnEffect", nil)] forState:CCControlStateNormal];
                else
                    [btnEffect setTitle:[NSString stringWithFormat:@"%@(NO)", NSLocalizedString(@"GameScene_PauseBtnEffect", nil)] forState:CCControlStateNormal];
                
            }
            
        }
            break;
            
    }
    
}

- (void)onButtonTouched:(id)sender
{
    [[SimpleAudioEngine sharedEngine] playEffect:@"btn.wav"];
    CCNode *btn = (CCNode*)sender;
    switch (btn.tag)
    {
        case kEatFishGameSceneTagPauseBtnResume:
        {
            //NSLog(@"返回游戏");
            CCNode *pauseMainNode = [self getChildByTag:kEatFishGameSceneTagPauseMainNode];
            [pauseMainNode removeFromParentAndCleanup:YES];
            
            CCMenu *menu = (CCMenu*)[self getChildByTag:kEatFishGameSceneTagMenu];
            [menu setEnabled:YES];
#ifdef __CC_PLATFORM_IOS
            [self setTouchEnabled:YES];
#elif defined(__CC_PLATFORM_MAC)
            [self setMouseEnabled:YES];
#endif
            
            //继续游戏节点的所有子对象
            CCNode *nodeFish = [self getChildByTag:kEatFishGameSceneTagNodeFish];
            NSArray *fishs = [[nodeFish children] getNSArray];
            for (CCNode *fish in fishs)
            {
                NSArray *fishChildren = [[fish children] getNSArray];
                for (CCNode *fishChild in fishChildren)
                    [fishChild resumeSchedulerAndActions];
                
                [fish resumeSchedulerAndActions];
            }
            [self scheduleUpdate];
        }
            break;
        case kEatFishGameSceneTagPauseBtnBgSound:
        {
            //NSLog(@"背景音乐");
            if(![[NSUserDefaults standardUserDefaults] boolForKey:APP_CFG_BGSOUND])
            {
                [[SimpleAudioEngine sharedEngine] setBackgroundMusicVolume:1.0];
                [[NSUserDefaults standardUserDefaults] setBool:YES forKey:APP_CFG_BGSOUND];
                [((CCControlButton*)btn) setTitle:[NSString stringWithFormat:@"%@(OFF)", NSLocalizedString(@"GameScene_PauseBtnBgSound", nil)] forState:CCControlStateNormal];
            }
            else
            {
                [[SimpleAudioEngine sharedEngine] setBackgroundMusicVolume:0.0];
                [[NSUserDefaults standardUserDefaults] setBool:NO forKey:APP_CFG_BGSOUND];
                [((CCControlButton*)btn) setTitle:[NSString stringWithFormat:@"%@(NO)", NSLocalizedString(@"GameScene_PauseBtnBgSound", nil)] forState:CCControlStateNormal];
            }
        }
            break;
        case kEatFishGameSceneTagPauseBtnEffect:
        {
            //NSLog(@"效果声音");
            if(![[NSUserDefaults standardUserDefaults] boolForKey:APP_CFG_EFFECT])
            {
                [[SimpleAudioEngine sharedEngine] setEffectsVolume:1.0];
                [[NSUserDefaults standardUserDefaults] setBool:YES forKey:APP_CFG_EFFECT];
                [((CCControlButton*)btn) setTitle:[NSString stringWithFormat:@"%@(OFF)", NSLocalizedString(@"GameScene_PauseBtnEffect", nil)] forState:CCControlStateNormal];
            }
            else
            {
                [[SimpleAudioEngine sharedEngine] setEffectsVolume:0.0];
                [[NSUserDefaults standardUserDefaults] setBool:NO forKey:APP_CFG_EFFECT];
                [((CCControlButton*)btn) setTitle:[NSString stringWithFormat:@"%@(NO)", NSLocalizedString(@"GameScene_PauseBtnEffect", nil)] forState:CCControlStateNormal];
            }
        }
            break;
        case kEatFishGameSceneTagPauseBtnQuit:
        {
            //NSLog(@"退出游戏");
#ifdef __CC_PLATFORM_IOS
            UIAlertView *alert = [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Alert_Title", nil) message:NSLocalizedString(@"GameScene_AlertMessage", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"GameScene_AlertBtnNo", nil) otherButtonTitles:NSLocalizedString(@"GameScene_AlertBtnYes", nil), nil] autorelease];
            [alert setTag:kEatFishGameSceneAlertTagQuit];
            [alert show];
#elif defined(__CC_PLATFORM_MAC)
            NSAlert *alert = [[[NSAlert alloc] init] autorelease];
            alert.delegate = self;
            [alert addButtonWithTitle:NSLocalizedString(@"GameScene_AlertBtnNo", nil)];
            [alert addButtonWithTitle:NSLocalizedString(@"GameScene_AlertBtnYes", nil)];
            [alert setMessageText:NSLocalizedString(@"Alert_Title", nil)];
            [alert setInformativeText:NSLocalizedString(@"GameScene_AlertMessage", nil)];
            [alert setAlertStyle:NSWarningAlertStyle];
            [alert beginSheetModalForWindow:[[[CCDirectorMac sharedDirector] view] window] modalDelegate:self didEndSelector:@selector(alertDidEnd:withReturnCode:withContextInfo:) contextInfo:[NSNumber numberWithInteger:kEatFishGameSceneAlertTagQuit]];
#endif
        }
            break;
        case kEatFishGameSceneTagGameOverMainNodeBtnQuit:
        {
            //NSLog(@"退出游戏");
#ifdef __CC_PLATFORM_IOS
            UIAlertView *alert = [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Alert_Title", nil) message:NSLocalizedString(@"GameScene_AlertMessage", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"GameScene_AlertBtnNo", nil) otherButtonTitles:NSLocalizedString(@"GameScene_AlertBtnYes", nil), nil] autorelease];
            [alert setTag:kEatFishGameSceneAlertTagQuit];
            [alert show];
#elif defined(__CC_PLATFORM_MAC)
            NSAlert *alert = [[[NSAlert alloc] init] autorelease];
            alert.delegate = self;
            [alert addButtonWithTitle:NSLocalizedString(@"GameScene_AlertBtnNo", nil)];
            [alert addButtonWithTitle:NSLocalizedString(@"GameScene_AlertBtnYes", nil)];
            [alert setMessageText:NSLocalizedString(@"Alert_Title", nil)];
            [alert setInformativeText:NSLocalizedString(@"GameScene_AlertMessage", nil)];
            [alert setAlertStyle:NSWarningAlertStyle];
            [alert beginSheetModalForWindow:[[[CCDirectorMac sharedDirector] view] window] modalDelegate:self didEndSelector:@selector(alertDidEnd:withReturnCode:withContextInfo:) contextInfo:[NSNumber numberWithInteger:kEatFishGameSceneAlertTagQuit]];
#endif
        }
            break;
        case kEatFishGameSceneTagGameClearMainNodeBtnQuit:
        {
            //NSLog(@"退出游戏");
#ifdef __CC_PLATFORM_IOS
            UIAlertView *alert = [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Alert_Title", nil) message:NSLocalizedString(@"GameScene_AlertMessage", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"GameScene_AlertBtnNo", nil) otherButtonTitles:NSLocalizedString(@"GameScene_AlertBtnYes", nil), nil] autorelease];
            [alert setTag:kEatFishGameSceneAlertTagQuit];
            [alert show];
#elif defined(__CC_PLATFORM_MAC)
            NSAlert *alert = [[[NSAlert alloc] init] autorelease];
            alert.delegate = self;
            [alert addButtonWithTitle:NSLocalizedString(@"GameScene_AlertBtnNo", nil)];
            [alert addButtonWithTitle:NSLocalizedString(@"GameScene_AlertBtnYes", nil)];
            [alert setMessageText:NSLocalizedString(@"Alert_Title", nil)];
            [alert setInformativeText:NSLocalizedString(@"GameScene_AlertMessage", nil)];
            [alert setAlertStyle:NSWarningAlertStyle];
            [alert beginSheetModalForWindow:[[[CCDirectorMac sharedDirector] view] window] modalDelegate:self didEndSelector:@selector(alertDidEnd:withReturnCode:withContextInfo:) contextInfo:[NSNumber numberWithInteger:kEatFishGameSceneAlertTagQuit]];
#endif
        }
            break;
        case kEatFishGameSceneTagGameOverMainNodeBtnRestart:
        {
            //NSLog(@"重新开始");
            
            //游戏的初始化数据
            _score = 0;
            _checkpoints = 1;
            _playerLife = APP_PLAYER_LIFE;
            
            _eatFish = 0;
            _eatFishTotal = 0;
            
            _eatFishTotalStatus1And2 = 0;
            _eatFishTotalStatus3 = 0;
            _eatFishTotalStatus4 = 0;
            
            [self changeCheckpoints:_checkpoints];
            [self changePlayerLife:_playerLife];
            
#ifdef __CC_PLATFORM_IOS
            CCLabelTTF *scoreLab = (CCLabelTTF*)[self getChildByTag:kEatFishGameSceneTagScore];
            [scoreLab setString:[NSString stringWithFormat:@"%@%i", NSLocalizedString(@"GameScene_LabScore", nil), _score]];
#elif defined(__CC_PLATFORM_MAC)
            CCLabelTTF *scoreLab = (CCLabelTTF*)[self getChildByTag:kEatFishGameSceneTagScore];
            [scoreLab setString:[NSString stringWithFormat:@"%@%ld", NSLocalizedString(@"GameScene_LabScore", nil), _score]];
#endif
            CCSprite *progress = (CCSprite*)[self getChildByTag:kEatFishGameSceneTagProgress];
            [progress setScaleX:0];
            
            CCNode *gameOver = [self getChildByTag:kEatFishGameSceneTagGameOverMainNode];
            [gameOver removeFromParentAndCleanup:YES];
            
            //玩家控制的鱼
            CCNode *nodeFish = [self getChildByTag:kEatFishGameSceneTagNodeFish];
            
            EatFishObjPlayerNode *player = [EatFishObjPlayerNode nodeWithFishSpriteFrameNames:[EatFishObjFishData getPlayerFish]];
            [player setPosition:CGPointMake([[CCDirector sharedDirector] winSize].width / 2, 400)];
            [player setTag:kEatFishGameSceneTagPlayer];
            [nodeFish addChild:player];
            
            [self gameStart];
        }
            break;
        case kEatFishGameSceneTagGameClearMainNodeBtnNext:
        {
            //NSLog(@"下一关");
            _checkpoints += 1;
            if(_checkpoints > APP_MAX_CP)
                _checkpoints = APP_MAX_CP;
            [self changeCheckpoints:_checkpoints];
            
            _eatFish = 0;
            _eatFishTotal = 0;
            
            _eatFishTotalStatus1And2 = 0;
            _eatFishTotalStatus3 = 0;
            _eatFishTotalStatus4 = 0;
            
            CCSprite *progress = (CCSprite*)[self getChildByTag:kEatFishGameSceneTagProgress];
            [progress setScaleX:0];
            
            CCNode *gameClear = [self getChildByTag:kEatFishGameSceneTagGameClearMainNode];
            [gameClear removeFromParentAndCleanup:YES];
            
            //玩家控制的鱼
            CCNode *nodeFish = [self getChildByTag:kEatFishGameSceneTagNodeFish];
            
            EatFishObjPlayerNode *player = [EatFishObjPlayerNode nodeWithFishSpriteFrameNames:[EatFishObjFishData getPlayerFish]];
            [player setPosition:CGPointMake([[CCDirector sharedDirector] winSize].width / 2, 400)];
            [player setTag:kEatFishGameSceneTagPlayer];
            [nodeFish addChild:player];
            
            [self gameStart];
        }
            break;
    }
}

//UIAlertViewDelegate
#ifdef __CC_PLATFORM_IOS
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    switch (alertView.tag)
    {
        case kEatFishGameSceneAlertTagQuit:
        {
            //是否退出游戏
            if(buttonIndex == 1)
            {
                [self unscheduleUpdate];
                [[CCDirector sharedDirector] resume];
                
                CCScene *s = [EatFishStartScene scene];
                CCTransitionFade *t = [CCTransitionFade transitionWithDuration:APP_TRANSITION scene:s];
                [[CCDirector sharedDirector] replaceScene:t];
                
            }
        }
            break;
    }
}
#elif defined(__CC_PLATFORM_MAC)
- (void)alertDidEnd:(NSAlert *)alert withReturnCode:(NSInteger)returnCode withContextInfo:(void *)contextInfo
{
    NSNumber *alertTag = (NSNumber*)contextInfo;
    switch ([alertTag integerValue])
    {
        case kEatFishGameSceneAlertTagQuit:
        {
            if(returnCode == NSAlertSecondButtonReturn)
            {
                [self unscheduleUpdate];
                [[CCDirector sharedDirector] resume];
                
                CCScene *s = [EatFishStartScene scene];
                CCTransitionFade *t = [CCTransitionFade transitionWithDuration:APP_TRANSITION scene:s];
                [[CCDirector sharedDirector] replaceScene:t];
            }
        }
            break;
    }
}
#endif

- (void)changeScore:(enum EatFishObjEnemyFishNodeStatus)enemyFishNodeStatus
{
    switch (enemyFishNodeStatus)
    {
        case kEatFishObjEnemyFishNodeStatus2:
            _score += APP_SCORE_FISH2;
            
            _eatFish += 1;
            _eatFishTotal += 1;
            _eatFishTotalStatus1And2 += 1;
            break;
        case kEatFishObjEnemyFishNodeStatus3:
            _score += APP_SCORE_FISH3;
            
            _eatFish += 2;
            _eatFishTotal += 2;
            _eatFishTotalStatus3 += 1;
            break;
        case kEatFishObjEnemyFishNodeStatus4:
            _score += APP_SCORE_FISH4;
            
            _eatFish += 3;
            _eatFishTotal +=3;
            _eatFishTotalStatus4 += 1;
            break;
        default:
            _score += APP_SCORE_FISH1;
            
            _eatFish += 1;
            _eatFishTotal += 1;
            _eatFishTotalStatus1And2 += 1;
            break;
    }
    
    if(_score > APP_MAX_SCORE)
        _score = APP_MAX_SCORE;
    
    if(_eatFish > APP_MAX_SCORE)
        _eatFish = APP_MAX_SCORE;
    if(_eatFishTotal > APP_MAX_SCORE)
        _eatFishTotal = APP_MAX_SCORE;
    
    CCLabelTTF *scoreLab = (CCLabelTTF*)[self getChildByTag:kEatFishGameSceneTagScore];
#ifdef __CC_PLATFORM_IOS
    [scoreLab setString:[NSString stringWithFormat:@"%@%i", NSLocalizedString(@"GameScene_LabScore", nil), _score]];
#elif defined(__CC_PLATFORM_MAC)
    [scoreLab setString:[NSString stringWithFormat:@"%@%ld", NSLocalizedString(@"GameScene_LabScore", nil), _score]];
#endif
    
}

- (void)changeCheckpoints:(NSInteger)checkpoints
{
    _checkpoints = checkpoints;
    
    CCLabelTTF *checkpointsLab = (CCLabelTTF*)[self getChildByTag:kEatFishGameSceneTagCheckpoints];
#ifdef __CC_PLATFORM_IOS
    [checkpointsLab setString:[NSString stringWithFormat:@"%@%i", NSLocalizedString(@"GameScene_LabCheckpoints", nil), _checkpoints]];
#elif defined(__CC_PLATFORM_MAC)
    [checkpointsLab setString:[NSString stringWithFormat:@"%@%ld", NSLocalizedString(@"GameScene_LabCheckpoints", nil), _checkpoints]];
#endif
    
}

- (void)changePlayerLife:(NSInteger)playerLife
{
    _playerLife = playerLife;
    
    CCLabelTTF *fishLifeLab = (CCLabelTTF*)[self getChildByTag:kEatFishGameSceneTagFishLifeLab];
#ifdef __CC_PLATFORM_IOS
    [fishLifeLab setString:[NSString stringWithFormat:@"%i", _playerLife]];
#elif defined(__CC_PLATFORM_MAC)
    [fishLifeLab setString:[NSString stringWithFormat:@"%ld", _playerLife]];
#endif
    
}

//cocos2d update
- (void)update:(ccTime)delta
{
    CGSize winSize = [[CCDirector sharedDirector] winSize];
    
    //AI鱼和水母出现的层
    CCNode *nodeFish = [self getChildByTag:kEatFishGameSceneTagNodeFish];
    
    //水母
    if([OzgCCUtility randomRate:APP_AI_JELLYFISH])
    {
        //NSLog(@"水母出现了");
        
        EatFishObjJellyfishNode *jellyfish = [EatFishObjJellyfishNode node];
        
        CGFloat srcX = [OzgCCUtility randomRange:jellyfish.contentSize.width / 2 withMaxValue:winSize.width - (jellyfish.contentSize.width / 2)];
        
        [jellyfish setPosition:CGPointMake(srcX, -jellyfish.contentSize.height / 2)];
        
        [nodeFish addChild:jellyfish];
        
        ccTime moveTime = [OzgCCUtility randomRange:10.0 withMaxValue:15.0];
        [jellyfish runAction:[CCSequence actionOne:[CCMoveTo actionWithDuration:moveTime position:CGPointMake(srcX, winSize.height + (jellyfish.contentSize.height / 2))] two:[CCCallFuncN actionWithTarget:self selector:@selector(jellyfishMoveEnd:)]]];
        
    }
    
    //fish1
    if([OzgCCUtility randomRate:APP_AI_FISH1])
    {
        //NSLog(@"enemy fish1出现了");
        
        EatFishObjEnemyFishNode *enemyFishNode = [EatFishObjEnemyFishNode nodeWithStatus:kEatFishObjEnemyFishNodeStatus1];
        [self enemyFishEmergence:enemyFishNode];
    }
    
    //fish2
    if([OzgCCUtility randomRate:APP_AI_FISH2])
    {
        //NSLog(@"enemy fish2出现了");
        
        EatFishObjEnemyFishNode *enemyFishNode = [EatFishObjEnemyFishNode nodeWithStatus:kEatFishObjEnemyFishNodeStatus2];
        [self enemyFishEmergence:enemyFishNode];
    }
    
    //fish3
    if([OzgCCUtility randomRate:APP_AI_FISH3])
    {
        //NSLog(@"enemy fish3出现了");
        
        EatFishObjEnemyFishNode *enemyFishNode = [EatFishObjEnemyFishNode nodeWithStatus:kEatFishObjEnemyFishNodeStatus3];
        [self enemyFishEmergence:enemyFishNode];
    }
    
    //fish4
    if([OzgCCUtility randomRate:APP_AI_FISH4])
    {
        //NSLog(@"enemy fish4出现了");
        
        EatFishObjEnemyFishNode *enemyFishNode = [EatFishObjEnemyFishNode nodeWithStatus:kEatFishObjEnemyFishNodeStatus4];
        [self enemyFishEmergence:enemyFishNode];
    }
    
    //fish5
    if([OzgCCUtility randomRate:APP_AI_FISH5])
    {
        //NSLog(@"enemy fish5出现了");
        
        EatFishObjEnemyFishNode *enemyFishNode = [EatFishObjEnemyFishNode nodeWithStatus:kEatFishObjEnemyFishNodeStatus5];
        [self enemyFishEmergence:enemyFishNode];
    }
    
    //fish6
    if([OzgCCUtility randomRate:APP_AI_FISH6])
    {
        //NSLog(@"enemy fish6出现了");
        
        EatFishObjEnemyFishNode *enemyFishNode = [EatFishObjEnemyFishNode nodeWithStatus:kEatFishObjEnemyFishNodeStatus6];
        [self enemyFishEmergence:enemyFishNode];
    }
    
    //以下是碰撞

    NSArray *srcAllFishs = [[nodeFish children] getNSArray]; //碰撞源对象
    NSArray *targetAllFishs = [srcAllFishs copy]; //碰撞目标对象
    
    //AI鱼和水母之间的检测
    for (NSInteger i = 0; i < srcAllFishs.count; i++)
    {
        EatFishObjFishNode *srcObj = (EatFishObjFishNode*)[srcAllFishs objectAtIndex:i];
        
        for (NSInteger j = 0; j < targetAllFishs.count; j++)
        {
            EatFishObjFishNode *targetObj = (EatFishObjFishNode*)[targetAllFishs objectAtIndex:j];
            if(CGRectIntersectsRect([srcObj boundingBox], [targetObj boundingBox]))
            {
                if([srcObj.typeName isEqualToString:APP_OBJ_TYPE_FISH] && [targetObj.typeName isEqualToString:APP_OBJ_TYPE_FISH])
                {
                    if(CGRectIntersectsRect(srcObj.collisionArea, [targetObj boundingBox]))
                    {
                        //AI鱼跟AI鱼的处理
                        //NSLog(@"AI鱼跟AI鱼碰撞了");
                        //大鱼吃小鱼
                        if(((EatFishObjEnemyFishNode*)srcObj).status >= kEatFishObjEnemyFishNodeStatus3 && ((EatFishObjEnemyFishNode*)srcObj).status > ((EatFishObjEnemyFishNode*)targetObj).status)
                        {
                            [((EatFishObjEnemyFishNode*)srcObj) cump];
                            [targetObj stopAllActions];
                            [targetObj removeFromParentAndCleanup:YES];
                        }
                    }
                    
                }
                else if([srcObj.typeName isEqualToString:APP_OBJ_TYPE_FISH] && [targetObj.typeName isEqualToString:APP_OBJ_TYPE_JELLYFISH])
                {
                    //鲨鱼不执行
                    if(((EatFishObjEnemyFishNode*)srcObj).status < kEatFishObjEnemyFishNodeStatus5)
                    {
                        //AI鱼跟水母的处理
                        //NSLog(@"AI鱼跟水母碰撞了");
                        [srcObj paralysis];
                        
                    }
                }
                else if([srcObj.typeName isEqualToString:APP_OBJ_TYPE_PLAYER])
                {
                    if([targetObj.typeName isEqualToString:APP_OBJ_TYPE_JELLYFISH])
                    {
                        //NSLog(@"player与水母碰撞了");
                        if(!((EatFishObjPlayerNode*)srcObj).statusIsInvincible)
                            [((EatFishObjPlayerNode*)srcObj) paralysis];
                    }
                    
#ifdef __CC_PLATFORM_IOS
                    if([targetObj.typeName isEqualToString:APP_OBJ_TYPE_FISH] && [self isTouchEnabled])
#elif defined(__CC_PLATFORM_MAC)
                    if([targetObj.typeName isEqualToString:APP_OBJ_TYPE_FISH] && [self isMouseEnabled])
#endif
                    {
                        //NSLog(@"player与AI鱼碰撞了");
                        
                        BOOL doEat = false;
                        
                        EatFishObjPlayerNode *player = (EatFishObjPlayerNode*)srcObj;
                        switch (player.status)
                        {
                            case kEatFishObjPlayerNodeStatusMiddle:
                            {
                                //中的状态
                                if(((EatFishObjEnemyFishNode*)targetObj).status == kEatFishObjEnemyFishNodeStatus1 || ((EatFishObjEnemyFishNode*)targetObj).status == kEatFishObjEnemyFishNodeStatus2 || ((EatFishObjEnemyFishNode*)targetObj).status == kEatFishObjEnemyFishNodeStatus3)
                                    doEat = true;
                            }
                                break;
                            case kEatFishObjPlayerNodeStatusBig:
                            {
                                //大的状态
                                if(((EatFishObjEnemyFishNode*)targetObj).status == kEatFishObjEnemyFishNodeStatus1 || ((EatFishObjEnemyFishNode*)targetObj).status == kEatFishObjEnemyFishNodeStatus2 || ((EatFishObjEnemyFishNode*)targetObj).status == kEatFishObjEnemyFishNodeStatus3 || ((EatFishObjEnemyFishNode*)targetObj).status == kEatFishObjEnemyFishNodeStatus4)
                                    doEat = true;
                            }
                                break;
                            default:
                            {
                                //小的状态
                                if(((EatFishObjEnemyFishNode*)targetObj).status == kEatFishObjEnemyFishNodeStatus1 || ((EatFishObjEnemyFishNode*)targetObj).status == kEatFishObjEnemyFishNodeStatus2)
                                    doEat = true;
                                
                            }
                                break;
                        }
                        
                        if(doEat)
                        {
                            //吃掉比自己小的鱼
                            [player cump:((EatFishObjEnemyFishNode*)targetObj).status];
                            [targetObj stopAllActions];
                            [targetObj removeFromParentAndCleanup:YES];
                            
                            //分数
                            [self changeScore:((EatFishObjEnemyFishNode*)targetObj).status];
                            
                            //关卡进度条
                            CGFloat cpProgress = (CGFloat)_eatFishTotal / (CGFloat)APP_CP_CLEAR;
                            CCSprite *progress = (CCSprite*)[self getChildByTag:kEatFishGameSceneTagProgress];
                            [progress setScaleX:cpProgress];
                            
                            if(cpProgress >= 1)
                            {
                                //过关
                                [self unscheduleUpdate];
                                
                                [[SimpleAudioEngine sharedEngine] playEffect:@"complete.mp3"];
                                
#ifdef __CC_PLATFORM_IOS
                                [self setTouchEnabled:NO];
#elif defined(__CC_PLATFORM_MAC)
                                [self setMouseEnabled:NO];
#endif
                                CCMenu *menu = (CCMenu*)[self getChildByTag:kEatFishGameSceneTagMenu];
                                [menu setEnabled:NO];
                                
                                [nodeFish removeAllChildrenWithCleanup:YES];
                                
                                CCNode *gameClear = [CCBReader nodeGraphFromFile:@"scene_game_clear.ccbi" owner:self];
                                [gameClear setTag:kEatFishGameSceneTagGameClearMainNode];
                                [gameClear setPosition:CGPointMake([[CCDirector sharedDirector] winSize].width / 2, [[CCDirector sharedDirector] winSize].height / 2)];
                                [self addChild:gameClear];
                                
                                CCLabelTTF *gameClearLab1 = (CCLabelTTF*)[gameClear getChildByTag:kEatFishGameSceneTagGameClearMainNodeLab1];
                                CCControlButton *gameClearBtnQuit = (CCControlButton*)[gameClear getChildByTag:kEatFishGameSceneTagGameClearMainNodeBtnQuit];
                                CCControlButton *gameClearBtnNext = (CCControlButton*)[gameClear getChildByTag:kEatFishGameSceneTagGameClearMainNodeBtnNext];
                                [gameClearLab1 setString:NSLocalizedString(@"GameScene_GameClearLab1", nil)];
                                [gameClearBtnQuit setTitle:NSLocalizedString(@"GameScene_GameClearBtnQuit", nil) forState:CCControlStateNormal];
                                [gameClearBtnNext setTitle:NSLocalizedString(@"GameScene_GameClearBtnNext", nil) forState:CCControlStateNormal];
                                
                                //各种鱼的计数
                                CCLabelTTF *gameClearLab2 = (CCLabelTTF*)[gameClear getChildByTag:kEatFishGameSceneTagGameClearMainNodeLab2];
#ifdef __CC_PLATFORM_IOS
                                [gameClearLab2 setString:[NSString stringWithFormat:@"%i", _eatFishTotalStatus1And2]];
#elif defined(__CC_PLATFORM_MAC)
                                [gameClearLab2 setString:[NSString stringWithFormat:@"%ld", _eatFishTotalStatus1And2]];
#endif
                                
                                
                                CCLabelTTF *gameClearLab3 = (CCLabelTTF*)[gameClear getChildByTag:kEatFishGameSceneTagGameClearMainNodeLab3];
#ifdef __CC_PLATFORM_IOS
                                [gameClearLab3 setString:[NSString stringWithFormat:@"%i", _eatFishTotalStatus3]];
#elif defined(__CC_PLATFORM_MAC)
                                [gameClearLab3 setString:[NSString stringWithFormat:@"%ld", _eatFishTotalStatus3]];
#endif
                                
                                
                                CCLabelTTF *gameClearLab4 = (CCLabelTTF*)[gameClear getChildByTag:kEatFishGameSceneTagGameClearMainNodeLab4];
#ifdef __CC_PLATFORM_IOS
                                [gameClearLab4 setString:[NSString stringWithFormat:@"%i", _eatFishTotalStatus4]];
#elif defined(__CC_PLATFORM_MAC)
                                [gameClearLab4 setString:[NSString stringWithFormat:@"%ld", _eatFishTotalStatus4]];
#endif
                                
                            }
                            
                            //变大的判断
                            if(player.status == kEatFishObjPlayerNodeStatusMiddle && _eatFish >= APP_PLAYER_STATUS_BIG)
                                [player changeStatus:kEatFishObjPlayerNodeStatusBig];
                            else if(player.status == kEatFishObjPlayerNodeStatusSmall && _eatFish >= APP_PLAYER_STATUS_MIDDLE)
                                [player changeStatus:kEatFishObjPlayerNodeStatusMiddle];
                            
                        }
                        else
                        {
                            //如果不是无敌状态的话，就会被比自己大的鱼吃了
                            if(!player.statusIsInvincible)
                            {
                                [((EatFishObjEnemyFishNode*)targetObj) cump];
                                [player stopAllActions];
                                [player removeFromParentAndCleanup:YES];
                                
                                if(_playerLife == 0)
                                {
                                    [self unscheduleUpdate];
                                    
                                    //没有了生命值就game over
                                    [[SimpleAudioEngine sharedEngine] playEffect:@"complete.mp3"];
                                    
#ifdef __CC_PLATFORM_IOS
                                    [self setTouchEnabled:NO];
#elif defined(__CC_PLATFORM_MAC)
                                    [self setMouseEnabled:NO];
#endif
                                    CCMenu *menu = (CCMenu*)[self getChildByTag:kEatFishGameSceneTagMenu];
                                    [menu setEnabled:NO];
                                    
                                    [nodeFish removeAllChildrenWithCleanup:YES];
                                    
                                    CCNode *gameOver = [CCBReader nodeGraphFromFile:@"scene_game_over.ccbi" owner:self];
                                    [gameOver setTag:kEatFishGameSceneTagGameOverMainNode];
                                    [gameOver setPosition:CGPointMake([[CCDirector sharedDirector] winSize].width / 2, [[CCDirector sharedDirector] winSize].height / 2)];
                                    [self addChild:gameOver];
                                    
                                    CCLabelTTF *gameOverLab1 = (CCLabelTTF*)[gameOver getChildByTag:kEatFishGameSceneTagGameOverMainNodeLab1];
                                    CCLabelTTF *gameOverLab2 = (CCLabelTTF*)[gameOver getChildByTag:kEatFishGameSceneTagGameOverMainNodeLab2];
                                    CCControlButton *gameOverBtnQuit = (CCControlButton*)[gameOver getChildByTag:kEatFishGameSceneTagGameOverMainNodeBtnQuit];
                                    CCControlButton *gameOverBtnRestart = (CCControlButton*)[gameOver getChildByTag:kEatFishGameSceneTagGameOverMainNodeBtnRestart];
                                    [gameOverLab1 setString:NSLocalizedString(@"GameScene_GameOverLab1", nil)];
                                    [gameOverLab2 setString:NSLocalizedString(@"GameScene_GameOverLab2", nil)];
                                    [gameOverBtnQuit setTitle:NSLocalizedString(@"GameScene_GameOverBtnQuit", nil) forState:CCControlStateNormal];
                                    [gameOverBtnRestart setTitle:NSLocalizedString(@"GameScene_GameOverBtnRestart", nil) forState:CCControlStateNormal];
                                }
                                else
                                {
                                    _eatFish = 0;
                                    
                                    //生命值减1
                                    [[SimpleAudioEngine sharedEngine] playEffect:@"playbyeat.mp3"];
                                    [self changePlayerLife:_playerLife - 1];
                                    [self scheduleOnce:@selector(gameRestart:) delay:2.5]; //等待一定时间后继续游戏
                                    
                                }
                            }
                        }
                        
                    }
                }
                
            }
            
        }
        
    }
    
    [targetAllFishs release];
    
}

- (void)jellyfishMoveEnd:(id)sender
{
    //NSLog(@"水母消失了");
    EatFishObjJellyfishNode *jellyfish = (EatFishObjJellyfishNode*)sender;
    [jellyfish removeFromParentAndCleanup:YES];
    
}

- (void)enemyFishMoveEnd:(id)sender
{
    //NSLog(@"enemy fish消失了");
    EatFishObjEnemyFishNode *enemyFishNode = (EatFishObjEnemyFishNode*)sender;
    [enemyFishNode removeFromParentAndCleanup:YES];
}

- (CGPoint)enemyFishRandomLeftPoint:(EatFishObjEnemyFishNode*)_enemyFishNode
{
    CGSize winSize = [[CCDirector sharedDirector] winSize];
    CGFloat x = 0;
    CGFloat minY = _enemyFishNode.contentSize.height / 2;
    CGFloat maxY = winSize.height - minY;
    CGFloat y = [OzgCCUtility randomRange:minY withMaxValue:maxY];
    return CGPointMake(x, y);
}

- (CGPoint)enemyFishRandomRightPoint:(EatFishObjEnemyFishNode*)_enemyFishNode
{
    CGSize winSize = [[CCDirector sharedDirector] winSize];
    CGFloat x = winSize.width + (_enemyFishNode.contentSize.width / 2);
    CGFloat minY = _enemyFishNode.contentSize.height / 2;
    CGFloat maxY = winSize.height - minY;
    CGFloat y = [OzgCCUtility randomRange:minY withMaxValue:maxY];
    return CGPointMake(x, y);
}

- (void)enemyFishEmergence:(EatFishObjEnemyFishNode*)_enemyFishNode
{
    CCNode *nodeFish = [self getChildByTag:kEatFishGameSceneTagNodeFish];
    
    CGPoint startPoint;
    CGPoint endPoint;
    //0.5为左边右边的机率各为50%
    if([OzgCCUtility randomRate:0.5])
    {
        //左边出现
        startPoint = [self enemyFishRandomLeftPoint:_enemyFishNode];
        endPoint = [self enemyFishRandomRightPoint:_enemyFishNode];
        [_enemyFishNode orientationRight]; //左边出现需要面向右边
    }
    else
    {
        //右边出现
        startPoint = [self enemyFishRandomRightPoint:_enemyFishNode];
        endPoint = [self enemyFishRandomLeftPoint:_enemyFishNode];
        [_enemyFishNode orientationLeft]; //右边出现需要面向左边
    }
    [_enemyFishNode setPosition:startPoint];
    [nodeFish addChild:_enemyFishNode];
    
    ccTime moveTime = [OzgCCUtility randomRange:10.0 withMaxValue:20.0];
    
    _enemyFishNode.isMoving = YES; //执行action需要强制设置成YES
    _enemyFishNode.moveTime = moveTime;
    _enemyFishNode.moveStartPoint = startPoint;
    _enemyFishNode.moveEndPoint = endPoint;
    [_enemyFishNode runAction:[CCSequence actionOne:[CCMoveTo actionWithDuration:moveTime position:endPoint] two:[CCCallFuncN actionWithTarget:self selector:@selector(enemyFishMoveEnd:)]]];
}

@end
