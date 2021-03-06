//
//  VCDebug.m
//  Voco
//
//  Created by Matthew Shultz on 7/18/14.
//  Copyright (c) 2014 Voco. All rights reserved.
//

#import "VCDebug.h"
#import "VCPushReceiver.h"
#import "VCApi.h"
#import "VCCommuteManager.h"


#define kLoggedInUserIdentifier @"DEBUG_LOGGED_IN_USER_IDENTIFIER"

static VCDebug * instance;

@interface VCDebug () <NSURLConnectionDelegate>

@property (nonatomic, strong) NSString * userIdentifier;
@property (nonatomic) BOOL pushTokenConfirmationEnabled;

@end

@implementation VCDebug

+ (void) showTriage {
    NSString * pushToken = [[NSUserDefaults standardUserDefaults] stringForKey:kPushTokenKey];
    BOOL pushTokenPublished = [[NSUserDefaults standardUserDefaults] boolForKey:kPushTokenPublishedKey];
    NSString * pushPublished = pushTokenPublished ? @"YES" : @"NO";
    NSString * userToken = [[VCApi apiToken] substringToIndex:6];

    NSString * message = [NSString stringWithFormat:@"User Token: %@ \n Push Token: %@ \nPush Token Published %@ \n", userToken, pushToken, pushPublished];
    
    NSString * alertsEnabledText = @"Enable Error Alerts";
    if([VCDebug sharedInstance].alertsEnabled){
        alertsEnabledText = @"Disable Error Alerts";
    }
    
    NSMutableArray * buttons =  [@[@"Refresh Push Token", alertsEnabledText, @"Status", @"Purge Tickets"] mutableCopy];
    
#if defined(DEVELOPMENT) || defined(NIGHTLY)
    [buttons addObject:@"Schedule Tickets"];
    
    NSString * blockPushMessagesText = @"Block Push Messages";
    if([VCDebug sharedInstance].blockPushMessages){
        blockPushMessagesText = @"Unblock Push Messages";
    }
    [buttons addObject:blockPushMessagesText];
#endif
    

    NSString * version = [[NSBundle mainBundle] objectForInfoDictionaryKey: @"CFBundleShortVersionString"];
    NSString * build = [[NSBundle mainBundle] objectForInfoDictionaryKey: (NSString *)kCFBundleVersionKey];
    NSString * appVersion = [NSString stringWithFormat:@"v%@b%@", version, build];
    NSString * title = [NSString stringWithFormat:@"Welcome to Triage %@", appVersion];
    [UIAlertView showWithTitle:title message:message cancelButtonTitle:@"OK" otherButtonTitles:buttons tapBlock:^(UIAlertView *alertView, NSInteger buttonIndex) {
        switch (buttonIndex) {
            case 1:
            {
                [VCPushReceiver registerForRemoteNotifications];
                [[VCDebug sharedInstance] enablePushTokenConfirmation];
            }
                break;
            case 2:
            {
                if([VCDebug sharedInstance].alertsEnabled){
                    [VCDebug sharedInstance].alertsEnabled = false;
                } else {
                    [VCDebug sharedInstance].alertsEnabled = true;

                }
                break;
            }
            case 3:
            {
                Ticket * ticket = [[VCCommuteManager instance] getDefaultTicket];
                Ticket * backHomeTicket = [[VCCommuteManager instance] getTicketBackHome];
                NSString * status = @"No Status";
                if(ticket != nil && backHomeTicket != nil){
                    status = [NSString stringWithFormat:@"My Commute: %@ %@ \nBack Home: %@ %@",
                              ticket.state, ticket.trip_state, backHomeTicket.state, backHomeTicket.trip_state ];
                }
                [UIAlertView showWithTitle:@"Ticket Status" message:status cancelButtonTitle:@"OK" otherButtonTitles:nil tapBlock:nil];
            }
            case 4:
            {
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                    
                    NSMutableURLRequest *req = [NSMutableURLRequest requestWithURL:
                                                [NSURL URLWithString:
                                                 [NSString stringWithFormat:@"%@%@", API_BASE_URL, @"v2/debug/purge"]
                                                 ]];
                    [req setHTTPMethod:@"POST"];
                    [req addValue:[NSString stringWithFormat:@"Token token=\"%@\"", [VCApi apiToken] ] forHTTPHeaderField:@"Authorization"];
                    NSURLResponse* response;
                    NSError* error;
                    [NSURLConnection sendSynchronousRequest:req returningResponse:&response error:&error];
                    if(error !=nil){
                        [WRUtilities criticalError:error];
                    }
                    [VCCoreData clearUserData];
                    [[VCCommuteManager instance] refreshTickets];
                });
                break;

            }
            case 5:
            {
#if defined(DEVELOPMENT) || defined(NIGHTLY)
                NSMutableURLRequest *req = [NSMutableURLRequest requestWithURL:
                                     [NSURL URLWithString:
                                                             [NSString stringWithFormat:@"%@%@", API_BASE_URL, @"v2/debug/schedule_commute"]
                                     ]];
                [req setHTTPMethod:@"POST"];
                [req addValue:[NSString stringWithFormat:@"Token token=\"%@\"", [VCApi apiToken] ] forHTTPHeaderField:@"Authorization"];
                NSURLConnection *conn = [NSURLConnection connectionWithRequest:req delegate:self];
                [conn start];
#else
                [UIAlertView showWithTitle:@"Not Allowed"  message:@"Sorry, can't let you do that!"  cancelButtonTitle:@"OK" otherButtonTitles:nil tapBlock:nil];
#endif

            }
            case 6:
            {
                if([VCDebug sharedInstance].blockPushMessages){
                    [VCDebug sharedInstance].blockPushMessages = false;
                } else {
                    [VCDebug sharedInstance].blockPushMessages = true;
                    
                }
                break;
            }

                
                break;
                
            default:
                break;
        }
    }];
}

