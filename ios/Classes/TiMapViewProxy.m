/**
 * Appcelerator Titanium Mobile
 * Copyright (c) 2009-2013 by Appcelerator, Inc. All Rights Reserved.
 * Licensed under the terms of the Apache Public License
 * Please see the LICENSE included with this distribution for details.
 */

#import "TiMapViewProxy.h"
#import "TiMapView.h"
#import "TiMapModule.h"
#import "TiMapRouteProxy.h"

@implementation TiMapViewProxy

#pragma mark Internal

#define VIEW_METHOD_ON_UI_THREAD(methodname,obj) \
[[self view] performSelectorOnMainThread:@selector(methodname:) withObject:obj waitUntilDone:NO];

-(NSArray *)keySequence
{
    return [NSArray arrayWithObjects:
            @"animate",
            @"location",
            @"regionFit",
            nil];
}

-(void)_destroy
{
	RELEASE_TO_NIL(selectedAnnotation);
	RELEASE_TO_NIL(annotationsToAdd);
	RELEASE_TO_NIL(annotationsToRemove);
	RELEASE_TO_NIL(routesToAdd);
	RELEASE_TO_NIL(routesToRemove);
    
    //nf
    RELEASE_TO_NIL(overlaysToAdd);
    RELEASE_TO_NIL(overlaysToRemove);
    //TODO add other array and dictionary types
    
	[super _destroy];
}

-(NSString*)apiName
{
    return @"Ti.Map.View";
}

-(NSNumber*) longitudeDelta
{
	__block CLLocationDegrees delta = 0.0;
	
	if ([self viewAttached]) {
		TiThreadPerformOnMainThread(^{
			delta = [(TiMapView *)[self view] longitudeDelta];
		},YES);
		
	}
	return [NSNumber numberWithDouble:delta];

}

-(NSNumber*) latitudeDelta
{
	__block CLLocationDegrees delta = 0.0;
	
	if ([self viewAttached]) {
		TiThreadPerformOnMainThread(^{
			delta = [(TiMapView *)[self view] latitudeDelta];
		},YES);
		
	}
	return [NSNumber numberWithDouble:delta];
}

