//
//  WRUtilities
//  WinterRoot LLC
//
//  Created by Matthew Shultz on 6/3/12.
//  Copyright (c) 2012 WinterRoot LLC. All rights reserved.
//

#import "WRUtilities.h"
#import "NSDate+Pretty.h"
#import "VCDebug.h"
#import "RavenClient.h"

static UIAlertView * criticalErrorView = nil;
static UIAlertView * networkUnavailableErrorView = nil;

@interface WRUtilities () <UIAlertViewDelegate>

@end

@implementation WRUtilities

+ (id)getViewFromNib: (NSString *) nibName class: (id) class {
    NSArray *bundle = [[NSBundle mainBundle] loadNibNamed:nibName
                                                    owner:nil options:nil];
    UIView * view;
    for (id object in bundle) {
        if ([object isKindOfClass:class])
            view = (UIView *)object;
    }
    assert(view != nil && "View can't be nil");
    return view;
    
}

+ (void) criticalError: (NSError *) error {
    
    NSString * errorString = [NSString stringWithFormat:@"%@ Critical Error: %@", [[NSDate date] pretty], [error debugDescription]];
    NSLog(@"%@", errorString);
    [[VCDebug sharedInstance] apiLog:errorString];
    
    RavenCaptureError(error);
    
    if([[VCDebug sharedInstance] alertsEnabled]) {
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if(criticalErrorView != nil){
                [criticalErrorView dismissWithClickedButtonIndex:0 animated:NO];
            }
            
            NSString * errString = [error debugDescription];
            if([error.domain isEqualToString:@"org.restkit.RestKit.ErrorDomain"]
               && error.code == -1011) {
                
                NSString * trace;
                
                NSError * jsonError;
                NSData *objectData = [ [error.userInfo objectForKey:NSLocalizedRecoverySuggestionErrorKey] dataUsingEncoding:NSUTF8StringEncoding];
                NSDictionary *json = [NSJSONSerialization JSONObjectWithData:objectData
                                                                     options:NSJSONReadingMutableContainers
                                                                       error:&jsonError];
                if(json == nil){
                    trace = @"No Trace Available";
                } else {
                    trace = [json objectForKey:@"error"];
                }
                
                errString = [NSString stringWithFormat:@"Domain: %@\nCode: %i\n URL: %@\n %@\n Trace: %@",
                         error.domain,
                         (int) error.code,
                         [error.userInfo objectForKey:@"NSErrorFailingURLKey" ],
                         [error.userInfo objectForKey:NSLocalizedDescriptionKey ],
                             trace
                             ];
            }
            
            criticalErrorView = [UIAlertView showWithTitle:@"System Error"
                                                   message:errString
                                         cancelButtonTitle:@"Done"
                                         otherButtonTitles:@[@"Copy"]
                                                  tapBlock:^(UIAlertView *alertView, NSInteger buttonIndex) {
                                                      switch (buttonIndex) {
                                                          case 1:
                                                          {
                                                              UIPasteboard *pb = [UIPasteboard generalPasteboard];
                                                              [pb setString:errString];
                                                          }
                                                              break;
                                                              
                                                          default:
                                                              break;
                                                      }
                                                  }];
        });

        
    }
    CLS_LOG(@"%@ Critical Error: %@", [[NSDate date] pretty] , error);
    
}

+ (void) criticalErrorWithString: (NSString *) error {
    
    NSString * errorString = [NSString stringWithFormat:@"%@ Critical Error: %@", [[NSDate date] pretty] , error];
    NSLog(@"%@", errorString);
    [[VCDebug sharedInstance] apiLog:errorString];
    
    if([[VCDebug sharedInstance] alertsEnabled]) {
        
        dispatch_async(dispatch_get_main_queue(), ^{

        if(criticalErrorView != nil){
            [criticalErrorView dismissWithClickedButtonIndex:0 animated:NO];
            criticalErrorView = nil;
        }
        criticalErrorView = [UIAlertView showWithTitle:@"System Error"
                                                   message:error
                                         cancelButtonTitle:@"Done"
                                         otherButtonTitles:@[@"Copy"]
                                                  tapBlock:^(UIAlertView *alertView, NSInteger buttonIndex) {
                                                      switch (buttonIndex) {
                                                          case 1:
                                                          {
                                                              UIPasteboard *pb = [UIPasteboard generalPasteboard];
                                                              [pb setString:error];
                                                          }
                                                              break;
                                                              
                                                          default:
                                                              break;
                                                      }
                                                  }];
        });
    }
                       
    
    CLS_LOG(@"%@ Critical Error: %@", [[NSDate date] pretty] , error);
    
}


