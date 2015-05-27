/**
 * Copyright (c) 2011 NetFunctional Inc. All Rights Reserved.
 * Please see the LICENSE included with this distribution for details.
 */

#import <MapKit/MapKit.h>
#import "TiNFMFloatingImageOverlayView.h"
#import "TiNFMFloatingImageOverlay.h"


@implementation TiNFMFloatingImageOverlayView

@synthesize overl,counter,overlay;

- (id)initWithUIImage:(TiNFMFloatingImageOverlay*)imageOverlay {
	self.counter=0;
	//NSLog(@"Initializing NFM image overlay view");
	if (self = [super init]) {
		self.overl = imageOverlay;
		//self.overlay = imageOverlay;
	}
	return self;	
}

-(id) basicInit {
		if (self = [super init]) {
		}
		return self;
	
}

//Note, from MKGeometry.h:
// MKZoomScale provides a conversion factor between MKMapPoints and screen points.
// When MKZoomScale = 1, 1 screen point = 1 MKMapPoint.  When MKZoomScale is
// 0.5, 1 screen point = 2 MKMapPoints.
//typedef CGFloat MKZoomScale;

- (void)drawMapRect:(MKMapRect)mapRect zoomScale:(MKZoomScale)zoomScale inContext:(CGContextRef)context {
	self.counter++;
	//NSLog(@"blahtastic!  drawing map rect for custom image overlay; called %d times",counter);
	
	TiNFMFloatingImageOverlay* ovl = self.overl;
	CGFloat alpha = ovl.alpha;
	UIImage *image = ovl.img;

	//TODO replace with the map rect for the bounding map rect by deleting following line and uncommenting line afterwards
	//MKMapRect theMapRect =MKMapRectWorld;
    
    MKMapRect theMapRect = [ovl boundingMapRect];
    
    /*here we do our funny business.  
     Here we compute a bounding map rect for our image based on a 
     scaling of the image's size, rather than blah blah balh
    */
    //CLLocationCoordinate2D* centerPoint = (CLLocationCoordinate2D) malloc(sizeof(CLLocationCoordinate2D));
//    [ovl coordinate].latitude;
    CLLocationDistance metersPerMapPoint = MKMetersPerMapPointAtLatitude([ovl coordinate].latitude);
    //MKMapRectMake([ovl coordinate].latitude 
//  MKMapPoint nwc = MKMapPointForCoordinate(ovl.northWestCorner);
//	MKMapPoint sec = MKMapPointForCoordinate(ovl.southEastCorner);
    MKMapPoint center = MKMapPointForCoordinate(ovl.centerCoord);
    
    CGFloat imageWidth = ovl.width;
    CGFloat tr = center.x - ((imageWidth/zoomScale))/2;
    CGFloat bl = center.y - ((imageWidth/zoomScale)/2);
    CGFloat w = imageWidth/zoomScale;
    CGFloat h = imageWidth/zoomScale;

    //theMapRect = MKMapRectMake(((nwc.x + sec.x- (imageWidth/zoomScale))/2), , imageWidth/zoomScale, imageWidth/zoomScale);
    theMapRect = MKMapRectMake(tr, bl, w, h); 
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
	[image drawInRect:theRect blendMode:kCGBlendModeNormal alpha:alpha];
    UIGraphicsPopContext();
}

//- (CGImageRef)resizeCGImage:(CGImageRef)image toScale:(CGFloat)scale
//{
//    // Create the bitmap context
//    CGContextRef    context = NULL;
//    void *          bitmapData;
//    int             bitmapByteCount;
//    int             bitmapBytesPerRow;
//    
//    // Get image width, height. We'll use the entire image.
//    int width = CGImageGetWidth(image) * scale;
//    int height = CGImageGetHeight(image) * scale;
//    
//    // Declare the number of bytes per row. Each pixel in the bitmap in this
//    // example is represented by 4 bytes; 8 bits each of red, green, blue, and
//    // alpha.
//    bitmapBytesPerRow   = (width * 4);
//    bitmapByteCount     = (bitmapBytesPerRow * height);
//    
//    // Allocate memory for image data. This is the destination in memory
//    // where any drawing to the bitmap context will be rendered.
//    bitmapData = malloc( bitmapByteCount );
//    if (bitmapData == NULL)
//    {
//        return nil;
//    }
//    
//    // Create the bitmap context. We want pre-multiplied ARGB, 8-bits
//    // per component. Regardless of what the source image format is
//    // (CMYK, Grayscale, and so on) it will be converted over to the format
//    // specified here by CGBitmapContextCreate.
//    CGColorSpaceRef colorspace = CGImageGetColorSpace(image);
//    context = CGBitmapContextCreate (bitmapData,width,height,8,bitmapBytesPerRow,
//                                     colorspace,kCGImageAlphaNoneSkipFirst);
//    CGColorSpaceRelease(colorspace);
//    
//    if (context == NULL)
//        // error creating context
//        return nil;
//    
//    // Draw the image to the bitmap context. Once we draw, the memory
//    // allocated for the context for rendering will then contain the
//    // raw image data in the specified color space.
//    CGContextDrawImage(context, CGRectMake(0,0,width, height), image);
//    
//    CGImageRef imgRef = CGBitmapContextCreateImage(context);
//    CGContextRelease(context);
//    free(bitmapData);
//    
//    return imgRef;
//}