-(void)viewDidAttach
{
	ENSURE_UI_THREAD_0_ARGS;
	TiMapView * ourView = (TiMapView *)[self view];

    for (id arg in annotationsToAdd) {
        [ourView addAnnotation:arg];
    }
    
    for (id arg in annotationsToRemove) {
        [ourView removeAnnotation:arg];
    }

    for (id arg in routesToAdd)
    {
        [ourView addRoute:arg];
    }
    
    for (id arg in routesToRemove)
    {
        [ourView removeRoute:arg];
    }
    
	[ourView selectAnnotation:selectedAnnotation];
	if (zoomCount > 0) {
		for (int i=0; i < zoomCount; i++) {
			[ourView zoom:[NSNumber numberWithDouble:1.0]];
		}
	}
	else {
		for (int i=zoomCount;i < 0;i++) {
			[ourView zoom:[NSNumber numberWithDouble:-1.0]];
		}
	}
	
	RELEASE_TO_NIL(selectedAnnotation);
	RELEASE_TO_NIL(annotationsToAdd);
	RELEASE_TO_NIL(annotationsToRemove);
	RELEASE_TO_NIL(routesToAdd);
	RELEASE_TO_NIL(routesToRemove);
    
    //nf
    TiMapView* mapView = (TiMapView*)[self view];
    //add the tile overlay first, if one has been specified
    if (false) {
        NSString * resourcePath = [[NSBundle mainBundle] resourcePath];
        NSString * documentsPath = [resourcePath stringByAppendingPathComponent:@"Resources"];
        documentsPath = [resourcePath stringByAppendingPathComponent:@"maps"];
        NSString * tiledbPath = [documentsPath stringByAppendingString:@"/SDR.mbtiles"];
        NSLog(@"checking to see if sdr database file exists at path %@",tiledbPath);
        bool exists = [[NSFileManager defaultManager] fileExistsAtPath:tiledbPath isDirectory:false];
        
        NSLog(@"sdr database file exists at path? %d",exists);
        if (exists) {
            NetfunctionalMapoverlayTileDatabase* tiledb = [NetfunctionalMapoverlayTileDatabase database];
            
            NetfunctionalMapoverlayTilerOverlay* tilerOverlay = [[NetfunctionalMapoverlayTilerOverlay alloc] initWithTileDB:tiledb];
            
            [mapView addTilerOverlay:tilerOverlay];
        }
        
        
    }
    if (tileDBPath) {
        NSLog(@"tiledbpath is %@",tileDBPath);
        NSURL* tileDBURL = [NSURL URLWithString:tileDBPath];
        
        bool exists = [[NSFileManager defaultManager] fileExistsAtPath:[tileDBURL path] isDirectory:false];
        
        NSLog(@"sdr database file exists at path? %d",exists);
        if (exists) {
            //            NetfunctionalMapoverlayTileDatabase* tiledb = [NetfunctionalMapoverlayTileDatabase database];
            NetfunctionalMapoverlayTileDatabase* tiledb = [[NetfunctionalMapoverlayTileDatabase alloc ] initWithMBTilesDB:[tileDBURL path]];
            NetfunctionalMapoverlayTilerOverlay* tilerOverlay = [[NetfunctionalMapoverlayTilerOverlay alloc] initWithTileDB:tiledb];
            
            [mapView addTilerOverlay:tilerOverlay];
        }
    }
    
    
    //mmatan
    if (overlaysToAdd!=nil)
    {
        for (id arg in overlaysToAdd)
        {
            [mapView addOverlay:arg];
        }
    }
    if (overlaysToRemove!=nil)
    {
        for (id arg in overlaysToRemove)
        {
            [mapView removeOverlay:arg];
        }
    } //-mmatan
    if (polylinesToAdd!=nil)
    {
        for (id arg in polylinesToAdd)
        {
            [mapView addPolyline:arg];
        }
    }
    if (polylinesToRemove!=nil)
    {
        for (id arg in polylinesToRemove)
        {
            [mapView removePolyline:arg];
        }
    } //-mmatan
    
    //mmatan
    if (kmlOverlaysToAdd!=nil)
    {
        for (id arg in kmlOverlaysToAdd)
        {
            [mapView addKMLOverlays:arg];
        }
    }
    if (kmlOverlaysToRemove!=nil)
    {
        for (id arg in kmlOverlaysToRemove)
        {
            [mapView removeKMLOverlays:arg];
        }
    } //-mmatan
    
    RELEASE_TO_NIL(polylinesToAdd);
    RELEASE_TO_NIL(polylinesToRemove);
    RELEASE_TO_NIL(overlaysToAdd);
    RELEASE_TO_NIL(overlaysToRemove);
    
    RELEASE_TO_NIL(kmlOverlaysToRemove);
    RELEASE_TO_NIL(kmlOverlaysToAdd);
	
	[super viewDidAttach];
}

-(TiMapAnnotationProxy*)annotationFromArg:(id)arg
{
	if ([arg isKindOfClass:[TiMapAnnotationProxy class]])
	{
		[(TiMapAnnotationProxy*)arg setDelegate:self];
		[arg setPlaced:NO];
		return arg;
	}
	ENSURE_TYPE(arg,NSDictionary);
	TiMapAnnotationProxy *proxy = [[[TiMapAnnotationProxy alloc] _initWithPageContext:[self pageContext] args:[NSArray arrayWithObject:arg]] autorelease];
    
	[proxy setDelegate:self];
	return proxy;
}

#pragma mark Public API

-(void)zoom:(id)arg
{
	ENSURE_SINGLE_ARG(arg,NSObject);
	if ([self viewAttached]) {
		TiThreadPerformOnMainThread(^{[(TiMapView*)[self view] zoom:arg];}, NO);
	}
	else {
		double v = [TiUtils doubleValue:arg];
		// TODO: Find good delta tolerance value to deal with floating point goofs
		if (v == 0.0) {
			return;
		}
		if (v > 0) {
			zoomCount++;
		}
		else {
			zoomCount--;
		}
	}
}

-(void)selectAnnotation:(id)arg
{
	ENSURE_SINGLE_ARG(arg,NSObject);
	if ([self viewAttached]) {
		 TiThreadPerformOnMainThread(^{[(TiMapView*)[self view] selectAnnotation:arg];}, NO);
	}
	else {
		if (selectedAnnotation != arg) {
			RELEASE_TO_NIL(selectedAnnotation);
			selectedAnnotation = [arg retain];
		}
	}
}

