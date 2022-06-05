using Toybox.Application;


var first_use;

var carousel_view;
var carousel_delegate;

var selection_view;
var selection_delegate;
var selection_view_up;

var settings_main_view;
var settings_main_delegate;
var settings_menu_up;

var habit_menu_view;
var habit_menu_delegate;

var single_habit_settings_view;
var single_habit_settings_delegate;



class BlueApp extends Application.AppBase {

    function initialize() {
        AppBase.initialize();
    }

    // onStart() is called on application start up
    // Before the initial WatchUi.View is retrieved, onStart() is called.
	// This is where app level settings can be initialized or retrieved from
	// the object store before the initial View is created.
    function onStart(state) {
        			
		// Is this the first time the app has run?
		first_use = is_first_use();

		// If so, set up app by writing default and example values to storage
		if (first_use) {
			first_time_setup();
		}

		// A function to load app-wide settings/set variables not available to the user
		refreshFixedSettings();
    	
    	//  A function to load app-wide settings/set variables based on settings which 
    	// will be available to the user
    	refreshUserSettings();

		selection_view_up = false;
		settings_menu_up = false;
    	
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
		SaveHabitData(current_data);
    }

}