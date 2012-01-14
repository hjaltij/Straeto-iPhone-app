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

#import <MessageUI/MessageUI.h>


#import "IASKSpecifier.h"
#import "IASKSettingsReader.h"



@interface StraetoViewController()
- (NSArray*)findAllPins;
@end

@implementation StraetoViewController
@synthesize mapView = _mapView;
@synthesize pinsToDelete;

@synthesize appSettingsViewController;

- (void)dealloc
{
    [pinsToDelete release];
    [_mapView release];
    [super dealloc];
}

- (void)viewWillAppear:(BOOL)animated
{
    self.title = @"Rauntímakort";
    
    self.navigationItem.rightBarButtonItem = [[[UIBarButtonItem alloc] initWithTitle:@"Leiðir" style:UIBarButtonItemStylePlain target:self action:@selector(loadSettings)] autorelease];
    
    debug = YES;
    
    pinsToDelete = [[NSMutableArray alloc] init];
    
    CLLocationCoordinate2D zoomLocation;
    zoomLocation.latitude = 64.133004;
    zoomLocation.longitude = -21.89764;
	
    MKCoordinateRegion viewRegion = MKCoordinateRegionMakeWithDistance(zoomLocation, 3000.0, 3000.0);

    MKCoordinateRegion adjustedRegion = [_mapView regionThatFits:viewRegion];                

    [_mapView setRegion:adjustedRegion animated:YES];
    
    [self fetchBusData];
}

- (IASKAppSettingsViewController*)appSettingsViewController
{	
    if (!appSettingsViewController)
    {
		appSettingsViewController = [[IASKAppSettingsViewController alloc] initWithNibName:@"IASKAppSettingsView" bundle:nil];
        
        appSettingsViewController.title = @"Leiðir";
		appSettingsViewController.delegate = self;
	}
    
	return appSettingsViewController;
}

- (void)loadSettings
{    
    NSLog(@"log log log");
    
    self.appSettingsViewController.showDoneButton = NO;
	[self.navigationController pushViewController:self.appSettingsViewController animated:YES];
    
    
//    SettingsViewController *settingsViewController = [[SettingsViewController alloc] initWithNibName:@"SettingsViewController" bundle:nil];
//    
//    [self.navigationController pushViewController:settingsViewController animated:YES];
//    
//    [SettingsViewController release];
    
}

- (void)settingsViewControllerDidEnd:(IASKAppSettingsViewController*)sender {
    [self dismissModalViewControllerAnimated:YES];
    
    NSLog(@"settingsViewControllerDidEnd");
	
	// your code here to reconfigure the app for changed settings
}


- (void)fetchBusData
{
    NSURL *url = [NSURL URLWithString:@"http://www.straeto.is/bitar/bus/livemap/json.jsp?routes=12"];
    
    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:url];

    [request setDelegate:self];
   
    [request setCompletionBlock:^{        
        NSString *responseString = [request responseString];        
        [self parseBusData:responseString];        
        [self performSelector:@selector(fetchBusData) withObject:nil afterDelay:5.0];
    }];
    
    [request setFailedBlock:^{
        NSError *error = [request error];
        NSLog(@"Error: %@", error.localizedDescription);
    }];
    
    [request startAsynchronous];
}

- (NSArray*)findAllPins
{
    NSMutableArray *pins = [NSMutableArray array];
    
    for(NSObject<MKAnnotation>* annotation in [_mapView annotations])
    {
        if([annotation isKindOfClass:[BusLocation class]])
            [pins addObject:annotation];
    }
    
    return pins;
}

- (void)parseBusData:(NSString *)busDataString
{   
    NSDictionary * root = [busDataString JSONValue];
    
    NSArray *routes = [root objectForKey:@"routes"];
    
    [self.pinsToDelete addObjectsFromArray:[self findAllPins]];
    
    for(NSDictionary *r in routes)
    {
        NSArray *busses = [r objectForKey:@"busses"];
        
        for(NSDictionary *b in busses)
        {
            NSString *nr = [b objectForKey:@"BUSNR"];
            NSNumber *x = [b objectForKey:@"X"];
            NSNumber *y = [b objectForKey:@"Y"];
            
            NSString *from = [b objectForKey:@"FROMSTOP"];
            NSString *to = [b objectForKey:@"TOSTOP"];
            
            NSString* fromTo = [NSString stringWithFormat:@"%@ -> %@", from, to];
            
            BusLocation *annotation = [[BusLocation alloc] initWithNumber:nr fromTo:fromTo x:[x intValue] y:[y intValue]];                
            [_mapView addAnnotation:annotation];                
            [annotation release];
        }
    }
}

- (void)mapView:(MKMapView *)mapView didAddAnnotationViews:(NSArray *)views
{
    if([pinsToDelete count])
    {
        [_mapView removeAnnotations:pinsToDelete];
        [pinsToDelete removeAllObjects];
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