-(void)deselectAnnotation:(id)arg
{
	ENSURE_SINGLE_ARG(arg,NSObject);
	if ([self viewAttached]) {
		TiThreadPerformOnMainThread(^{[(TiMapView*)[self view] deselectAnnotation:arg];}, NO);
	}
	else {
		RELEASE_TO_NIL(selectedAnnotation);
	}
}

-(void)addAnnotation:(id)arg
{
	ENSURE_SINGLE_ARG(arg,NSObject);
    TiMapAnnotationProxy* annProxy = [self annotationFromArg:arg];
    [self rememberProxy:annProxy];
    
	if ([self viewAttached]) {
        TiThreadPerformOnMainThread(^{[(TiMapView*)[self view] addAnnotation:arg];}, NO);
	}
	else 
	{
		if (annotationsToAdd==nil)
		{
			annotationsToAdd = [[NSMutableArray alloc] init];
		}
		if (annotationsToRemove!=nil && [annotationsToRemove containsObject:arg]) 
		{
			[annotationsToRemove removeObject:arg];
		}
		else 
		{
			[annotationsToAdd addObject:arg];
		}
	}
}

-(void)addAnnotations:(id)arg
{
	ENSURE_SINGLE_ARG(arg,NSArray);
    NSMutableArray* newAnnotations = [NSMutableArray arrayWithCapacity:[arg count]];
    for (id ann in arg) {
        TiMapAnnotationProxy* annotation = [self annotationFromArg:ann];
        [newAnnotations addObject:annotation];
        [self rememberProxy:annotation];
    }
    
	if ([self viewAttached]) {
        TiThreadPerformOnMainThread(^{[(TiMapView*)[self view] addAnnotations:newAnnotations];}, NO);
	}
	else {
		for (id annotation in newAnnotations) {
			[self addAnnotation:annotation];
		}
	}
}

-(void)setAnnotations:(id)arg{
    ENSURE_TYPE(arg,NSArray);
    
    NSMutableArray* newAnnotations = [NSMutableArray arrayWithCapacity:[arg count]];
    for (id ann in arg) {
        [newAnnotations addObject:[self annotationFromArg:ann]];
    }
    
    BOOL attached = [self viewAttached];
    __block NSArray* currentAnnotations = nil;
    if (attached) {
        TiThreadPerformOnMainThread(^{
            currentAnnotations = [[(TiMapView*)[self view] customAnnotations] retain];
        }, YES);
    }
    else {
        currentAnnotations = annotationsToAdd;
    }
 
    // Because the annotations may contain an annotation proxy and not just
    // descriptors for them, we have to check and make sure there is
    // no overlap and remember/forget appropriately.
    
    for(TiMapAnnotationProxy * annProxy in currentAnnotations) {
        if (![newAnnotations containsObject:annProxy]) {
            [self forgetProxy:annProxy];
        }
    }
    for(TiMapAnnotationProxy* annProxy in newAnnotations) {
        if (![currentAnnotations containsObject:annProxy]) {
            [self rememberProxy:annProxy];
        }
    }
    
    if(attached) {
        TiThreadPerformOnMainThread(^{
            [(TiMapView*)[self view] setAnnotations_:newAnnotations];
        }, NO);
        [currentAnnotations release];
    }
    else {
        RELEASE_TO_NIL(annotationsToAdd);
        RELEASE_TO_NIL(annotationsToRemove);
        
        annotationsToAdd = [[NSMutableArray alloc] initWithArray:newAnnotations];
    }
}

-(NSArray*)annotations
{
    if ([self viewAttached]) {
        __block NSArray* currentAnnotations = nil;
        TiThreadPerformOnMainThread(^{
            currentAnnotations = [[(TiMapView*)[self view] customAnnotations] retain];
        }, YES);
        return [currentAnnotations autorelease];
    }
    else {
        return annotationsToAdd;
    }
}

