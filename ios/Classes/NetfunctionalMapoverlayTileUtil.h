//
//  NetfunctionalMapoverlayTileUtil.h
//  NFMapTileNativePlay
//
//  Created by Michael Matan on 13-08-09.
//  Copyright (c) 2013 Michael Matan. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

@interface TileInfo: NSObject {
    int x;
    int y;
    int zoom;
    CLLocationCoordinate2D nwCorner;
    CLLocationCoordinate2D seCorner;
    
}

@property (nonatomic, assign) int x;
@property (nonatomic, assign) int y;
@property (nonatomic, assign) int zoom;
@property (nonatomic, assign)     CLLocationCoordinate2D nwCorner;
@property (nonatomic, assign)     CLLocationCoordinate2D seCorner;

@end

@interface NetfunctionalMapoverlayTileUtil : NSObject

+(TileInfo*) tileContainingCoordinate:(CLLocationCoordinate2D)coordinate atLevel:(int) zoom ;
+(NSArray*) tilesCoveringRegion:(MKCoordinateRegion)region atLevel:(NSUInteger) zoom;
@end
