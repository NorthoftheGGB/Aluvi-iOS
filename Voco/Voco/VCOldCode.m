//
//  VCOldCode.m
//  Voco
//
//  Created by matthewxi on 8/1/15.
//  Copyright (c) 2015 Voco. All rights reserved.
//

#import "VCOldCode.h"

@implementation VCOldCode


///////////////////////////  OLD CODE ///////////////////////////////


#pragma makr RiderInterface

- (void) showRiderInterface {
    _rideDetailsHud.driverFirstNameLabel.text = _ticket.driver.firstName;
    _rideDetailsHud.driverLastNameLabel.text = _ticket.driver.lastName;
    _rideDetailsHud.carTypeValueLabel.text = [_ticket.car summary];
    _rideDetailsHud.licenseValueLabel.text = _ticket.car.licensePlate;
    _rideDetailsHud.cardNicknamelabel.text = [VCUserStateManager instance].profile.cardBrand;
    _rideDetailsHud.cardNumberLabel.text = [VCUserStateManager instance].profile.cardLastFour;
    _rideDetailsHud.fareLabel.text = [VCUtilities formatCurrencyFromCents: _ticket.fixedPrice];
    CGRect frame = _rideDetailsHud.frame;
    frame.origin.x = 0;
    frame.origin.y = self.view.frame.size.height - 154;
    _rideDetailsHud.frame = frame;
    [self.view addSubview:_rideDetailsHud];
}

#pragma mark HovDriverInterface
- (void) showHovDriverInterface{
    
    [self setupDriverHuds];
    if([_ticket.hovFare.state isEqualToString:@"started"]){
        [self moveFromPickupToRideInProgressInteface];
    }
    
}

- (void) setupDriverHuds {
    
    // _driverCallHUD.riders = [_ticket.hovFare.riders allObjects];
    
    CGRect currentLocationframe = _currentLocationButton.frame;
    currentLocationframe.origin.x = 271;
    currentLocationframe.origin.y = self.view.frame.size.height - 46;
    _currentLocationButton.frame = currentLocationframe;
    [self.view addSubview:self.currentLocationButton];
    /*
     CGRect directionsListFrame = _directionsListButton.frame;
     directionsListFrame.origin.x = 224;
     directionsListFrame.origin.y = self.view.frame.size.height - 46;
     _directionsListButton.frame = directionsListFrame;
     [self.view addSubview:self.directionsListButton];
     */
    
    CGRect ridersPickedUpFrame = _ridersPickedUpButton.frame;
    ridersPickedUpFrame.origin.x = 18;
    ridersPickedUpFrame.origin.y = self.view.frame.size.height - 46;
    _ridersPickedUpButton.frame = ridersPickedUpFrame;
    [self.view addSubview:self.ridersPickedUpButton];
    
    /*
     CGRect frame = _driverCallHUD.frame;
     frame.origin.x = kDriverCallHudOriginX;
     frame.origin.y = self.view.frame.size.height - kDriverCallHudOriginY;
     _driverCallHUD.frame = frame;
     
     [self.view addSubview:_driverCallHUD];
     
     {
     CGRect frame = _driverCancelHUD.frame;
     frame.origin.x = kDriverCancelHudOriginX;
     frame.origin.y = self.view.frame.size.height - kDriverCancelHudOriginY;
     _driverCancelHUD.frame = frame;
     
     [self.view addSubview:_driverCancelHUD];
     }
     
     {
     UIPanGestureRecognizer *panRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(move:)];
     [panRecognizer setMinimumNumberOfTouches:1];
     [panRecognizer setMaximumNumberOfTouches:1];
     [_driverCallHUD addGestureRecognizer:panRecognizer];
     }
     
     {
     UIPanGestureRecognizer *panRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(move2:)];
     [panRecognizer setMinimumNumberOfTouches:1];
     [panRecognizer setMaximumNumberOfTouches:1];
     [_driverCancelHUD addGestureRecognizer:panRecognizer];
     }
     */
    
}

/*
 -(void)move:(id)sender {
 
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
 } else if(translatedPoint.x < -75){
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
 */


