//
//  KMLPOIView.m
//  KML Explorer
//
//  Created by Vladimir Smirnov on 10/25/13.
//  Copyright (c) 2013 Vladimir Smirnov. All rights reserved.
//

#import "KMLView.h"
#import "KMLPOIView.h"
#import <GoogleMaps/GoogleMaps.h>

@interface KMLPOIView ()
{
    NSArray *mapmarkers;
    NSMutableArray *tableData;
}
@end

@implementation KMLPOIView

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        [[self navigationItem] setTitle:NSLocalizedString(@"POIs List", NULL)];
    }
    return self;
}

- (id) initWithMarkers: (NSArray *) markers {
    mapmarkers = markers;
    tableData = [[NSMutableArray alloc] initWithArray:mapmarkers];
    
    self = [self initWithStyle:UITableViewStylePlain];
    
    return self;
}


- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    tableData = [[NSMutableArray alloc] init];
    
    if(![searchText isEqualToString:@""]) {
        for (GMSMarker *marker in mapmarkers) {
            NSRange title_r = [[marker title] rangeOfString:searchText options:NSCaseInsensitiveSearch];
            NSRange snippet_r = [[marker snippet] rangeOfString:searchText options:NSCaseInsensitiveSearch];
            
            if (([[marker title] length] > 0 && title_r.location != NSNotFound) || ([[marker snippet] length] > 0 && snippet_r.location != NSNotFound)) {
                [tableData addObject:marker];
            }
        }
    } else {
        tableData = [[NSMutableArray alloc] initWithArray:mapmarkers];
    }
    
    [[self tableView] reloadData];
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    UISearchBar *searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0, 0, 320, 44)];
    [searchBar setDelegate:self];
    [[self tableView] setTableHeaderView:searchBar];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [tableData count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"poiCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
        [cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
    }
    
    GMSMarker *marker = [tableData objectAtIndex:[indexPath row]];
    
    [[cell textLabel] setText:[marker title]];
    [[cell detailTextLabel] setText:[marker snippet]];

    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    GMSMarker *marker = [tableData objectAtIndex:[indexPath row]];
    KMLView * viewController = [self.navigationController.viewControllers objectAtIndex:1];
    [viewController zoomToCoordinate:[marker position]];
    
    [[self navigationController] popViewControllerAnimated:YES];
}


@end
