/**
 * Copyright (c) 2011 NetFunctional Inc. All Rights Reserved.
 * Please see the LICENSE included with this distribution for details.
 */

#import "TiBase.h"

#import <MapKit/MapKit.h>
#import "TiNFMFloatingImageOverlay.h"

@interface TiNFMFloatingImageOverlayView : MKOverlayView {
	@private
	TiNFMFloatingImageOverlay* overl;
	id <MKOverlay> overlay;
	int counter;
	
}

@property (nonatomic, assign) 	TiNFMFloatingImageOverlay* overl;
@property (nonatomic, assign) 	int counter;
@property (nonatomic, readonly) id <MKOverlay> overlay;

//constructor to initialize with a given imageoverlay
- (id) initWithUIImage:(TiNFMFloatingImageOverlay*)imageOverlay;


-(id) basicInit;

- (void)drawMapRect:(MKMapRect)mapRect zoomScale:(MKZoomScale)zoomScale inContext:(CGContextRef)context;

- (CGImageRef)resizeCGImage:(CGImageRef)image toScale:(CGFloat)scale;

@end
