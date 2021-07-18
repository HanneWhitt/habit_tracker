using Toybox.Application;

class BlueApp extends Application.AppBase {

    function initialize() {
        AppBase.initialize();
    }

    // onStart() is called on application start up
    // Before the initial WatchUi.View is retrieved, onStart() is called.
	// This is where app level settings can be initialized or retrieved from
	// the object store before the initial View is created.
    function onStart(state) {
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
        return [ new DataView(null) ];
    }
//    
//    function getGlanceView() {
//        return [ new DataView(null), new DataViewDelegate() ];
//    }
    
    // onStop() is called when your application is exiting
    // When the system is going to terminate an application, onStop() is called.
	// If the application needs to save state to the object store it should be
	// done in this function.
    function onStop(state) {
    }

}