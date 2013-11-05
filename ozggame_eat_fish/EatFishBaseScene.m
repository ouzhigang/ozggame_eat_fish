//
//  EatFishBaseScene.m
//  ozggame_eat_fish
//
//  Created by 欧志刚 on 13-11-2.
//  Copyright (c) 2013年 欧志刚. All rights reserved.
//

#import "EatFishBaseScene.h"

@interface EatFishBaseScene()

@end

@implementation EatFishBaseScene

- (id)init
{
    self = [super init];
    if(self)
    {
        if(![[SimpleAudioEngine sharedEngine] isBackgroundMusicPlaying])
            [[SimpleAudioEngine sharedEngine] playBackgroundMusic:@"bg.mp3" loop:YES];
        
    }
    return self;
}

@end
