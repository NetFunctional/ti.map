//
//  NetfunctionalMapoverlayTilerOverlayView.m
//  NFMapTileNativePlay
//
//  Created by Michael Matan on 13-08-15.
//  Copyright (c) 2013 Michael Matan. All rights reserved.
//

#import "NetfunctionalMapoverlayTilerOverlayView.h"
#import "NetfunctionalMapoverlayTileDatabase.h"
#import "NetfunctionalMapoverlayTilerOverlay.h"
#import "NetfunctionalMapoverlayTileUtil.h"

@implementation NetfunctionalMapoverlayTilerOverlayView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

-(id) initWithOverlay:(id<MKOverlay>)overlay {
    self = [super initWithOverlay:overlay];
    if (self) {
        NSLog(@"Tiler overlay view has been initialized");
    }
    return self;
}


-(MKMapRect) mapRectBoundedByNW:(CLLocationCoordinate2D)nwCorner andSE:(CLLocationCoordinate2D)seCorner {
    //convert from cllocationcoordinates to mkmappoints
    MKMapPoint nwPoint = MKMapPointForCoordinate(nwCorner);
    MKMapPoint sePoint = MKMapPointForCoordinate(seCorner);
    
    
    
    MKMapRect bmr =   MKMapRectMake(nwPoint.x, nwPoint.y, sePoint.x-nwPoint.x, sePoint.y-nwPoint.y);
    return bmr;
}

- (NSUInteger)levelForScale:(MKZoomScale)zoomScale {
    CGFloat scaleByScreen = zoomScale / [[UIScreen mainScreen] scale];
    NSUInteger zoomLevel = (NSUInteger)(log(scaleByScreen)/log(2.0)+20.0);
    
    zoomLevel = zoomLevel + ([[UIScreen mainScreen] scale] - 1.0);
    
    //ensure zoom level doesn't exceed max zoom level for tile database.
    zoomLevel = MIN(zoomLevel, 6);
    return zoomLevel;
}



