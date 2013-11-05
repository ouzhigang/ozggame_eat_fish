//
//  EatFishObjFishNode.h
//  ozggame_eat_fish
//
//  Created by 欧志刚 on 13-11-3.
//  Copyright (c) 2013年 欧志刚. All rights reserved.
//

#import "cocos2d.h"
#import "AppConfig.h"

enum EatFishObjFishNodeTag
{
    kEatFishObjFishNodeTagMainSprite = 0
};

@interface EatFishObjFishNode : CCNode

+ (id)nodeWithFishSpriteFrameNames:(NSArray*)fishSpriteFrameNames;
- (id)initWithFishSpriteFrameNames:(NSArray*)fishSpriteFrameNames;

- (void)orientationLeft; //转向左边
- (void)orientationRight; //转向右边

@end
