/**
 * Copyright (c) 2011 NetFunctional Inc. All Rights Reserved.
 * Please see the LICENSE included with this distribution for details.
 */

#import "TiBase.h"

#import <MapKit/MapKit.h>


@interface TiNFMMapCircle : NSObject<MKOverlay> {
	@private
	MKCircle* circle;
	// specified center of the circle. 
	CLLocationCoordinate2D center;	
	//
	CLLocationDistance radius;
	// color of the outline of the circle that will be rendered. 
	UIColor* strokeColor;
	// color of the interior of the circle that will be rendered. 
	UIColor* fillColor;
	// id of the circle we can use for indexing. 
	NSString* circleID;
	// the width of the line
	CGFloat lineWidth;
	//TODO - create additional properties for other aesthetic aspects of the circle - mmatan
	CGFloat strokeAlpha;  //alpha transparency of stroke
	CGFloat fillAlpha;    //alpha transparency of fill
	MKMapRect boundingRect;
}
@property (nonatomic, assign) MKCircle* circle;
@property (nonatomic, assign) CLLocationDistance radius;
@property (nonatomic, assign) CLLocationCoordinate2D center;	
@property (nonatomic, assign) CGFloat lineWidth;
@property (nonatomic, assign) CGFloat strokeAlpha;
@property (nonatomic, assign) CGFloat fillAlpha;
@property (nonatomic, retain) UIColor* strokeColor;
@property (nonatomic, retain) UIColor* fillColor;
@property (nonatomic, retain) NSMutableArray* points;
@property (nonatomic, retain) NSString* circleID;
@property (nonatomic) MKMapRect boundingRect;

-(id) circleWithCenterCoordinate:(CLLocationCoordinate2D)coord radius:(CLLocationDistance)radius;
@end
