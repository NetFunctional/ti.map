//
//  NetfunctionalMapoverlayTileDatabase.h
//  NFMapTileNativePlay
//
//  Created by Michael Matan on 13-08-09.
//  Copyright (c) 2013 Michael Matan. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <sqlite3.h>

@interface NetfunctionalMapoverlayTileDatabase : NSObject {
    sqlite3 *_database;
}

-(id) initWithMBTilesDB:(NSString*)mbTilesDBPath;

+ (NetfunctionalMapoverlayTileDatabase*) database;
-(UIImage*) imageDataForTileX:(NSUInteger)x andY:(NSUInteger)y andZoom:(NSUInteger) zoom;
-(UIImage*) imageForTile:(NSString*)tileID;
-(NSString*) idForTileX:(NSUInteger)x andY:(NSUInteger)y andZoom:(NSUInteger) zoom;

@end
