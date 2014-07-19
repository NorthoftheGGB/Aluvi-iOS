//
//  main.m
//  Voco
//
//  Created by Matthew Shultz on 5/20/14.
//  Copyright (c) 2014 Voco. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "VCAppDelegate.h"
#import "lecore.h"


int main(int argc, char * argv[])
{
    @autoreleasepool {
        
        // logentries initialization
        le_init();
        le_set_token("ed3d80ed-6310-4d1c-85b0-784610b4011");
        
        return UIApplicationMain(argc, argv, nil, NSStringFromClass([VCAppDelegate class]));
    }
}
