//
//  VCMapStyle.h
//  Voco
//
//  Created by matthewxi on 8/11/15.
//  Copyright (c) 2015 Voco. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface VCMapStyle : NSObject

+ (UIImage *) homePinImage;
+ (UIImage *) workPinImage;
+ (UIImage *) annotationImageForType: (NSInteger) type;
+ (NSInteger) defaultZoomForType: (NSInteger) type;

@end
