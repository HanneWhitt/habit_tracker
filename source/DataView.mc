using Toybox.WatchUi;
using Toybox.Time.Gregorian;
using Toybox.Application;
using Toybox.System;
using Toybox.Lang;


var n_habits;
var n_days;
var total_items;
var item_idx;


// Convert item_idx (index over all selectables) to day_idx, habit_idx pair
function item_to_coords(item_idx) {
	if (item_idx == total_items - 1 or item_idx == null) {
		return [null, null];
	} else if (item_idx < total_items - 1 and item_idx >= 0) {
		return [item_idx / n_habits, item_idx % n_habits]; 
	} else {
		var exception_string = "Invalid item_idx: " + item_idx.toString() + ". Must be in range 0 - " + (total_items - 1).toString();
		throw new Lang.InvalidValueException(exception_string);
	}
}


class DataView extends WatchUi.View {

	protected var colour_dict;
	protected var active_habits;
	protected var current_data;
	protected var habit_metadata;
	protected var time;	
	protected var dispSett;
	protected var colour_scheme;

    function initialize(selection_idx) {
        View.initialize();
        item_idx = selection_idx;
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
		
		// Writing all this to storage for development. All of this will be in storage already when app fully built. 
    	Application.Storage.setValue(h1_key, h1_val);
    	Application.Storage.setValue(h2_key, h2_val);
    	Application.Storage.setValue(h2_key2, h2_val2);
    	Application.Storage.setValue(h1_meta_key, h1_meta_val);
    	Application.Storage.setValue(h2_meta_key, h2_meta_val);
    	Application.Storage.setValue(all_habits_key, all_habits_val);
    	Application.Storage.setValue(current_habits_key, current_habits_val);
    	
    	
    	// App code start
    	
		// A function to load settings which are qualities of the device. We only support fr645m for the moment. 
		self.deviceSettings();
    	
    	// A function to load settings which will eventually be available to user as settings
    	self.userSettings();   	
    	
    	// Get current time information
    	self.time = getTime();
    	
    	// A function to load from storage data for the last n_days and put it in an array
    	self.current_data = self.loadCurrentData(self.time["day_num"], n_days);	
    	
    	
    }

	// A function to load settings which are qualities of the device. We only support fr645m for the moment. 
	function deviceSettings() {
		self.dispSett = WatchUi.loadResource(Rez.JsonData.displaySettings);
		System.println(dispSett);
	}
	

    // A function to load general, permanent settings which depend on user preference - not the day or time. Some hard coded for dev but more could be made available to user later.
    function userSettings() {
        
    	// Days to display. If made available as a setting probably cap out at 28 to avoid having to do more than two different months on same screen
        n_days = 10;
        
        // Habits to display
      	self.active_habits = Application.Storage.getValue("__ACTIVE_HABITS__");
      	n_habits = self.active_habits.size();
      	
      	// Total items
      	total_items = n_days*n_habits + 1;
      	
      	// Habit metadata
      	self.habit_metadata = {};
      	self.colour_scheme = {};
      	var habit_name;
      	var habit_meta;
      	var habit_colours;
      	
      	for (var h = 0; h < n_habits; h += 1) {
      	
      		habit_name = self.active_habits[h];
      		
      		habit_meta = Application.Storage.getValue(habit_name);
    		self.habit_metadata[habit_name] = habit_meta;
    		
    		habit_colours = habit_meta["Colours"];
    		self.colour_scheme[habit_colours] = WatchUi.loadResource(Rez.JsonData.colourSchemes)[habit_colours];
		}
    }

	// A function to load from storage data for the last n_days_to_display and put it in an array
    function loadCurrentData(current_day_number, n_days_to_display) {
    	
    	var first_day_number = current_day_number - n_days_to_display + 1; // +1 for boundary problem
    	System.println("loadCurrentData() loading data from day " + first_day_number.toString() + " to " + current_day_number.toString());
    	
    	// dict to store data
	   	var current_data = {};
		
		for (var h = 0; h < n_habits; h += 1) {
		
    		var habit_name = self.active_habits[h];
			System.println("\nLoading " + habit_name + " data...");    		
    		    		
    		var display_data = new [n_days_to_display];
    		
    		// Get blocks from habit metadata    		
    		var blocks = self.habit_metadata[habit_name]["block_date_intervals"];
    		
    		System.println("Available data blocks: " + blocks.toString());
    		
    		// Iterate through data blocks, with most recent first
    		for (var block_idx = blocks.size() - 1; block_idx >= 0; block_idx -= 1) {

       			var block_start = blocks[block_idx][0];   			
    			var block_end = blocks[block_idx][1];    			
				
				if (block_end > current_day_number) { 
					// should never happen - data was recorded on future days!?
					throw new Lang.InvalidValueException("block end date seems to be after current date which should be impossible");
				
				} else if (block_end < first_day_number) { 
					// When we reach the point that all the rest of the data is before the first day to be shown on screen - so does not need to be loaded
					System.println("No more relevant " + habit_name + " data");
					break;
					
				} else { 
					// Relevant data!
					
					// Construct storage key and load block:		
					var storage_key = habit_name + '_' + block_start.toString();
					var block_data = Application.Storage.getValue(storage_key);
					System.println("Loaded block " + storage_key);
					
					// Figure out which data from the block to copy onto which part of the display array
					var first_start = max(first_day_number, block_start);
					var splice_start = first_start - block_start;
					var copy_length = block_data.size() - splice_start;										
					var write_start = first_start - first_day_number;
					
					// Copy it 
					for (var i = 0; i < copy_length; i += 1) {
						display_data[i + write_start] = block_data[i + splice_start];
					
					}					
				}
    		}
    		
			// Add fully constructed display data into all-habit array_dict
			current_data[habit_name] = display_data;
		}
    	
    	System.println(current_data);
    	
    	return current_data;	
    }
    

