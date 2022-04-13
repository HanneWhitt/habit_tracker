using Toybox.WatchUi;
using Toybox.Time.Gregorian;
using Toybox.Application;
using Toybox.System;


var item_idx;


class DataViewSelect extends WatchUi.View {


    function initialize() {
        View.initialize();
    }

    // Load your resources here
    function onLayout(dc) {
        dc.setColor(Graphics.COLOR_TRANSPARENT, Graphics.COLOR_WHITE);
		dc.clear();
    }

    // Called when this View is brought to the foreground. Restore
    // the state of this View and prepare it to be shown. This includes
    // loading resources into memory.
    function onShow() {
    	// Set item index back to 1 whenever the view brought to foreground
        item_idx = 0;
	   	// Refresh current daynum
    	current_daynum = getTime()["day_num"];
    	// Load the data from the last n_days
    	current_data = loadDaynumHabitData(active_habits, current_daynum);
    }

    // Update the view
    function onUpdate(dc) {
    	
    	// Save and refresh the data if the day has changed (i.e if it has just passed midnight)
    	var new_daynum = getTime()["day_num"];
		if (new_daynum != current_daynum) {
			SaveHabitData(current_data);
	    	current_data = loadDaynumHabitData(active_habits, new_daynum);
	    	current_daynum = new_daynum;
		}
		display_full(dc, current_data, item_idx);		
		
    }        

    // Called when this View is removed from the screen. Save the
    // state of this View here. This includes freeing resources from
    // memory.
    function onHide() {
    
    	System.println(current_data);
    
    }
	
}


function up() {
	item_idx = (item_idx + 1) % total_items;
}

function down() {
	item_idx = (item_idx - 1) % total_items;
	if (item_idx < 0) {
		item_idx += total_items;
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
    		up();
    	} else if (key == down_key) {
    		down();
    	} else if (key == start_key) {
    		self.response_code = change_datum(item_idx);
    		SaveHabitData(current_data);
    		respond(self.response_code);
    	} else if (key == back_key) {
    		WatchUi.pushView(carousel_view, carousel_delegate, 2);
    	}
    	
    	System.println(response_code);
    	    	
        WatchUi.requestUpdate();
        return true;
    }
}
