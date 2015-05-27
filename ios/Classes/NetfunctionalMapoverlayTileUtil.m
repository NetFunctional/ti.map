//
//  NetfunctionalMapoverlayTileUtil.m
//  NFMapTileNativePlay
//
//  Created by Michael Matan on 13-08-09.
//  Copyright (c) 2013 Michael Matan. All rights reserved.
//

#import "NetfunctionalMapoverlayTileUtil.h"

@implementation TileInfo

@synthesize x = _x;
@synthesize y = _y;
@synthesize zoom = _zoom;
@synthesize nwCorner = _nwCorner;
@synthesize seCorner = _seCorner;

@end

@implementation NetfunctionalMapoverlayTileUtil

//int long2tilex(double lon, int z)
float long2tilex(double lon, int z)
{
//	return (int)(floor((lon + 180.0) / 360.0 * pow(2.0, z)));
	return (((lon + 180.0) / 360.0 * pow(2.0, z)));
}

//int lat2tiley(double lat, int z)
float lat2tiley(double lat, int z)
{
//	return (int)(floor((1.0 - log( tan(lat * M_PI/180.0) + 1.0 / cos(lat * M_PI/180.0)) / M_PI) / 2.0 * pow(2.0, z)));
    	return (((1.0 - log( tan(lat * M_PI/180.0) + 1.0 / cos(lat * M_PI/180.0)) / M_PI) / 2.0 * pow(2.0, z)));
}

double tilex2long(int x, int z)
{
	return x / pow(2.0, z) * 360.0 - 180;
}

double tiley2lat(int y, int z)
{
	double n = M_PI - 2.0 * M_PI * y / pow(2.0, z);
    return 180.0 / M_PI * atan(0.5 * (exp(n) - exp(-n)));
}

+(TileInfo*) tileContainingCoordinate:(CLLocationCoordinate2D)coordinate atLevel:(int) zoom {
    TileInfo* tinfo = [[TileInfo alloc] init];
    float tileX =long2tilex(coordinate.longitude, zoom);
    float tileY =lat2tiley(-coordinate.latitude, zoom);
//    [tinfo setX:long2tilex(coordinate.longitude, zoom)];
//    [tinfo setY:lat2tiley(coordinate.latitude, zoom)];
    tileY = MAX(tileY,0);
    tileX = MAX(tileX,0);
    
    
    NSLog(@"determined tile for coordinates (lat,lon,zoom) %f,%f,%d to have indexes %f,%f",coordinate.latitude,coordinate.longitude,zoom,tileX,tileY);
    
//    CLLocationCoordinate2D nwCorner = CLLocationCoordinate2DMake(tiley2lat(floor(tinfo.y), zoom), tilex2long(floor(tinfo.x), zoom));
//    CLLocationCoordinate2D seCorner = CLLocationCoordinate2DMake(tiley2lat(ceil(tinfo.y), zoom), tilex2long(ceil(tinfo.x), zoom));
    
    CLLocationCoordinate2D nwCorner = CLLocationCoordinate2DMake(-tiley2lat(ceil(tileY), zoom), tilex2long(floor(tileX), zoom));
    CLLocationCoordinate2D seCorner = CLLocationCoordinate2DMake(-tiley2lat(floor(tileY), zoom), tilex2long(ceil(tileX), zoom));
    
    
    
    [tinfo setNwCorner:nwCorner];
    [tinfo setSeCorner:seCorner];
    
    [tinfo setX:floor(tileX)];
    [tinfo setY:floor(tileY)];
    
    [tinfo setZoom:zoom];
    
    return tinfo; //TODO release tinfo
}

