//
//  ARAppNFTTestDelegate.m
//  ARAppNFTTest
//
//  Created by เฮียกวง on 6/3/2559 BE.
//  Copyright © 2559 Metamedia. All rights reserved.
//


#import "ARAppNFTTestDelegate.h"
#import "ARViewController.h"


@implementation ARAppNFTTestDelegate

@synthesize window;
@synthesize viewController;

- (void)applicationDidFinishLaunching:(UIApplication *)application {
    
    // Override point for customization after app launch
    
    // Set working directory so that camera parameters, models etc. can be loaded using relative paths.
    NSLog(@"in ARAppNFTTestDelegate applicationDidFinishLaunching");
    arUtilChangeToResourcesDirectory(AR_UTIL_RESOURCES_DIRECTORY_BEHAVIOR_BEST, NULL);
    
    self.window.rootViewController = self.viewController;
    [window makeKeyAndVisible];
}

// Application has been interrupted, by e.g. a phone call.
- (void)applicationWillResignActive:(UIApplication *)application {
    NSLog(@"in ARAppNFTTestDelegate applicationWillResignActive");
    viewController.paused = TRUE;
}

// The interruption ended.
- (void)applicationDidBecomeActive:(UIApplication *)application {
    NSLog(@"in ARAppNFTTestDelegate applicationDidBecomeActive");
    viewController.paused = FALSE;
}

// User pushed home button. Save state etc.
- (void)applicationWillTerminate:(UIApplication *)application {
}

- (void)dealloc {
    
    [viewController release];
    [window release];
    [super dealloc];
}

@end