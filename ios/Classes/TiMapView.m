/**
 * Appcelerator Titanium Mobile
 * Copyright (c) 2009-2013 by Appcelerator, Inc. All Rights Reserved.
 * Licensed under the terms of the Apache Public License
 * Please see the LICENSE included with this distribution for details.
 */
 
#import "TiBase.h"
#import "TiMapView.h"
#import "TiUtils.h"
#import "TiMapModule.h"
#import "TiMapAnnotationProxy.h"
#import "TiMapPinAnnotationView.h"
#import "TiMapImageAnnotationView.h"
#import "TiMapCustomAnnotationView.h"
#import "TiMapRouteProxy.h"

#import "TiNFMMapPolygon.h"
#import "TiNFMMapPolyline.h"
#import "TiNFMMapCircle.h"
#import "TiNFMImageOverlayView.h"
#import "TiNFMImageOverlay.h"
#import "TiNFMFloatingImageOverlayView.h"
#import "TiNFMFloatingImageOverlay.h"
//#import "NetfunctionalMapoverlayAnnotationProxy.h"
//#import "NetfunctionalMapoverlayPinAnnotationView.h"
#import "NetfunctionalMapoverlayTilerOverlay.h"
#import "NetfunctionalMapoverlayTilerOverlayView.h"

@implementation TiMapView

#pragma mark Internal

-(void)dealloc
{
	if (map!=nil)
	{
		map.delegate = nil;
		RELEASE_TO_NIL(map);
	}
    if (mapLine2View) {
        CFRelease(mapLine2View);
        mapLine2View = nil;
    }
	RELEASE_TO_NIL(locationManager);
    RELEASE_TO_NIL(polylineViews);
    RELEASE_TO_NIL(polylines);
    RELEASE_TO_NIL(overlays);
    RELEASE_TO_NIL(overlayViews);
	[super dealloc];
}

-(void)render
{
    if (![NSThread isMainThread]) {
        TiThreadPerformOnMainThread(^{[self render];}, NO);
        return;
    }
    //TIMOB-10892 if any of below conditions is true , regionthatfits returns invalid.
    if (map == nil || map.bounds.size.width == 0 || map.bounds.size.height == 0) {
        return;
    }

    if (region.center.latitude!=0 && region.center.longitude!=0 && !isnan(region.center.latitude) && !isnan(region.center.longitude))
    {
        if (regionFits) {
            [map setRegion:[map regionThatFits:region] animated:animate];
        }
        else {
            [map setRegion:region animated:animate];
        }
    }
}

-(MKMapView*)map
{
    if (map==nil)
    {
        map = [[MKMapView alloc] initWithFrame:CGRectZero];
        map.delegate = self;
        map.userInteractionEnabled = YES;
        map.autoresizingMask = UIViewAutoresizingNone;
        if (![TiUtils isIOS8OrGreater]) {
            map.showsUserLocation = [TiUtils boolValue:[self.proxy valueForKey:@"userLocation"] def:NO];
        }
        [self addSubview:map];
        mapLine2View = CFDictionaryCreateMutable(NULL, 10, &kCFTypeDictionaryKeyCallBacks, &kCFTypeDictionaryValueCallBacks);
        //Initialize loaded state to YES. This will automatically go to NO if the map needs to download new data
        loaded = YES;
    }
    return map;
}

- (id)accessibilityElement
{
	return [self map];
}

- (NSArray *)customAnnotations
{
    NSMutableArray *annotations = [NSMutableArray arrayWithArray:self.map.annotations];
    [annotations removeObject:self.map.userLocation];
    return annotations;
}

-(void)willFirePropertyChanges
{
	regionFits = [TiUtils boolValue:[self.proxy valueForKey:@"regionFit"]];
	animate = [TiUtils boolValue:[self.proxy valueForKey:@"animate"]];
}

-(void)didFirePropertyChanges
{
	[self render];
}

-(void)setBounds:(CGRect)bounds
{
    //TIMOB-13102.
    //When the bounds change the mapview fires the regionDidChangeAnimated delegate method
    //Here we update the region property which is not what we want.
    //Instead we set a forceRender flag and render in frameSizeChanged and capture updated
    //region there.
    CGRect oldBounds = (map != nil) ? [map bounds] : CGRectZero;
    forceRender = (oldBounds.size.width == 0 || oldBounds.size.height==0);
    ignoreRegionChanged = YES;
    [super setBounds:bounds];
    ignoreRegionChanged = NO;
}

-(void)frameSizeChanged:(CGRect)frame bounds:(CGRect)bounds
{
    [[self map] setFrame:bounds];
    [super frameSizeChanged:frame bounds:bounds];
    if (forceRender) {
        //Set this to NO so that region gets captured.
        ignoreRegionChanged = NO;
        [self render];
        forceRender = NO;
    }
}

-(TiMapAnnotationProxy*)annotationFromArg:(id)arg
{
    return [(TiMapViewProxy*)[self proxy] annotationFromArg:arg];
}

-(NSArray*)annotationsFromArgs:(id)value
{
	ENSURE_TYPE_OR_NIL(value,NSArray);
	NSMutableArray * result = [NSMutableArray arrayWithCapacity:[value count]];
	if (value!=nil)
	{
		for (id arg in value)
		{
			[result addObject:[self annotationFromArg:arg]];
		}
	}
	return result;
}

-(void)refreshAnnotation:(TiMapAnnotationProxy*)proxy readd:(BOOL)yn
{
	NSArray *selected = map.selectedAnnotations;
	BOOL wasSelected = [selected containsObject:proxy]; //If selected == nil, this still returns FALSE.
    ignoreClicks = YES;
	if (yn==NO)
	{
		[map deselectAnnotation:proxy animated:NO];
	}
	else
	{
		[map removeAnnotation:proxy];
		[map addAnnotation:proxy];
		[map setNeedsLayout];
	}
	if (wasSelected)
	{
		[map selectAnnotation:proxy animated:NO];
	}
    ignoreClicks = NO;
}

#pragma mark Public APIs


-(void)addAnnotation:(id)args
{
	ENSURE_SINGLE_ARG(args,NSObject);
	ENSURE_UI_THREAD(addAnnotation,args);
	[[self map] addAnnotation:[self annotationFromArg:args]];
}

-(void)addAnnotations:(id)args
{
	ENSURE_TYPE(args,NSArray);
	ENSURE_UI_THREAD(addAnnotations,args);

	[[self map] addAnnotations:[self annotationsFromArgs:args]];
}

-(void)removeAnnotation:(id)args
{
	ENSURE_SINGLE_ARG(args,NSObject);

	id<MKAnnotation> doomedAnnotation = nil;
	
	if ([args isKindOfClass:[NSString class]])
	{
		// for pre 0.9, we supported removing by passing the annotation title
		NSString *title = [TiUtils stringValue:args];
		for (id<MKAnnotation>an in self.customAnnotations)
		{
			if ([title isEqualToString:an.title])
			{
				doomedAnnotation = an;
				break;
			}
		}
	}
	else if ([args isKindOfClass:[TiMapAnnotationProxy class]])
	{
		doomedAnnotation = args;
	}
	
    TiThreadPerformOnMainThread(^{
        [[self map] removeAnnotation:doomedAnnotation];
    }, NO);
}

