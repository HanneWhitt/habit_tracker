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
       dc.setColor(Graphics.COLOR_TRANSPARENT, Graphics.COLOR_TRANSPARENT);
//		dc.clear();
    }

    // Called when this View is brought to the foreground. Restore
    // the state of this View and prepare it to be shown. This includes
    // loading resources into memory.
    function onShow() {
    	// Set item indexes back to start whenever the view brought to foreground
        sectorDisplay.indices_to_start();
	   	// Refresh current daynum
    	current_time = getTime(null);
    	current_daynum = current_time["day_num"];
    	// Load the data from the last n_days
    	//current_data = loadDaynumHabitData(active_habits, current_daynum);
    }

    // Update the view
    function onUpdate(dc) {
    	
    	// Save and refresh the data if the day has changed (i.e if it has just passed midnight),
		// or if the settings may have changed
    	current_time = getTime(null);
		if (current_time["day_num"] != current_daynum or settings_menu_up) {
			SaveHabitData(current_data);
    		current_daynum = current_time["day_num"];
	    	current_data = loadDaynumHabitData(active_habits, current_daynum);
		}

		// If the settings menu was just up, we need to replot all the data
		if (settings_menu_up) {
			dc.setColor(Graphics.COLOR_TRANSPARENT, Graphics.COLOR_WHITE);
			dc.clear();
			sectorDisplay.display_habit_data(dc, current_data);
			settings_menu_up = false;
		}

		sectorDisplay.update_selection_and_labelling(dc, current_data, current_time);		
		
    }        

    // Called when this View is removed from the screen. Save the
    // state of this View here. This includes freeing resources from
    // memory.
    function onHide() {
    
    	System.println(current_data);
    
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
    	} else if (key == down_key) {
    		sectorDisplay.down();
    	} else if (key == start_key) {
			if (sectorDisplay.is_showing_settings()) {
				settings_menu_up = true;
				WatchUi.pushView(settings_main_view, settings_main_delegate, 1);
			} else {
				self.response_code = change_datum(sectorDisplay.item_idx);
    			respond(self.response_code);
			}
    	} else if (key == back_key) {
    		WatchUi.popView(2);
    	}
    	
    	System.println(response_code);
    	    	
        WatchUi.requestUpdate();
        return true;
    }
}
