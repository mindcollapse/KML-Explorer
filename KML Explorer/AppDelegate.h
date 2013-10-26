//
//  AppDelegate.h
//  KML Explorer
//
//  Created by Vladimir Smirnov on 10/25/13.
//  Copyright (c) 2013 Vladimir Smirnov. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate, UIAlertViewDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (nonatomic, strong) UINavigationController *navController;

@property (nonatomic, strong) NSMutableArray *files;

@end