-(void)removeAnnotations:(id)args
{
	ENSURE_TYPE(args,NSArray); // assumes an array of TiMapAnnotationProxy, and NSString classes
    
    // Test for annotation title strings
    NSMutableArray *doomedAnnotations = [NSMutableArray arrayWithArray:args];
    NSUInteger count = [doomedAnnotations count];
    id doomedAn;
    for (int i = 0; i < count; i++)
    {
        doomedAn = [doomedAnnotations objectAtIndex:i];
        if ([doomedAn isKindOfClass:[NSString class]])
        {
            // for pre 0.9, we supported removing by passing the annotation title
            NSString *title = [TiUtils stringValue:doomedAn];
            for (id<MKAnnotation>an in self.customAnnotations)
            {
                if ([title isEqualToString:an.title])
                {
                    [doomedAnnotations replaceObjectAtIndex:i withObject:an];
                }
            }
        }
    }
    
    TiThreadPerformOnMainThread(^{
        [[self map] removeAnnotations:doomedAnnotations];
    }, NO);
}

-(void)removeAllAnnotations:(id)args
{
	ENSURE_UI_THREAD(removeAllAnnotations,args);
	[self.map removeAnnotations:self.customAnnotations];
}

-(void)setAnnotations_:(id)value
{
	ENSURE_TYPE_OR_NIL(value,NSArray);
	ENSURE_UI_THREAD(setAnnotations_,value)
	[self.map removeAnnotations:self.customAnnotations];
	if (value != nil) {
		[[self map] addAnnotations:[self annotationsFromArgs:value]];
	}
}


-(void)setSelectedAnnotation:(id<MKAnnotation>)annotation
{
    [[self map] selectAnnotation:annotation animated:animate];
}

-(void)selectAnnotation:(id)args
{
	ENSURE_SINGLE_ARG_OR_NIL(args,NSObject);
	ENSURE_UI_THREAD(selectAnnotation,args);
	
	if (args == nil) {
		for (id<MKAnnotation> annotation in [[self map] selectedAnnotations]) {
			[[self map] deselectAnnotation:annotation animated:animate];
		}
		return;
	}
	
	if ([args isKindOfClass:[NSString class]])
	{
		// for pre 0.9, we supported selecting by passing the annotation title
		NSString *title = [TiUtils stringValue:args];
		for (id<MKAnnotation>an in [NSArray arrayWithArray:[self map].annotations])
		{
			if ([title isEqualToString:an.title])
			{
				// TODO: Slide the view over to the selected annotation, and/or zoom so it's with all other selected.
				[self setSelectedAnnotation:an];
				break;
			}
		}
	}
	else if ([args isKindOfClass:[TiMapAnnotationProxy class]])
	{
		[self setSelectedAnnotation:args];
	}
}

-(void)deselectAnnotation:(id)args
{
	ENSURE_SINGLE_ARG(args,NSObject);
	ENSURE_UI_THREAD(deselectAnnotation,args);

	if ([args isKindOfClass:[NSString class]])
	{
		// for pre 0.9, we supporting selecting by passing the annotation title
		NSString *title = [TiUtils stringValue:args];
		for (id<MKAnnotation>an in [NSArray arrayWithArray:[self map].annotations])
		{
			if ([title isEqualToString:an.title])
			{
				[[self map] deselectAnnotation:an animated:animate];
				break;
			}
		}
	}
	else if ([args isKindOfClass:[TiMapAnnotationProxy class]])
	{
		[[self map] deselectAnnotation:args animated:animate];
	}
}

-(void)zoom:(id)args
{
	ENSURE_SINGLE_ARG(args,NSObject);
	ENSURE_UI_THREAD(zoom,args);

	double v = [TiUtils doubleValue:args];
	// TODO: Find a good delta tolerance value to deal with floating point goofs
	if (v == 0.0) {
		return;
	}
	MKCoordinateRegion _region = [[self map] region];
	// TODO: Adjust zoom factor based on v
	if (v > 0)
	{
		_region.span.latitudeDelta = _region.span.latitudeDelta / 2.0002;
		_region.span.longitudeDelta = _region.span.longitudeDelta / 2.0002;
	}
	else
	{
		_region.span.latitudeDelta = _region.span.latitudeDelta * 2.0002;
		_region.span.longitudeDelta = _region.span.longitudeDelta * 2.0002;
	}
	region = _region;
	[self render];
}

-(MKCoordinateRegion)regionFromDict:(NSDictionary*)dict
{
	CGFloat latitudeDelta = [TiUtils floatValue:@"latitudeDelta" properties:dict];
	CGFloat longitudeDelta = [TiUtils floatValue:@"longitudeDelta" properties:dict];
	CLLocationCoordinate2D center;
	center.latitude = [TiUtils floatValue:@"latitude" properties:dict];
	center.longitude = [TiUtils floatValue:@"longitude" properties:dict];
	MKCoordinateRegion region_;
	MKCoordinateSpan span;
	span.longitudeDelta = longitudeDelta;
	span.latitudeDelta = latitudeDelta;
	region_.center = center;
	region_.span = span;
	return region_;
}

-(NSDictionary*)dictionaryFromRegion
{
    NSMutableDictionary* theDict = [NSMutableDictionary dictionary];
    [theDict setObject:NUMFLOAT(region.center.latitude) forKey:@"latitude"];
    [theDict setObject:NUMFLOAT(region.center.longitude) forKey:@"longitude"];
    [theDict setObject:NUMFLOAT(region.span.latitudeDelta) forKey:@"latitudeDelta"];
    [theDict setObject:NUMFLOAT(region.span.longitudeDelta) forKey:@"longitudeDelta"];
    
    return theDict;
}

-(CLLocationDegrees) longitudeDelta
{
    if (loaded) {
        MKCoordinateRegion _region = [[self map] region];
        return _region.span.longitudeDelta;
    }
    return 0.0;
}

-(CLLocationDegrees) latitudeDelta
{
    if (loaded) {
        MKCoordinateRegion _region = [[self map] region];
        return _region.span.latitudeDelta;
    }
    return 0.0;
}


#pragma mark Public APIs

-(void)setMapType_:(id)value
{
	[[self map] setMapType:[TiUtils intValue:value]];
}

-(void)setRegion_:(id)value
{
	if (value==nil)
	{
		// unset the region and set it back to the user's location of the map
		// what else to do??
		MKUserLocation* user = [self map].userLocation;
		if (user!=nil)
		{
			region.center = user.location.coordinate;
			[self render];
		}
		else 
		{
			// if we unset but we're not allowed to get the users location, what to do?
		}
	}
	else 
	{
		region = [self regionFromDict:value];
		[self render];
	}
}

-(void)setAnimate_:(id)value
{
	animate = [TiUtils boolValue:value];
}

-(void)setRegionFit_:(id)value
{
    regionFits = [TiUtils boolValue:value];
    [self render];
}

