//
//  AppDelegate.m
//  KML Explorer
//
//  Created by Vladimir Smirnov on 10/25/13.
//  Copyright (c) 2013 Vladimir Smirnov. All rights reserved.
//

#import "AppDelegate.h"

#import "KMLFiles.h"
#import <KML/KML.h>
#import <GoogleMaps/GoogleMaps.h>
#import <TestFlightSDK/TestFlight.h>

@implementation AppDelegate

@synthesize navController = _navController;
@synthesize files;

KMLFiles *filesView;
NSString *filesPlist;

NSURL *fileForImport;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [TestFlight takeOff:@"8a6dd9e1-e08e-4d8a-b926-2734ac0a08d6"];
    [GMSServices provideAPIKey:@"AIzaSyCMh79f5_jD-OZIeak8yQNUONs8Ln_RunM"];
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    
    KMLFiles *filesView = [[KMLFiles alloc] initWithStyle:UITableViewStylePlain];
    
    _navController = [[UINavigationController alloc] initWithRootViewController:filesView];
    
    filesPlist = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    filesPlist = [filesPlist stringByAppendingPathComponent:@"files.plist"];
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    if (![fileManager fileExistsAtPath:filesPlist]) {
        files = [[NSMutableArray alloc] init];
        
        [files writeToFile:filesPlist atomically:YES];
    } else {
        files = [[NSMutableArray alloc] initWithContentsOfFile:filesPlist];
    }
    
    [self.window setRootViewController:_navController];
    [self.window makeKeyAndVisible];
    
    return YES;
}

-(BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
    
    fileForImport = url;
    
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:[[url absoluteString] lastPathComponent]
                                                        message:NSLocalizedString(@"Enter desired name", NULL)
                                                       delegate:self
                                              cancelButtonTitle:NSLocalizedString(@"Cancel", NULL)
                                              otherButtonTitles:NSLocalizedString(@"OK", NULL),
                              nil];
    
    alertView.tag = 1;
    alertView.alertViewStyle = UIAlertViewStylePlainTextInput;

    [alertView show];
    
    return YES;
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 1 && alertView.tag == 1) {
        KMLRoot *KMLRoot = [KMLParser parseKMLAtURL:fileForImport];
        
        if (!KMLRoot || [[KMLRoot placemarks] count] == 0) {
            UIAlertView *errorAlert = [[UIAlertView alloc] initWithTitle:[[fileForImport absoluteString] lastPathComponent]
                                                                message:NSLocalizedString(@"Parsing error, wrong KML format", NULL)
                                                               delegate:nil
                                                      cancelButtonTitle:NSLocalizedString(@"OK", NULL)
                                                      otherButtonTitles:nil
                                      ];
            [errorAlert show];
        } else {
            NSString *UUIDString = [[NSUUID UUID] UUIDString];
            
            
            NSDictionary *newFile = [[NSDictionary alloc] initWithObjectsAndKeys:
                                    [[alertView textFieldAtIndex: 0] text], @"title",
                                     UUIDString, @"uuid",
                                     [[fileForImport absoluteString] lastPathComponent], @"filename"
                                     , nil];
            
            NSString *newFilePath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
            newFilePath = [newFilePath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.kml", UUIDString]];
            
            [[KMLRoot kml] writeToFile:newFilePath atomically:YES encoding:NSUTF8StringEncoding error:nil];
                        
            [files addObject:newFile];
            [files writeToFile:filesPlist atomically:YES];
            
            filesView = [[_navController viewControllers] objectAtIndex:0];
            [[filesView tableView] reloadData];
        }
    }
}
@end
