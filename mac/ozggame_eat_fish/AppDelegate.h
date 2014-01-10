//
//  AppDelegate.h
//  ozggame_eat_fish
//
//  Created by ozg on 14-1-9.
//  Copyright ozg 2014年. All rights reserved.
//

#import "cocos2d.h"

@interface ozggame_eat_fishAppDelegate : NSObject <NSApplicationDelegate>
{
	NSWindow	*window_;
	CCGLView	*glView_;
}

@property (assign) IBOutlet NSWindow	*window;
@property (assign) IBOutlet CCGLView	*glView;

- (IBAction)toggleFullScreen:(id)sender;

@end
