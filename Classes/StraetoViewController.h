//
//  StraetoViewController.h
//  Straeto
//
//  Created by Árni Jónsson on 5.1.2012.
//  Copyright 2012 ProNasty. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>

@interface StraetoViewController : UIViewController <MKMapViewDelegate> {
	MKMapView *_mapView;
}

@property (nonatomic, retain) IBOutlet MKMapView *mapView;

- (void)fetchBusData;
- (void)parseBusData:(NSString *)busDataString;


@end