-(void)removeAnnotation:(id)arg
{
	ENSURE_SINGLE_ARG(arg,NSObject);
    
    // For legacy reasons, we can apparently allow the arg here to be a string (0.8 compatibility?!?)
    // and so only need to convert/remember/forget if it is an annotation instead.
    if ([arg isKindOfClass:[TiMapAnnotationProxy class]]) {
        [self forgetProxy:arg];
    }
    
	if ([self viewAttached]) 
	{
        TiThreadPerformOnMainThread(^{
            [(TiMapView*)[self view] removeAnnotation:arg];
        }, NO);
	}
	else 
	{
		if (annotationsToRemove==nil)
		{
			annotationsToRemove = [[NSMutableArray alloc] init];
		}
		if (annotationsToAdd!=nil && [annotationsToAdd containsObject:arg]) 
		{
			[annotationsToAdd removeObject:arg];
		}
		else 
		{
			[annotationsToRemove addObject:arg];
		}
	}
}

-(void)removeAnnotations:(id)arg
{
    ENSURE_SINGLE_ARG(arg,NSArray);
    for (id ann in arg) {
        if ([ann isKindOfClass:[TiMapAnnotationProxy class]]) {
            [self forgetProxy:ann];
        }
    }
    
	if ([self viewAttached]) {
        [(TiMapView*)[self view] removeAnnotations:arg];
	}
	else {
		for (id annotation in arg) {
			[self removeAnnotation:annotation];
		}
	}
}

-(void)removeAllAnnotations:(id)unused
{
	if ([self viewAttached]) {
        __block NSArray* currentAnnotations = nil;
        TiThreadPerformOnMainThread(^{
            currentAnnotations = [[(TiMapView*)[self view] customAnnotations] retain];
        }, YES);
        
        for(id object in currentAnnotations)
        {
            TiMapAnnotationProxy * annProxy = [self annotationFromArg:object];
            [self forgetProxy:annProxy];
        }
        [currentAnnotations release];
        TiThreadPerformOnMainThread(^{[(TiMapView*)[self view] removeAllAnnotations:unused];}, NO);
	}
	else 
	{
        for (TiMapAnnotationProxy* annotation in annotationsToAdd) {
            [self forgetProxy:annotation];
        }
        
        RELEASE_TO_NIL(annotationsToAdd);
        RELEASE_TO_NIL(annotationsToRemove);
	}
}

-(void)addRoute:(id)arg
{
	ENSURE_SINGLE_ARG(arg,TiMapRouteProxy);
    
	if ([self viewAttached]) 
	{
		TiThreadPerformOnMainThread(^{[(TiMapView*)[self view] addRoute:arg];}, NO);
	}
	else 
	{
		if (routesToAdd==nil)
		{
			routesToAdd = [[NSMutableArray alloc] init];
		}
		if (routesToRemove!=nil && [routesToRemove containsObject:arg])
		{
			[routesToRemove removeObject:arg];
		}
		else 
		{
			[routesToAdd addObject:arg];
		}
	}
}

-(void)removeRoute:(id)arg
{
	ENSURE_SINGLE_ARG(arg,TiMapRouteProxy);
    
	if ([self viewAttached])
	{
		TiThreadPerformOnMainThread(^{[(TiMapView*)[self view] removeRoute:arg];}, NO);
	}
	else 
	{
		if (routesToRemove==nil)
		{
			routesToRemove = [[NSMutableArray alloc] init];
		}
		if (routesToAdd!=nil && [routesToAdd containsObject:arg])
		{
			[routesToAdd removeObject:arg];
		}
		else 
		{
			[routesToRemove addObject:arg];
		}
	}
}

#pragma mark Public APIs iOS 7

-(id)camera
{
    [TiMapModule logAddedIniOS7Warning:@"camera"];
    return nil;
}

-(void)animateCamera:(id)args
{
    [TiMapModule logAddedIniOS7Warning:@"animateCamera()"];
}

-(void)showAnnotations:(id)args
{
    [TiMapModule logAddedIniOS7Warning:@"showAnnotations()"];
}

#pragma mark NF1 methods

