//
//  ViewController.m
//  GeoFenceDemo
//
//  Created by SnehaPriya Ale on 6/30/17.
//  Copyright © 2017 DecoratingTheSkye. All rights reserved.
//

#import "ViewController.h"
@import MapKit;

@interface ViewController ()<MKMapViewDelegate, CLLocationManagerDelegate>
@property (weak, nonatomic) IBOutlet UISwitch *uiSwitch;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *statusCheck;
@property (weak, nonatomic) IBOutlet UILabel *statusLabel;
@property (weak, nonatomic) IBOutlet UILabel *eventLabel;
@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@property (strong, nonatomic) CLLocationManager *locationManager;
@property (assign, nonatomic) BOOL mapIsMoving;
@property (strong, nonatomic) MKPointAnnotation *currentAnot;
@property (strong, nonatomic) CLCircularRegion *geoRegion;
@property (weak, nonatomic) IBOutlet UIToolbar *toolbarView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.uiSwitch.transform = CGAffineTransformMakeScale(0.75, 0.75);
    self.uiSwitch.enabled = YES;
    self.statusCheck.enabled = NO;
    self.mapIsMoving = NO;
    
    
    self.toolbarView.hidden = YES;
    [self.uiSwitch setOn:YES];

    self.eventLabel.text = @"";
    self.statusLabel.text = @"";
    
    self.locationManager = [[CLLocationManager alloc]init];
    self.locationManager.delegate = self;
    self.locationManager.allowsBackgroundLocationUpdates = YES;
    self.locationManager.pausesLocationUpdatesAutomatically = YES;
    self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    self.locationManager.distanceFilter = 3;
    
    
    CLLocationCoordinate2D noLocation = CLLocationCoordinate2DMake(37.413533, -121.893654);
    MKCoordinateRegion viewRegion = MKCoordinateRegionMakeWithDistance(noLocation, 1500, 1500);
    MKCoordinateRegion adjustedRegion = [self.mapView regionThatFits:viewRegion];
    [self.mapView setRegion:adjustedRegion animated:YES];
    
    [self addCurrentAnnotation];
    [self setupGeoRegion];
    [self mymethod];
    
    if([CLLocationManager isMonitoringAvailableForClass:[CLCircularRegion class]] == YES){
        
        if(([CLLocationManager authorizationStatus] == kCLAuthorizationStatusAuthorizedWhenInUse) ||
           ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusAuthorizedAlways)){
            self.uiSwitch.enabled = YES;
        }else{
            [self.locationManager requestAlwaysAuthorization];
        }
        
        UIUserNotificationType types = UIUserNotificationTypeAlert | UIUserNotificationTypeBadge | UIUserNotificationTypeSound;
        UIUserNotificationSettings *mysettings = [UIUserNotificationSettings settingsForTypes:types categories:nil];
        [[UIApplication sharedApplication] registerUserNotificationSettings:mysettings];
    } else {
        self.statusLabel.text = @"Georegion not supported";
    }
}