-(void)setUserLocation_:(id)value
{
	ENSURE_SINGLE_ARG(value,NSObject);

	// Release the locationManager in case it was already created
	RELEASE_TO_NIL(locationManager);
	BOOL userLocation = [TiUtils boolValue:value def:NO];
	// if userLocation is true and this is iOS 8 or greater, then ask for permission
	if (userLocation && [TiUtils isIOS8OrGreater]) {
		// the locationManager needs to be created to permissions
		locationManager = [[CLLocationManager alloc] init];
		// set the "userLocation" on the delegate callback to avoid console warnings from the OS
		locationManager.delegate = self;
		if ([[NSBundle mainBundle] objectForInfoDictionaryKey:@"NSLocationAlwaysUsageDescription"]){
			[locationManager requestAlwaysAuthorization];
		} else if ([[NSBundle mainBundle] objectForInfoDictionaryKey:@"NSLocationWhenInUseUsageDescription"]){
			[locationManager requestWhenInUseAuthorization];
		} else {
			NSLog(@"[ERROR] The keys NSLocationAlwaysUsageDescription or NSLocationWhenInUseUsageDescription are not defined in your tiapp.xml.  Starting with iOS8 this is required.");
		}
		// Create the map
		[self map];
	} else {
		// else, just apply the userLocation
		[self map].showsUserLocation = userLocation;
	}
}

-(void)setLocation_:(id)location
{
	ENSURE_SINGLE_ARG(location,NSDictionary);
	//comes in like region: {latitude:100, longitude:100, latitudeDelta:0.5, longitudeDelta:0.5}
	id lat = [location objectForKey:@"latitude"];
	id lon = [location objectForKey:@"longitude"];
	id latdelta = [location objectForKey:@"latitudeDelta"];
	id londelta = [location objectForKey:@"longitudeDelta"];
	if (lat)
	{
		region.center.latitude = [lat doubleValue];
	}
	if (lon)
	{
		region.center.longitude = [lon doubleValue];
	}
	if (latdelta)
	{
		region.span.latitudeDelta = [latdelta doubleValue];
	}
	if (londelta)
	{
		region.span.longitudeDelta = [londelta doubleValue];
	}
	id an = [location objectForKey:@"animate"];
	if (an)
	{
		animate = [an boolValue];
	}
	id rf = [location objectForKey:@"regionFit"];
	if (rf)
	{
		regionFits = [rf boolValue];
	}
	[self render];
}

-(void)addRoute:(TiMapRouteProxy*)route
{
    CFDictionaryAddValue(mapLine2View, [route routeLine], [route routeRenderer]);
    [self addOverlay:[route routeLine] level:[route level]];
}

-(void)removeRoute:(TiMapRouteProxy*)route
{
    MKPolyline *routeLine = [route routeLine];
    CFDictionaryRemoveValue(mapLine2View, routeLine);
    [map removeOverlay:routeLine];
}

#pragma mark Public APIs iOS 7

-(void)setTintColor_:(id)color
{
    [TiMapModule logAddedIniOS7Warning:@"tintColor"];
}

-(void)setCamera_:(id)value
{
    [TiMapModule logAddedIniOS7Warning:@"camera"];
}

-(void)setPitchEnabled_:(id)value
{
    [TiMapModule logAddedIniOS7Warning:@"pitchEnabled"];
}

-(void)setRotateEnabled_:(id)value
{
    [TiMapModule logAddedIniOS7Warning:@"rotateEnabled"];
}

-(void)setShowsBuildings_:(id)value
{
    [TiMapModule logAddedIniOS7Warning:@"showsBuildings"];
}

-(void)setShowsPointsOfInterest_:(id)value
{
    [TiMapModule logAddedIniOS7Warning:@"showsPointsOfInterest"];
}

#pragma mark Utils
// Using these utility functions allows us to override them for different versions of iOS

-(void)addOverlay:(MKPolyline*)polyline level:(MKOverlayLevel)level
{
    [map addOverlay:polyline];
}

#pragma mark Delegates

