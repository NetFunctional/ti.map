//
//  NetfunctionalMapoverlayTilerOverlay.m
//  NFMapTileNativePlay
//
//  Created by Michael Matan on 13-08-15.
//  Copyright (c) 2013 Michael Matan. All rights reserved.
//

#import "NetfunctionalMapoverlayTilerOverlay.h"

@implementation NetfunctionalMapoverlayTilerOverlay


-(id) initWithTileDB:(NetfunctionalMapoverlayTileDatabase*) tileDB {
    self = [super init];
    if (self) {
        self.tileDB = tileDB;
    }
    return self;
}

-(MKMapRect) boundingMapRect {
    //tile the entire map
    return MKMapRectWorld;
}

@end
