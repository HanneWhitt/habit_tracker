using Toybox.WatchUi;
using Toybox.Time.Gregorian;
using Toybox.Application;
using Toybox.System;

var current_time;



class DataViewSelect extends WatchUi.View {


    function initialize() {
        View.initialize();
    }

    // Load your resources here
    function onLayout(dc) {
    }

    // Called when this View is brought to the foreground. Restore
    // the state of this View and prepare it to be shown. This includes
    // loading resources into memory.
    function onShow() {
    	// Set item indexes back to start whenever the view brought to foreground
	   	// Refresh current daynum
    	current_time = getTime(null);
    	current_daynum = current_time["day_num"];
    	// Load the data from the last n_days
    	//current_data = loadDaynumHabitData(active_habits, current_daynum);
    }

    // Update the view
    function onUpdate(dc) {
    	
		// If the settings menu was just up, we need to replot all the data
		if (settings_menu_up) {
			settings_menu_up = false;
			animation_complete = false;
			sectorDisplay.animation_item_idx = 0;
		}

		if (animation_complete) {
			sectorDisplay.update_selection_and_labelling(dc, current_data);	
		} else {
			animation_complete = sectorDisplay.display_habit_data_animated(dc, current_data, true);
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


class DataViewSelectDelegate extends WatchUi.InputDelegate {

	protected var response_code;

    function initialize() {
		InputDelegate.initialize();
		self.response_code = "None";
	}
	
    function onKey(keyEvent) {
    	
    	var key = keyEvent.getKey();
    	
    	if (key == up_key) {
    		sectorDisplay.up();
			WatchUi.requestUpdate();
    	} else if (key == down_key) {
    		sectorDisplay.down();
			WatchUi.requestUpdate();
    	} else if (key == start_key) {
			if (sectorDisplay.is_showing_settings()) {
				WatchUi.pushView(new SettingsMain(), new SettingsMainDelegate(), 1);
				settings_menu_up = true;
			} else {
				self.response_code = change_datum(sectorDisplay.item_idx);
    			respond(self.response_code);
				WatchUi.requestUpdate();
			}
    	} else if (key == back_key) {
			if (sectorDisplay.is_showing_settings()) {
				sectorDisplay.up();
				WatchUi.requestUpdate();
			} else {
				WatchUi.popView(2);
			}
    	}
    	    	    	
        return true;
    }
}
