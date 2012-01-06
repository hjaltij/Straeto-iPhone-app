//
//  StraetoViewController.m
//  Straeto
//
//  Created by Árni Jónsson on 5.1.2012.
//  Copyright 2012 ProNasty. All rights reserved.
//

#import "StraetoViewController.h"

#import "BusLocation.h"

#import "ASIHTTPRequest.h"
#import "SBJson.h"

@implementation StraetoViewController
@synthesize mapView = _mapView;


- (void)dealloc
{
    [_mapView release];
    [super dealloc];
}

- (void)viewWillAppear:(BOOL)animated
{
    CLLocationCoordinate2D zoomLocation;
    zoomLocation.latitude = 64.133004;
    zoomLocation.longitude = -21.89764;
	
    MKCoordinateRegion viewRegion = MKCoordinateRegionMakeWithDistance(zoomLocation, 3000.0, 3000.0);

    MKCoordinateRegion adjustedRegion = [_mapView regionThatFits:viewRegion];                

    [_mapView setRegion:adjustedRegion animated:YES];
    
    [self fetchBusData];
}

- (void)fetchBusData
{
    
//    NSURL *url = [NSURL URLWithString:@"http://pronasty.com/straeto.json"];
    NSURL *url = [NSURL URLWithString:@"http://www.straeto.is/bitar/bus/livemap/json.jsp?routes=3"];
    
    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:url];

    [request setDelegate:self];
   
    [request setCompletionBlock:^{        
        NSString *responseString = [request responseString];
//        NSLog(@"Response: %@", responseString);
        
        [self parseBusData:responseString];
    }];
    
    [request setFailedBlock:^{
        NSError *error = [request error];
        NSLog(@"Error: %@", error.localizedDescription);
    }];
    
    [request startAsynchronous];
}

- (void)parseBusData:(NSString *)busDataString
{
    for (id<MKAnnotation> annotation in _mapView.annotations)
        [_mapView removeAnnotation:annotation];

    NSDictionary * root = [busDataString JSONValue];
    
    NSArray *routes = [root objectForKey:@"routes"];
    
    for (NSDictionary *r in routes)
    {
        NSArray *busses = [r objectForKey:@"busses"];
        
        for (NSDictionary *b in busses)
        {
            NSString *nr = [b objectForKey:@"BUSNR"];
            NSNumber *x = [b objectForKey:@"X"];
            NSNumber *y = [b objectForKey:@"Y"];
            
            NSString *from = [b objectForKey:@"FROMSTOP"];

            NSString *to = [b objectForKey:@"TOSTOP"];
            
            NSString* fromTo = [NSString stringWithFormat:@"%@ -> %@", from, to];
                        
            BusLocation *annotation = [[BusLocation alloc] initWithNumber:nr fromTo:fromTo x:[x intValue]  y:[y intValue]];
            [_mapView addAnnotation:annotation];
            
            [annotation release];
        }
    }
}


/*
// The designated initializer. Override to perform setup that is required before the view is loaded.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}
*/

/*
// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView {
}
*/


/*
// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
}
*/


/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/

- (void)didReceiveMemoryWarning
{
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload
{
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
	
	[self setMapView:nil];
    [super viewDidUnload];

}

@end
