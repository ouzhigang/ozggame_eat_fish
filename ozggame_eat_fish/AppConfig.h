//
//  AppConfig.h
//  ozggame_eat_fish
//
//  Created by ozg on 13-11-2.
//  Copyright (c) 2013年 ozg. All rights reserved.
//

#ifndef ozggame_eat_fish_AppConfig_h
#define ozggame_eat_fish_AppConfig_h

#define APP_OBJ_FISH_ANIM 0.12 //鱼帧动画的播放速度
#define APP_PLAYER_INVINCIBLE 4.0 //玩家的初始化无敌时间
#define APP_PLAYER_INVINCIBLE2 30.0 //玩家使用道具获得的无敌时间
#define APP_TRANSITION 1.0f //过场时间
#define APP_PLAYER_LIFE 2 //player默认的生命值
#define APP_AI_JELLYFISH 0.0005 //水母每帧的出现机率 1/2000的机率
//各个AI鱼的出现机率
#define APP_AI_FISH1 0.05
#define APP_AI_FISH2 0.05
#define APP_AI_FISH3 0.00625
#define APP_AI_FISH4 0.00375
#define APP_AI_FISH5 0.00125
#define APP_AI_FISH6 0.00125

#define APP_CFG_BGSOUND @"APP_CFG_BGSOUND" //是否播放背景声音
#define APP_CFG_EFFECT @"APP_CFG_EFFECT" //是否播放效果音

//游戏对象的名称
#define APP_OBJ_TYPE_PLAYER @"player"
#define APP_OBJ_TYPE_FISH @"fish"
#define APP_OBJ_TYPE_JELLYFISH @"jellyfish"

//吃了一条鱼所加的分数
#define APP_SCORE_FISH1 1
#define APP_SCORE_FISH2 1
#define APP_SCORE_FISH3 2
#define APP_SCORE_FISH4 3

//最高分数
#define APP_MAX_SCORE 99999

//最高关卡（CP即checkpoints）
#define APP_MAX_CP 99

//升级到中等或大的所需分数
#define APP_PLAYER_STATUS_MIDDLE 145 //这个值必须为APP_CP_CLEAR的29%
#define APP_PLAYER_STATUS_BIG 305 //这个值必须为APP_CP_CLEAR的61%

//吃够多少条鱼过一关
#define APP_CP_CLEAR 500 //小鱼+1，中鱼+2，大鱼+3

#endif