// Delegate for >= iOS 8
-(void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status
{
	if((status == kCLAuthorizationStatusAuthorizedWhenInUse) || (status == kCLAuthorizationStatusAuthorizedAlways) || (status == kCLAuthorizationStatusAuthorized)){
		self.map.showsUserLocation = [TiUtils boolValue:[self.proxy valueForKey:@"userLocation"] def:NO];
	}
}

// Delegate for >= iOS 7
- (MKOverlayRenderer *)mapView:(MKMapView *)mapView rendererForOverlay:(id < MKOverlay >)overlay
{
    if ([overlay isKindOfClass:[NetfunctionalMapoverlayTilerOverlay class]] || [overlay isKindOfClass:[TiNFMMapPolyline class]] || [overlay isKindOfClass:[MKPolygon class]] || [overlay isKindOfClass:[TiNFMMapCircle class]] || [overlay isKindOfClass:[TiNFMMapPolygon class]] || [overlay isKindOfClass:[TiNFMFloatingImageOverlay class]] || [overlay isKindOfClass:[TiNFMImageOverlay class]]) {
        return [self mapView:mapView viewForOverlay:overlay];
    }
    else {
        return (MKOverlayRenderer *)CFDictionaryGetValue(mapLine2View, overlay);
    }
}

// Delegate for < iOS 7
// MKPolylineView is deprecated in iOS 7, still here for backward compatibility.
// Can be removed when support is dropped for iOS 6 and below.
- (MKOverlayView *)mapView:(MKMapView *)mapView viewForTiOverlay:(id <MKOverlay>)overlay
{	
    return (MKOverlayView *)CFDictionaryGetValue(mapLine2View, overlay);
}

- (void)mapView:(MKMapView *)mapView regionDidChangeAnimated:(BOOL)animated
{
    if (ignoreRegionChanged) {
        return;
    }
    region = [mapView region];
    [self.proxy replaceValue:[self dictionaryFromRegion] forKey:@"region" notification:NO];
	if ([self.proxy _hasListeners:@"regionChanged"])
	{	//TODO: Deprecate old event
		NSDictionary * props = [NSDictionary dictionaryWithObjectsAndKeys:
								@"regionChanged",@"type",
								[NSNumber numberWithDouble:region.center.latitude],@"latitude",
								[NSNumber numberWithDouble:region.center.longitude],@"longitude",
								[NSNumber numberWithDouble:region.span.latitudeDelta],@"latitudeDelta",
								[NSNumber numberWithDouble:region.span.longitudeDelta],@"longitudeDelta",nil];
		[self.proxy fireEvent:@"regionChanged" withObject:props];
	}
	if ([self.proxy _hasListeners:@"regionchanged"])
	{
		NSDictionary * props = [NSDictionary dictionaryWithObjectsAndKeys:
								@"regionchanged",@"type",
								[NSNumber numberWithDouble:region.center.latitude],@"latitude",
								[NSNumber numberWithDouble:region.center.longitude],@"longitude",
								[NSNumber numberWithDouble:region.span.latitudeDelta],@"latitudeDelta",
								[NSNumber numberWithDouble:region.span.longitudeDelta],@"longitudeDelta",
								NUMBOOL(animated),@"animated",nil];
		[self.proxy fireEvent:@"regionchanged" withObject:props];
	}
}

- (void)mapViewWillStartLoadingMap:(MKMapView *)mapView
{
	loaded = NO;
	if ([self.proxy _hasListeners:@"loading"])
	{
		[self.proxy fireEvent:@"loading" withObject:nil];
	}
}

- (void)mapViewDidFinishLoadingMap:(MKMapView *)mapView
{
	ignoreClicks = YES;
	loaded = YES;
	if ([self.proxy _hasListeners:@"complete"])
	{
		[self.proxy fireEvent:@"complete" withObject:nil errorCode:0 message:nil];
	}
	ignoreClicks = NO;
}

- (void)mapViewDidFailLoadingMap:(MKMapView *)mapView withError:(NSError *)error
{
	if ([self.proxy _hasListeners:@"error"])
	{
		NSString * message = [TiUtils messageFromError:error];
		NSDictionary *event = [NSDictionary dictionaryWithObject:message forKey:@"message"];
		[self.proxy fireEvent:@"error" withObject:event errorCode:[error code] message:message];
	}
}

- (void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)annotationView didChangeDragState:(MKAnnotationViewDragState)newState fromOldState:(MKAnnotationViewDragState)oldState
{
	[self firePinChangeDragState:annotationView newState:newState fromOldState:oldState];
	if (newState == MKAnnotationViewDragStateStarting) {
		[annotationView setDragState: MKAnnotationViewDragStateDragging];
	} else if (newState == MKAnnotationViewDragStateEnding || newState == MKAnnotationViewDragStateCanceling) {
		[annotationView setDragState: MKAnnotationViewDragStateNone];
	}
}

- (void)firePinChangeDragState:(MKAnnotationView *) pinview newState:(MKAnnotationViewDragState)newState fromOldState:(MKAnnotationViewDragState)oldState 
{
	TiMapAnnotationProxy *viewProxy = [self proxyForAnnotation:pinview];

	if (viewProxy == nil)
		return;

	TiProxy * ourProxy = [self proxy];
	BOOL parentWants = [ourProxy _hasListeners:@"pinchangedragstate"];
	BOOL viewWants = [viewProxy _hasListeners:@"pinchangedragstate"];
	
	if(!parentWants && !viewWants)
		return;

	id title = [viewProxy title];
	if (title == nil)
		title = [NSNull null];

	NSNumber * indexNumber = NUMINT([pinview tag]);

	NSDictionary * event = [NSDictionary dictionaryWithObjectsAndKeys:
								viewProxy,@"annotation",
								ourProxy,@"map",
								title,@"title",
								indexNumber,@"index",
								NUMINT(newState),@"newState",
								NUMINT(oldState),@"oldState",
								nil];

	if (parentWants)
		[ourProxy fireEvent:@"pinchangedragstate" withObject:event];

	if (viewWants)
		[viewProxy fireEvent:@"pinchangedragstate" withObject:event];
}

- (TiMapAnnotationProxy*)proxyForAnnotation:(MKAnnotationView*)pinview
{
	for (id annotation in [map annotations])
	{
		if ([annotation isKindOfClass:[TiMapAnnotationProxy class]])
		{
			if ([annotation tag] == pinview.tag)
			{
				return annotation;
			}
		}
	}
	return nil;
}

- (void)mapView:(MKMapView *)mapView didSelectAnnotationView:(MKAnnotationView *)view{
	if ([view conformsToProtocol:@protocol(TiMapAnnotation)])
	{
		BOOL isSelected = [view isSelected];
		MKAnnotationView<TiMapAnnotation> *ann = (MKAnnotationView<TiMapAnnotation> *)view;
		[self fireClickEvent:view source:isSelected?@"pin":[ann lastHitName]];
		return;
	}
}
- (void)mapView:(MKMapView *)mapView didDeselectAnnotationView:(MKAnnotationView *)view{
	if ([view conformsToProtocol:@protocol(TiMapAnnotation)])
	{
		BOOL isSelected = [view isSelected];
		MKAnnotationView<TiMapAnnotation> *ann = (MKAnnotationView<TiMapAnnotation> *)view;
		[self fireClickEvent:view source:isSelected?@"pin":[ann lastHitName]];
		return;
	}
}

- (void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)aview calloutAccessoryControlTapped:(UIControl *)control
{
	if ([aview conformsToProtocol:@protocol(TiMapAnnotation)])
	{
		MKPinAnnotationView *pinview = (MKPinAnnotationView*)aview;
		NSString * clickSource = @"unknown";
		if (aview.leftCalloutAccessoryView == control)
		{
			clickSource = @"leftButton";
		}
		else if (aview.rightCalloutAccessoryView == control)
		{
			clickSource = @"rightButton";
		}
		[self fireClickEvent:pinview source:clickSource];
	}
}


// mapView:viewForAnnotation: provides the view for each annotation.
// This method may be called for all or some of the added annotations.
// For MapKit provided annotations (eg. MKUserLocation) return nil to use the MapKit provided annotation view.
- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id <MKAnnotation>)annotation
{
    if ([annotation isKindOfClass:[TiMapAnnotationProxy class]]) {
        TiMapAnnotationProxy *ann = (TiMapAnnotationProxy*)annotation;
        id customView = [ann valueForUndefinedKey:@"customView"];
        if ( (customView == nil) || (customView == [NSNull null]) || (![customView isKindOfClass:[TiViewProxy class]]) ){
            customView = nil;
        }
        NSString *identifier = nil;
        UIImage* image = nil;
        if (customView == nil) {
            id imagePath = [ann valueForUndefinedKey:@"image"];
            image = [TiUtils image:imagePath proxy:ann];
            identifier = (image!=nil) ? @"timap-image":@"timap-pin";
        }
        else {
            identifier = @"timap-customView";
        }
        MKAnnotationView *annView = nil;
		
        annView = (MKAnnotationView*) [mapView dequeueReusableAnnotationViewWithIdentifier:identifier];
		
        if (annView==nil) {
            if ([identifier isEqualToString:@"timap-customView"]) {
                annView = [[[TiMapCustomAnnotationView alloc] initWithAnnotation:ann reuseIdentifier:identifier map:self] autorelease];
            }
            else if ([identifier isEqualToString:@"timap-image"]) {
                annView=[[[TiMapImageAnnotationView alloc] initWithAnnotation:ann reuseIdentifier:identifier map:self image:image] autorelease];
            }
            else {
                annView=[[[TiMapPinAnnotationView alloc] initWithAnnotation:ann reuseIdentifier:identifier map:self] autorelease];
            }
        }
        if ([identifier isEqualToString:@"timap-customView"]) {
            [((TiMapCustomAnnotationView*)annView) setProxy:customView];
        }
        else if ([identifier isEqualToString:@"timap-image"]) {
            annView.image = image;
        }
        else {
            MKPinAnnotationView *pinview = (MKPinAnnotationView*)annView;
            pinview.pinColor = [ann pinColor];
            pinview.animatesDrop = [ann animatesDrop] && ![(TiMapAnnotationProxy *)annotation placed];
            annView.calloutOffset = CGPointMake(-8, 0);
        }
        annView.canShowCallout = [TiUtils boolValue:[ann valueForUndefinedKey:@"canShowCallout"] def:YES];;
        annView.enabled = YES;
        annView.centerOffset = ann.offset;
        UIView *left = [ann leftViewAccessory];
        UIView *right = [ann rightViewAccessory];
        if (left!=nil) {
            annView.leftCalloutAccessoryView = left;
        }
        if (right!=nil) {
            annView.rightCalloutAccessoryView = right;
        }

        [annView setDraggable: [TiUtils boolValue: [ann valueForUndefinedKey:@"draggable"]]];
        annView.userInteractionEnabled = YES;
        annView.tag = [ann tag];
        return annView;
    }
    return nil;
}


