//
//  KMLPOIView.h
//  KML Explorer
//
//  Created by Vladimir Smirnov on 10/25/13.
//  Copyright (c) 2013 Vladimir Smirnov. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <GoogleMaps/GoogleMaps.h>

@interface KMLPOIView : UITableViewController <UITableViewDelegate, UISearchBarDelegate>

- (id) initWithMarkers: (NSArray *) markers;

@end
