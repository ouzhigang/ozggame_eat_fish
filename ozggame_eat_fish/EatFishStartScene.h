//
//  EatFishStartScene.h
//  ozggame_eat_fish
//
//  Created by 欧志刚 on 13-11-2.
//  Copyright (c) 2013年 欧志刚. All rights reserved.
//

#import "EatFishBaseScene.h"
#import "EatFishGameScene.h"

enum EatFishStartTag
{
    kEatFishStartTagRootNode = 99,
    kEatFishStartTagBg = 0,
    kEatFishStartTagTitle = 1,
    kEatFishStartTagBtnStart = 2,
    kEatFishStartTagBtnBluetooth = 3,
    kEatFishStartTagBtnHelp = 4,
    kEatFishStartTagHelp = 5,
    kEatFishStartTagHelpMain = 6,
    kEatFishStartTagHelpBtnBack = 7
    
};

@interface EatFishStartScene : EatFishBaseScene<UIAlertViewDelegate>

+ (CCScene*)scene;

@end