// mapView:didAddAnnotationViews: is called after the annotation views have been added and positioned in the map.
// The delegate can implement this method to animate the adding of the annotations views.
// Use the current positions of the annotation views as the destinations of the animation.
- (void)mapView:(MKMapView *)mapView didAddAnnotationViews:(NSArray *)views
{
	for (MKAnnotationView<TiMapAnnotation> *thisView in views)
	{
		if(![thisView conformsToProtocol:@protocol(TiMapAnnotation)])
		{
			return;
		}
        /*Image Annotation don't have any animation of its own. 
         *So in this case we do a custom animation, to place the 
         *image annotation on top of the mapview.*/
        if([thisView isKindOfClass:[TiMapImageAnnotationView class]] || [thisView isKindOfClass:[TiMapCustomAnnotationView class]])
        {
            TiMapAnnotationProxy *anntProxy = [self proxyForAnnotation:thisView];
            if([anntProxy animatesDrop] && ![anntProxy placed])
            {
                CGRect viewFrame = thisView.frame;
                thisView.frame = CGRectMake(viewFrame.origin.x, viewFrame.origin.y - self.frame.size.height, viewFrame.size.width, viewFrame.size.height);
                [UIView animateWithDuration:0.4 
                                      delay:0.0 
                                    options:UIViewAnimationCurveEaseOut 
                                 animations:^{thisView.frame = viewFrame;}
                                 completion:nil];
            }
        }
		TiMapAnnotationProxy * thisProxy = [self proxyForAnnotation:thisView];
		[thisProxy setPlaced:YES];
	}
}

#pragma mark Click detection

-(id<MKAnnotation>)wasHitOnAnnotation:(CGPoint)point inView:(UIView*)view
{
	id<MKAnnotation> result = nil;
	for (UIView* subview in [view subviews]) {
		if (![subview pointInside:[self convertPoint:point toView:subview] withEvent:nil]) {
			continue;
		}
		
		if ([subview isKindOfClass:[MKAnnotationView class]]) {
			result = [(MKAnnotationView*)subview annotation];
		}
		else {
			result = [self wasHitOnAnnotation:point inView:subview];
		}
		
		if (result != nil) {
			break;
		}
	}
	return result;
}

#pragma mark Event generation

- (void)fireClickEvent:(MKAnnotationView *) pinview source:(NSString *)source
{
	if (ignoreClicks)
	{
		return;
	}

	TiMapAnnotationProxy *viewProxy = [self proxyForAnnotation:pinview];
	if (viewProxy == nil)
	{
		return;
	}

	TiProxy * ourProxy = [self proxy];
	BOOL parentWants = [ourProxy _hasListeners:@"click"];
	BOOL viewWants = [viewProxy _hasListeners:@"click"];
	if(!parentWants && !viewWants)
	{
		return;
	}
	
	id title = [viewProxy title];
	if (title == nil)
	{
		title = [NSNull null];
	}

	NSNumber * indexNumber = NUMINT([pinview tag]);
	id clicksource = source ? source : (id)[NSNull null];
	
	NSDictionary * event = [NSDictionary dictionaryWithObjectsAndKeys:
			clicksource,@"clicksource",	viewProxy,@"annotation",	ourProxy,@"map",
			title,@"title",			indexNumber,@"index",		nil];

	if (parentWants)
	{
		[ourProxy fireEvent:@"click" withObject:event];
	}
	if (viewWants)
	{
		[viewProxy fireEvent:@"click" withObject:event];
	}
}

#pragma mark Customized viewForOverlay method 

//override of native Titanium.Map method.  Our version will use the native MapKit MKPolyline and MKPolylineView classes which were added for iOS 4.0

-(void)addPolyline:(id)args
{
    //verify we have a dictionary object as args
    ENSURE_DICT(args);
    ENSURE_UI_THREAD(addAnnotation,args);
    
    //retrieve the name of our polyline
    NSString *name = [TiUtils stringValue:@"name" properties:args];
    
    //initialize our polylines array field if it isn't already
    if (polylines==nil)
    {
        polylines = [[NSMutableDictionary dictionary] retain];
    }
    
    //determine if there are any polyline annotations already with this name; delete them if there are
    id<MKAnnotation> ann = [polylines objectForKey:name];
    if (ann!=nil)
    {
        
        [map removeAnnotation:ann];
        //[map removeAnnotation:ann];
        [polylines removeObjectForKey:name];
        [polylineViews removeObjectForKey:name];
    }
    
    if (polylineViews==nil)
    {
        polylineViews = [[NSMutableDictionary dictionary] retain];
    }
    
    
    
    
    //retrieve the polyline's styling details
    
    CGFloat strokeAlpha;
    if ([args objectForKey:@"alpha"] != nil) {
        strokeAlpha = [TiUtils floatValue:@"alpha" properties:args def:2];
    }
    else {
        //TODO log use of default
        strokeAlpha = 1.0;
    }
    
    TiColor *strokeColor= [TiUtils colorValue:@"color" properties:args];
    UIColor* strokeColorUI;
    
    if (strokeColor!=nil)
    {
        strokeColorUI = [[strokeColor _color] colorWithAlphaComponent:strokeAlpha];
    }
    else {
        NSLog(@"No color specified for polyline/route; using default color black instead");
        strokeColorUI = [[UIColor blackColor] colorWithAlphaComponent:strokeAlpha];
    }
    
    CGFloat lineWidth;
    if ([args objectForKey:@"width"] != nil) {
        lineWidth = [TiUtils floatValue:@"width" properties:args def:2];
    }
    else {
        //TODO log use of default
        lineWidth = 1.0;
    }
    
    //retrieve the points of the route
    //array to store overlay polyline vertice coordinates
    NSArray *points = [args objectForKey:@"points"];
    //check that arguments contain vertices
    if (points==nil)
    {
        [self throwException:@"Missing required key: 'points'" subreason:nil location:CODELOCATION];
    }
    else {
        TiNFMMapPolyline* routePolyline = [[TiNFMMapPolyline alloc]initWithPoints:points];
        routePolyline.lineWidth = lineWidth;
        routePolyline.strokeColor = strokeColorUI;
        
        [map addOverlay:routePolyline];
        [polylines setObject:routePolyline forKey:name];
        [routePolyline release];
    }
    
    
}

-(void)removePolyline:(id)args
{
    ENSURE_DICT(args);
    NSString *name = [TiUtils stringValue:@"name" properties:args];
    if (polylines==nil)
    {
        polylines = [[NSMutableDictionary dictionary] retain];
    }
    id<MKOverlay> ann = [polylines objectForKey:name];
    if (ann!=nil)
    {
        [map removeOverlay:ann];
        //[map removeOverlay:ann];
        [polylines removeObjectForKey:name];
        [polylineViews removeObjectForKey:name];
    }
}


