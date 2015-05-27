/**
 * Copyright (c) 2011 NetFunctional Inc. All Rights Reserved.
 * Please see the LICENSE included with this distribution for details.
 */
#import "TiBase.h"
#import <MapKit/MapKit.h>
#import <CoreLocation/CoreLocation.h>
#import "TiUtils.h"

#import "TiNFMMapPolygon.h"




@implementation TiNFMMapPolygon

@synthesize polygon, strokeColor, fillColor, points, polygonID, lineWidth, strokeAlpha, fillAlpha, coordinate = center,boundingRect;


-(id) initWithPoints:(NSArray*) points_
{
	//points_ should be a list of lat/long coordinates
	
	if (self = [super init])
	{
		//allocate an internal array which will hold the coordinates in the form of CLLocation objects
		points = [[NSMutableArray alloc] initWithCapacity:points_.count];
		
		//need to create this reference object so that we can determine the size of elements of the coords array when we dynamically allocate it.
		struct foo {
			CLLocationDegrees latitude;
			CLLocationDegrees longitude;
		};
		
		coords = malloc(sizeof(struct foo) * points_.count);
		
		//iterate through the points_ array of dictionary tuples and generate the points array of CLLocation objs
		for(int idx = 0; idx < points_.count; idx++)
		{
			NSDictionary *entry = [points_ objectAtIndex:idx];
			CLLocationDegrees lat = [TiUtils doubleValue:[entry objectForKey:@"latitude"]];
			CLLocationDegrees lon = [TiUtils doubleValue:[entry objectForKey:@"longitude"]];
			CLLocation* currentLocation = [[CLLocation alloc] initWithLatitude:lat longitude:lon];
			[points addObject:currentLocation];
			[currentLocation release];

			CLLocationCoordinate2D coord = CLLocationCoordinate2DMake(lat,lon);

			coords[idx] = coord;

		}
		
		// determine a logical center point for this route based on the middle of the lat/lon extents.
		double maxLat = -91;
		double minLat =  91;
		double maxLon = -181;
		double minLon =  181;
		
		//determine max and min lat/lon range of the coordinates by scanning the array
		for(CLLocation* currentLocation in points)
		{
			CLLocationCoordinate2D coordinate = currentLocation.coordinate;
			
			if(coordinate.latitude > maxLat)
			{
				maxLat = coordinate.latitude;
			}
			if(coordinate.latitude < minLat)
			{
				minLat = coordinate.latitude;
			}
			if(coordinate.longitude > maxLon)
			{
				maxLon = coordinate.longitude;
			}
			if(coordinate.longitude < minLon)
			{
				minLon = coordinate.longitude; 
			}
		}
		
		//generate a viewable span from the max min values
		span.latitudeDelta = (maxLat + 90) - (minLat + 90);
		span.longitudeDelta = (maxLon + 180) - (minLon + 180);

		
		// the center point is the average of the max and mins
		center.latitude = minLat + span.latitudeDelta / 2;
		center.longitude = minLon + span.longitudeDelta / 2;
		
//		self.boundingRect = MKMapRectMake(minLon,minLat,span.longitudeDelta,span.latitudeDelta); 
//		self.boundingRect = MKMapRectMake(minLon,minLat,maxLon - minLon,maxLat-minLat); 
		//TODO revise to return the most compact rectangle containing the overlay, rather than a rectangle containing the whole world
		self.boundingRect = MKMapRectWorld;
		
		
		//self.strokeColor = [UIColor blueColor];
		//self.lineWidth = 2;
		
		//initialize the native polygon object with the coordinats passed
		self.polygon = [MKPolygon polygonWithCoordinates:coords count:points_.count];
	}	
	return self;
}

-(MKCoordinateRegion) region
{
	MKCoordinateRegion region_;
	region_.center = center;
	region_.span = span;
	return region_;
}

-(void) dealloc
{
	RELEASE_TO_NIL(points);
	RELEASE_TO_NIL(polygonID);
	//TODO consider better ways of handling the deallocation of space for polygon, rather than having the mapkit object do it.
	//RELEASE_TO_NIL(polygon);  //Note:  This is NOT deallocated automatically because when you remove this <Overlay> from a mapkit map object, the mkpolygon will be deallocated automagically, and then attempts to deallocate this will fail with EXC_BAD_ACCESS
	//RELEASE_TO_NIL(coords);	//TODO deallocated coords array
	//dealloc(coords);
	RELEASE_TO_NIL(strokeColor);
	RELEASE_TO_NIL(fillColor);	
	[super dealloc];
}

-(MKMapRect) boundingMapRect
{

	//NSLog(@"Here is the boundingMapRect object info: origin (x,y):(%f,%f), width,height:(%f,%f)",
//	self.boundingRect.origin.x, self.boundingRect.origin.y,self.boundingRect.size.width,self.boundingRect.size.height);

	return self.boundingRect;
	//TODO consider using the boundingMapRect value for self.polygon, as that should implement it correctly.
	//return self.polygon.boundingMapRect;

}

@end