-(void) addKMLOverlays:(id) arg {
    ENSURE_SINGLE_ARG(arg, NetfunctionalMapoverlayKMLDocumentProxy)
    
    NetfunctionalMapoverlayKMLDocumentProxy* kmlDoc = arg;
    
    //first try to determine if the kml file/document has already had it's overlay's added; if so, don't add it again.  Also, try to resolve whether this particular kml document proxy has the same source file as a kml document proxy that has already been added to the map; if so, we should probably not duplicate it, but instead treat it as the same kml document.  This will be even more important when removing kml overlays, as we will want to remove overlays created by all kml doc proxy's with the same source file, not treat the overlays as different because they had different proxy's despite having the same source file.  We'll want to ensure we put in proper comments of this logic, so users are not tripped up if they happen to be dynamically rewriting the same source file
    if ([self viewAttached])
    {
        VIEW_METHOD_ON_UI_THREAD(addKMLOverlays,arg)
    }
    else
    {
        if (kmlOverlaysToAdd==nil)
        {
            kmlOverlaysToAdd = [[NSMutableArray alloc] init];
        }
        if (kmlOverlaysToRemove!=nil && [kmlOverlaysToRemove containsObject:arg])
        {
            [kmlOverlaysToRemove removeObject:arg];
        }
        else
        {
            [kmlOverlaysToAdd addObject:arg];
        }
    }
}

-(void) removeKMLOverlays:(id) arg {
    ENSURE_SINGLE_ARG(arg, NetfunctionalMapoverlayKMLDocumentProxy)
    
    NetfunctionalMapoverlayKMLDocumentProxy* kmlDoc = arg;
    
    //first try to determine if the kml file/document has already had it's overlay's added; if so, don't add it again.  Also, try to resolve whether this particular kml document proxy has the same source file as a kml document proxy that has already been added to the map; if so, we should probably not duplicate it, but instead treat it as the same kml document.  This will be even more important when removing kml overlays, as we will want to remove overlays created by all kml doc proxy's with the same source file, not treat the overlays as different because they had different proxy's despite having the same source file.  We'll want to ensure we put in proper comments of this logic, so users are not tripped up if they happen to be dynamically rewriting the same source file
    if ([self viewAttached])
    {
        VIEW_METHOD_ON_UI_THREAD(removeKMLOverlays,arg)
    }
    else
    {
        if (kmlOverlaysToRemove==nil)
        {
            kmlOverlaysToRemove = [[NSMutableArray alloc] init];
        }
        if (kmlOverlaysToAdd!=nil && [kmlOverlaysToAdd containsObject:arg])
        {
            [kmlOverlaysToAdd removeObject:arg];
        }
        else
        {
            [kmlOverlaysToRemove addObject:arg];
        }
    }
}


-(void)addOverlay:(id)arg
{
    ENSURE_SINGLE_ARG(arg,NSDictionary)
    if ([self viewAttached])
    {
        VIEW_METHOD_ON_UI_THREAD(addOverlay,arg)
    }
    else
    {
        if (overlaysToAdd==nil)
        {
            overlaysToAdd = [[NSMutableArray alloc] init];
        }
        if (overlaysToRemove!=nil && [overlaysToRemove containsObject:arg])
        {
            [overlaysToRemove removeObject:arg];
        }
        else
        {
            [overlaysToAdd addObject:arg];
        }
    }
}

-(void)removeOverlay:(id)arg
{
    ENSURE_SINGLE_ARG(arg,NSDictionary)
    if ([self viewAttached])
    {
        VIEW_METHOD_ON_UI_THREAD(removeOverlay,arg)
    }
    else
    {
        if (overlaysToRemove==nil)
        {
            overlaysToRemove = [[NSMutableArray alloc] init];
        }
        if (overlaysToAdd!=nil && [overlaysToAdd containsObject:arg])
        {
            [overlaysToAdd removeObject:arg];
        }
        else
        {
            [overlaysToRemove addObject:arg];
        }
    }
}

-(void)addPolyline:(id)arg
{
    ENSURE_SINGLE_ARG(arg,NSDictionary)
    if ([self viewAttached])
    {
        VIEW_METHOD_ON_UI_THREAD(addPolyline,arg)
    }
    else
    {
        if (polylinesToAdd==nil)
        {
            polylinesToAdd = [[NSMutableArray alloc] init];
        }
        if (polylinesToRemove!=nil && [polylinesToRemove containsObject:arg])
        {
            [polylinesToRemove removeObject:arg];
        }
        else
        {
            [polylinesToAdd addObject:arg];
        }
    }
}

