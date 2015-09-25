//
//  VCContants.m
//  Voco
//
//  Created by matthewxi on 9/25/15.
//  Copyright © 2015 Voco. All rights reserved.
//

#import "VCConstants.h"

#ifdef STRIPE_MODE_LIVE
NSString *const kStripeApiKey = @"pk_live_4Ub7D8qgqi87KpWFkMRtEkzJ";
#else
NSString *const kStripeApiKey = @"pk_test_qebkNcGfOXsQJ6aSrimJt3mf";
#endif