- (void)locationManager: (CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status {
    CLAuthorizationStatus currentStatus = [CLLocationManager authorizationStatus];
    if((currentStatus == kCLAuthorizationStatusAuthorizedWhenInUse) || (currentStatus == kCLAuthorizationStatusAuthorizedAlways)){
        self.uiSwitch.enabled = YES;
    }
}

-(void)addCurrentAnnotation {
    self.currentAnot = [[MKPointAnnotation alloc] init];
    self.currentAnot.coordinate = CLLocationCoordinate2DMake(0.0, 0.0);
    self.currentAnot.title = @"My Location";
}

- (void)mapView:(MKMapView *)mapView regionWillChangeAnimated:(BOOL)animated {
    self.mapIsMoving = YES;
}

- (void)mapView:(MKMapView *)mapView regionDidChangeAnimated:(BOOL)animated {
    self.mapIsMoving = NO;
 
}
- (IBAction)switchStatusChanged:(UISwitch *)sender {
    if(self.uiSwitch.isOn){
        self.mapView.showsUserLocation = YES;
        [self.locationManager startUpdatingLocation];
        [self.locationManager startMonitoringForRegion:self.geoRegion];
        self.statusCheck.enabled = YES;
        MKPointAnnotation *annotation = [[MKPointAnnotation alloc] init];
        CLLocationCoordinate2D coord = CLLocationCoordinate2DMake(37.413533, -121.893654);
        MKCoordinateSpan span = MKCoordinateSpanMake(0.1, 0.1);
        MKCoordinateRegion region = {coord, span};
        [annotation setCoordinate:coord];
        [self.mapView setRegion:region];
        [annotation setTitle:@"Priya's Boutique"];
        [self.mapView addAnnotation:annotation];
    }else {
        self.statusCheck.enabled = YES;
        [self.locationManager stopMonitoringForRegion:self.geoRegion];
        [self.locationManager stopUpdatingLocation];
        self.mapView.showsUserLocation = NO;
    }
}

- (void)mymethod {
    self.mapView.showsUserLocation = YES;
    [self.locationManager startUpdatingLocation];
    [self.locationManager startMonitoringForRegion:self.geoRegion];
    self.statusCheck.enabled = YES;
    MKPointAnnotation *annotation = [[MKPointAnnotation alloc] init];
    CLLocationCoordinate2D coord = CLLocationCoordinate2DMake(37.413533, -121.893654);
    MKCoordinateSpan span = MKCoordinateSpanMake(0.1, 0.1);
    MKCoordinateRegion region = {coord, span};
    [annotation setCoordinate:coord];
    [self.mapView setRegion:region];
    [annotation setTitle:@"Priya's Boutique"];
    [self.mapView addAnnotation:annotation];
}

- (void)setupGeoRegion {
    self.geoRegion = [[CLCircularRegion alloc] initWithCenter:CLLocationCoordinate2DMake(37.413533,-121.893654) radius:3 identifier:@"MyRegionIdentifier"];
}

- (IBAction)onClickOfCheckStatus:(UIBarButtonItem *)sender {
    [self.locationManager requestStateForRegion:self.geoRegion];
//    if(self.geoRegion != nil){
//        [self.locationManager requestStateForRegion:self.geoRegion];
//    } else {
//        NSLog(@"Georegion is nil.");
//    }
}

#pragma mark - location call backs

- (void)locationManager:(CLLocationManager *)manager didDetermineState:(CLRegionState)state forRegion:(nonnull CLRegion *)region {
    if(state == CLRegionStateUnknown){
        NSLog(@"Region: Unknown");
        self.statusLabel.text = @"Unknown";
    }
    else if(state == CLRegionStateInside){
        NSLog(@"Region: Inside");
        self.statusLabel.text = @"Inside";
        [self addAlert];
    }
    else if(state == CLRegionStateOutside){
        NSLog(@"Region: Outside");
        self.statusLabel.text = @"Outside";
        [self warnAlert];
    } else {
        NSLog(@"Region: Mystery");
        self.statusLabel.text = @"Mystery";
    }
}

- (void)addAlert {
    UIAlertController * alert=[UIAlertController alertControllerWithTitle:@"Priya's Coupon Alert"
                                                                  message:@"You received a discount coupon of 50% off on any dresses you buy for next 2hrs #GYWBNDKLD00YBM "
                                                           preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction* yesButton = [UIAlertAction actionWithTitle:@"Apply"
                                                        style:UIAlertActionStyleDefault
                                                      handler:^(UIAlertAction * action)
    {
        UIAlertController * alert=[UIAlertController alertControllerWithTitle:@"Priya's Coupon Alert"
                                                                      message:@"Congratulations! Coupon has been applied "
                                                               preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction* dismissAction = [UIAlertAction actionWithTitle:@"Ok"
                                                           style:UIAlertActionStyleDefault
                                                              handler:nil];
        [alert addAction:dismissAction];
        
        [self presentViewController:alert animated:YES completion:nil];
    }];
    
    UIAlertAction* noButton = [UIAlertAction actionWithTitle:@"No, thanks"
                                                       style:UIAlertActionStyleDefault
                                                     handler:^(UIAlertAction * action)
    {
        /** What we write here???????? **/
        NSLog(@"you pressed No, thanks button");
        // call method whatever u need
    }];
    
    [alert addAction:yesButton];
    [alert addAction:noButton];
    
    [self presentViewController:alert animated:YES completion:nil];
}

-(void)warnAlert {
    UIAlertController * alert=[UIAlertController alertControllerWithTitle:@"Priya's Coupon Alert"
                                                                  message:@"Your coupon would expire in 2hrs."
                                                           preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction* dismissAction = [UIAlertAction actionWithTitle:@"Ok"
                                                            style:UIAlertActionStyleDefault
                                                          handler:nil];
    [alert addAction:dismissAction];
    
    [self presentViewController:alert animated:YES completion:nil];
}

-(void) locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray<CLLocation *> *)locations {
    self.currentAnot.coordinate = locations.lastObject.coordinate;
    if(self.mapIsMoving == NO){
        [self centerMap:self.currentAnot];
    }
}

- (void)locationManager:(CLLocationManager *)manager didEnterRegion:(CLRegion *)region {
    UILocalNotification *note = [[UILocalNotification alloc] init];
    note.fireDate = nil;
    note.repeatInterval = 0;
    note.alertTitle = @"Priya's Coupon Alert";
    note.alertBody = [NSString stringWithFormat:@"You received a discount coupon of 50% off on any dresses you buy for next 2hrs #GYWBNDKLD00YBM "];
    [[UIApplication sharedApplication] scheduleLocalNotification:note];
    self.eventLabel.text = @"Entered";
}

- (void) locationManager:(CLLocationManager *)manager didExitRegion:(CLRegion *)region {
    UILocalNotification *note = [[UILocalNotification alloc] init];
    note.fireDate = nil;
    note.repeatInterval = 0;
    note.alertTitle = @"Priya's Coupon Alert";
    note.alertBody = [NSString stringWithFormat:@"Dont' miss the coupon of 50% off."];
    [[UIApplication sharedApplication] scheduleLocalNotification:note];
    self.eventLabel.text = @"Exited";
}

-(void)centerMap: (MKPointAnnotation *) centerPoint {
    [self.mapView setCenterCoordinate:centerPoint.coordinate animated:YES];
}




@end
