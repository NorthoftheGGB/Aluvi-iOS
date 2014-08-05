//
//  VCDriveViewController.m
//  Voco
//
//  Created by Elliott De Aratanha on 7/29/14.
//  Copyright (c) 2014 Voco. All rights reserved.
//

#import "VCDriveViewController.h"
//#import <MapKit/MapKit.h>
#import "VCButtonFont.h"


#define kDriverCallHudOriginX 271
#define kDriverCallHudOriginY 226
#define kDriverCallHudOpenX 31
#define kDriverCallHudOpenY 226

#define kDriverCancelHudOriginX 271
#define kDriverCancelHudOriginY 302
#define kDriverCancelHudOpenX 165
#define kDriverCancelHudOpenY 302

@interface VCDriveViewController () //<MKMapViewDelegate>

@property (strong, nonatomic) IBOutlet UIView *driverCallHUD;
@property (strong, nonatomic) IBOutlet UIView *driverCancelHUD;
@property (strong, nonatomic) IBOutlet UIButton *currentLocationButton;
@property (strong, nonatomic) IBOutlet UIButton *directionsListButton;

//Call HUD
@property (nonatomic) BOOL callHudPanLocked;
@property (strong, nonatomic) NSTimer * timer;
@property (nonatomic) BOOL callHudOpen;
@property (weak, nonatomic) IBOutlet VCButtonFont *riderCallButton1;
@property (weak, nonatomic) IBOutlet VCButtonFont *riderCallButton2;
@property (weak, nonatomic) IBOutlet VCButtonFont *riderCallButton3;
@property (weak, nonatomic) IBOutlet UIImageView *phoneIconImageView;
- (IBAction)didTapCallRider1:(id)sender;
- (IBAction)didTapCallRider2:(id)sender;
- (IBAction)didTapCallRider3:(id)sender;

//Cancel HUD
@property (nonatomic) BOOL cancelHudPanLocked;
@property (strong, nonatomic) NSTimer * cancelTimer;
@property (nonatomic) BOOL cancelHudOpen;
@property (weak, nonatomic) IBOutlet VCButtonFont *cancelRideButton;
@property (weak, nonatomic) IBOutlet UIImageView *cancelIconImageView;
- (IBAction)didTapCancelRide:(id)sender;



//Ride Status
@property (strong, nonatomic) IBOutlet VCButtonFont *ridersPickedUpButton;
@property (strong, nonatomic) IBOutlet VCButtonFont *rideCompleteButton;
- (IBAction)didTapRidersPickedUp:(id)sender;
- (IBAction)didTapRideCompleted:(id)sender;

//Navigation Tools
- (IBAction)didTapCurrentLocationButton:(id)sender;
- (IBAction)didTapDirectionsListButton:(id)sender;




//@property (nonatomic) BOOL appeared;

@end

@implementation VCDriveViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        _callHudPanLocked = NO;
        _callHudOpen = NO;
    }
    return self;
}

- (void) viewWillAppear:(BOOL)animated{
    [self showHome];
    
}

- (void)viewDidLoad{
    
        [super viewDidLoad];
        
        
        UIPanGestureRecognizer *panRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(move:)];
        [panRecognizer setMinimumNumberOfTouches:1];
        [panRecognizer setMaximumNumberOfTouches:1];
        [_driverCallHUD addGestureRecognizer:panRecognizer];
        
        
        
        {UIPanGestureRecognizer *panRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(move2:)];
            [panRecognizer setMinimumNumberOfTouches:1];
            [panRecognizer setMaximumNumberOfTouches:1];
            [_driverCancelHUD addGestureRecognizer:panRecognizer];}
        
    }
    
- (void)didReceiveMemoryWarning
    {
        [super didReceiveMemoryWarning];
        // Dispose of any resources that can be recreated.
    }
    

- (void) showHome{
    
    CGRect currentLocationframe = _currentLocationButton.frame;
    currentLocationframe.origin.x = 271;
    currentLocationframe.origin.y = self.view.frame.size.height - 46;
    _currentLocationButton.frame = currentLocationframe;
    [self.view addSubview:self.currentLocationButton];
    
    CGRect directionsListFrame = _directionsListButton.frame;
    directionsListFrame.origin.x = 224;
    directionsListFrame.origin.y = self.view.frame.size.height - 46;
    _directionsListButton.frame = directionsListFrame;
    [self.view addSubview:self.directionsListButton];
    
    CGRect ridersPickedUpFrame = _ridersPickedUpButton.frame;
    ridersPickedUpFrame.origin.x = 18;
    ridersPickedUpFrame.origin.y = self.view.frame.size.height - 46;
    _ridersPickedUpButton.frame = ridersPickedUpFrame;
    [self.view addSubview:self.ridersPickedUpButton];
    
    CGRect frame = _driverCallHUD.frame;
    frame.origin.x = kDriverCallHudOriginX;
    frame.origin.y = self.view.frame.size.height - kDriverCallHudOriginY;
    _driverCallHUD.frame = frame;
    
    [self.view addSubview:_driverCallHUD];
    
    {CGRect frame = _driverCancelHUD.frame;
        frame.origin.x = kDriverCancelHudOriginX;
        frame.origin.y = self.view.frame.size.height - kDriverCancelHudOriginY;
        _driverCancelHUD.frame = frame;
        
        [self.view addSubview:_driverCancelHUD];}
    
}