+(TileInfo*) tileWithX:(NSUInteger)x andY:(NSUInteger)y andZoom:(NSUInteger) zoom {
    TileInfo* tinfo = [[TileInfo alloc] init];
    
    CLLocationCoordinate2D nwCorner = CLLocationCoordinate2DMake(-tiley2lat(ceil(y), zoom), tilex2long(floor(x), zoom));
    CLLocationCoordinate2D seCorner = CLLocationCoordinate2DMake(-tiley2lat(floor(y), zoom), tilex2long(ceil(x), zoom));
    
    
    
    [tinfo setNwCorner:nwCorner];
    [tinfo setSeCorner:seCorner];
    
    [tinfo setX:floor(x)];
    [tinfo setY:floor(y)];
    
    [tinfo setZoom:zoom];
    
    if (isnan([tinfo zoom]) || isnan([tinfo x]) || isnan([tinfo y])) {
        NSLog(@"Error: zoom, x or y is nan");
        return nil;
    }
    
    
    return tinfo; //TODO release tinfo
}


+(void) ensureValid:(CLLocationCoordinate2D) coord {
    coord.longitude = MAX(coord.longitude, -180);
    coord.longitude = MIN(coord.longitude, 180);
    coord.latitude = MAX(coord.latitude, -90);
    coord.latitude = MIN(coord.latitude,90);
    
}

//returns array of TileInfo
+(NSArray*) tilesCoveringRegion:(MKCoordinateRegion)region atLevel:(NSUInteger) zoom {
    NSMutableArray* tiles = [[NSMutableArray alloc] initWithCapacity:4];
    //first we'll get the tile covering the nw corner, the region's 'origin' point
    CLLocationCoordinate2D nwCorner = CLLocationCoordinate2DMake(region.center.latitude - region.span.latitudeDelta/2, region.center.longitude-region.span.longitudeDelta/2);
    
    //ensure our coordinates are within the logical range
    nwCorner.longitude = MAX(nwCorner.longitude, -180);
    nwCorner.longitude = MIN(nwCorner.longitude, 180);
    nwCorner.latitude = MAX(nwCorner.latitude, -90);
    nwCorner.latitude = MIN(nwCorner.latitude,90);
    
    TileInfo* nwTile = [NetfunctionalMapoverlayTileUtil tileContainingCoordinate:nwCorner atLevel:zoom];
    //the nw corner tile will give us the height and width span in lat/lon coordinates for the tiles we will need to cover this region, so we can then iterate by that amount in determining which tiles to use
    //TODO consider doing this in a more efficient way, but simply calculating the number of tiles which will cover the region, and then iterating through the tile indices, rather than looking them each individually up by their coordinates
    //TODO ensure that the coordinates spans of the tiles is constant, in both lat and long, if not we will have to reconsider this approach
    
    //actually, let's just calculate the increments of the tile indices, and grab all those within that range.  That makes more sense, a lot more sense, and is easier to implement
    
    CLLocationCoordinate2D seCorner = CLLocationCoordinate2DMake(region.center.latitude + region.span.latitudeDelta/2, region.center.longitude + region.span.longitudeDelta/2);
    [NetfunctionalMapoverlayTileUtil ensureValid:seCorner];
    
    TileInfo* seTile = [NetfunctionalMapoverlayTileUtil tileContainingCoordinate:seCorner atLevel:zoom];
    NSLog(@"NW and SE corner tiles of region to tile have respective tile info(x,y,zoom): %d,%d,%d and %d,%d,%d",nwTile.x,nwTile.y,nwTile.zoom,seTile.x,seTile.y,seTile.zoom);
//    NSLog(@"Attempting to ")
    for(int i=nwTile.x;i<=seTile.x;i++) {
        for(int j=nwTile.y;j<=seTile.y;j++)  {
            TileInfo* componentTileInfo = [NetfunctionalMapoverlayTileUtil tileWithX:i andY:j andZoom:zoom];
            NSLog(@"Determined tile info for tile with x,y,zoom: %d,%d,%d to be x,y,zoom: %d,%d,%d",i,j,zoom,componentTileInfo.x,componentTileInfo.y,componentTileInfo.zoom);
            [tiles addObject:componentTileInfo];
        }
    }
    
    
    return tiles;
    
}


@end
