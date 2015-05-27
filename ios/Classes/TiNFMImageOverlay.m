/**
 * Copyright (c) 2011 NetFunctional Inc. All Rights Reserved.
 * Please see the LICENSE included with this distribution for details.
 */

#import "TiNFMImageOverlay.h"


@implementation TiNFMImageOverlay

@synthesize northWestCorner, southEastCorner, img, width, height,alpha, minZoomScale, maxZoomScale;



-(MKMapRect) boundingMapRect
{
	
 
	MKMapPoint nwc = MKMapPointForCoordinate(northWestCorner);
	MKMapPoint sec = MKMapPointForCoordinate(southEastCorner);
	MKMapRect brect = MKMapRectMake(nwc.x,nwc.y,sec.x-nwc.x,sec.y-nwc.y);
//	NSLog(@"boundingMapRect details within function for x,y,w,h: (%f,%f,%f,%f)",
//		  brect.origin.x,
//		  brect.origin.y,
//		  brect.size.width,
//		  brect.size.height
//
//		  );
	return brect;
}

-(id) overlayWithImage:(UIImage*)image northWestBound:(CLLocationCoordinate2D)nwc southEastBound:(CLLocationCoordinate2D)sec alpha:(CGFloat)alphaTransparency{
	//NSLog(@"Initializing NFM image overlay");
	if (self = [super init]) {
		self.img = [image retain];
		self.northWestCorner = nwc;
		self.southEastCorner = sec;
		self.alpha = alphaTransparency;
	}
	return self;
}

-(CLLocationCoordinate2D) coordinate {
	CGFloat latDelta = (self.southEastCorner.latitude + 180) - (self.northWestCorner.latitude + 180) ;  //TODO do we need to add the 180 to each?  Seems unnecessary, though I can't see how it hurts (besides a ~negligible performance hit) ...
	CGFloat lonDelta =  (self.southEastCorner.longitude + 90) - (self.northWestCorner.longitude + 90);  //TODO do we need to add the 180 to each?  Seems unnecessary, though I can't see how it hurts (besides a ~negligible performance hit) ...
	CLLocationCoordinate2D coord = CLLocationCoordinate2DMake(self.northWestCorner.latitude-latDelta/2,self.northWestCorner.longitude-lonDelta/2);
	//NSLog(@"central coordinate for image overlay is (lat/lon degress): %d,%d",coord.latitude,coord.longitude);
	return coord;
	
	//return MKCoordinateForMapPoint(MKMapPointMake(MKMapRectGetMidX(self.boundingMapRect), MKMapRectGetMidY(self.boundingMapRect)));
}

//TODO destructor
-(void) dealloc
{
	RELEASE_TO_NIL(img);
	
	[super dealloc];
}

@end