-(void) drawMapRect:(MKMapRect)mapRect zoomScale:(MKZoomScale)zoomScale inContext:(CGContextRef)context {
    NSLog(@"zoomscale is %f",zoomScale);
    //    self.counter++;
	//NSLog(@"blahtastic!  drawing map rect for custom image overlay; called %d times",counter);
	
    //	TiNFMFloatingImageOverlay* ovl = self.overl;
    //	CGFloat alpha = ovl.alpha;
    
    /*pseudo code:
        Determine mbtiles zoom level from zoomScale
        Determine tiles which will cover mapRect for zoom level
        retrieve images for tiles
        draw tiles to context
    */
//    NSUInteger zoomLevel = zoomScale;
//    zoomLevel = 1;
    NSUInteger zoomLevel = [self levelForScale:zoomScale];
//    zoomLevel = 1;
    MKCoordinateRegion mapRegion = MKCoordinateRegionForMapRect(mapRect); //TODO release when done with this
//    [NetfunctionalMapoverlayTileUtil tilesCoveringRegion:mapRegion atLevel:zoomLevel];
    
    NetfunctionalMapoverlayTileDatabase* tileDB = [((NetfunctionalMapoverlayTilerOverlay*) [self overlay]) tileDB];
    TileInfo* tileToDraw = [NetfunctionalMapoverlayTileUtil tileContainingCoordinate:mapRegion.center atLevel:zoomLevel];
    NSString* tileID = [tileDB idForTileX:tileToDraw.x andY:tileToDraw.y andZoom:tileToDraw.zoom];
	UIImage *image = [tileDB imageForTile:tileID] ;
    //	UIImage *image = [[self tileDB] imageForTile:[[self tileDB] idForTileX:[tileOverlay x] andY:[tileOverlay y] andZoom:[tileOverlay zoomLevel]]] ;
    
	//TODO replace with the map rect for the bounding map rect by deleting following line and uncommenting line afterwards
	//MKMapRect theMapRect =MKMapRectWorld;
    
//    MKMapRect theMapRect = [tileOverlay boundingMapRect];
    
    
    MKMapRect theMapRect = [self mapRectBoundedByNW:tileToDraw.nwCorner andSE:tileToDraw.seCorner];
    
    
    
    /*here we do our funny business.
     Here we compute a bounding map rect for our image based on a
     scaling of the image's size, rather than blah blah balh
     */
    //CLLocationCoordinate2D* centerPoint = (CLLocationCoordinate2D) malloc(sizeof(CLLocationCoordinate2D));
    //    [ovl coordinate].latitude;
    //    CLLocationDistance metersPerMapPoint = MKMetersPerMapPointAtLatitude([ovl coordinate].latitude);
    //    //MKMapRectMake([ovl coordinate].latitude
    //    //  MKMapPoint nwc = MKMapPointForCoordinate(ovl.northWestCorner);
    //    //	MKMapPoint sec = MKMapPointForCoordinate(ovl.southEastCorner);
    //    MKMapPoint center = MKMapPointForCoordinate(ovl.centerCoord);
    //
    //    CGFloat imageWidth = ovl.width;
    //    CGFloat tr = center.x - ((imageWidth/zoomScale))/2;
    //    CGFloat bl = center.y - ((imageWidth/zoomScale)/2);
    //    CGFloat w = imageWidth/zoomScale;
    //    CGFloat h = imageWidth/zoomScale;
    //
    //    //theMapRect = MKMapRectMake(((nwc.x + sec.x- (imageWidth/zoomScale))/2), , imageWidth/zoomScale, imageWidth/zoomScale);
    //    theMapRect = MKMapRectMake(tr, bl, w, h);
    
    // [ovl coordinate];
    //	NSLog(@"comparing mapRect with boundingMapRect for x,y,w,h: (%f,%f,%f,%f) vs (%f,%f,%f,%f)",
    //		  mapRect.origin.x,
    //		  mapRect.origin.y,
    //		  mapRect.size.width,
    //		  mapRect.size.height,
    //		  theMapRect.origin.x,
    //		  theMapRect.origin.y,
    //		  theMapRect.size.width,
    //		  theMapRect.size.height
    //		  );
    
    CGRect theRect = [self rectForMapRect:theMapRect];
	//CGRect theRect = [self rectForMapRect:mapRect];
    
	//TODO consider removing usage of UIKit and using Core Graphics instead, as recommended in the class reference for MKOverlayView
	
	//CG version of drawing code - mmatan
    //    CGImageRef imageReference = image.CGImage;
    //	//CGImageRef imageReference = [self resizeCGImage:image.CGImage toWidth:1 andHeight:1];
    ////	CGImageRef imageReference =  [self resizeCGImage:image.CGImage toScale:zoomScale];
    ////    CGImageRef imageReference =  [self resizeCGImage:image.CGImage toScale:1.0];
    //
    //	//CGRect theRect           = [self rectForMapRect:theMapRect];
    //    CGRect clipRect     = [self rectForMapRect:mapRect];
    //
    //	//NSUserDefaults *preferences = [NSUserDefaults standardUserDefaults];
    //    CGContextSetAlpha(context, alpha);
    //
    //    CGContextAddRect(context, clipRect);
    //    CGContextClip(context);
    //
    ////    CGContextTranslateCTM(context, 0, image.size.height);
    ////    CGContextScaleCTM(context, 1.0, -1.0);
    //
    //    CGContextDrawImage(context, theRect, imageReference);
    //[image release];
    //Note:  Don't release the imageReference object, since it's just a reference to an object maintained in another class (UIImage); otherwise, you won't be able to access it in the second call to this method
	//end of CG stuff - mmatan
    
	UIGraphicsPushContext(context);
	//[image drawInRect:[self rectForMapRect:mapRect] blendMode:kCGBlendModeNormal alpha:alpha];
	[image drawInRect:theRect blendMode:kCGBlendModeNormal alpha:1.0];
    UIGraphicsPopContext();
}



/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
