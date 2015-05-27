/**
 * Copyright (c) 2011 NetFunctional Inc. All Rights Reserved.
 * Please see the LICENSE included with this distribution for details.
 */

#import "TiBase.h"

#import <MapKit/MapKit.h>


@interface TiNFMImageOverlay : NSObject<MKOverlay> {
	@private
	UIImage* img;
	CLLocationCoordinate2D northWestCorner;
	CLLocationCoordinate2D southEastCorner;
	CLLocationDistance width;
	CLLocationDistance height;	
	MKMapRect boundingMapRect;
	CGFloat	alpha;
    
	CGFloat minZoomScale;
    CGFloat maxZoomScale;
}

@property (nonatomic, assign)	CLLocationCoordinate2D northWestCorner;
@property (nonatomic, assign)	CLLocationCoordinate2D southEastCorner;
@property (nonatomic, assign)	CLLocationDistance width;
@property (nonatomic, assign)	CLLocationDistance height;	
@property (nonatomic, assign)	UIImage* img;
@property (nonatomic, assign)	CGFloat	alpha;
@property (nonatomic, readonly) MKMapRect boundingMapRect;

@property (nonatomic, assign)   CGFloat minZoomScale;
@property (nonatomic, assign)   CGFloat maxZoomScale;

-(id) overlayWithImage:(UIImage*)image northWestBound:(CLLocationCoordinate2D)nwc southEastBound:(CLLocationCoordinate2D)sec alpha:(CGFloat)alphaTransparency;

@end
