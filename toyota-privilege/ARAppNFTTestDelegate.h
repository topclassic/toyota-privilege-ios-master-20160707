//
//  ARAppNFTTestDelegate.h
//  ARAppNFTTest
//
//  Created by เฮียกวง on 6/3/2559 BE.
//  Copyright © 2559 Metamedia. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ARViewController;

@interface ARAppNFTTestDelegate : NSObject <UIApplicationDelegate> {
    UIWindow *window;
    ARViewController *viewController;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet ARViewController *viewController;

@end