-(NSValue*) keyForMKOverlay:(id<MKOverlay>) overlay {
    //    if ([overlay )
    NSValue* keyVal;
    if ([overlay isKindOfClass:[MKPolygon class]]) {
        return [NSValue valueWithPointer:&overlay];
    }
}


-(void) addTilerOverlay:(id<MKOverlay>)overlay {
    [map addOverlay:overlay];
}

-(void) addKMLOverlays:(NetfunctionalMapoverlayKMLDocumentProxy*) kmlDocument {
    NSLog(@"[INFO] adding kml overlays from file %@",kmlDocument);
    NSArray *kmlOverlays = [kmlDocument overlays];
    
    if (!kmlOverlayToKMLDoc) {
        kmlOverlayToKMLDoc = [[NSMutableDictionary alloc] initWithCapacity:[kmlOverlays count]];
    }
    
    for(id kmlOverlay in kmlOverlays) {
        [kmlOverlayToKMLDoc setObject:kmlDocument forKey:[NSValue valueWithPointer:kmlOverlay]];
    }
    
    //    dispatch_async(dispatch_get_main_queue(), ^{
    [map addOverlays:kmlOverlays];
    
    NSLog(@"[INFO] added %d kml overlays from file %@",[kmlOverlays count],kmlDocument);
    
}

-(void) removeKMLOverlays:(NetfunctionalMapoverlayKMLDocumentProxy*) kmlDocument {
    NSArray *kmlOverlays = [kmlDocument overlays];
    
    for(id kmlOverlay in kmlOverlays) {
        [kmlOverlayToKMLDoc removeObjectForKey:[NSValue valueWithPointer:kmlOverlay]];
    }
    
    //    dispatch_async(dispatch_get_main_queue(), ^{
    [map removeOverlays:kmlOverlays];
}


