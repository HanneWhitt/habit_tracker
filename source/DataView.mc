using Toybox.WatchUi;
using Toybox.Time.Gregorian;
using Toybox.Application;
using Toybox.System;


class DataView extends WatchUi.View {

	protected var colour_dict;
	protected var active_habits;
	protected var current_data;
	protected var n_days;
	protected var n_habits;
	protected var day;
	protected var day_of_week;
	protected var month;
	protected var month_number;
	protected var year;
	protected var dayNum;	
	protected var time;

    function initialize(arg) {
        View.initialize();
        
        System.println(arg);
        
    }

    // Load your resources here
    function onLayout(dc) {
        setLayout(Rez.Layouts.MainLayout(dc));
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
    	
    	// A function to load general, permanent settings which depend on user preference - not the day or time. 
    	// Some hard coded for dev but more could be made available to user later.
    	self.loadSettings();
    	
    	// Get current time information
    	self.time = getTime();
    	
    	// A function to load from storage data for the last self.n_days and put it in an array
    	self.current_data = self.loadCurrentData(self.time["day_num"], self.n_days);	
    	
    	
    }


    // A function to load general, permanent settings which depend on user preference - not the day or time. Some hard coded for dev but more could be made available to user later.
    function loadSettings() {
    
    	// Days to display. If made available as a setting probably cap out at 28 to avoid having to do more than two different months on same screen
        self.n_days = 10;
        
        // Habits to display
      	self.active_habits = Application.Storage.getValue("__ACTIVE_HABITS__");
      	      	
      	self.n_habits = self.active_habits.size();
		
    }

	// A function to load from storage data for the last n_days_to_display and put it in an array
    function loadCurrentData(current_day_number, n_days_to_display) {
    	
    	var first_day_number = current_day_number - n_days_to_display + 1; // +1 for boundary problem
    	System.println("loadCurrentData() loading data from day " + first_day_number.toString() + " to " + current_day_number.toString());
    	
    	// dict to store data
	   	var current_data = {};
		
		for (var h = 0; h < self.n_habits; h += 1) {
		
    		var habit_name = self.active_habits[h];
			System.println("\nLoading " + habit_name + " data...");    		
    		
    		// Load habit metadata (includes block start and end dates)
    		var habit_meta = Application.Storage.getValue(habit_name);
    		
    		var display_data = new [n_days_to_display];
    		var blocks = habit_meta["block_date_intervals"];
    		
    		System.println("Available data blocks: " + blocks.toString());
    		
    		// Iterate through data blocks, with most recent first
    		for (var block_idx = blocks.size() - 1; block_idx >= 0; block_idx -= 1) {

       			var block_start = blocks[block_idx][0];   			
    			var block_end = blocks[block_idx][1];    			
				
				if (block_end > current_day_number) { 
					// should never happen - data was recorded on future days!?
					throw new InvalidValueException("block end date seems to be after current date which should be impossible");
				
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
    	
    	return current_data;	
    }

//	function display(dc, selected_habit, selected_day) {
//		
//        // Bunch of variables
//		var screen_radius = 120.0; // Should be read directly
//		var min_display_degrees = 0.0; // Should be in config
//		var max_display_degrees = 300.0; // Should be in config
//		var min_radius = 40.0; // Should be in config
//		var gap_degrees = 2.0; // Should be in config
//		var gap_radius = 3.0; // Should be in config
//		
//		// days in month
//		var days_in_month = self.daysInMonth(self.month, self.year);
//				
//		var degree_increment = (max_display_degrees - min_display_degrees)/n_sectors;
//		var radius_increment = (screen_radius - min_radius)/self.n_habits;
//		
//		var current_data_habit_names = self.current_data[0];
//		var current_data_values = self.current_data[1];
//		//System.println(current_data_habit_names);
//		//System.println(current_data_values);
//		
//		var n_days_with_data = current_data_values.size();
//		
//		//var n_habits = "placeholder";
//		var current_habits = 0;
//		var day_data = null;
//		var habit_name = null; 
//		var habit_value = null;
//		var habit_colour = null;
//		var radius_increment = null;
//		var day_min_deg = null;
//		var day_max_deg = null;
//		var colour_name = null;
//
//		var selected_day = 0;
//		var selected = null;		
//	
//
//		for (var day = 0; day < n_sectors; day += 1) {
//					
//			// There should always be an entry for day 0 so n_habits will never be "placeholder", this value chosen to throw error if it ever does
//			var names_entry = current_data_habit_names[day];
//			
//			//System.println(day);
//			//System.println(names_entry);
//			//System.println((names_entry != null));
//			//System.println(current_habits);
//			//System.println($.n_habits);
//			
//			if (day < n_days_with_data) {
//				
//				if (names_entry != null) {
//					//System.println("TRIGGGEREDDDDD");
//					current_habits = names_entry;
//					$.n_habits = current_habits.size();
//				}
//				
//				//System.println(day);h
//				//System.println(names_entry);
//				//System.println((names_entry != null));
//				//System.println(current_habits);
//				//System.println($.n_habits);
//				
//				day_data = current_data_values[day];
//				//System.println(day_data);
//				
//			} else {
//				
//				day_data = [0, 0, 0, 0];
//				//System.println(day_data);
//			
//			}
//			
//			
//
//			day_min_deg = min_display_degrees + day*degree_increment;
//			day_max_deg = day_min_deg + degree_increment - gap_degrees;
//		
//			for (var j = 0; j < $.n_habits; j += 1) {
//			
//				habit_name = current_habits[j];
//				
//				if (day == $.selected_day and j == $.selected_habit) {
//					selected = "selected";
//				} else {
//					selected = "unselected";
//				}
//					
//				habit_value = day_data[j];
//				
//				colour_name = self.colour_scheme[habit_name][selected][habit_value];
//				habit_colour = self.colour_dict[colour_name];
//				
//				//System.println(colour_name);
//			
//				self.annulusSector(
//				dc, 
//				day_min_deg, 
//				day_max_deg, 
//				min_radius + j*radius_increment, 
//				min_radius + (j + 1)*radius_increment - gap_radius, 
//				habit_colour
//				);
//		
//	}


    // Update the view
    function onUpdate(dc) {
  
        
    }        

    // Called when this View is removed from the screen. Save the
    // state of this View here. This includes freeing resources from
    // memory.
    function onHide() {
    }
	
}


