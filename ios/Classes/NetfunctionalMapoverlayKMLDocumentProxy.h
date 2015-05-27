/*
     File: KMLParser.h
 Abstract: 
 Implements a limited KML parser.
 The following KML types are supported:
         Style,
         LineString,
         Point,
         Polygon,
         Placemark.
      All other types are ignored
 
  Version: 1.3
 
 Copyright (C) 2013 NetFunctional Inc. All Rights Reserved (modifications to original apple source code)
 
*/

#import <MapKit/MapKit.h>
#import "TiBase.h"
#import "TiProxy.h"
#import "TiBlob.h"
#import "TiFile.h"


@class KMLPlacemark;
@class KMLStyle;

@interface NetfunctionalMapoverlayKMLDocumentProxy : TiProxy <NSXMLParserDelegate> {
    NSMutableDictionary *_styles;
    NSMutableArray *_placemarks;
    
    KMLPlacemark *_placemark;
    KMLStyle *_style;
    
    NSXMLParser *_xmlParser;
    
    NSString* kmlSourceFileURLPath;
}

- (id)initWithURL:(NSURL *)url;
- (void)parseKML;

@property (nonatomic, readonly) NSArray *overlays;
@property (nonatomic, readonly) NSArray *points;

- (MKAnnotationView *)viewForAnnotation:(id <MKAnnotation>)point;
- (MKOverlayView *)viewForOverlay:(id <MKOverlay>)overlay;

@end