-(void)removePolyline:(id)arg
{
    ENSURE_SINGLE_ARG(arg,NSDictionary)
    if ([self viewAttached])
    {
        VIEW_METHOD_ON_UI_THREAD(removePolyline,arg)
    }
    else
    {
        if (polylinesToRemove==nil)
        {
            polylinesToRemove = [[NSMutableArray alloc] init];
        }
        if (polylinesToAdd!=nil && [polylinesToAdd containsObject:arg])
        {
            [polylinesToAdd removeObject:arg];
        }
        else
        {
            [polylinesToRemove addObject:arg];
        }
    }
}

-(void) setTileDB:(id)tileDB {
    NSLog(@"Setimagee called");
    UIImage* insetImageUI;
    if ([tileDB isKindOfClass:[TiBlob class]]) {
        NSLog(@"tiblob passed");
        //NSLog(@"tiblob correctly passed");
        TiBlob* imageBlob = (TiBlob*) tileDB;
        //        insetImageUI = [UIImage animatedImageWithAnimatedGIFData:[imageBlob data]];
        
    }
    else if ([tileDB isKindOfClass:[NSURL class]]) {
        NSLog(@"nsurl passed");
        //TODO handle case of url being passed instead of blob object; ie load from url
        NSData* fileData = [NSData dataWithContentsOfURL:tileDB];
        //        insetImageUI = [UIImage animatedImageWithAnimatedGIFData:fileData];
    }
    else if([tileDB isKindOfClass:[NSString class]]) {
        NSLog(@"string passed");
        //        [NSFileManager defaultManager]
        
        TiFile* dbFileRef = [self getTiFile:tileDB];
        //        [dbFileRef ]
        
        NSString* tileDBFilePath = [dbFileRef path];
        
        NSLog(@"path passed for tileDB is %@",tileDBFilePath);
        
        NSURL* imageFileURL = [NSURL URLWithString:tileDBFilePath];
        imageFileURL = [imageFileURL filePathURL];
        //        NSLog(@"b url: %@",image);
        NSLog(@"c url: %@",imageFileURL);
        NSData* fileData = [NSData dataWithContentsOfURL:imageFileURL];
        bool exists = [[NSFileManager defaultManager] fileExistsAtPath:tileDB isDirectory:false];
        NSLog(@"file exists at path? %d",exists);
        
        tileDBPath = [(NSString*)tileDB retain];
        
        //        insetImageUI = [UIImage animatedImageWithAnimatedGIFData:fileData];
        //        NSLog(@"animated gif image size is %f",[insetImageUI size].height);
        
        
        
    }
    else {
        
        NSLog(@"tiblob not passed, instead found %@",[tileDB class]);
    }
    //    if (agifV) [agifV release];
    //    agifV = [[UIImageView alloc] initWithImage:insetImageUI];
    //    if (insetImageUI != nil) {
    //        autoHeight = insetImageUI.size.height;
    //        autoWidth = insetImageUI.size.width;
    //        [self setGifHeight:[NSNumber numberWithFloat:insetImageUI.size.height]];
    //        [self setGifWidth:[NSNumber numberWithFloat:insetImageUI.size.width]];
    //    }
    //    else {
    //        autoHeight = autoWidth = 0;
    //    }
    //    //    [self setBounds:CGRectMake(0, 0, insetImageUI.size.width, insetImageUI.size.height)];
    //    NSLog(@"exit imagee");
    //    [self addSubview:agifV];
}

-(TiFile*) getTiFile:(id)args
{
    // This method is an example of exposing a native method that accepts a
    // single string argument and returns a TiFile object.
    // Arguments from JavaScript are passed to the native methods as an NSArray
    
    // The ENSURE_SINGLE_ARG macro will confirm that only 1 argument was passed
    // to the method and that it is of the specified type, and as a side-effect
    // will reassign 'args' to be the value of the first object in the argument array.
    ENSURE_SINGLE_ARG(args,NSString);
    
    NSLog(@"[METHODSDEMO] getTiFile received 1 argument of type NSString");
    
    NSString *path = args;
    
    // NOTE: File paths may contain URL prefix as of release 1.7 of the SDK
    if ([path hasPrefix:@"file:/"]) {
        NSURL* url = [NSURL URLWithString:path];
        path = [url path];
    }
    
    TiFile *result = [[[TiFile alloc] initWithPath:path] autorelease];
    
    NSLog(@"[METHODSDEMO] Path: %@  Size: %d", result.path, result.size);
    
    return result;
}

@end
