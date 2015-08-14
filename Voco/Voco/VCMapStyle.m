//
//  VCMapStyle.m
//  Voco
//
//  Created by matthewxi on 8/11/15.
//  Copyright (c) 2015 Voco. All rights reserved.
//

#import "VCMapStyle.h"
#import "VCMapConstants.h"

@implementation VCMapStyle

+ (UIImage *) homePinImage {
    return [UIImage imageNamed:@"map_pin_red"];
}

+ (UIImage *) workPinImage {
    return [UIImage imageNamed:@"map_pin_green"];
}


+ (UIImage *) annotationImageForType: (NSInteger) type {
    UIImage * image = nil;
    switch (type) {
        case kHomeType:
            image = [VCMapStyle homePinImage];
            break;
        case kWorkType:
            image = [VCMapStyle workPinImage];
            break;
        default:
            break;
    }
    return image;
}

+ (NSInteger) defaultZoomForType: (NSInteger) type {
    if(type == kHomeType || type == kWorkType){
        return 11;
    } else if (type == kPickupZoneType){
        return 9;
    }
    return 9;
    
}

@end