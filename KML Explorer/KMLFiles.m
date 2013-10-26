//
//  KMLFiles.m
//  KML Explorer
//
//  Created by Vladimir Smirnov on 10/25/13.
//  Copyright (c) 2013 Vladimir Smirnov. All rights reserved.
//

#import "AppDelegate.h"
#import "KMLFiles.h"
#import "KMLView.h"

@interface KMLFiles ()
{
    AppDelegate *appdelegate;
}
@end

@implementation KMLFiles

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        [[self navigationItem] setTitle:NSLocalizedString(@"KML Files", NULL)];
        appdelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [[appdelegate files] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"kmlCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
        [cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
    }
    
    NSDictionary *KMLRecord =[[appdelegate files] objectAtIndex:[indexPath row]];
    
    
    [[cell textLabel] setText:[KMLRecord objectForKey:@"title"]];
    [[cell detailTextLabel] setText:[KMLRecord objectForKey:@"filename"]];

    return cell;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        NSDictionary *KMLRecord =[[appdelegate files] objectAtIndex:[indexPath row]];
        
        NSFileManager *fileManager = [NSFileManager defaultManager];
        NSString *removeFilePath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
        removeFilePath = [removeFilePath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.kml", [KMLRecord objectForKey:@"uuid"]]];
        [fileManager removeItemAtPath:removeFilePath error:nil];
        
        NSString *filesPlist = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
        filesPlist = [filesPlist stringByAppendingPathComponent:@"files.plist"];
        [[appdelegate files] removeObjectAtIndex:[indexPath row]];
        [[appdelegate files] writeToFile:filesPlist atomically:YES];
        
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
    }
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *KMLRecord =[[appdelegate files] objectAtIndex:[indexPath row]];
    
    KMLView *viewer = [[KMLView alloc] initWithKMLFile:KMLRecord];
    
    [[self navigationController] pushViewController:viewer animated:YES];
}


@end
