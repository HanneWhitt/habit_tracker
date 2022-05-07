using Toybox.WatchUi;
using Toybox.Time.Gregorian;
using Toybox.Application;
using Toybox.System;
using Toybox.Lang;


var current_daynum;
var current_data;

var screen_radius;


class DataViewInitial extends WatchUi.View {


    function initialize() {
        View.initialize();   	
    }

    // Load your resources here
    function onLayout(dc) {

//		screen_radius = dc.getWidth()/2;
    	// Refresh current daynum
    	current_daynum = getTime(null)["day_num"];
    	    	
    	// Load the data from the last n_days
    	current_data = loadDaynumHabitData(active_habits, current_daynum);
    }

    // Called when this View is brought to the foreground. Restore
    // the state of this View and prepare it to be shown. This includes
    // loading resources into memory.
    protected var just_shown;
    function onShow() {  	
		just_shown = true;
    }

    // Update the view
    function onUpdate(dc) {
    
    	// Refresh the data if the day has changed (i.e if it has just passed midnight)
    	var new_daynum = getTime(null)["day_num"];
		if (new_daynum != current_daynum) {
	    	current_data = loadDaynumHabitData(active_habits, new_daynum);
	    	current_daynum = new_daynum;
		}
		
		if (just_shown) {
			// Show data with no selection, no date, no habit names displayed
			dc.setColor(Graphics.COLOR_TRANSPARENT, Graphics.COLOR_WHITE);
			dc.clear();
			sectorDisplay.display_habit_data(dc, current_data);
			just_shown = false;
		}
    }        

    // Called when this View is removed from the screen. Save the
    // state of this View here. This includes freeing resources from
    // memory.
    function onHide() {
    }
       
	
}


class DataViewInitialDelegate extends WatchUi.InputDelegate {

    function initialize() {
		InputDelegate.initialize();
	}
	
    function onKey(keyEvent) {
    	var key = keyEvent.getKey();
		if (key == start_key) {
			WatchUi.pushView(selection_view, selection_delegate, 1);
    	}      
    	return true;
    }
}

