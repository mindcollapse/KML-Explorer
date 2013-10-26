//
//  KMLView.h
//  KML Explorer
//
//  Created by Vladimir Smirnov on 10/25/13.
//  Copyright (c) 2013 Vladimir Smirnov. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <GoogleMaps/GoogleMaps.h>

@interface KMLView : UIViewController <GMSMapViewDelegate>

- (id) initWithKMLFile: (NSDictionary *) filedata;
- (void) zoomToCoordinate: (CLLocationCoordinate2D) coord;

@end
