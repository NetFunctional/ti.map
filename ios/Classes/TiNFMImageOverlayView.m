/**
 * Copyright (c) 2011 NetFunctional Inc. All Rights Reserved.
 * Please see the LICENSE included with this distribution for details.
 */

#import <MapKit/MapKit.h>
#import "TiNFMImageOverlayView.h"
#import "TiNFMImageOverlay.h"


@implementation TiNFMImageOverlayView

@synthesize overl,counter,overlay;
 
- (id)initWithUIImage:(TiNFMImageOverlay*)imageOverlay {
	self.counter=0;
	//NSLog(@"Initializing NFM image overlay view");
	if (self = [super init]) {
		self.overl = imageOverlay;
		//self.overlay = imageOverlay;
	}
	return self;	
}

-(id) basicInit {
		if (self = [super init]) {
		}
		return self;
	
}

- (void)drawMapRect:(MKMapRect)mapRect zoomScale:(MKZoomScale)zoomScale inContext:(CGContextRef)context {
    NSLog(@"Zoom Scale is %f",zoomScale);
	self.counter++;
	//NSLog(@"blahtastic!  drawing map rect for custom image overlay; called %d times",counter);
	
	TiNFMImageOverlay* ovl = self.overl;
	CGFloat alpha = ovl.alpha;
	UIImage *image = ovl.img;
    
    NSLog(@"Zoom scale min is %f and zoom scale max is %f",ovl.minZoomScale,ovl.maxZoomScale);
    
    //don't draw anything if we are outside the allowed zoom scale range
    if (zoomScale < ovl.minZoomScale || zoomScale > ovl.maxZoomScale) return;

	//TODO replace with the map rect for the bounding map rect by deleting following line and uncommenting line afterwards
	//MKMapRect theMapRect =MKMapRectWorld;
    MKMapRect theMapRect = [ovl boundingMapRect];
//	NSLog(@"comparing mapRect with boundingMapRect for x,y,w,h: (%f,%f,%f,%f) vs (%f,%f,%f,%f)",
//		  mapRect.origin.x,
//		  mapRect.origin.y,
//		  mapRect.size.width,
//		  mapRect.size.height,
//		  theMapRect.origin.x,
//		  theMapRect.origin.y,
//		  theMapRect.size.width,
//		  theMapRect.size.height
//		  );
		  
    CGRect theRect = [self rectForMapRect:theMapRect];
	//CGRect theRect = [self rectForMapRect:mapRect];

	//TODO consider removing usage of UIKit and using Core Graphics instead, as recommended in the class reference for MKOverlayView
	
	//CG version of drawing code - mmatan
//	CGImageRef imageReference = image.CGImage;
//	
//	//CGRect theRect           = [self rectForMapRect:theMapRect];
//    CGRect clipRect     = [self rectForMapRect:mapRect];
//	
//	//NSUserDefaults *preferences = [NSUserDefaults standardUserDefaults];
//    CGContextSetAlpha(context, alpha);
//	
//    CGContextAddRect(context, clipRect);
//    CGContextClip(context);
//	
//    CGContextDrawImage(context, theRect, imageReference);


	//end of CG stuff - mmatan

	UIGraphicsPushContext(context);
	//[image drawInRect:[self rectForMapRect:mapRect] blendMode:kCGBlendModeNormal alpha:alpha];
	[image drawInRect:theRect blendMode:kCGBlendModeNormal alpha:alpha];
    UIGraphicsPopContext();
}

@end
