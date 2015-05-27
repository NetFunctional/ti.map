/**
 * Copyright (c) 2011 NetFunctional Inc. All Rights Reserved.
 * Please see the LICENSE included with this distribution for details.
 */

#import "TiBase.h"

#import <MapKit/MapKit.h>
#import "TiNFMImageOverlay.h"

@interface TiNFMImageOverlayView : MKOverlayView {
	@private
	TiNFMImageOverlay* overl;
	id <MKOverlay> overlay;
	int counter;
	
}

@property (nonatomic, assign) 	TiNFMImageOverlay* overl;
@property (nonatomic, assign) 	int counter;
@property (nonatomic, readonly) id <MKOverlay> overlay;

//constructor to initialize with a given imageoverlay
- (id) initWithUIImage:(TiNFMImageOverlay*)imageOverlay;


-(id) basicInit;

- (void)drawMapRect:(MKMapRect)mapRect zoomScale:(MKZoomScale)zoomScale inContext:(CGContextRef)context;



@end