	function get_colour(habit_name, datum, selected) {
		
		var type = self.habit_metadata[habit_name]["Type"];
		var habit_colours = self.habit_metadata[habit_name]["Colours"];
			
		if (type.equals("Binary")) {
		
			if (datum == 1) {
				datum = "Yes";
			} else if (datum == 0) {
				datum = "No";
			} else if (datum == null) {
				datum = "No data";
			} else {
				throw new Lang.InvalidValueException("Invalid datum in storage!");
			}
			
			if (selected) {
				return self.colour_scheme[habit_colours]["selected"][datum];
			} else {
				return self.colour_scheme[habit_colours]["unselected"][datum];
			}
							
		} else {
			throw new Lang.InvalidValueException("Only Binary habits implemented at the moment.");
		}
		
	}


	function display_habit_data(dc, item_idx) {
		
		var coords = item_to_coords(item_idx);
		var selected_day_idx = coords[0];
		var selected_habit_idx = coords[1];
		
		System.println(selected_habit_idx);
		System.println(selected_day_idx);
		
		var screen_radius = dc.getWidth()/2;
		var days_in_month = self.time["days_in_month"];
		var degree_increment = (self.dispSett["max_display_degrees"] - self.dispSett["min_display_degrees"])/n_days;
		var radius_increment = (screen_radius - self.dispSett["min_radius"])/n_habits;

		var habit_name;
		var datum;
		var selected;
		var colour;
		
		for (var habit_idx = 0; habit_idx < n_habits; habit_idx += 1) {
		
			habit_name = self.active_habits[habit_idx];

			for (var day_idx = 0; day_idx < n_days; day_idx += 1) {

				datum = self.current_data[habit_name][day_idx];
				
				selected = (day_idx == selected_day_idx and habit_idx == selected_habit_idx);
				
				colour = self.get_colour(habit_name, datum, selected);
				
				self.annulusSector(
					dc, 
					self.dispSett["min_display_degrees"] + day_idx*degree_increment, 
					self.dispSett["min_display_degrees"] + (day_idx + 1)*degree_increment - self.dispSett["gap_degrees"], 
					self.dispSett["min_radius"] + habit_idx*radius_increment, 
					self.dispSett["min_radius"] + (habit_idx + 1)*radius_increment - self.dispSett["gap_radius"], 
					colour
				);
			}
		}
	}
		
	
	function display_full() {
	
	}
	

    // Update the view
    function onUpdate(dc) {
    
		self.display_habit_data(dc, 13);
		
    }        

    // Called when this View is removed from the screen. Save the
    // state of this View here. This includes freeing resources from
    // memory.
    function onHide() {
    }
	
}


//class DataViewDelegate extends WatchUi.InputDelegate {
//    
//    // Key indexes 
//    var start_key = 4;
//    var back_key = 5;
//    var up_key = 13;
//    var down_key = 8;
//    
//    function initialize() {
//		InputDelegate.initialize();
//	}
//	
//	function up() {
//		item_idx = (item_idx + 1) % total_items;
//	}
//	
//	function down() {
//		item_idx = (item_idx - 1) % total_items;
//	}
//	
//    function onKey(keyEvent) {
//    	
//    	// We are on start screen
//    	if item_idx == null;
//    	
//    	var key = keyEvent.getKey();
//    	
//    	if (key == up_key) {
//    		self.up();
//    	} else if (key == down_key) {
//    		self.down();
//    	}
//    	
//    	System.println("Key Pressed:");
//    	System.println(keyEvent.getKey());
//        WatchUi.requestUpdate();
//        return true;
//    }
//}