/*
 - (void) transitionFromEditPickupTimeToEditHome {
 
 _editCommuteState = kEditCommuteStateEditHome;
 
 _homeLocationWidget.mode = kEditLocationWidgetEditMode;
 CGRect frame = _homeLocationWidget.view.frame;
 frame.origin.x = 0;
 frame.origin.y = 102;
 frame.size.height = 0;
 _homeLocationWidget.view.frame = frame;
 [self.view addSubview:_homeLocationWidget.view];
 
 [UIView animateWithDuration:0.35 animations:^{
 CGRect frame = _homeLocationWidget.view.frame;
 frame.size.height = 40;
 _homeLocationWidget.view.frame = frame;
 }];
 
 
 }
 
 - (void) transitionFromEditHomeToEditWork {
 
 _editCommuteState = kEditCommuteStateEditWork;
 
 [_nextButton removeFromSuperview];
 
 _workLocationWidget.mode = kEditLocationWidgetEditMode;
 CGRect frame = _homeLocationWidget.view.frame;
 frame.origin.x = 0;
 frame.origin.y = 142;
 frame.size.height = 0;
 _workLocationWidget.view.frame = frame;
 [self.view addSubview:_workLocationWidget.view];
 
 [UIView animateWithDuration:0.35 animations:^{
 CGRect frame = _workLocationWidget.view.frame;
 frame.size.height = 40;
 _workLocationWidget.view.frame = frame;
 }];
 
 }
 
 - (void) transitionFromEditWorkToSetReturnTime {
 
 _editCommuteState = kEditCommuteStateReturnTime;
 
 [_nextButton removeFromSuperview];
 
 CGRect frame = _returnHudView.frame;
 frame.origin.x = 0;
 frame.origin.y = 182;
 frame.size.height = 0;
 _returnHudView.frame = frame;
 [self.view addSubview:self.returnHudView];
 [UIView animateWithDuration:0.35 animations:^{
 CGRect frame = _returnHudView.frame;
 frame.size.height = 40;
 _returnHudView.frame = frame;
 }];
 
 [self showReturnTimePicker];
 
 }
 */

/*
 - (void) transitionFromSetReturnTimeToEditWork {
 
 _editCommuteState = kEditCommuteStateEditWork;
 
 [UIView animateWithDuration:0.35 animations:^{
 CGRect frame = _returnHudView.frame;
 frame.size.height = 0;
 _returnHudView.frame = frame;
 } completion:^(BOOL finished) {
 [_returnHudView removeFromSuperview];
 } ];
 
 [self showNextButton];
 //[_scheduleRideButton removeFromSuperview];
 
 
 }
 
 - (void) transitionFromSetReturnTimeToScheduleRide {
 
 [_currentLocationButton removeFromSuperview];
 
 
 if([[VCUserStateManager instance] isHovDriver]){
 CGRect frame = _hovDriverOptionView.frame;
 frame.origin.x = 0;
 frame.origin.y = self.view.frame.size.height - 91;
 _hovDriverOptionView.frame = frame;
 [self.view addSubview:_hovDriverOptionView];
 }
 
 
 {
 if( [[VCCommuteManager instance] hasSettings] ){
 _scheduleRideButton.titleLabel.text = @"COMMUTE TOMORROW";
 } else {
 _scheduleRideButton.titleLabel.text = @"SAVE COMMUTE";
 }
 CGRect frame = _scheduleRideButton.frame;
 frame.origin.x = 0;
 frame.origin.y = self.view.frame.size.height - 53;
 _scheduleRideButton.frame = frame;
 [self.view addSubview:_scheduleRideButton];
 }
 }
 
 
 - (void) transitionToWaitingScreen {
 [_scheduleRideButton removeFromSuperview];
 [self updateRightMenuButton];
 _step = kStepDone;
 }
 
 - (void) transitionToRideDetailsConfirmation {
 
 [self updateRideDetailsConfirmationView: _ticket];
 
 self.scrollView = [[UIScrollView alloc] init];
 self.scrollView.bounces = NO;
 CGRect frame = self.view.frame;
 frame.origin.y = frame.origin.y + 62;
 frame.size.height = frame.size.height - 62;
 self.scrollView.frame = frame;
 [self.view addSubview:self.scrollView];
 [self.scrollView setContentSize:_rideItineraryView.frame.size];
 [self.scrollView addSubview:_rideItineraryView];
 
 
 }
 */



/*
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
 
 
 
 */



/*
 - (IBAction)didTapHovDriveYesButton:(id)sender {
 
 if (_hovDriveYesButton.selected == YES){
 _hovDriveYesButton.selected = NO;
 [VCCommuteManager instance].driving = NO;
 } else {
 _hovDriveYesButton.selected = YES;
 [VCCommuteManager instance].driving = YES;
 }
 }
 */




