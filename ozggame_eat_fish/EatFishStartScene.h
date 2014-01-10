//
//  EatFishStartScene.h
//  ozggame_eat_fish
//
//  Created by ozg on 13-11-2.
//  Copyright (c) 2013年 ozg. All rights reserved.
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
    kEatFishStartTagHelpBtnBack = 7,
    kEatFishStartTagHelpTitle = 8,
    kEatFishStartTagHelp1 = 9,
    kEatFishStartTagHelp2 = 10,
    kEatFishStartTagHelp3 = 11
};

#ifdef __CC_PLATFORM_IOS
@interface EatFishStartScene : EatFishBaseScene<UIAlertViewDelegate>

+ (CCScene*)scene;

@end
#elif defined(__CC_PLATFORM_MAC)
@interface EatFishStartScene : EatFishBaseScene<NSAlertDelegate>

+ (CCScene*)scene;

@end
#endif
