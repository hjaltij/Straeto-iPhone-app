//
//  StraetoViewController.h
//  Straeto
//
//  Created by Árni Jónsson on 5.1.2012.
//  Copyright 2012 ProNasty. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>

#import "IASKAppSettingsViewController.h"

@interface StraetoViewController : UIViewController <MKMapViewDelegate>
{
	MKMapView *_mapView;
    BOOL debug;
    NSMutableArray *pinsToDelete;
    
    IASKAppSettingsViewController *appSettingsViewController;
}

@property (nonatomic, retain) IBOutlet MKMapView *mapView;
@property (readwrite, retain) NSMutableArray *pinsToDelete;

@property (nonatomic, retain) IASKAppSettingsViewController *appSettingsViewController;

- (void)fetchBusData;
- (void)parseBusData:(NSString *)busDataString;

- (void)loadSettings;

@end
