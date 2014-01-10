//
//  IntroLayer.m
//  ozggame_eat_fish
//
//  Created by ozg on 13-11-2.
//  Copyright ozg 2013年. All rights reserved.
//


// Import the interfaces
#import "IntroLayer.h"

#pragma mark - IntroLayer

@interface IntroLayer()

@end

@implementation IntroLayer

// Helper class method that creates a Scene with the HelloWorldLayer as the only child.
+(CCScene *) scene
{
	// 'scene' is an autorelease object.
	CCScene *scene = [CCScene node];
	
	// 'layer' is an autorelease object.
	IntroLayer *layer = [IntroLayer node];
	
	// add layer as a child to scene
	[scene addChild: layer];
	
	// return the scene
	return scene;
}

// 
-(id) init
{
	if( (self=[super init])) {

		// ask director for the window size
		CGSize size = [[CCDirector sharedDirector] winSize];

		CCSprite *background;
		
		if( UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone ) {
			background = [CCSprite spriteWithFile:@"Default.png"];
			background.rotation = 90;
		} else {
			background = [CCSprite spriteWithFile:@"Default-Landscape~ipad.png"];
		}
        [background setTag:0];
		background.position = ccp(size.width/2, size.height/2);

		// add the label as a child to this Layer
		[self addChild: background];
	}
	
	return self;
}

- (void)dealloc
{
    
    [super dealloc];
}

-(void) onEnter
{
	[super onEnter];
    
    CCNode *background = [self getChildByTag:0];
    [background removeFromParentAndCleanup:YES];
    [[CCTextureCache sharedTextureCache] removeTextureForKey:@"Default.png"];
    
    //声音的处理
    if(![[NSUserDefaults standardUserDefaults] objectIsForcedForKey:APP_CFG_BGSOUND])
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:APP_CFG_BGSOUND];
    if(![[NSUserDefaults standardUserDefaults] objectIsForcedForKey:APP_CFG_EFFECT])
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:APP_CFG_EFFECT];
    
    if([[NSUserDefaults standardUserDefaults] boolForKey:APP_CFG_BGSOUND])
        [[SimpleAudioEngine sharedEngine] setBackgroundMusicVolume:1.0];
    else
        [[SimpleAudioEngine sharedEngine] setBackgroundMusicVolume:0.0];
    
    if([[NSUserDefaults standardUserDefaults] boolForKey:APP_CFG_EFFECT])
        [[SimpleAudioEngine sharedEngine] setEffectsVolume:1.0];
    else
        [[SimpleAudioEngine sharedEngine] setEffectsVolume:0.0];
    //声音处理结束
    
	[[CCDirector sharedDirector] replaceScene:[CCTransitionFade transitionWithDuration:1.0 scene:[EatFishStartScene scene] ]];
}
@end
