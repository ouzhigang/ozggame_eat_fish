//
//  EatFishGameScene.h
//  ozggame_eat_fish
//
//  Created by 欧志刚 on 13-11-3.
//  Copyright (c) 2013年 欧志刚. All rights reserved.
//

#import "EatFishBaseScene.h"
#import "EatFishObjFishNode.h"
#import "EatFishObjPlayerNode.h"
#import "EatFishStartScene.h"
#import "EatFishObjJellyfishNode.h"
#import "EatFishObjEnemyFishNode.h"

enum EatFishGameSceneTag
{
    kEatFishGameSceneTagBg = 0,
    kEatFishGameSceneTagPlayer = 1,
    kEatFishGameSceneTagBlisterLeft = 2,
    kEatFishGameSceneTagBlisterRight = 3,
    kEatFishGameSceneTagCheckpoints = 4,
    kEatFishGameSceneTagScore = 5,
    kEatFishGameSceneTagMenu = 6,
    kEatFishGameSceneTagMenuPause = 7,
    kEatFishGameSceneTagPauseBg = 8,
    kEatFishGameSceneTagPauseBtnResume = 9,
    kEatFishGameSceneTagPauseBtnBgSound = 10,
    kEatFishGameSceneTagPauseBtnEffect = 11,
    kEatFishGameSceneTagPauseBtnQuit = 12,
    kEatFishGameSceneTagPauseMainNode = 13,
    kEatFishGameSceneTagProgress = 23,
    kEatFishGameSceneTagProgressBg = 14,
    kEatFishGameSceneTagFishLife = 15,
    kEatFishGameSceneTagFishLifeLab = 16,
    kEatFishGameSceneTagNodeFish = 17,
    kEatFishGameSceneTagGameOverMainNode = 18,
    kEatFishGameSceneTagGameOverMainNodeLab1 = 19,
    kEatFishGameSceneTagGameOverMainNodeLab2 = 20,
    kEatFishGameSceneTagGameOverMainNodeBtnQuit = 21,
    kEatFishGameSceneTagGameOverMainNodeBtnRestart = 22,
    kEatFishGameSceneTagGameClearMainNode = 24,
    kEatFishGameSceneTagGameClearMainNodeLab1 = 25,
    kEatFishGameSceneTagGameClearMainNodeBtnQuit = 26,
    kEatFishGameSceneTagGameClearMainNodeBtnNext = 27,
    kEatFishGameSceneTagGameClearMainNodeLab2 = 28,
    kEatFishGameSceneTagGameClearMainNodeLab3 = 29,
    kEatFishGameSceneTagGameClearMainNodeLab4 = 30
};

enum EatFishGameSceneAlertTag
{
    kEatFishGameSceneAlertTagQuit = 100
};

@interface EatFishGameScene : EatFishBaseScene<UIAlertViewDelegate>

+ (CCScene*)scene;

@end
