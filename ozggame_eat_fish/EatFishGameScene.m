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

- (void)changeScore:(NSInteger)score; //分数发生改变时调用
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
        
        //test
        //[player changeStatus:kEatFishObjPlayerNodeStatusBig];
        
        //AI控制的鱼和水母的层
        CCNode *nodeAI = [CCNode node];
        [nodeAI setAnchorPoint:CGPointZero];
        [nodeAI setPosition:CGPointZero];
        [nodeAI setTag:kEatFishGameSceneTagNodeAI];
        [self addChild:nodeAI];
        
        //右上角的部分
        CCLabelTTF *checkpointsLab = [CCLabelTTF labelWithString:[NSString stringWithFormat:@"关卡：%i", _checkpoints] fontName:@"Arial-BoldMT" fontSize:15 dimensions:CGSizeMake(100, 20) hAlignment:kCCTextAlignmentLeft];
        [checkpointsLab setPosition:CGPointMake(winSize.width - 50, winSize.height - 12)];
        [checkpointsLab setTag:kEatFishGameSceneTagCheckpoints];
        [self addChild:checkpointsLab];
        
        CCLabelTTF *scoreLab = [CCLabelTTF labelWithString:[NSString stringWithFormat:@"分数：%i", _score] fontName:@"Arial-BoldMT" fontSize:15 dimensions:CGSizeMake(100, 20) hAlignment:kCCTextAlignmentLeft];
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
        
        CCSprite *fishLife = [CCSprite spriteWithSpriteFrameName:@"fishlife.png"];
        [fishLife setPosition:CGPointMake(35, 275)];
        [fishLife setTag:kEatFishGameSceneTagFishLife];
        [self addChild:fishLife];
        
        CCLabelTTF *fishLifeLab = [CCLabelTTF labelWithString:[NSString stringWithFormat:@"%i", _playerLife] fontName:@"Arial-BoldMT" fontSize:15 dimensions:CGSizeMake(50, 20) hAlignment:kCCTextAlignmentLeft];
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
    
    //随机性质的事件和AI都在这里计算
    [self scheduleUpdate];
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
                //NSLog(@"暂停游戏");
                [[SimpleAudioEngine sharedEngine] playEffect:@"btn.wav"];
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
    [[SimpleAudioEngine sharedEngine] playEffect:@"btn.wav"];
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

- (void)changeScore:(NSInteger)score
{
    _score = score;
    
    CCLabelTTF *scoreLab = (CCLabelTTF*)[self getChildByTag:kEatFishGameSceneTagScore];
    [scoreLab setString:[NSString stringWithFormat:@"分数：%i", _score]];
}

- (void)changeCheckpoints:(NSInteger)checkpoints
{
    _checkpoints = checkpoints;
    
    CCLabelTTF *checkpointsLab = (CCLabelTTF*)[self getChildByTag:kEatFishGameSceneTagCheckpoints];
    [checkpointsLab setString:[NSString stringWithFormat:@"关卡：%i", _checkpoints]];    
}

- (void)changePlayerLife:(NSInteger)playerLife
{
    _playerLife = playerLife;
    
    CCLabelTTF *fishLifeLab = (CCLabelTTF*)[self getChildByTag:kEatFishGameSceneTagFishLifeLab];
    [fishLifeLab setString:[NSString stringWithFormat:@"%i", _playerLife]];
}

//cocos2d update
- (void)update:(ccTime)delta
{
    CGSize winSize = [[CCDirector sharedDirector] winSize];
    
    //AI鱼和水母出现的层
    CCNode *nodeAI = [self getChildByTag:kEatFishGameSceneTagNodeAI];
    
    //player
    EatFishObjPlayerNode *player = (EatFishObjPlayerNode*)[self getChildByTag:kEatFishGameSceneTagPlayer];
    
    //水母
    if([OzgCCUtility randomRate:APP_AI_JELLYFISH])
    {
        //NSLog(@"水母出现了");
        
        EatFishObjJellyfishNode *jellyfish = [EatFishObjJellyfishNode node];
        
        CGFloat srcX = [OzgCCUtility randomRange:jellyfish.contentSize.width / 2 withMaxValue:winSize.width - (jellyfish.contentSize.width / 2)];
        
        [jellyfish setPosition:CGPointMake(srcX, -jellyfish.contentSize.height / 2)];
        
        [nodeAI addChild:jellyfish];
        
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
    
    //碰撞
//    if(!player.statusIsInvincible)
//    {
    
//        EatFishObjJellyfishNode *srcObj = NULL;
//        CCARRAY_FOREACH(allFishs, srcObj)
//        {
//            if(CGRectIntersectsRect([srcObj boundingBox], [player boundingBox]))
//            {
//                NSLog(@"player跟水母碰撞了");
//            }
//        }
//    }
    
    NSArray *srcAllFishs = [[nodeAI children] getNSArray];
    NSArray *targetAllFishs = [srcAllFishs copy];
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
                    if(((EatFishObjEnemyFishNode*)srcObj).status < kEatFishObjEnemyFishNodeStatus5)
                    {
                        //AI鱼跟水母的处理
                        NSLog(@"AI鱼跟水母碰撞了");
                        
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
    CCNode *nodeAI = [self getChildByTag:kEatFishGameSceneTagNodeAI];
    
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
    [nodeAI addChild:_enemyFishNode];
    
    ccTime moveTime = [OzgCCUtility randomRange:10.0 withMaxValue:20.0];
    
    _enemyFishNode.moveTime = moveTime;
    _enemyFishNode.moveStartPoint = startPoint;
    _enemyFishNode.moveEndPoint = endPoint;
    [_enemyFishNode runAction:[CCSequence actionOne:[CCMoveTo actionWithDuration:moveTime position:endPoint] two:[CCCallFuncN actionWithTarget:self selector:@selector(enemyFishMoveEnd:)]]];
}

@end
