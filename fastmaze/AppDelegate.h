//
//  AppDelegate.h
//  fastmaze
//
//  Created by Eric on 13-2-24.
//  Copyright appcpu.com 2013年. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "cocos2d.h"
#import "AdWhirlView.h"

@interface AppController : NSObject <UIApplicationDelegate, CCDirectorDelegate,AdWhirlDelegate,UIAlertViewDelegate>
{
	UIWindow *window_;
	UINavigationController *navController_;

	CCDirectorIOS	*director_;							// weak ref
}

@property (nonatomic, retain) UIWindow *window;
@property (readonly) UINavigationController *navController;
@property (readonly) CCDirectorIOS *director;

@end
