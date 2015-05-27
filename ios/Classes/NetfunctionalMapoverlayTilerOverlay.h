//
//  NetfunctionalMapoverlayTilerOverlay.h
//  NFMapTileNativePlay
//
//  Created by Michael Matan on 13-08-15.
//  Copyright (c) 2013 Michael Matan. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>
#import "NetfunctionalMapoverlayTileDatabase.h"

@interface NetfunctionalMapoverlayTilerOverlay : NSObject<MKOverlay>


@property (nonatomic, assign) NetfunctionalMapoverlayTileDatabase* tileDB;

-(id) initWithTileDB:(NetfunctionalMapoverlayTileDatabase*) tileDB;


@end
