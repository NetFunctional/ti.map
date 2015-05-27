/**
 * Copyright (c) 2011 NetFunctional Inc. All Rights Reserved.
 * Please see the LICENSE included with this distribution for details.
 */

#import "TiBase.h"

#import <MapKit/MapKit.h>


@interface TiNFMFloatingImageOverlay : NSObject<MKOverlay> {
	@private
	UIImage* img;
	CLLocationCoordinate2D centerCoord;
	CLLocationDistance width;
	CLLocationDistance height;	
	MKMapRect boundingMapRect;
	CGFloat	alpha;
	
	
}

@property (nonatomic, assign)	CLLocationCoordinate2D centerCoord;
@property (nonatomic, assign)	CLLocationDistance width;
@property (nonatomic, assign)	CLLocationDistance height;	
@property (nonatomic, assign)	UIImage* img;
@property (nonatomic, assign)	CGFloat	alpha;
@property (nonatomic, readonly) MKMapRect boundingMapRect;

-(id) overlayWithImage:(UIImage*)image centerCoord:(CLLocationCoordinate2D)center width:(CGFloat)width alpha:(CGFloat)alphaTransparency;

@end