- (CGImageRef)resizeCGImage:(CGImageRef)image toScale:(CGFloat)scale
{
    //TODO [ Remember to release the return CGImageRef with CGImageRelease() manually! ]
    
    // Create the bitmap context
    CGContextRef context = NULL;
    void * bitmapData;
    int bitmapByteCount;
    int bitmapBytesPerRow;
    
    // Get image width, height. We'll use the entire image.
    int width = CGImageGetWidth(image) * scale;
    int height = CGImageGetHeight(image) * scale;
    
    // Declare the number of bytes per row. Each pixel in the bitmap in this
    // example is represented by 4 bytes; 8 bits each of red, green, blue, and
    // alpha.
    bitmapBytesPerRow = (width * 4);
    bitmapByteCount = (bitmapBytesPerRow * height);
    
    // Allocate memory for image data. This is the destination in memory
    // where any drawing to the bitmap context will be rendered.
    bitmapData = malloc( bitmapByteCount );
    if (bitmapData == NULL)
    {
        return nil;
    }
    
    // Create the bitmap context. We want pre-multiplied ARGB, 8-bits
    // per component. Regardless of what the source image format is
    // (CMYK, Grayscale, and so on) it will be converted over to the format
    // specified here by CGBitmapContextCreate.
    CGColorSpaceRef colorspace = CGImageGetColorSpace(image);
    context = CGBitmapContextCreate (bitmapData,width,height,8,bitmapBytesPerRow,
                                     colorspace,kCGImageAlphaPremultipliedFirst);
    CGColorSpaceRelease(colorspace);
    
    if (context == NULL)
        // error creating context
        return nil;
    
    // Draw the image to the bitmap context. Once we draw, the memory
    // allocated for the context for rendering will then contain the
    // raw image data in the specified color space.
    CGContextDrawImage(context, CGRectMake(0,0,width, height), image);
    
    CGImageRef imgRef = CGBitmapContextCreateImage(context);
    CGContextRelease(context);
    free(bitmapData);
    
    return imgRef;
}

//enum CGImageAlphaInfo {
//    kCGImageAlphaNone,               /* For example, RGB. */
//    kCGImageAlphaPremultipliedLast,  /* For example, premultiplied RGBA */
//    kCGImageAlphaPremultipliedFirst, /* For example, premultiplied ARGB */
//    kCGImageAlphaLast,               /* For example, non-premultiplied RGBA */
//    kCGImageAlphaFirst,              /* For example, non-premultiplied ARGB */
//    kCGImageAlphaNoneSkipLast,       /* For example, RBGX. */
//    kCGImageAlphaNoneSkipFirst,      /* For example, XRGB. */
//    kCGImageAlphaOnly                /* No color data, alpha data only */
//};



//+ (CGImageRef)resizeCGImage:(CGImageRef)image toWidth:(int)width andHeight:(int)height {
//    // create context, keeping original image properties
//    CGColorSpaceRef colorspace = CGImageGetColorSpace(image);
//    CGContextRef context = CGBitmapContextCreate(NULL, width, height,
//                                                 CGImageGetBitsPerComponent(image),
//                                                 CGImageGetBytesPerRow(image),
//                                                 colorspace,
//                                                 CGImageGetAlphaInfo(image));
//    CGColorSpaceRelease(colorspace);
//    
//    if(context == NULL)
//        return nil;
//    
//    // draw image to context (resizing it)
//    CGContextDrawImage(context, CGRectMake(0, 0, width, height), image);
//    // extract resulting image from context
//    CGImageRef imgRef = CGBitmapContextCreateImage(context);
//    CGContextRelease(context);
//    
//    return imgRef;
//}

@end
