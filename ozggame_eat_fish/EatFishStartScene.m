//
//  EatFishStartScene.m
//  ozggame_eat_fish
//
//  Created by ozg on 13-11-2.
//  Copyright (c) 2013年 ozg. All rights reserved.
//

#import "EatFishStartScene.h"

@interface EatFishStartScene()

- (void)onButtonTouched:(id)sender;

#ifdef  __CC_PLATFORM_MAC
- (void)alertDidEnd:(NSAlert *)alert withReturnCode:(NSInteger)returnCode withContextInfo:(void *)contextInfo;
#endif

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
        
        CCControlButton *btnStart = (CCControlButton*)[rootNode getChildByTag:kEatFishStartTagBtnStart];
        [btnStart setTitle:NSLocalizedString(@"StartScene_BtnStart", nil) forState:CCControlStateNormal];
        
        CCControlButton *btnBluetooth = (CCControlButton*)[rootNode getChildByTag:kEatFishStartTagBtnBluetooth];
        [btnBluetooth setTitle:NSLocalizedString(@"StartScene_BtnBluetooth", nil) forState:CCControlStateNormal];
        
        CCControlButton *btnHelp = (CCControlButton*)[rootNode getChildByTag:kEatFishStartTagBtnHelp];
        [btnHelp setTitle:NSLocalizedString(@"StartScene_BtnHelp", nil) forState:CCControlStateNormal];
        
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
    [[CCTextureCache sharedTextureCache] removeTextureForKey:@"scene_start_title.png"];
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
//            UIAlertView *alert = [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Alert_Title", nil) message:@"" delegate:self cancelButtonTitle:NSLocalizedString(@"StartScene_AlertBtnCancel", nil) otherButtonTitles:NSLocalizedString(@"StartScene_AlertBtnMonitor", nil), NSLocalizedString(@"StartScene_AlertBtnScan", nil), nil] autorelease];
//            [alert show];
            
#ifdef __CC_PLATFORM_IOS
            UIAlertView *alert = [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Alert_Title", nil) message:@"本功能未完成" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil] autorelease];
            [alert show];
#elif defined(__CC_PLATFORM_MAC)
            NSAlert *alert = [[[NSAlert alloc] init] autorelease];
            alert.delegate = self;
            [alert addButtonWithTitle:@"确定"];
            [alert setMessageText:NSLocalizedString(@"Alert_Title", nil)];
            [alert setInformativeText:@"Mac版不支持蓝牙"];
            [alert setAlertStyle:NSWarningAlertStyle];            
            [alert beginSheetModalForWindow:[[[CCDirectorMac sharedDirector] view] window] modalDelegate:self didEndSelector:@selector(alertDidEnd:withReturnCode:withContextInfo:) contextInfo:nil];
#endif
            
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
#ifdef __CC_PLATFORM_IOS
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
#elif defined(__CC_PLATFORM_MAC)
- (void)alertDidEnd:(NSAlert *)alert withReturnCode:(NSInteger)returnCode withContextInfo:(void *)contextInfo
{
    NSLog(@"Mac版本不支持蓝牙");
}
#endif

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
        
        CCControlButton *btnBack = (CCControlButton*)[help getChildByTag:kEatFishStartTagHelpBtnBack];
        CCLabelTTF *helpTitle = (CCLabelTTF*)[help getChildByTag:kEatFishStartTagHelpTitle];
        CCLabelTTF *help1 = (CCLabelTTF*)[help getChildByTag:kEatFishStartTagHelp1];
        CCLabelTTF *help2 = (CCLabelTTF*)[help getChildByTag:kEatFishStartTagHelp2];
        CCLabelTTF *help3 = (CCLabelTTF*)[help getChildByTag:kEatFishStartTagHelp3];
        
        [btnBack setTitle:NSLocalizedString(@"StartScene_HelpBtnBack", nil) forState:CCControlStateNormal];
        [helpTitle setString:NSLocalizedString(@"StartScene_HelpTitle", nil)];
        [help1 setString:NSLocalizedString(@"StartScene_Help1", nil)];
        [help2 setString:NSLocalizedString(@"StartScene_Help2", nil)];
        [help3 setString:NSLocalizedString(@"StartScene_Help3", nil)];
        
    }
    
}

- (void)hideHelp
{
    CCNode *help = [self getChildByTag:kEatFishStartTagHelp];
    if(help)
        [help removeFromParentAndCleanup:YES];
    
}

@end
