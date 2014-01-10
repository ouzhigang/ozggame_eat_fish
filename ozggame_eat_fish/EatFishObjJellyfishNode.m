//
//  EatFishObjJellyfishNode.m
//  ozggame_eat_fish
//
//  Created by ozg on 13-11-6.
//  Copyright (c) 2013年 ozg. All rights reserved.
//

#import "EatFishObjJellyfishNode.h"

@interface EatFishObjJellyfishNode()

@end

@implementation EatFishObjJellyfishNode

+ (id)node
{
    EatFishObjJellyfishNode *obj = [[[EatFishObjJellyfishNode alloc] init] autorelease];
    return obj;
}

- (id)init
{
    self = [super initWithFishSpriteFrameNames:[EatFishObjFishData getJellyFish]];
    if(self)
    {
        self.typeName = APP_OBJ_TYPE_JELLYFISH; //这个属性来自父类
        
    }
    return self;
}

- (void)dealloc
{
    [self removeAllChildrenWithCleanup:YES];
    
    [super dealloc];
}

@end