-(void)addOverlay:(id)args
{
    //verify we have a dictionary object as args
    ENSURE_DICT(args);
    ENSURE_UI_THREAD(addAnnotation,args);
    
    //retrieve the type of our overlay (should be either 'polygon', 'circle' or 'image')
    NSString *overlayType = [TiUtils stringValue:@"type" properties:args];
    
    
    
    //retrieve the name of our overlay
    NSString *name = [TiUtils stringValue:@"name" properties:args];
    
    //initialize our overlays array field if it isn't already
    if (overlays==nil)
    {
        overlays = [[NSMutableDictionary dictionary] retain];
    }
    
    //determine if there are any overlay annotations already with this name; delete them if there are
    id<MKAnnotation> ann = [overlays objectForKey:name];
    if (ann!=nil)
    {
        
        [map removeAnnotation:ann];
        //[map removeAnnotation:ann];
        [overlays removeObjectForKey:name];
        [overlayViews removeObjectForKey:name];
    }
    
    if (overlayViews==nil)
    {
        overlayViews = [[NSMutableDictionary dictionary] retain];
    }
    
    
    if ([overlayType isEqualToString:@"image"]  || [overlayType isEqualToString:@"floating_image"]) {
        
        
        //retrieve the other properties of the image
        
        //ensure the 'img' file has been specified.
        if ([args objectForKey:@"img"] == nil) {
            [self throwException:@"missing required 'img' key; cannot locate image file to use for overlay" subreason:nil location:CODELOCATION];
        }
        NSString *imagePath = [TiUtils stringValue:@"img" properties:args];
        CGFloat imageAlpha;
        if ([args objectForKey:@"alpha"] !=nil) {
            imageAlpha = [TiUtils floatValue:@"alpha" properties:args];
        }
        else {
            //set a default alpha
            imageAlpha = 0.9;
        }
        
        //if specified, get the zoom scale range limits; cover the full range of zoom scales if none are specified, or in any case err on the side of maximum permissability.
        CGFloat minZoomScale;
        if ([args objectForKey:@"minZoomScale"] !=nil) {
            minZoomScale = [TiUtils floatValue:@"minZoomScale" properties:args];
        }
        else {
            //set a default alpha
            minZoomScale = 0.0;
        }
        
        CGFloat maxZoomScale;
        if ([args objectForKey:@"maxZoomScale"] !=nil) {
            maxZoomScale = [TiUtils floatValue:@"maxZoomScale" properties:args];
        }
        else {
            //set a default alpha
            maxZoomScale = 1.0;
        }
        
        //NSLog(@"2: alpha is %f",imageAlpha);
        
        UIImage* img = [UIImage imageNamed:imagePath];
        if (img == nil) {
            //possibly is not within the named resources of application, so see if there is a native file path to use
            //img = [UIImage imageWithContentsOfFile:imagePath];
            //img = [UIImage imageWithContentsOfFile:@"file:///localhost/Users/michael/Library/Application Support/iPhone Simulator/4.3/Applications/D2DA3575-01A8-4412-93F9-51C69EBA1802/Documents/test.png"];
            
            /*NSString* pathToAppDataDir = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
             //pathToAppDataDir = [[NSURL fileURLWithPath:pathToAppDataDir isDirectory:YES] absoluteString];
             
             //NSLog(@"Path to application directory, according to NSSearchPathForDirectoriesInDomains: %@",pathToAppDataDir);
             
             
             //NSString* pathToImageFile = [NSString stringWithFormat:@"%@%@", pathToAppDataDir, imagePath];
             
             //NSLog(@"Path to image file: %@",pathToImageFile);
             
             //img = [UIImage imageWithContentsOfFile:pathToImageFile];
             */
            //NSURL* urlToFile = [NSURL URLWithString:pathToImageFile];
            NSURL* urlToFile = [NSURL URLWithString:imagePath];
            NSData* imageData = [NSData dataWithContentsOfURL:urlToFile];
            img = [[UIImage alloc] initWithData:imageData];
            //img = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:pathToImageFile]]];
        }
        
        if (img == nil) {
            NSLog(@"failed to load image file for overlay");
        }
        else {
            //NSLog(@"successfully loaded an image file for use as a map overlay");
        }
        
        //here we branch the code to handle the two types of image overlays:  floating and non-floating (i.e., ones painted onto the surface of the globe)
        
        if ([overlayType isEqualToString:@"image"]) {
            //retrieve the coordinates for the north west corner of the overlay and convert to the appropriate Core Location type
            NSDictionary *nwcCoords = [args objectForKey:@"northWestCoord"];
            if (nwcCoords == nil) {
                [self throwException:@"missing required 'northWestCoord' key" subreason:nil location:CODELOCATION];
            }
            if ([nwcCoords objectForKey:@"latitude"]==nil ||  [nwcCoords objectForKey:@"longitude"]==nil) {
                [self throwException:@"missing required latitude and longitude key-value pairs for 'northWestCoord' key" subreason:nil location:CODELOCATION];
            }
            CLLocationDegrees nwLat = [TiUtils doubleValue:[nwcCoords objectForKey:@"latitude"]];
            CLLocationDegrees nwLon = [TiUtils doubleValue:[nwcCoords objectForKey:@"longitude"]];
            CLLocationCoordinate2D nwc = CLLocationCoordinate2DMake(nwLat,nwLon);
            
            //do the same as above but for the south east corner
            NSDictionary *secCoords = [args objectForKey:@"southEastCoord"];
            if (secCoords == nil) {
                [self throwException:@"missing required 'southEastCoord' key" subreason:nil location:CODELOCATION];
            }
            if ([secCoords objectForKey:@"latitude"]==nil ||  [secCoords objectForKey:@"longitude"]==nil) {
                [self throwException:@"missing required latitude and longitude key-value pairs for 'southEastCoord' key" subreason:nil location:CODELOCATION];
            }
            CLLocationDegrees seLat = [TiUtils doubleValue:[secCoords objectForKey:@"latitude"]];
            CLLocationDegrees seLon = [TiUtils doubleValue:[secCoords objectForKey:@"longitude"]];
            CLLocationCoordinate2D sec = CLLocationCoordinate2DMake(seLat,seLon);
            
            //TODO release the se/nw latlon stuff, if neccessary
            
            //TODO implement checks that the image overlay parameters were all found and converted properly
            
            
            //NSLog(@"Overlay Image size: %f,%f",img.size.width,img.size.height);
            
            
            TiNFMImageOverlay* imgOverlay = [[TiNFMImageOverlay alloc] overlayWithImage:img northWestBound:nwc southEastBound:sec alpha:imageAlpha];
            //TiNFMImageOverlay* imgOverlay = [[TiNFMImageOverlay alloc] overlayWithImage:img northWestBound:nwc southEastBound:sec];
            
            [imgOverlay setMinZoomScale:minZoomScale];
            [imgOverlay setMaxZoomScale:maxZoomScale];
            
            [map addOverlay:imgOverlay];
            [overlays setObject:imgOverlay forKey:name];
            [imgOverlay release];
            
        }
        else if ([overlayType isEqualToString:@"floating_image"]) {
            
            //retrieve the coordinates of the point on the globe where the floating image should be centered
            NSDictionary *centerCoords = [args objectForKey:@"centerCoord"];
            if (centerCoords == nil) {
                [self throwException:@"missing required 'centerCoord' key" subreason:nil location:CODELOCATION];
            }
            if ([centerCoords objectForKey:@"latitude"]==nil ||  [centerCoords objectForKey:@"longitude"]==nil) {
                [self throwException:@"missing required latitude and longitude key-value pairs for 'centerCoords' key" subreason:nil location:CODELOCATION];
            }
            CLLocationDegrees centerLat = [TiUtils doubleValue:[centerCoords objectForKey:@"latitude"]];
            CLLocationDegrees centerLon = [TiUtils doubleValue:[centerCoords objectForKey:@"longitude"]];
            CLLocationCoordinate2D center = CLLocationCoordinate2DMake(centerLat,centerLon);
            
            //retrive the width the image should take up in meters at the maximum zoom level
            //retrieve the polygon/circle overlay styling details
            
            CGFloat imageWidth;
            if ([args objectForKey:@"width"] != nil) {
                imageWidth = [TiUtils floatValue:@"width" properties:args def:2];
            }
            else {
                //TODO log use of default, or perhaps through exception instead
                imageWidth = 10.0;
            }
            
            TiNFMFloatingImageOverlay* imgOverlay = [[TiNFMFloatingImageOverlay alloc] overlayWithImage:img centerCoord:center width:imageWidth alpha:imageAlpha];
            //TiNFMImageOverlay* imgOverlay = [[TiNFMImageOverlay alloc] overlayWithImage:img northWestBound:nwc southEastBound:sec];
            [map addOverlay:imgOverlay];
            [overlays setObject:imgOverlay forKey:name];
            [imgOverlay release];
            
            
        }
        
        
    }
    else {
        
        
        
        
        
        //retrieve the polygon/circle overlay styling details
        
        CGFloat strokeAlpha;
        if ([args objectForKey:@"strokeAlpha"] != nil) {
            strokeAlpha = [TiUtils floatValue:@"strokeAlpha" properties:args def:2];
        }
        else {
            //TODO log use of default
            strokeAlpha = 1.0;
        }
        CGFloat fillAlpha;
        if ([args objectForKey:@"fillAlpha"] != nil) {
            fillAlpha = [TiUtils floatValue:@"fillAlpha" properties:args def:2];
        }
        else {
            //TODO log use of default
            fillAlpha = 0.5;
        }
        
        
        TiColor *strokeColor= [TiUtils colorValue:@"strokeColor" properties:args];
        TiColor *fillColor= [TiUtils colorValue:@"fillColor" properties:args];
        UIColor* strokeColorUI;
        UIColor* fillColorUI;
        
        if (strokeColor!=nil)
        {
            strokeColorUI = [[strokeColor _color] colorWithAlphaComponent:strokeAlpha];
        }
        else {
            NSLog(@"No stroke color specified for polygon overlay; using default color blue instead");
            strokeColorUI = [[UIColor blueColor] colorWithAlphaComponent:strokeAlpha];
        }
        
        
        if (fillColor!=nil)
        {
            fillColorUI = [[fillColor _color] colorWithAlphaComponent:fillAlpha];
        }
        else {
            //use the stroke color as the fill color.
            //TODO log use of default
            fillColorUI = [[strokeColor _color] colorWithAlphaComponent:fillAlpha];
        }
        
        
        CGFloat lineWidth;
        if ([args objectForKey:@"width"] != nil) {
            lineWidth = [TiUtils floatValue:@"width" properties:args def:2];
        }
        else {
            //TODO log use of default
            lineWidth = 1.0;
        }
        
        if ([overlayType isEqualToString:@"polygon"]) {
            
            //array to store overlay polygon vertice coordinates
            NSArray *points = [args objectForKey:@"points"];
            //check that arguments contain vertices
            if (points==nil)
            {
                [self throwException:@"Missing required key: 'points'" subreason:nil location:CODELOCATION];
            }
            else {
                TiNFMMapPolygon *overlayPolygon =  [[TiNFMMapPolygon alloc]initWithPoints:points];
                
                overlayPolygon.strokeColor = strokeColorUI;
                overlayPolygon.fillColor = fillColorUI;
                overlayPolygon.lineWidth = lineWidth;
                overlayPolygon.polygonID = name;
                
                [map addOverlay:overlayPolygon];
                [overlays setObject:overlayPolygon forKey:name];
                [overlayPolygon release];
            }
            
        }
        else if ([overlayType isEqualToString:@"circle"]) {
            if ([args objectForKey:@"center"]== nil) {
                [self throwException:@"Missing required key: 'center'" subreason:nil location:CODELOCATION];
            }
            else if ([args objectForKey:@"radius"]== nil) {
                [self throwException:@"Missing required key: 'radius'" subreason:nil location:CODELOCATION];
            }
            else {
                NSDictionary *centerCoordinates = [args objectForKey:@"center"];
                CLLocationDegrees lat = [TiUtils doubleValue:[centerCoordinates objectForKey:@"latitude"]];
                CLLocationDegrees lon = [TiUtils doubleValue:[centerCoordinates objectForKey:@"longitude"]];
                CLLocationCoordinate2D coord = CLLocationCoordinate2DMake(lat,lon);
                CLLocationDegrees rad = [TiUtils doubleValue:[args objectForKey:@"radius"]];
                TiNFMMapCircle* overlayCircle = [[TiNFMMapCircle alloc]circleWithCenterCoordinate:coord radius:rad];
                overlayCircle.circleID = name;
                overlayCircle.strokeColor = strokeColorUI;
                overlayCircle.fillColor = fillColorUI;
                overlayCircle.lineWidth = lineWidth;
                
                [map addOverlay:overlayCircle];
                [overlays setObject:overlayCircle forKey:name];
                [overlayCircle release];
                //TODO release centerCoordinates?
            }
        }
        else {
            //[self throwException:@"Missing required key: 'points'" subreason:nil location:CODELOCATION];
            //TODO consider throwing exception or passing to parent class.
            NSLog(@"Value for key 'type' for new overlay was unrecognized.");
        }
    }
    
    
}

