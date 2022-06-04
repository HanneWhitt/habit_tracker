using Toybox.WatchUi;
using Toybox.Time.Gregorian;
using Toybox.Application;
using Toybox.System;
using Toybox.Lang;

var current_daynum;
var current_data;

var screen_radius;

var animation_complete;


class DataViewInitial extends WatchUi.View {


    function initialize() {
        View.initialize();
		just_shown = true;
    }

    // Load your resources here
    function onLayout(dc) {

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
		
    }

    // Update the view
    function onUpdate(dc) {    	
		
		if (selection_view_up) {
			sectorDisplay.clear_selection_and_labelling(dc, current_data);
			selection_view_up = false;
		}

		if (just_shown) {
			// Show data with no selection, no date, no habit names displayed
			animation_complete = sectorDisplay.display_habit_data_animated(dc, current_data);
			if (animation_complete) {
				just_shown = false;
			}
		}

		// MIDNIGHT EDGE CASE
		// Save and refresh the data if the day has changed (i.e if it has just passed midnight)
		// current_time = getTime(null);
		// if (current_time["day_num"] != current_daynum) {
		// 	SaveHabitData(current_data);
		// 	current_daynum = current_time["day_num"];
		// 	current_data = loadDaynumHabitData(active_habits, current_daynum);
		// }

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
			selection_view = new DataViewSelect();
			selection_delegate = new DataViewSelectDelegate();
			selection_view_up = true;
			WatchUi.pushView(selection_view, selection_delegate, 1);
    	}      
    	return true;
    }
}

