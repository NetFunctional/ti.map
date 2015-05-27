// var nfm = require('netfunctional.mapoverlay');
//var nfm = require('ti.map');

exports.title = 'Overlays';
exports.run = function(UI, Map) {

	var nfm = Map;
	nfm.requestLocationUpdatesWhenInUseAuthorization();
	
	// var timap = require('ti.map');
	// Titanium.Map = require('ti.map');
	
	// create base window
	//
	var win1 = Titanium.UI.createWindow({
	    title : 'MapOverlay Example',
	    backgroundColor : '#fff'
	});
	
	//#First create an object defining the properties of our overlay for a circle
	var circleOverlayDef2 = {
	    name : "broadcastRange2",
	    type : "circle",
	    center : {
	        latitude : 42.814243,
	        longitude : -73.939569
	    },
	    radius : 160000, //approximates 1000 miles
	    //strokeColor : "red",
	    strokeColor : "#2E0854",
	    strokeAlpha : 0.9,
	    fillColor : "blue",
	    fillAlpha : 0.5,
	    width : 1
	};
	
	var polyOverlayDef = {
	    name : "pOverlay1",
	    type : "polygon",
	    points : [
	        {latitude : 32.259265, longitude : -64.863281}, 
	        {latitude : 18.354526, longitude : -66.049805}, 
	        {latitude : 25.839449, longitude : -80.244141}],
	    strokeColor : "blue",
	    strokeAlpha : 0.9,
	    fillColor : "blue",
	    fillAlpha : 0.5
	};
	
	var polyLineOverlayDef = {
	    name: "polyLine",
	    points : [
	        {longitude:-73.939569, latitude : 42.814243},
	        {longitude:-74.970703, latitude :39.842286},
	        {longitude:-74.970703, latitude :38.548165}, 
	        {longitude:-74.355469, latitude :36.809285}, 
	        {longitude:-73.916016, latitude :35.173808}, 
	        {longitude:-73.300781, latitude :33.28462},
	        {longitude:-73.212891, latitude :31.877558}, 
	        {longitude:-72.421875, latitude :29.53523},
	        {longitude:-71.542969, latitude :28.767659}, 
	        {longitude:-71.191406, latitude :27.371767}],
	    color : "red",
	    width:3,
	    alpha:0.9
	};
	
	
	// var mapView = nfm.createMapView({
	var mapView = nfm.createView({	
	    mapType : nfm.STANDARD_TYPE,
		// mapType : Titanium.Map.NORMAL_TYPE,    
	    region : {
	    	latitude : 42.814243,
		    longitude : -73.939569,
	        // latitude : 50.814243,
	        // longitude :11.939569,
	        latitudeDelta : 8,
	        longitudeDelta : 8
	    },
	    animate : true,
	    regionFit : true,
	    userLocation : true
	});
	
	win1.add(mapView);
	// return;
	if (true) {
		// buttons to demonstrate creating and removing overlays
		var button01 = Ti.UI.createButton({
		    title : 'Circle',
		    width : 60,
		    height : 40,
		    left : 10,
		    top : 20,
		    isON : false
		});
		
		button01.addEventListener('click', function() {
		    if(button01.isON) {
		        mapView.removeOverlay(circleOverlayDef2);
		        button01.isON = false;
		    } else {
		        mapView.addOverlay(circleOverlayDef2);
		        button01.isON = true;
		    }
		});
		
		var button02 = Ti.UI.createButton({
		    title : 'Image',
		    width : 70,
		    height : 40,
		    left:80,
		    top : 20,
		    isON : false
		});
	
		button02.addEventListener('click', function(){
		    
		    if(button02.isON) {
		        mapView.removeOverlay({
		            name : 'floridaWeatherMap',
		            type : 'image',
		            northWestCoord : {latitude : 30,longitude : -85},
		            southEastCoord : {latitude : 27.5,longitude : -80},
		            alpha : 0.9,
		            img : 'images/mapImageOverlay.png',
			    minZoomScale:0.0000000061,
			    maxZoomScale:0.488
		        });
		        button02.isON = false;
		    }
		    else{
		        mapView.addOverlay({
		            name : 'floridaWeatherMap',
		            type : 'image',
		            northWestCoord : {latitude : 30,longitude : -85},
		            southEastCoord : {latitude : 27.5,longitude : -80},
		            alpha : 0.9,
		            img : 'images/mapImageOverlay.png',
		            minZoomScale:0.000061,
		            maxZoomScale:0.000488
		        });
		        button02.isON = true;
		
		
		    }
		
		});
		
		
		
		var button03 = Ti.UI.createButton({
		    title : 'Polygon',
		    width : 70,
		    height : 40,
		    right : 80,
		    top : 20,
		    isON : false
		});
		
		button03.addEventListener('click', function() {
		    if(button03.isON) {
		        mapView.removeOverlay(polyOverlayDef);
		        button03.isON = false;
		
		    } else {
		        mapView.addOverlay(polyOverlayDef);
		        button03.isON = true;
		    }
		});
		
		var button04 = Ti.UI.createButton({
		    title : 'Route',
		    width : 60,
		    height : 40,
		    right : 10,
		    top : 20,
		    isON : false
		});
		
		button04.addEventListener('click', function() {
		    if(button04.isON) {
		        mapView.removePolyline(polyLineOverlayDef);
		        button04.isON = false;
		
		    } else {
		        mapView.addPolyline(polyLineOverlayDef);
		        button04.isON = true;
		    }
		});
		
		
		win1.add(mapView);
		win1.add(button02);
		win1.add(button01);
		win1.add(button03);
		win1.add(button04);
		
			
	
		//Note:  can alternatively use Titanium.Map.createAnnotation, but the 'draggable' property will be ignored
		//var broadcastInfo = Titanium.Map.createAnnotation({
		var broadcastInfo = nfm.createAnnotation({
		    latitude : 42.814243,
		    longitude : -73.939569,
		    title : "First College Radio Station",
		    subtitle : '~1000 mile broadcast range, 1921, Union College, NY',
		    pincolor : nfm.ANNOTATION_GREEN,
		    animate : true,
		    draggable: false
		});
		
		
		mapView.addAnnotation(broadcastInfo);
		
		
		var bermTriWarning = nfm.createAnnotation({
		    latitude : 27.293689,
		    longitude : -68.730469,
		    title : "Bermuda Triangle",
		    subtitle : '(Here be dragons!)',
		    pincolor : nfm.ANNOTATION_GREEN,
		    leftButton: 'images/dragon.png', 
		    rightButton: 'images/dragon.png',
		    animate : true,
		    draggable: false    
		});
		mapView.addAnnotation(bermTriWarning);
		
		
		
		//create a map pin which can be dragged and dropped with touch events.  Note that this requires the NetFunctional version of the map annotation object;  changing this to use Titanium.Map.createAnnotation will cause the 'draggable' property to be ignored, and the pin will not be made draggable.
		
		var initLat = 50.8258293489407;
		var initLon =  8.78689295429902;
		
		var dnd = nfm.createAnnotation({
		    latitude : initLat,
		    longitude :initLon,
		    title : Ti.Platform.osname === 'android' ? 'A pin' : "Drag n\' Drop Pin!",
		    subtitle : Ti.Platform.osname === 'android' ? '' :'Press and hold to pick me up.',
		    pincolor : nfm.ANNOTATION_RED,
		    animate : true,
		    draggable: true
		});
		
		dnd.addEventListener('click',function(e){
		   Ti.API.info("Annotation Pin Click Event: "+ JSON.stringify(e));
		});
		
		//add event listener to list the coordinates when the drag and drop pin is dropped
		dnd.addEventListener('coordinatechange',function(e) {
		    Ti.API.info("Annotation Pin CoordianteChange Event: "+ JSON.stringify(e));
		//    Ti.API.debug("started dragging pin");
		    Ti.API.debug("Drag N' Drop pin has been moved to location: " + e.source.latitude + "," + e.source.longitude);
		    var lat = new Number(e.source.latitude);
		    var lon = new Number(e.source.longitude);  
		    
		    //Change the subtitle on a delay because if it is done mid-drop it can cause a jump in the animation, at least on the first drop.
		    setTimeout(function() {
		        e.source.subtitle = "Pin (lat,long): " + e.source.latitude.toPrecision(5) + "," + e.source.longitude.toPrecision(5);    
		        
		    },300);
		
		});
		
		
		mapView.addAnnotation(dnd);
		
		mapView.addEventListener('click',function(e){
		    Ti.API.info("MapView Click Event" + JSON.stringify(e));
		});
		
		
	}
	if (false) {	
		
	}
	
	win1.open();
	
};