+ (void) triage: (NSString *) error {
    
    NSString * errorString = [NSString stringWithFormat:@"%@ Triage: %@", [[NSDate date] pretty] , error];
    NSLog(@"%@", errorString);
    [[VCDebug sharedInstance] apiLog:errorString];
    
    if([[VCDebug sharedInstance] alertsEnabled]) {
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            if(criticalErrorView != nil){
                [criticalErrorView dismissWithClickedButtonIndex:0 animated:NO];
                criticalErrorView = nil;
            }
            criticalErrorView = [UIAlertView showWithTitle:@"Triage"
                                                   message:error
                                         cancelButtonTitle:@"Done"
                                         otherButtonTitles:@[@"Copy"]
                                                  tapBlock:^(UIAlertView *alertView, NSInteger buttonIndex) {
                                                      switch (buttonIndex) {
                                                          case 1:
                                                          {
                                                              UIPasteboard *pb = [UIPasteboard generalPasteboard];
                                                              [pb setString:error];
                                                          }
                                                              break;
                                                              
                                                          default:
                                                              break;
                                                      }
                                                  }];
        });
    }
    
    
    CLS_LOG(@"%@ Critical Error: %@", [[NSDate date] pretty] , error);
    
}


+ (void) subcriticaError: (NSError *) error {
    
    NSString * errorString = [NSString stringWithFormat:@"%@ Error: %@", [[NSDate date] pretty], [error debugDescription]];
    NSLog(@"%@", errorString);
    [[VCDebug sharedInstance] apiLog:errorString];
    
    if([[VCDebug sharedInstance] alertsEnabled]) {
        if(criticalErrorView != nil){
            [criticalErrorView dismissWithClickedButtonIndex:0 animated:NO];
        }
        
        UIAlertView *alert = [[UIAlertView alloc]
                              initWithTitle: @"Critical Error"
                              message: [error debugDescription]
                              delegate: nil
                              cancelButtonTitle:@"OK"
                              otherButtonTitles:nil];
        criticalErrorView = alert;
        [alert show];
    }
    CLS_LOG(@"%@ Critical Error: %@", [[NSDate date] pretty] , error);
}

+ (void) subcriticalErrorWithString: (NSString *) error {
    
    NSString * errorString = [NSString stringWithFormat:@"%@ Error: %@", [[NSDate date] pretty] , error];
    NSLog(@"%@", errorString);
    [[VCDebug sharedInstance] apiLog:errorString];
    
    UIAlertView *alert = [[UIAlertView alloc]
                          initWithTitle: @"Error"
                          message: error
                          delegate: self
                          cancelButtonTitle:@"OK"
                          otherButtonTitles:nil];
    [alert performSelectorOnMainThread:@selector(show) withObject:nil waitUntilDone:YES];
    
}

+ (void) warningWithString: (NSString *) error {
    NSString * errorString = [NSString stringWithFormat:@"%@ Warning: %@", [[NSDate date] pretty] , error];
    NSLog(@"%@", errorString);
    [[VCDebug sharedInstance] apiLog:errorString];
    
    UIAlertView *alert = [[UIAlertView alloc]
                          initWithTitle: @"Warning"
                          message: error
                          delegate: self
                          cancelButtonTitle:@"OK"
                          otherButtonTitles:nil];
    [alert performSelectorOnMainThread:@selector(show) withObject:nil waitUntilDone:YES];
}


+ (void) stateErrorWithString: (NSString *) error {
    
    NSLog(@"%@ Critical Error: %@", [[NSDate date] pretty] , error);
    
    if(criticalErrorView != nil){
        [criticalErrorView dismissWithClickedButtonIndex:0 animated:NO];
        criticalErrorView = nil;
    }
    
    UIAlertView *alert = [[UIAlertView alloc]
                          initWithTitle: @"Error"
                          message: error
                          delegate: self
                          cancelButtonTitle:@"OK"
                          otherButtonTitles:nil];
    criticalErrorView = alert;
    [alert performSelectorOnMainThread:@selector(show) withObject:nil waitUntilDone:YES];
    
}

+ (void) successMessage: (NSString *) message {
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Success"
                                                    message:message
                                                   delegate:nil
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles:nil];
    [alert show];
}


- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    criticalErrorView = nil;
}

+ (void)showNetworkUnavailableMessage {
    if(networkUnavailableErrorView == nil) {
        networkUnavailableErrorView = [UIAlertView showWithTitle:@"Network Unavailable" message:@"This application requires internet connectivity" cancelButtonTitle:@"OK" otherButtonTitles:nil tapBlock:^(UIAlertView *alertView, NSInteger buttonIndex) {
            networkUnavailableErrorView = nil;
        }];
    }
}


@end
