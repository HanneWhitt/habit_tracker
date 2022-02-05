using Toybox.Application;


var first_use;
var carousel_view;
var carousel_delegate;


class BlueApp extends Application.AppBase {

    function initialize() {
        AppBase.initialize();
    }

    // onStart() is called on application start up
    // Before the initial WatchUi.View is retrieved, onStart() is called.
	// This is where app level settings can be initialized or retrieved from
	// the object store before the initial View is created.
    function onStart(state) {
    
    	System.println("onSTART RAN");
    	
    	Application.Storage.clearValues();
		
		// Is this the first time the app has run?
		first_use = is_first_use();
		
		var thing = [1, 2, 3];
		System.println(thing);
		System.println(thing.size());
		System.println(thing.slice(1, 3));
		

		// If so, set up app by writing default and example values to storage
		if (first_use) {
			first_time_setup();
		}
		
		// A function to load app-wide settings/set variables not available to the user
		fixedSettings();
    	
    	//  A function to load app-wide settings/set variables based on settings which 
    	// will be available to the user
    	userSettings();   	
    }
    
    // Return the initial view of your application here
    // To retrieve the initial WatchUi.View and WatchUi.InputDelegate
	// of the application, call getInitialView(). Providing a
	// WatchUi.InputDelegate is optional for widgets and watch-apps. For
	// watchfaces and datafields, an array containing just a WatchUi.View
	// should be returned as input is not available for these app types.
	// @return [Array] An array containing
	// [ WatchUi.View, WatchUi.InputDelegate (optional) ]
    function getInitialView() {
    
    	carousel_view = new DataViewInitial();
    	carousel_delegate = new DataViewInitialDelegate();
    
        return [ carousel_view, carousel_delegate ];
    }
    
//    function getGlanceView() {
//        return [ new DataViewInitial(), new DataViewInitialDelegate() ];
//    }
    
    // onStop() is called when your application is exiting
    // When the system is going to terminate an application, onStop() is called.
	// If the application needs to save state to the object store it should be
	// done in this function.
    function onStop(state) {
    }

}