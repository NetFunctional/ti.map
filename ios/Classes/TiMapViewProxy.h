/**
 * Appcelerator Titanium Mobile
 * Copyright (c) 2009-2013 by Appcelerator, Inc. All Rights Reserved.
 * Licensed under the terms of the Apache Public License
 * Please see the LICENSE included with this distribution for details.
 */
 
#import "TiViewProxy.h"
#import "TiMapAnnotationProxy.h"

//#import "NetfunctionalMapoverlayAnnotationProxy.h"
#import "NetfunctionalMapoverlayTilerOverlay.h"

#import "NetfunctionalMapoverlayKMLDocumentProxy.h"

@interface TiMapViewProxy : TiViewProxy {
	TiMapAnnotationProxy* selectedAnnotation; // Annotation to select on initial display
	NSMutableArray* annotationsToAdd; // Annotations to add on initial display
	NSMutableArray* annotationsToRemove; // Annotations to remove on initial display
	NSMutableArray* routesToAdd; 
	NSMutableArray* routesToRemove; 
	int zoomCount; // Number of times to zoom in/out on initial display
    
    //nf
    NSMutableArray* overlaysToAdd;
    NSMutableArray* overlaysToRemove; //mmatan
    NSMutableArray* polylinesToAdd;
    NSMutableArray* polylinesToRemove; //mmatan
    NSMutableArray* kmlOverlaysToAdd; //mmatan
    NSMutableArray* kmlOverlaysToRemove; //mmatan
    NSString* tileDBPath; //mmatan
}

@property (nonatomic, readonly) NSNumber* longitudeDelta;
@property (nonatomic, readonly) NSNumber* latitudeDelta;

-(TiMapAnnotationProxy*)annotationFromArg:(id)arg;

-(void)addAnnotation:(id)args;
-(void)addAnnotations:(id)args;
-(void)removeAnnotation:(id)args;
-(void)removeAnnotations:(id)args;
-(void)removeAllAnnotations:(id)args;
-(void)selectAnnotation:(id)args;
-(void)deselectAnnotation:(id)args;
-(void)zoom:(id)args;
-(void)addRoute:(id)args;
-(void)removeRoute:(id)args;

//nf
-(void)addOverlay:(id)args;
-(void)removeOverlay:(id)args;
-(void)addPolyline:(id)args;
-(void)removePolyline:(id)args;

@end