-(void)removeOverlay:(id)args
{
    ENSURE_DICT(args);
    NSString *name = [TiUtils stringValue:@"name" properties:args];
    if (overlays==nil)
    {
        overlays = [[NSMutableDictionary dictionary] retain];
    }
    id<MKOverlay> ann = [overlays objectForKey:name];
    if (ann!=nil)
    {
        [map removeOverlay:ann];
        //[map removeOverlay:ann];
        [overlays removeObjectForKey:name];
        [overlayViews removeObjectForKey:name];
    }
}

-(MKOverlayView *)mapView:(MKMapView *)mapView viewForOverlay:(id )overlay{
    
    //NSLog(@"Determining the proper overlay view class to use for this overlay ...");
    if ([overlay isKindOfClass:[TiNFMImageOverlay class]]){
        //NSLog(@"Setting overlayview for image overlay as TINFMImageOverlayView class");
        TiNFMImageOverlay* imgOverlay = overlay;
        TiNFMImageOverlayView* imgView = [[TiNFMImageOverlayView alloc] initWithUIImage:imgOverlay];
        return imgView;
    }
    else if ([overlay isKindOfClass:[TiNFMFloatingImageOverlay class]]){
        //NSLog(@"Setting overlayview for image overlay as TINFMImageOverlayView class");
        TiNFMFloatingImageOverlay* imgOverlay = overlay;
        TiNFMFloatingImageOverlayView* imgView = [[TiNFMFloatingImageOverlayView alloc] initWithUIImage:imgOverlay];
        return imgView;
    }
    
    else if ([overlay isKindOfClass:[TiNFMMapPolygon class]]){
        //NSLog(@"Setting overlayview for polygon overlay as TINFMMapPolygonView class");
        
        
        TiNFMMapPolygon *nfmPolygon = overlay;
        MKPolygonView *view = [[[MKPolygonView alloc]initWithPolygon:[nfmPolygon polygon]] autorelease];
        view.lineWidth=nfmPolygon.lineWidth;
        view.strokeColor=nfmPolygon.strokeColor;
        view.fillColor=nfmPolygon.fillColor;
        
        //		CGColorRef color = view.fillColor.CGColor;
        //
        //
        //		int numComponents = CGColorGetNumberOfComponents(color);
        //
        //		if (numComponents == 4)
        //		{
        //			const CGFloat *components = CGColorGetComponents(color);
        //			CGFloat red = floor(components[0]*255.0);
        //			CGFloat green = floor(components[1]*255.0);
        //			CGFloat blue = floor(components[2]*255.0);
        //			CGFloat alpha = components[3];
        //
        //			NSString* rComp = [NSString stringWithFormat:@"%f", red];
        //			NSString* gComp = [NSString stringWithFormat:@"%f", green];
        //			NSString* bComp = [NSString stringWithFormat:@"%f", blue];
        //			NSLog(@"%@",rComp);
        //			NSLog(@"%@",gComp);
        //			NSLog(@"%@",bComp);
        //			NSLog(@"%@%@%@",rComp,gComp,bComp);
        //		}
        //		else {
        //			NSLog(@"wrong number of components");
        //		}
        //TODO implement storage of the overlay views in overlayViews so that they can be shown/hidden.
        //[overlayViews setObject:view forKey:overlay.name];
        return view;
    }
    else if ([overlay isKindOfClass:[TiNFMMapCircle class]]) {
        //NSLog(@"Setting overlayview for circle overlay as TINFMMapCircleView class");
        TiNFMMapCircle* circle = overlay;
        MKCircleView* cView = [[[MKCircleView alloc]initWithCircle:[circle circle]] autorelease];
        cView.lineWidth = circle.lineWidth;
        cView.strokeColor = circle.strokeColor;
        cView.fillColor = circle.fillColor;
        return cView;
    }
    else if ([overlay isKindOfClass:[TiNFMMapPolyline class]]) {
        TiNFMMapPolyline* polylineO = overlay;
        MKPolylineView* polylineView = [[MKPolylineView alloc] initWithPolyline:polylineO.polyline];
        polylineView.strokeColor = polylineO.strokeColor;
        polylineView.lineWidth = polylineO.lineWidth;
        return polylineView;
    }
    else if ([overlay isKindOfClass:[NetfunctionalMapoverlayTilerOverlay class]]) {
        NetfunctionalMapoverlayTilerOverlayView* ov = [[NetfunctionalMapoverlayTilerOverlayView alloc] initWithOverlay:overlay];
        return ov;
    }
    else if ([overlay isKindOfClass:[MKPolygon class]]) {
        NSLog(@"[TRACE] base MKPolygon overlay found, returning basic MKPolygonView");
        
        //presume that this is a overlay from a kml document
        //we need the kml document in order to create the view for the overlay, so use our mapping of kml overlays to kml docs (see addKMLOverlays and removeKMLOverlays) to retrieve the appropriate doc
        NetfunctionalMapoverlayKMLDocumentProxy* kmlDocForOverlay = [kmlOverlayToKMLDoc objectForKey:[NSValue valueWithPointer:overlay]];
        if (!kmlDocForOverlay) {
            NSLog(@"[ERROR] No KML doc found corresponding to MKPolygonOverlay Specified!  Expected this overlay to be mapped to a kml document with details of how the view should look; returning nil for view for overlay");
            return nil;
        }
        
        //        MKPolygon* polygon = overlay;
        //        NSLog(@"polygon has title %@",[polygon title]);
        MKOverlayView* polygonOverlayView = [kmlDocForOverlay viewForOverlay:overlay];
        //        MKOverlayView* polygonOverlayView = [[MKPolygonView alloc ] initWithOverlay:overlay];
        //        polygonOverlayView.fillColor = [[UIColor cyanColor] colorWithAlphaComponent:0.2];
        //        polygonOverlayView.strokeColor = [[UIColor blueColor] colorWithAlphaComponent:0.7];
        //        polygonOverlayView.lineWidth = 3;
        
        //        [polygonOverlayView set]
        return polygonOverlayView;
    }
    else {
        //fall back on super class in case we don't recognize the overlay type.  Also, this is safer in case TiMap eventually does implement overlay functionality.
        NSLog(@"[ERROR] Unrecognized overlay type found %@, relying on default mapview to determine overlay view",overlay);
                return [self mapView:map viewForTiOverlay:overlay];
//        return nil;
        
    }
    
    
    return nil;
}


@end