-(void)move:(id)sender {
        NSLog(@"%@", @"YO!");
        
        if( _callHudPanLocked ) {
            return;
        }
        
        CGPoint translatedPoint = [(UIPanGestureRecognizer*)sender translationInView:self.view];
        
        if(_callHudOpen == NO) {
            
            if(translatedPoint.x > 0){
                return;
            }
            
            if(translatedPoint.x < kDriverCallHudOpenX - kDriverCallHudOriginX ){
                return;
            }
            
            if ([(UIPanGestureRecognizer*)sender state] == UIGestureRecognizerStateEnded) {
                CGPoint velocity = [(UIPanGestureRecognizer*)sender velocityInView:self.view];
                
                if(velocity.x < -2000) {
                    [self animateCallHudToOpen];
                } else if(translatedPoint.x < -100){
                    [self animateCallHudToOpen];
                } else {
                    [self animateCallHudToClosed];
                }
                
                return;
            }
            
            CGRect frame = _driverCallHUD.frame;
            frame.origin.x = kDriverCallHudOriginX + translatedPoint.x;
            _driverCallHUD.frame = frame;
            if ( kDriverCallHudOriginX + translatedPoint.x <= kDriverCallHudOpenX ){
                [self animateCallHudToOpen];
            }
            
        } else {
            if(translatedPoint.x < 0){
                return;
            }
            
            if ([(UIPanGestureRecognizer*)sender state] == UIGestureRecognizerStateEnded) {
                [self animateCallHudToClosed];
            }
        }
    }
    
    -(void)move2:(id)sender {
        NSLog(@"%@", @"YO!");
        
        if( _cancelHudPanLocked ) {
            return;
        }
        
        CGPoint translatedPoint = [(UIPanGestureRecognizer*)sender translationInView:self.view];
        
        if(_cancelHudOpen == NO) {
            
            if(translatedPoint.x > 0){
                return;
            }
            
            if(translatedPoint.x < kDriverCallHudOpenX - kDriverCallHudOriginX ){
                return;
            }
            
            if ([(UIPanGestureRecognizer*)sender state] == UIGestureRecognizerStateEnded) {
                CGPoint velocity = [(UIPanGestureRecognizer*)sender velocityInView:self.view];
                
                if(velocity.x < -2000) {
                    [self animateCancelHudToOpen];
                } else if(translatedPoint.x < -100){
                    [self animateCancelHudToOpen];
                } else {
                    [self animateCancelHudToClosed];
                }
                
                return;
            }
            
            CGRect frame = _driverCancelHUD.frame;
            frame.origin.x = kDriverCancelHudOriginX + translatedPoint.x;
            _driverCancelHUD.frame = frame;
            if ( kDriverCancelHudOriginX + translatedPoint.x <= kDriverCancelHudOpenX ){
                [self animateCancelHudToOpen];
            }
            
        } else {
            if(translatedPoint.x < 0){
                return;
            }
            
            if ([(UIPanGestureRecognizer*)sender state] == UIGestureRecognizerStateEnded) {
                [self animateCancelHudToClosed];
            }
        }
    }
    
    
    - (void) animateCallHudToOpen {
        _callHudPanLocked = YES;
        
        _timer = [NSTimer scheduledTimerWithTimeInterval:.5 target:self selector:@selector(unlockCallHudPan:) userInfo:nil repeats:NO];
        
        [UIView animateWithDuration:0.15 animations:^{
            CGRect frame = _driverCallHUD.frame;
            frame.origin.x = kDriverCallHudOpenX;
            _driverCallHUD.frame = frame;
            _callHudOpen = YES;
        }];
        
    }

    - (void) animateCancelHudToOpen {
        _cancelHudPanLocked = YES;
        
        _cancelTimer = [NSTimer scheduledTimerWithTimeInterval:.5 target:self selector:@selector(unlockCancelHudPan:) userInfo:nil repeats:NO];
        
        [UIView animateWithDuration:0.15 animations:^{
            CGRect frame = _driverCancelHUD.frame;
            frame.origin.x = kDriverCancelHudOpenX;
            _driverCancelHUD.frame = frame;
            _cancelHudOpen = YES;
        }];
        
    }
    
    - (void) animateCallHudToClosed{
        _callHudPanLocked = YES;
        
        _timer = [NSTimer scheduledTimerWithTimeInterval:.5 target:self selector:@selector(unlockCallHudPan:) userInfo:nil repeats:NO];
        
        [UIView animateWithDuration:0.15 animations:^{
            CGRect frame = _driverCallHUD.frame;
            frame.origin.x = kDriverCallHudOriginX;
            _driverCallHUD.frame = frame;
            _callHudOpen = NO;
        }];
        
    }

    
    - (void) animateCancelHudToClosed{
        _cancelHudPanLocked = YES;
        
        _cancelTimer = [NSTimer scheduledTimerWithTimeInterval:.5 target:self selector:@selector(unlockCancelHudPan:) userInfo:nil repeats:NO];
        
        [UIView animateWithDuration:0.15 animations:^{
            CGRect frame = _driverCancelHUD.frame;
            frame.origin.x = kDriverCancelHudOriginX;
            _driverCancelHUD.frame = frame;
            _cancelHudOpen = NO;
        }];
        
    }
    
    
    - (void) unlockCallHudPan:(id)sender {
        _callHudPanLocked = NO;
    }
    
    
    - (void) unlockCancelHudPan:(id)sender {
        _cancelHudPanLocked = NO;
    }
    
- (IBAction)didTapCallRider1:(id)sender {
    }
- (IBAction)didTapCallRider3:(id)sender {
    }
- (IBAction)didTapCallRider2:(id)sender {
    }
- (IBAction)didTapCurrentLocationButton:(id)sender {
    }
- (IBAction)didTapDirectionsListButton:(id)sender {
    }
- (IBAction)didTapRidersPickedUp:(id)sender {
    }
- (IBAction)didTapRideCompleted:(id)sender {
    }
- (IBAction)didTapCancelRide:(id)sender {
    }

@end