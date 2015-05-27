/**
 * Copyright (c) 2011 NetFunctional Inc. All Rights Reserved.
 * Please see the LICENSE included with this distribution for details.
 */

#import "TiBase.h"



#import <MapKit/MapKit.h>

@interface TiNFMMapPolyline : NSObject<MKOverlay> { //TODO consider removing MKOverlay profile
@private
	//the mapkit object which will define the actual overlay for inclusion in the native map
	MKPolyline *polyline;
	// points that make up the polyline. 
	NSMutableArray* points; 
	// coords that make up the polyline. 
	//NSMutableArray* coords; 
	CLLocationCoordinate2D* coords; 
	// computed span of the polyline
	MKCoordinateSpan span;
	// computed center of the polyline. 
	CLLocationCoordinate2D center;	
	// color of the outline of the polyline that will be rendered. 
	UIColor* strokeColor;
	// color of the interior of the polyline that will be rendered. 
	UIColor* fillColor;
	// id of the polyline we can use for indexing. 
	NSString* polylineID;
	// the width of the line
	CGFloat lineWidth;
	//TODO - create additional properties for other aesthetic aspects of the polyline - mmatan
	CGFloat strokeAlpha;  //alpha transparency of stroke
	CGFloat fillAlpha;    //alpha transparency of fill
	MKMapRect boundingRect;
	
	
}

@property (readonly) MKCoordinateRegion region;
@property (nonatomic, assign) MKPolyline* polyline;
@property (nonatomic, assign) CGFloat lineWidth;
@property (nonatomic, assign) CGFloat strokeAlpha;
@property (nonatomic, assign) CGFloat fillAlpha;
@property (nonatomic, retain) UIColor* strokeColor;
@property (nonatomic, retain) UIColor* fillColor;
@property (nonatomic, retain) NSMutableArray* points;
@property (nonatomic, retain) NSString* polylineID;
@property (nonatomic) MKMapRect boundingRect;


-(id) initWithPoints:(NSArray*) points;

@end

