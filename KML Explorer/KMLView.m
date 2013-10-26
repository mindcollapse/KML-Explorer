//
//  KMLView.m
//  KML Explorer
//
//  Created by Vladimir Smirnov on 10/25/13.
//  Copyright (c) 2013 Vladimir Smirnov. All rights reserved.
//

#import <GoogleMaps/GoogleMaps.h>
#import <KML/KML.h>
#import "KMLView.h"
#import "KMLPOIView.h"
#import "NSString_stripHtml.h"
#import "UIViewController+CWPopup.h"

@interface KMLView ()
{
    NSMutableArray *markers;
    
    NSDictionary *KMLFileData;
    NSArray *placemarks;
    GMSMapView *mapView;

}
@end

@implementation KMLView

- (id) initWithKMLFile: (NSDictionary *) filedata {
    self = [self init];
    
    if (self) {
        KMLFileData = filedata;
        
        markers = [[NSMutableArray alloc] init];
        
        [[self navigationItem] setTitle:[KMLFileData objectForKey:@"title"]];
        
        NSString *kmlFilePath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
        kmlFilePath = [kmlFilePath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.kml", [KMLFileData objectForKey:@"uuid"]]];
        
        KMLRoot *fileRoot = [KMLParser parseKMLAtPath:kmlFilePath];
        
        placemarks = [fileRoot placemarks];
        
        UIBarButtonItem *POIButton = [[UIBarButtonItem alloc]
                                       initWithTitle:NSLocalizedString(@"POIs", nil)
                                       style:UIBarButtonItemStyleBordered
                                       target:self
                                       action:@selector(showPOIWindow:)];
        
        [[self navigationItem] setRightBarButtonItem:POIButton];
    }
    
    return self;
}

-(void)showPOIWindow:(UIBarButtonItem *)sender{
    KMLPOIView *poiWindow = [[KMLPOIView alloc] initWithMarkers:markers];
    
    [[self navigationController] pushViewController:poiWindow animated:YES];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    GMSCameraPosition *camera = [GMSCameraPosition cameraWithLatitude:0
                                                            longitude:0
                                                                 zoom:0];
    
    mapView = [GMSMapView mapWithFrame:CGRectZero camera:camera];
    
    [mapView setMyLocationEnabled:YES];
    
    [[mapView settings] setMyLocationButton:YES];
    [[mapView settings] setRotateGestures:NO];
    [[mapView settings] setTiltGestures:NO];
    [[mapView settings] setCompassButton:NO];
    [mapView setDelegate:self];
    
    self.view = mapView;
    
    GMSCoordinateBounds *placemarkBounds = [[GMSCoordinateBounds alloc] init];
    
    for (KMLPlacemark *placemark in placemarks) {
        if ([[placemark geometry] isKindOfClass:[KMLPoint class]]) {
            KMLPoint *point = (KMLPoint *)[placemark geometry];
            
            CLLocationCoordinate2D coord = CLLocationCoordinate2DMake([[point coordinate] latitude], [[point coordinate] longitude]);
            placemarkBounds = [placemarkBounds includingCoordinate:coord];
            
            GMSMarker * placemarkMarker = [GMSMarker markerWithPosition:coord];
            [placemarkMarker setTitle:[placemark name]];
            [placemarkMarker setSnippet:[[placemark descriptionValue] stripHtml]];
            [placemarkMarker setUserData:[[placemark descriptionValue] stripHtml]];
            
            [markers addObject:placemarkMarker];
            
            placemarkMarker.map = mapView;
        }
    }
    
    [mapView animateWithCameraUpdate:[GMSCameraUpdate fitBounds:placemarkBounds withPadding:-130]];
}

- (void) mapView: (GMSMapView *) mapViewc didTapInfoWindowOfMarker: (GMSMarker *) marker
{
    UIAlertView *infoAlert = [[UIAlertView alloc] initWithTitle:[marker title]
                                                         message:[marker userData]
                                                        delegate:nil
                                               cancelButtonTitle:NSLocalizedString(@"OK", NULL)
                                               otherButtonTitles:nil
                               ];
    [infoAlert show];
    [mapViewc setSelectedMarker:nil];
}

- (void) zoomToCoordinate: (CLLocationCoordinate2D) coord {
    [mapView animateToCameraPosition:[GMSCameraPosition cameraWithTarget:coord zoom:15]];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
