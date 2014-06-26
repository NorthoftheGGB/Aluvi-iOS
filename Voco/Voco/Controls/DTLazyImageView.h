//
//  DTLazyImageView.h
//  Voco
//
//  Created by Matthew Shultz on 6/25/14.
//  Copyright (c) 2014 Voco. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DTLazyImageView : UIImageView
{
	NSURL *_url;
    
	NSURLConnection *_connection;
	NSMutableData *_receivedData;
}

@property (nonatomic, retain) NSURL *url;

- (void)loadImageAtURL:(NSURL *)url;
- (void)cancelLoading;

@end