- (void) transitionToEditCommute {
    [_editCommuteButton removeFromSuperview]; //homeActionView goes here
    _editCommuteState = kEditCommuteStateEditAll;
    
    [self updateRightMenuButton];
    
    {
        CGRect frame = _pickupHudView.frame;
        frame.origin.x = 0;
        frame.origin.y = 62;
        frame.size.height = 0;
        _pickupHudView.frame = frame;
        [self.view addSubview:self.pickupHudView];
    }
    {
        _homeLocationWidget.mode = kEditLocationWidgetEditMode;
        CGRect frame = _homeLocationWidget.view.frame;
        frame.origin.x = 0;
        frame.origin.y = 102;
        frame.size.height = 0;
        _homeLocationWidget.view.frame = frame;
        _homeLocationWidget.mode = kEditLocationWidgetDisplayMode;
        [self.view addSubview:_homeLocationWidget.view];
    }
    {
        _workLocationWidget.mode = kEditLocationWidgetEditMode;
        CGRect frame = _homeLocationWidget.view.frame;
        frame.origin.x = 0;
        frame.origin.y = 142;
        frame.size.height = 0;
        _workLocationWidget.view.frame = frame;
        _workLocationWidget.mode = kEditLocationWidgetDisplayMode;
        [self.view addSubview:_workLocationWidget.view];
    }
    {
        CGRect frame = _returnHudView.frame;
        frame.origin.x = 0;
        frame.origin.y = 182;
        frame.size.height = 0;
        _returnHudView.frame = frame;
        [self.view addSubview:self.returnHudView];
    }
    {
        if([[VCUserStateManager instance] isHovDriver]){
            CGRect frame = _hovDriverOptionView.frame;
            frame.origin.x = 0;
            frame.origin.y = self.view.frame.size.height - 91;
            _hovDriverOptionView.frame = frame;
            [self.view addSubview:_hovDriverOptionView];
        }
    }
    {
        _scheduleRideButton.titleLabel.adjustsFontSizeToFitWidth = YES;
        if( [[VCCommuteManager instance] hasSettings] ){
            _scheduleRideButton.titleLabel.text = @"COMMUTE TOMORROW";
        } else {
            _scheduleRideButton.titleLabel.text = @"SAVE MY COMMUTE";
        }
        CGRect frame = _scheduleRideButton.frame;
        frame.origin.x = 0;
        frame.origin.y = self.view.frame.size.height - 53;
        _scheduleRideButton.frame = frame;
        [self.view addSubview:_scheduleRideButton];
    }
    
    
    [UIView animateWithDuration:0.35 animations:^{
        CGRect frame = _pickupHudView.frame;
        frame.size.height = 40; //changed height
        _pickupHudView.frame = frame;
        
        frame = _homeLocationWidget.view.frame;
        frame.size.height = 40;
        _homeLocationWidget.view.frame = frame;
        
        frame = _workLocationWidget.view.frame;
        frame.size.height = 40;
        _workLocationWidget.view.frame = frame;
        
        frame = _returnHudView.frame;
        frame.size.height = 40;
        _returnHudView.frame = frame;
        
    }];
    
}

- (void) transitionToSetupCommute {
    if([[VCCommuteManager instance] hasSettings]){
        [self showSuggestedRoute:[VCCommuteManager instance].home to:[VCCommuteManager instance].work];
    } else {
        [self zoomToCurrentLocation];
    }
    
    CGRect currentLocationframe = _currentLocationButton.frame;
    currentLocationframe.origin.x = 271;
    currentLocationframe.origin.y = self.view.frame.size.height - 46;
    _currentLocationButton.frame = currentLocationframe;
    [self.view addSubview:self.currentLocationButton];
    
    [_editCommuteButton removeFromSuperview]; //homeActionView goes here
    [self updateRightMenuButton];
    
    _editCommuteState = kEditCommuteStatePickupTime;
    CGRect frame = _pickupHudView.frame;
    frame.origin.x = 0;
    frame.origin.y = 62;
    frame.size.height = 0;
    _pickupHudView.frame = frame;
    [self.view addSubview:self.pickupHudView];
    [UIView animateWithDuration:0.35 animations:^{
        CGRect frame = _pickupHudView.frame;
        frame.size.height = 40; //changed height
        _pickupHudView.frame = frame;
    }];
    
    [self showPickupTimePicker];
    
}



- (IBAction)didTapCallRider1:(id)sender {
    Rider * rider = [_driverCallHUD.riders objectAtIndex:0];
    [self callPhone:rider.phone];
}





@end
