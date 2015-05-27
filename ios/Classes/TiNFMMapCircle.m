/**
 * Copyright (c) 2011 NetFunctional Inc. All Rights Reserved.
 * Please see the LICENSE included with this distribution for details.
 */

#import "TiNFMMapCircle.h"


@implementation TiNFMMapCircle

@synthesize circle, strokeColor, fillColor, points, circleID, lineWidth, strokeAlpha, fillAlpha, center,boundingRect;

-(id) circleWithCenterCoordinate:(CLLocationCoordinate2D)coord radius:(CLLocationDistance)circleRadius {
	if (self = [super init]) {
//		self.center = coord;
//		self.radius = circleRadius;
		//TODO revise to return the most compact rectangle containing the overlay, rather than a rectangle containing the whole world
		self.boundingRect = MKMapRectWorld;
		
		//initialize the mkcircle object which will hold the overlay information used by mapkit
		self.circle = [MKCircle circleWithCenterCoordinate:coord radius:circleRadius];

	}
	return self;

}

-(MKMapRect) boundingMapRect
{
	
	//NSLog(@"Here is the boundingMapRect object info: origin (x,y):(%d,%d), width,height:(%d,%d)",
	//	  self.boundingRect.origin.x, self.boundingRect.origin.y,self.boundingRect.size.width,self.boundingRect.size.height);
	
	return self.boundingRect;
	
}

@end