+ (VCDebug *) sharedInstance {
    if (instance == nil){
        instance = [[VCDebug alloc] init];

    }
    return instance;
}

- (id)init{
    self = [super init];
    if (self != nil){
        self.userIdentifier = [[NSUserDefaults standardUserDefaults] objectForKey:kLoggedInUserIdentifier];
        self.pushTokenConfirmationEnabled = NO;
#ifdef DEBUG
        self.alertsEnabled = YES;
#endif
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(pushTokenUpdated) name:kPushTokenUpdatedNotification object:nil];
    return self;
}

- (void) pushTokenUpdated {
    if(_pushTokenConfirmationEnabled) {
        [UIAlertView showWithTitle:@"Triage Message" message:@"Push Token Updated" cancelButtonTitle:@"OK" otherButtonTitles:nil tapBlock:nil];
    }
}

-(void) enablePushTokenConfirmation {
    _pushTokenConfirmationEnabled = YES;
}



- (void) setLoggedInUserIdentifier: (NSString *) identifier {
    [[NSUserDefaults standardUserDefaults] setObject:identifier forKey:kLoggedInUserIdentifier];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void) clearLoggedInUserIdentifier {
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:kLoggedInUserIdentifier];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void) log:(NSString *) string {
    NSLog(@"Log: %@", string);
    //[[LELog sharedInstance] log:[NSString stringWithFormat:@"%@: %@", _userIdentifier, string]];
}

- (void) apiLog:(NSString *) string {
    [self log:[NSString stringWithFormat:@"API: %@", string]];
}

- (void) localNotificationLog:(NSString *) string {
    [self log:[NSString stringWithFormat:@"Local Notification: %@", string]];
}

- (void) remoteNotificationLog:(NSString *) string {
    [self log:[NSString stringWithFormat:@"Remote Notification: %@", string]];
}



- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    [WRUtilities criticalError:error];
}

@end
