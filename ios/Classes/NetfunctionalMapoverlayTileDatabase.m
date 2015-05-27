//
//  NetfunctionalMapoverlayTileDatabase.m
//  NFMapTileNativePlay
//
//  Created by Michael Matan on 13-08-09.
//  Copyright (c) 2013 Michael Matan. All rights reserved.
//

#import "NetfunctionalMapoverlayTileDatabase.h"

@implementation NetfunctionalMapoverlayTileDatabase


static NetfunctionalMapoverlayTileDatabase* _database;

+ (NetfunctionalMapoverlayTileDatabase*)database {
    if (_database == nil) {
        _database = [[NetfunctionalMapoverlayTileDatabase alloc] init];
    }
    return _database;
}


-(UIImage*) imageDataForTileX:(NSUInteger)x andY:(NSUInteger)y andZoom:(NSUInteger) zoom {
    NSString *query = @"SELECT tile_data FROM images WHERE tile_id='?'";
    query = [query stringByReplacingOccurrencesOfString:@"?" withString:[self idForTileX:x andY:y andZoom:zoom]];
//    NSLog(@"attempting to query for image data with query: %@",query);
    sqlite3_stmt *statement;
    
    int queryCreateVal = sqlite3_prepare_v2(_database, [query UTF8String], -1, &statement, nil);
    
    UIImage* ret = nil;
    
    if (queryCreateVal == SQLITE_OK) {
        while (sqlite3_step(statement) == SQLITE_ROW) {
            NSData *dataForCachedImage = [[NSData alloc] initWithBytes:sqlite3_column_blob(statement, 0) length: sqlite3_column_bytes(statement, 0)];
            ret = [UIImage imageWithData:dataForCachedImage];
            [dataForCachedImage release];
        }
        return ret;
    }
    else {
        NSLog(@"Failed to create image tile data query, expected SQLITE_OK, got %d",queryCreateVal);
        return nil;
    }

}

-(UIImage*) imageForTile:(NSString*)tileID {
    if (tileID == nil) {
        NSLog(@"Error: tile ID is nil, cannot retrieve image for tile because tile ID passed is nil");
        return nil;
    }
    
    NSString *query = @"SELECT tile_data FROM images WHERE tile_id='?'"; //TODO reimplement with stringWithFormat
    query = [query stringByReplacingOccurrencesOfString:@"?" withString:tileID];
//    NSLog(@"attempting to query for image data with query: %@",query);
    sqlite3_stmt *statement;

    @synchronized (self){ //needed to prevent threading collision, 
    
        int queryCreateVal = sqlite3_prepare_v2(_database, [query UTF8String], -1, &statement, nil);
        
        UIImage* ret = nil;
        
        if (queryCreateVal == SQLITE_OK) {
            while (sqlite3_step(statement) == SQLITE_ROW) {
                NSData *dataForCachedImage = [[NSData alloc] initWithBytes:sqlite3_column_blob(statement, 0) length: sqlite3_column_bytes(statement, 0)];
                ret = [UIImage imageWithData:dataForCachedImage];
                [dataForCachedImage release];
            }
            return ret;
        }
        else {
            NSLog(@"Failed to create image tile data query, expected SQLITE_OK, got %d",queryCreateVal);
            return nil;
        }
    }
}

-(NSString*) idForTileX:(NSUInteger)x andY:(NSUInteger)y andZoom:(NSUInteger) zoom {
    
    NSString* query = [[NSString alloc] initWithFormat:@"SELECT tile_id FROM map WHERE zoom_level=%d and tile_column=%d and tile_row=%d",zoom,x,y];
//    NSString *query = @"SELECT tile_id FROM map WHERE zoom_level=2 and tile_column=1 and tile_row=1";
    
    NSLog(@"id for tile query is %@",query);
    
    sqlite3_stmt *statement;
    NSString* retval;
    @synchronized (self){ //needed to prevent threading collision,
        int queryCreateVal = sqlite3_prepare_v2(_database, [query UTF8String], -1, &statement, nil);
        
        NSLog(@"query creation ret val is %d",queryCreateVal);
        
        if (queryCreateVal
            == SQLITE_OK) {
            while (sqlite3_step(statement) == SQLITE_ROW) {
                char *tileIDc = sqlite3_column_text(statement, 0);
                NSString *tileID = [[NSString alloc] initWithUTF8String:tileIDc];
                //
                retval = tileID;
            }
            sqlite3_finalize(statement);
            //        NSLog(@"tile id is ")
            if (retval) {
                //            return [retval autorelease];
                return retval;
            }
            else {
                NSLog(@"failed to retrieve tile id, retval was not set in while loop");
                return nil;
            }
            
        }
        else {
            return nil;
        }

    }

}


-(id) initWithMBTilesDB:(NSString*)mbTilesDBPath {
    if ((self = [super init])) {
        //        NSString *sqLiteDb = [[NSBundle mainBundle] pathForResource:@"SDR"
        //                                                             ofType:@"mbtiles"];
        
//        NSString * resourcePath = [[NSBundle mainBundle] resourcePath];
//        NSString * documentsPath = [resourcePath stringByAppendingPathComponent:@"Resources"];
//        documentsPath = [resourcePath stringByAppendingPathComponent:@"maps"];
//        NSString * sqLiteDb = [documentsPath stringByAppendingString:@"/SDR.mbtiles"];
        
        //        NSString *sqLiteDb = [[NSBundle mainBundle] pathForResource:@"SDR" ofType:@"mbtiles" inDirectory:@"NFMapTileNativePlay"];
        if (![[NSFileManager defaultManager] fileExistsAtPath:mbTilesDBPath]) {
            NSLog(@"no db file at path %@",mbTilesDBPath);
        }
        int openVal = sqlite3_open([mbTilesDBPath UTF8String], &_database);
        NSLog(@"value from opening sqldb is %d",openVal);
        
        if (sqlite3_open([mbTilesDBPath UTF8String], &_database) != SQLITE_OK) {
            NSLog(@"Failed to open database!");
        }
    }
    return self;
}

- (id)init {
    if ((self = [super init])) {
//        NSString *sqLiteDb = [[NSBundle mainBundle] pathForResource:@"SDR"
//                                                             ofType:@"mbtiles"];
        
//        NSString * resourcePath = [[NSBundle mainBundle] resourcePath];
//        NSString * documentsPath = [resourcePath stringByAppendingPathComponent:@"Resources"];
//        documentsPath = [resourcePath stringByAppendingPathComponent:@"maps"];
//        NSString * sqLiteDb = [documentsPath stringByAppendingString:@"/SDR.mbtiles"];
//        
////        NSString *sqLiteDb = [[NSBundle mainBundle] pathForResource:@"SDR" ofType:@"mbtiles" inDirectory:@"NFMapTileNativePlay"];
//        if (![[NSFileManager defaultManager] fileExistsAtPath:sqLiteDb]) {
//            NSLog(@"no db file at path %@",sqLiteDb);
//        }
//        int openVal = sqlite3_open([sqLiteDb UTF8String], &_database);
//        NSLog(@"value from opening sqldb is %d",openVal);
//        
//        if (sqlite3_open([sqLiteDb UTF8String], &_database) != SQLITE_OK) {
//            NSLog(@"Failed to open database!");
//        }
    }
    return self;
}

- (void)dealloc {
    sqlite3_close(_database);
    [super dealloc];
}


@end
