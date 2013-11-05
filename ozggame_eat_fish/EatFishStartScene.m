//
//  EatFishStartScene.m
//  ozggame_eat_fish
//
//  Created by 欧志刚 on 13-11-2.
//  Copyright (c) 2013年 欧志刚. All rights reserved.
//

#import "EatFishStartScene.h"

@interface EatFishStartScene()

- (void)onButtonTouched:(id)sender;
- (void)showMain;
- (void)hideMain;
- (void)showHelp;
- (void)hideHelp;

@end

@implementation EatFishStartScene

- (id)init
{
    self = [super init];
    if(self)
    {        
        CGSize winSize = [[CCDirector sharedDirector] winSize];
        
        CCNode *rootNode = [CCBReader nodeGraphFromFile:[OzgCCUtility getImagePath:@"scene_start.ccbi"] owner:self];
        [rootNode setPosition:CGPointMake(winSize.width / 2, winSize.height / 2)];
        [rootNode setTag:kEatFishStartTagRootNode];
        [self addChild:rootNode];
        
    }
    return self;
}

- (void)dealloc
{
    CCNode *rootNode = [self getChildByTag:kEatFishStartTagRootNode];
    [rootNode removeFromParentAndCleanup:YES];
    [[CCTextureCache sharedTextureCache] removeTextureForKey:[OzgCCUtility getImagePath:@"bg1.png"]];
    [[CCTextureCache sharedTextureCache] removeTextureForKey:@"btn1_dw.png"];
    [[CCTextureCache sharedTextureCache] removeTextureForKey:@"btn1_up.png"];
    
    //[[CCTextureCache sharedTextureCache] dumpCachedTextureInfo];
    //NSLog(@"EatFishStartScene dealloc");
    [super dealloc];
}

+ (CCScene*)scene
{
    CCScene *s = [CCScene node];
    EatFishStartScene *layer = [EatFishStartScene node];
    [s addChild:layer];
    return s;
}

- (void)onButtonTouched:(id)sender
{
    CCControlButton *btn = (CCControlButton*)sender;
    
    switch (btn.tag)
    {
        case kEatFishStartTagBtnStart:
        {
            //NSLog(@"开始游戏");
            CCScene *s = [EatFishGameScene scene];
            CCTransitionFade *t = [CCTransitionFade transitionWithDuration:APP_TRANSITION scene:s];
            [[CCDirector sharedDirector] replaceScene:t];
        }
            break;
            
        case kEatFishStartTagBtnBluetooth:
        {
            [[SimpleAudioEngine sharedEngine] playEffect:@"btn.wav"];
            
            //NSLog(@"蓝牙连接");
            UIAlertView *alert = [[[UIAlertView alloc] initWithTitle:APP_ALERT_TITLE message:@"本功能未完成" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"监听周边玩家", @"扫描周边玩家", nil] autorelease];
            [alert show];
            
        }
            break;
            
        case kEatFishStartTagBtnHelp:
        {
            [[SimpleAudioEngine sharedEngine] playEffect:@"btn.wav"];
            
            //NSLog(@"游戏帮助");
            [self hideMain];
            [self showHelp];
        }
            break;
        case kEatFishStartTagHelpBtnBack:
        {
            [[SimpleAudioEngine sharedEngine] playEffect:@"btn.wav"];
            
            //NSLog(@"游戏帮助");
            [self hideHelp];
            [self showMain];
        }
            break;
    }
    
}

//UIAlertViewDelegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    switch (buttonIndex)
    {
        case 1:
        {
            NSLog(@"监听周边玩家");
            
        }
            break;
        case 2:
        {
            NSLog(@"扫描周边玩家");
            
        }
            break;
        default:
            NSLog(@"取消");
            break;
    }
}

- (void)showMain
{
    CCNode *rootNode = [self getChildByTag:kEatFishStartTagRootNode];
    CCNode *title = [rootNode getChildByTag:kEatFishStartTagTitle];
    CCNode *btnStart = [rootNode getChildByTag:kEatFishStartTagBtnStart];
    CCNode *btnBluetooth = [rootNode getChildByTag:kEatFishStartTagBtnBluetooth];
    CCNode *btnHelp = [rootNode getChildByTag:kEatFishStartTagBtnHelp];
    
    [title setVisible:YES];
    [btnStart setVisible:YES];
    [btnBluetooth setVisible:YES];
    [btnHelp setVisible:YES];
}

- (void)hideMain
{
    CCNode *rootNode = [self getChildByTag:kEatFishStartTagRootNode];
    CCNode *title = [rootNode getChildByTag:kEatFishStartTagTitle];
    CCNode *btnStart = [rootNode getChildByTag:kEatFishStartTagBtnStart];
    CCNode *btnBluetooth = [rootNode getChildByTag:kEatFishStartTagBtnBluetooth];
    CCNode *btnHelp = [rootNode getChildByTag:kEatFishStartTagBtnHelp];
    
    [title setVisible:NO];
    [btnStart setVisible:NO];
    [btnBluetooth setVisible:NO];
    [btnHelp setVisible:NO];
}

- (void)showHelp
{
    CCNode *help = (CCSprite*)[self getChildByTag:kEatFishStartTagHelp];
    if(!help)
    {
        CGSize winSize = [[CCDirector sharedDirector] winSize];
        
        help = [CCBReader nodeGraphFromFile:[OzgCCUtility getImagePath:@"scene_start_help.ccbi"] owner:self];
        [help setPosition:CGPointMake(winSize.width / 2, winSize.height / 2)];
        [help setTag:kEatFishStartTagHelp];
        [self addChild:help];
        
    }
    
}

- (void)hideHelp
{
    CCNode *help = [self getChildByTag:kEatFishStartTagHelp];
    if(help)
        [help removeFromParentAndCleanup:YES];
    
}

@end
