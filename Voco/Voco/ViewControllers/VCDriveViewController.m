//
//  VCDriveViewController.m
//  Voco
//
//  Created by Elliott De Aratanha on 7/29/14.
//  Copyright (c) 2014 Voco. All rights reserved.
//

#import "VCDriveViewController.h"

#define kDriverCallHudOriginX 271
#define kDriverCallHudOriginY 353
#define kDriverCallHudOpenX 31
#define kDriverCallHudOpenY 353

#define kDriverCancelHudOriginX 271
#define kDriverCancelHudOriginY 278
#define kDriverCancelHudOpenX 165
#define kDriverCancelHudOpenY 278

@interface VCDriveViewController ()
@property (strong, nonatomic) IBOutlet UIView *driverCallHUD;
@property (strong, nonatomic) IBOutlet UIView *driverCancelHUD;

@property (nonatomic) BOOL callHudPanLocked;
@property (strong, nonatomic) NSTimer * timer;
@property (nonatomic) BOOL callHudOpen;

@property (nonatomic) BOOL cancelHudPanLocked;
@property (strong, nonatomic) NSTimer * cancelTimer;
@property (nonatomic) BOOL cancelHudOpen;

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

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    CGRect frame = _driverCallHUD.frame;
    frame.origin.x = kDriverCallHudOriginX;
    frame.origin.y = kDriverCallHudOriginY;
    _driverCallHUD.frame = frame;
    
    [self.view addSubview:_driverCallHUD];
    
    UIPanGestureRecognizer *panRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(move:)];
    [panRecognizer setMinimumNumberOfTouches:1];
    [panRecognizer setMaximumNumberOfTouches:1];
    [_driverCallHUD addGestureRecognizer:panRecognizer];
    
    {CGRect frame = _driverCallHUD.frame;
        frame.origin.x = kDriverCancelHudOriginX;
    frame.origin.y = kDriverCancelHudOriginY;
    _driverCancelHUD.frame = frame;
    
    [self.view addSubview:_driverCancelHUD];
        
        UIPanGestureRecognizer *panRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(move:)];
        [panRecognizer setMinimumNumberOfTouches:1];
        [panRecognizer setMaximumNumberOfTouches:1];
        [_driverCancelHUD addGestureRecognizer:panRecognizer];
    }
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
//TODO: add cancel
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
//TODO: add cancel

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

@end
