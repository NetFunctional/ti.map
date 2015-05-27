/**
 * Copyright (c) 2011 NetFunctional Inc. All Rights Reserved.
 * Please see the LICENSE included with this distribution for details.
 */

#import "TiNFMFloatingImageOverlay.h"


@implementation TiNFMFloatingImageOverlay

@synthesize centerCoord, img, width, height,alpha;



-(MKMapRect) boundingMapRect
{
	

//	MKMapPoint nwc = MKMapPointForCoordinate(northWestCorner);
//	MKMapPoint sec = MKMapPointForCoordinate(southEastCorner);
//	MKMapRect brect = MKMapRectMake(nwc.x,nwc.y,sec.x-nwc.x,sec.y-nwc.y);
//	NSLog(@"boundingMapRect details within function for x,y,w,h: (%f,%f,%f,%f)",
//		  brect.origin.x,
//		  brect.origin.y,
//		  brect.size.width,
//		  brect.size.height
//
//		  );
//	return brect;
    //TODO calculate the bounding rect based on the centercoord and the mapview points, if possible (since we need to know the current zoomlevel for that)
    return MKMapRectWorld;
}

-(id) overlayWithImage:(UIImage*)image centerCoord:(CLLocationCoordinate2D)center width:(CGFloat)width alpha:(CGFloat)alphaTransparency{
	//NSLog(@"Initializing NFM image overlay");
	if (self = [super init]) {
		self.img = image;
		self.centerCoord = center;
        self.width = width;
		self.alpha = alphaTransparency;
        //[self.img retain];
	}
	return self;
}

-(CLLocationCoordinate2D) coordinate {
	return self.centerCoord;
	
	//return MKCoordinateForMapPoint(MKMapPointMake(MKMapRectGetMidX(self.boundingMapRect), MKMapRectGetMidY(self.boundingMapRect)));
}

//TODO destructor
-(void) dealloc
{
	RELEASE_TO_NIL(img);
	
	[super dealloc];
    //[self.img release];
}

@end
