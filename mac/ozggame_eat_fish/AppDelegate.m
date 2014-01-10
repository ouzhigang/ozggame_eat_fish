//
//  AppDelegate.m
//  ozggame_eat_fish
//
//  Created by ozg on 14-1-9.
//  Copyright ozg 2014年. All rights reserved.
//

#import "AppDelegate.h"
#import "SimpleAudioEngine.h"
#import "AppConfig.h"
#import "EatFishStartScene.h"

@implementation ozggame_eat_fishAppDelegate
@synthesize window=window_, glView=glView_;

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
	CCDirectorMac *director = (CCDirectorMac*) [CCDirector sharedDirector];
    [glView_ setFrameSize:NSMakeSize(480, 320)];
    
	// enable FPS and SPF
	[director setDisplayStats:NO];
	
	// connect the OpenGL view with the director
	[director setView:glView_];

	// EXPERIMENTAL stuff.
	// 'Effects' don't work correctly when autoscale is turned on.
	// Use kCCDirectorResize_NoScale if you don't want auto-scaling.
	[director setResizeMode:kCCDirectorResize_AutoScale];
	
    [glView_ setFrameSize:NSMakeSize(window_.frame.size.width, window_.frame.size.height - 42)];
    
	// Enable "moving" mouse event. Default no.
	[window_ setAcceptsMouseMovedEvents:NO];
	
	// Center main window
	[window_ center];
	
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
    
	[director runWithScene:[EatFishStartScene scene]];
}

- (BOOL) applicationShouldTerminateAfterLastWindowClosed: (NSApplication *) theApplication
{
	return YES;
}

- (void)dealloc
{
	[[CCDirector sharedDirector] end];
	[window_ release];
	[super dealloc];
}

#pragma mark AppDelegate - IBActions

- (IBAction)toggleFullScreen: (id)sender
{
	CCDirectorMac *director = (CCDirectorMac*) [CCDirector sharedDirector];
	[director setFullScreen: ! [director isFullScreen] ];
}

@end
